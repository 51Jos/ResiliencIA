import 'package:flutter/material.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../modelos/pregunta_beck.dart';
import '../servicios/test_servicio.dart';
import 'resultado_test_vista.dart';

/// Vista del Test de Ansiedad de Beck con secciones desplegables
class TestAnsiedadVista extends StatefulWidget {
  final String usuarioId;

  const TestAnsiedadVista({
    super.key,
    required this.usuarioId,
  });

  @override
  State<TestAnsiedadVista> createState() => _TestAnsiedadVistaState();
}

class _TestAnsiedadVistaState extends State<TestAnsiedadVista> {
  final TestServicio _testServicio = TestServicio();
  final Map<int, int> _respuestas = {};
  bool _cargando = false;

  // Organizar preguntas por categoría
  late final Map<String, List<PreguntaBeck>> _preguntasPorCategoria;

  @override
  void initState() {
    super.initState();
    _preguntasPorCategoria = InventarioBeck.obtenerPorCategoria();
  }

  Future<void> _enviarTest() async {
    // Validar que todas las preguntas estén respondidas
    if (_respuestas.length != InventarioBeck.preguntas.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor responde todas las preguntas'),
          backgroundColor: ColoresApp.error,
        ),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      // Calcular resultado
      final resultado = _testServicio.calcularResultado(
        usuarioId: widget.usuarioId,
        respuestas: _respuestas,
      );

      // Guardar en Firestore
      final testId = await _testServicio.guardarResultado(resultado);

      // Navegar a resultados
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResultadoTestVista(
              resultado: resultado.copyWith(id: testId),
              usuarioId: widget.usuarioId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar el test: ${e.toString()}'),
            backgroundColor: ColoresApp.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPreguntas = InventarioBeck.preguntas.length;
    final progreso = _respuestas.length / totalPreguntas;

    return Scaffold(
      backgroundColor: ColoresApp.fondoPrincipal,
      appBar: AppBar(
        title: const Text('Test de Ansiedad'),
        backgroundColor: ColoresApp.primario,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de progreso
          Container(
            color: ColoresApp.fondoBlanco,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progreso: ${_respuestas.length}/$totalPreguntas',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColoresApp.textoOscuro,
                      ),
                    ),
                    Text(
                      '${(progreso * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColoresApp.primario,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progreso,
                    minHeight: 8,
                    backgroundColor: ColoresApp.bordeDivisor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      ColoresApp.primario,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de secciones
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instrucciones
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColoresApp.primario.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ColoresApp.primario.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: ColoresApp.primario,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Instrucciones',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColoresApp.primario,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'A continuación encontrarás una lista de síntomas comunes de ansiedad. Lee cada ítem y selecciona qué tanto te ha afectado durante la última semana, incluyendo hoy.',
                          style: TextStyle(
                            fontSize: 14,
                            color: ColoresApp.textoMedio,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Secciones desplegables
                  ..._preguntasPorCategoria.entries.map((entry) {
                    return _buildSeccion(
                      categoria: entry.key,
                      preguntas: entry.value,
                    );
                  }),

                  const SizedBox(height: 24),

                  // Botón de enviar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _cargando ? null : _enviarTest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColoresApp.primario,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _cargando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Finalizar Test',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccion({
    required String categoria,
    required List<PreguntaBeck> preguntas,
  }) {
    // Calcular cuántas preguntas están respondidas en esta sección
    final respondidas = preguntas
        .where((p) => _respuestas.containsKey(p.id))
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ColoresApp.fondoBlanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColoresApp.bordeDivisor,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: respondidas < preguntas.length,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColoresApp.primario.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconoCategoria(categoria),
                  color: ColoresApp.primario,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoria,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ColoresApp.textoOscuro,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$respondidas/${preguntas.length} respondidas',
                      style: TextStyle(
                        fontSize: 12,
                        color: respondidas == preguntas.length
                            ? ColoresApp.exito
                            : ColoresApp.textoClaro,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: preguntas.map((pregunta) {
                  return _buildPregunta(pregunta);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPregunta(PreguntaBeck pregunta) {
    final respuestaSeleccionada = _respuestas[pregunta.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: respuestaSeleccionada != null
                      ? ColoresApp.primario
                      : ColoresApp.bordeDivisor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${pregunta.id}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: respuestaSeleccionada != null
                          ? Colors.white
                          : ColoresApp.textoClaro,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pregunta.texto,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: ColoresApp.textoOscuro,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...pregunta.opciones.map((opcion) {
            final isSelected = respuestaSeleccionada == opcion.valor;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _respuestas[pregunta.id] = opcion.valor;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColoresApp.primario.withValues(alpha: 0.1)
                      : ColoresApp.fondoTarjeta,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? ColoresApp.primario
                        : ColoresApp.bordeDivisor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? ColoresApp.primario
                          : ColoresApp.textoClaro,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        opcion.texto,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? ColoresApp.textoOscuro
                              : ColoresApp.textoMedio,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getIconoCategoria(String categoria) {
    switch (categoria) {
      case 'Síntomas Físicos':
        return Icons.favorite_outline;
      case 'Síntomas Cognitivos':
        return Icons.psychology_outlined;
      case 'Síntomas Autonómicos':
        return Icons.air_outlined;
      default:
        return Icons.help_outline;
    }
  }
}
