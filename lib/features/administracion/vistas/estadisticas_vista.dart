import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../controladores/administracion_controlador.dart';
import '../componentes/tarjeta_estadistica.dart';
import '../../evaluaciones/modelos/pregunta_beck.dart';

/// Vista de estadísticas globales del sistema
class EstadisticasVista extends StatefulWidget {
  final String psicologoId;
  final String psicologoNombre;
  final bool ocultarAppBar;

  const EstadisticasVista({
    super.key,
    required this.psicologoId,
    required this.psicologoNombre,
    this.ocultarAppBar = false,
  });

  @override
  State<EstadisticasVista> createState() => _EstadisticasVistaState();
}

class _EstadisticasVistaState extends State<EstadisticasVista> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdministracionControlador>().cargarEstadisticasGlobales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPrincipal,
      appBar: widget.ocultarAppBar ? null : AppBar(
        title: const Text('Estadísticas Globales'),
        backgroundColor: ColoresApp.primario,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AdministracionControlador>(
        builder: (context, controlador, _) {
          if (controlador.cargando) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ColoresApp.primario),
              ),
            );
          }

          if (controlador.estadisticasGlobales == null) {
            return const Center(
              child: Text('No hay datos disponibles'),
            );
          }

          final stats = controlador.estadisticasGlobales!;

          return RefreshIndicator(
            color: ColoresApp.primario,
            onRefresh: () =>
                controlador.cargarEstadisticasGlobales(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Métricas principales
                  const Text(
                    'Resumen general',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.textoOscuro,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      TarjetaEstadistica(
                        titulo: 'Total de estudiantes',
                        valor: '${stats.totalEstudiantes}',
                        icono: Icons.people,
                        colorIcono: ColoresApp.primario,
                      ),
                      TarjetaEstadistica(
                        titulo: 'Total de evaluaciones',
                        valor: '${stats.totalTests}',
                        icono: Icons.assignment,
                        colorIcono: Colors.blue,
                      ),
                      TarjetaEstadistica(
                        titulo: 'Con ansiedad',
                        valor: '${stats.estudiantesConAnsiedad}',
                        icono: Icons.psychology,
                        colorIcono: ColoresApp.advertencia,
                        subtitulo:
                            '${stats.porcentajeConAnsiedad.toStringAsFixed(1)}%',
                      ),
                      TarjetaEstadistica(
                        titulo: 'Requieren atención',
                        valor: '${stats.estudiantesRequierenAtencion}',
                        icono: Icons.priority_high,
                        colorIcono: ColoresApp.error,
                        subtitulo:
                            '${stats.porcentajeRequierenAtencion.toStringAsFixed(1)}%',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Distribución por niveles
                  const Text(
                    'Distribución por niveles de ansiedad',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.textoOscuro,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DistribucionNiveles(
                    distribucion: stats.distribucionNiveles,
                    total: stats.totalEstudiantes,
                  ),

                  const SizedBox(height: 24),

                  // Distribución por carrera
                  if (stats.distribucionPorCarrera.isNotEmpty) ...[
                    const Text(
                      'Distribución por carrera',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoOscuro,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DistribucionLista(
                      items: stats.distribucionPorCarrera,
                      total: stats.totalEstudiantes,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Distribución por facultad
                  if (stats.distribucionPorFacultad.isNotEmpty) ...[
                    const Text(
                      'Distribución por facultad',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoOscuro,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DistribucionLista(
                      items: stats.distribucionPorFacultad,
                      total: stats.totalEstudiantes,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DistribucionNiveles extends StatelessWidget {
  final Map<NivelAnsiedad, int> distribucion;
  final int total;

  const _DistribucionNiveles({
    required this.distribucion,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.fondoBlanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.bordeDivisor),
      ),
      child: Column(
        children: NivelAnsiedad.values.map((nivel) {
          final cantidad = distribucion[nivel] ?? 0;
          final porcentaje = total > 0 ? (cantidad / total) * 100 : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getIconoNivel(nivel),
                      color: _getColorNivel(nivel),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        nivel.nombre,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '$cantidad (${porcentaje.toStringAsFixed(1)}%)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColoresApp.textoMedio,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: porcentaje / 100,
                    minHeight: 8,
                    backgroundColor: ColoresApp.bordeDivisor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getColorNivel(nivel),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getColorNivel(NivelAnsiedad nivel) {
    switch (nivel) {
      case NivelAnsiedad.minima:
        return ColoresApp.exito;
      case NivelAnsiedad.leve:
        return Colors.blue;
      case NivelAnsiedad.moderada:
        return ColoresApp.advertencia;
      case NivelAnsiedad.moderadaGrave:
        return Colors.deepOrange;
      case NivelAnsiedad.severa:
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
      case NivelAnsiedad.moderadaGrave:
        return Icons.sentiment_dissatisfied;
      case NivelAnsiedad.severa:
        return Icons.sentiment_very_dissatisfied;
    }
  }
}

class _DistribucionLista extends StatelessWidget {
  final Map<String, int> items;
  final int total;

  const _DistribucionLista({
    required this.items,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    // Ordenar por cantidad descendente
    final itemsOrdenados = items.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.fondoBlanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.bordeDivisor),
      ),
      child: Column(
        children: itemsOrdenados.map((entry) {
          final porcentaje = total > 0 ? (entry.value / total) * 100 : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ColoresApp.primario.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${entry.value} (${porcentaje.toStringAsFixed(1)}%)',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ColoresApp.primario,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
