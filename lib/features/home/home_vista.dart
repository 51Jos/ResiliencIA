import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../compartidos/tema/colores_app.dart';
import '../autenticacion/controladores/auth_controlador.dart';
import '../evaluaciones/servicios/test_servicio.dart';
import '../evaluaciones/modelos/resultado_test.dart';
import '../evaluaciones/modelos/pregunta_beck.dart';

/// Pantalla de prueba - Home
class HomeVista extends StatefulWidget {
  const HomeVista({super.key});

  @override
  State<HomeVista> createState() => _HomeVistaState();
}

class _HomeVistaState extends State<HomeVista> {
  final TestServicio _testServicio = TestServicio();
  ResultadoTest? _ultimoTest;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final authControlador = Provider.of<AuthControlador>(context, listen: false);
    final usuario = authControlador.usuarioActual;

    if (usuario != null) {
      final test = await _testServicio.obtenerUltimoTest(usuario.uid);
      setState(() {
        _ultimoTest = test;
        _cargando = false;
      });
    } else {
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

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays == 0) {
      return 'Hoy';
    } else if (diferencia.inDays == 1) {
      return 'Ayer';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} días';
    } else if (diferencia.inDays < 30) {
      final semanas = (diferencia.inDays / 7).floor();
      return 'Hace $semanas ${semanas == 1 ? 'semana' : 'semanas'}';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }

  Widget _buildProximoTestInfo() {
    if (_ultimoTest == null) return const SizedBox.shrink();

    final diasDesdeUltimoTest = DateTime.now().difference(
      _ultimoTest!.fechaRealizacion,
    ).inDays;

    final diasRestantes = 30 - diasDesdeUltimoTest;

    if (diasRestantes <= 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ColoresApp.advertencia.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.assignment_late,
              color: ColoresApp.advertencia,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Es momento de realizar una nueva evaluación',
                style: TextStyle(
                  fontSize: 13,
                  color: ColoresApp.advertencia,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColoresApp.primario.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            color: ColoresApp.primario,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Próxima evaluación en $diasRestantes ${diasRestantes == 1 ? 'día' : 'días'}',
              style: const TextStyle(
                fontSize: 13,
                color: ColoresApp.primario,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarHistorial(BuildContext context) async {
    final authControlador = Provider.of<AuthControlador>(context, listen: false);
    final usuario = authControlador.usuarioActual;

    if (usuario == null) return;

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ColoresApp.primario),
        ),
      ),
    );

    try {
      final historial = await _testServicio.obtenerHistorial(usuario.uid);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Cerrar indicador de carga

      if (historial.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sin Historial'),
            content: const Text('No hay evaluaciones previas registradas.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
        return;
      }

      // Mostrar historial en un diálogo
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: ColoresApp.primario,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Historial de Evaluaciones',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Lista de tests
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: historial.length,
                    itemBuilder: (context, index) {
                      final test = historial[index];
                      final colorNivel = _getColorNivel(test.nivelAnsiedad);
                      final isReciente = index == 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isReciente
                              ? colorNivel.withValues(alpha: 0.1)
                              : ColoresApp.fondoBlanco,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isReciente
                                ? colorNivel
                                : ColoresApp.bordeDivisor,
                            width: isReciente ? 2 : 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (isReciente)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ColoresApp.primario,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'ACTUAL',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  if (isReciente) const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _formatearFecha(test.fechaRealizacion),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: ColoresApp.textoMedio,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorNivel.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      test.nivelAnsiedad.nombre,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: colorNivel,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    _getIconoNivel(test.nivelAnsiedad),
                                    size: 20,
                                    color: colorNivel,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Puntaje: ${test.puntajeTotal}/63',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: ColoresApp.textoOscuro,
                                    ),
                                  ),
                                  if (test.derivadoPsicologo) ...[
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.medical_services,
                                      size: 16,
                                      color: ColoresApp.error,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Derivado',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: ColoresApp.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Cerrar indicador de carga

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Error al cargar el historial: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authControlador = Provider.of<AuthControlador>(context);
    final usuario = authControlador.usuarioActual;

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

    return Scaffold(
      backgroundColor: ColoresApp.fondoPrincipal,
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: ColoresApp.primario,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authControlador.cerrarSesion();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bienvenida
            Text(
              '¡Hola, ${usuario?.displayName ?? 'Estudiante'}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoOscuro,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aquí está tu resumen de bienestar',
              style: TextStyle(
                fontSize: 16,
                color: ColoresApp.textoMedio,
              ),
            ),
            const SizedBox(height: 24),

            // Resumen del último test
            if (_ultimoTest != null) ...[
              // Tarjeta de nivel de ansiedad
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _getColorNivel(_ultimoTest!.nivelAnsiedad).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getColorNivel(_ultimoTest!.nivelAnsiedad).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _getColorNivel(_ultimoTest!.nivelAnsiedad).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconoNivel(_ultimoTest!.nivelAnsiedad),
                            size: 30,
                            color: _getColorNivel(_ultimoTest!.nivelAnsiedad),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nivel de Ansiedad',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ColoresApp.textoMedio,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _ultimoTest!.nivelAnsiedad.nombre,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: _getColorNivel(_ultimoTest!.nivelAnsiedad),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Puntaje',
                              style: TextStyle(
                                fontSize: 12,
                                color: ColoresApp.textoMedio,
                              ),
                            ),
                            Text(
                              '${_ultimoTest!.puntajeTotal}/63',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ColoresApp.textoOscuro,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Última evaluación',
                              style: TextStyle(
                                fontSize: 12,
                                color: ColoresApp.textoMedio,
                              ),
                            ),
                            Text(
                              _formatearFecha(_ultimoTest!.fechaRealizacion),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ColoresApp.textoOscuro,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Días hasta próximo test
                    _buildProximoTestInfo(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Derivación si aplica
              if (_ultimoTest!.derivadoPsicologo)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: ColoresApp.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ColoresApp.error,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.medical_services,
                        color: ColoresApp.error,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Has sido derivado al servicio de psicología. Un profesional se pondrá en contacto contigo pronto.',
                          style: TextStyle(
                            fontSize: 14,
                            color: ColoresApp.error,
                            fontWeight: FontWeight.w600,
                          ),
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
                'Sigue estas recomendaciones para mejorar tu bienestar:',
                style: TextStyle(
                  fontSize: 14,
                  color: ColoresApp.textoMedio,
                ),
              ),
              const SizedBox(height: 16),

              // Lista de actividades
              ..._ultimoTest!.actividadesRecomendadas.asMap().entries.map((entry) {
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

              const SizedBox(height: 24),

              // Botón para ver historial
              OutlinedButton.icon(
                onPressed: () => _mostrarHistorial(context),
                icon: const Icon(Icons.history),
                label: const Text('Ver Historial de Evaluaciones'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColoresApp.primario,
                  side: const BorderSide(color: ColoresApp.primario),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ] else ...[
              // No hay test previo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ColoresApp.fondoBlanco,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ColoresApp.bordeDivisor,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 60,
                      color: ColoresApp.primario.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aún no has realizado ninguna evaluación',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoOscuro,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Realiza tu primera evaluación de ansiedad para obtener recomendaciones personalizadas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: ColoresApp.textoMedio,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

}
