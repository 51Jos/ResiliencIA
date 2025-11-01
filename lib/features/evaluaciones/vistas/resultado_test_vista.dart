import 'package:flutter/material.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../../../compartidos/componentes/modales/modal_mensaje.dart';
import '../modelos/resultado_test.dart';
import '../modelos/pregunta_beck.dart';
import '../servicios/test_servicio.dart';

/// Vista para mostrar los resultados del test de ansiedad
class ResultadoTestVista extends StatefulWidget {
  final ResultadoTest resultado;
  final String usuarioId;

  const ResultadoTestVista({
    super.key,
    required this.resultado,
    required this.usuarioId,
  });

  @override
  State<ResultadoTestVista> createState() => _ResultadoTestVistaState();
}

class _ResultadoTestVistaState extends State<ResultadoTestVista> {
  final TestServicio _testServicio = TestServicio();
  bool _cargando = true;
  bool _huboMejora = false;
  bool _mantieneNivelGrave = false;

  @override
  void initState() {
    super.initState();
    _verificarProgreso();
  }

  Future<void> _verificarProgreso() async {
    try {
      final mejora = await _testServicio.huboMejora(
        widget.usuarioId,
        widget.resultado.nivelAnsiedad,
      );

      final mantiene = await _testServicio.mantienNivelGrave(
        widget.usuarioId,
        widget.resultado.nivelAnsiedad,
      );

      setState(() {
        _huboMejora = mejora;
        _mantieneNivelGrave = mantiene;
        _cargando = false;
      });

      // Si mantiene nivel grave, mostrar alerta adicional
      if (_mantieneNivelGrave && mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ModalMensaje.mostrarAdvertencia(
              context: context,
              titulo: 'Derivación Necesaria',
              mensaje:
                  'Dado que tus niveles de ansiedad se mantienen elevados, te hemos derivado automáticamente al servicio de psicología. Un profesional se pondrá en contacto contigo pronto.',
            );
          }
        });
      }
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  Color _getColorNivel(NivelAnsiedad nivel) {
    switch (nivel) {
      case NivelAnsiedad.minima:
        return ColoresApp.exito;
      case NivelAnsiedad.leve:
        return Colors.blue;
      case NivelAnsiedad.moderada:
        return ColoresApp.advertencia;
      case NivelAnsiedad.grave:
        return ColoresApp.error;
    }
  }

  IconData _getIconoNivel(NivelAnsiedad nivel) {
    switch (nivel) {
      case NivelAnsiedad.minima:
        return Icons.mood;
      case NivelAnsiedad.leve:
        return Icons.sentiment_satisfied;
      case NivelAnsiedad.moderada:
        return Icons.sentiment_neutral;
      case NivelAnsiedad.grave:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        backgroundColor: ColoresApp.fondoPrincipal,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColoresApp.primario),
          ),
        ),
      );
    }

    final colorNivel = _getColorNivel(widget.resultado.nivelAnsiedad);

    return Scaffold(
      backgroundColor: ColoresApp.fondoPrincipal,
      appBar: AppBar(
        title: const Text('Resultados del Test'),
        backgroundColor: ColoresApp.primario,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con resultado principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorNivel.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: colorNivel.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: colorNivel.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconoNivel(widget.resultado.nivelAnsiedad),
                      size: 50,
                      color: colorNivel,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.resultado.nivelAnsiedad.nombre,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorNivel,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Puntaje: ${widget.resultado.puntajeTotal}/63',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: ColoresApp.textoMedio,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ColoresApp.fondoBlanco,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.resultado.nivelAnsiedad.descripcion,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ColoresApp.textoMedio,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicador de progreso (si aplica)
                  if (_huboMejora)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColoresApp.exito.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ColoresApp.exito,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: ColoresApp.exito,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              '¡Excelente! Has mejorado respecto a tu evaluación anterior. Continúa con las actividades recomendadas.',
                              style: TextStyle(
                                fontSize: 14,
                                color: ColoresApp.exito,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Consejo inicial
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColoresApp.fondoBlanco,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColoresApp.bordeDivisor,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: colorNivel,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ActividadesRecomendadas.obtenerConsejoInicial(
                              widget.resultado.nivelAnsiedad,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: ColoresApp.textoMedio,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Derivación (si aplica)
                  if (widget.resultado.requiereDerivacion)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColoresApp.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ColoresApp.error,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.medical_services,
                                color: ColoresApp.error,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Derivación al Psicólogo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: ColoresApp.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Hemos generado automáticamente una derivación al servicio de psicología. Un profesional se pondrá en contacto contigo dentro de las próximas 48 horas.',
                            style: TextStyle(
                              fontSize: 14,
                              color: ColoresApp.textoMedio,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Actividades Recomendadas
                  const Text(
                    'Actividades Recomendadas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.textoOscuro,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sigue estas recomendaciones para manejar tu ansiedad:',
                    style: TextStyle(
                      fontSize: 14,
                      color: ColoresApp.textoMedio,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lista de actividades
                  ...widget.resultado.actividadesRecomendadas
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final actividad = entry.value;
                    final isPrioridad = actividad.contains('PRIORIDAD');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isPrioridad
                            ? ColoresApp.error.withValues(alpha: 0.1)
                            : ColoresApp.fondoBlanco,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPrioridad
                              ? ColoresApp.error
                              : ColoresApp.bordeDivisor,
                          width: isPrioridad ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isPrioridad
                                  ? ColoresApp.error
                                  : ColoresApp.primario.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isPrioridad
                                      ? Colors.white
                                      : ColoresApp.primario,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              actividad.replaceAll('PRIORIDAD: ', ''),
                              style: TextStyle(
                                fontSize: 14,
                                color: ColoresApp.textoOscuro,
                                fontWeight: isPrioridad
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 32),

                  // Botón para ir al home
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/home',
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColoresApp.primario,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ir al Inicio',
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
          ],
        ),
      ),
    );
  }
}
