import 'package:flutter/material.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../modelos/estudiante_info.dart';
import '../../evaluaciones/modelos/pregunta_beck.dart';

/// Tarjeta que muestra información resumida de un estudiante
class TarjetaEstudiante extends StatelessWidget {
  final EstudianteInfo estudiante;
  final VoidCallback onTap;

  const TarjetaEstudiante({
    super.key,
    required this.estudiante,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColoresApp.fondoBlanco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: estudiante.requiereAtencion
                ? ColoresApp.error.withValues(alpha: 0.3)
                : ColoresApp.bordeDivisor,
            width: estudiante.requiereAtencion ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera con nombre y alerta
            Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ColoresApp.primario.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _obtenerIniciales(estudiante.nombreCompleto),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.primario,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        estudiante.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ColoresApp.textoOscuro,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Código: ${estudiante.codigo}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: ColoresApp.textoMedio,
                        ),
                      ),
                    ],
                  ),
                ),
                if (estudiante.requiereAtencion)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ColoresApp.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.priority_high,
                          color: ColoresApp.error,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Atención',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ColoresApp.error,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Información adicional
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icono: Icons.school_outlined,
                    texto: estudiante.programa ?? 'Sin carrera',
                  ),
                ),
              ],
            ),
            if (estudiante.facultad != null) ...[
              const SizedBox(height: 8),
              _InfoItem(
                icono: Icons.business_outlined,
                texto: estudiante.facultad!,
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Nivel de ansiedad
            if (estudiante.ultimoNivelAnsiedad != null) ...[
              Row(
                children: [
                  Icon(
                    _getIconoNivel(estudiante.ultimoNivelAnsiedad!),
                    color: _getColorNivel(estudiante.ultimoNivelAnsiedad!),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      estudiante.ultimoNivelAnsiedad!.nombre,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getColorNivel(estudiante.ultimoNivelAnsiedad!),
                      ),
                    ),
                  ),
                  if (estudiante.puntajeUltimoTest != null)
                    Text(
                      '${estudiante.puntajeUltimoTest} pts',
                      style: const TextStyle(
                        fontSize: 13,
                        color: ColoresApp.textoMedio,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              if (estudiante.fechaUltimoTest != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Último test: ${_formatearFecha(estudiante.fechaUltimoTest!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColoresApp.textoClaro,
                  ),
                ),
              ],
            ] else ...[
              const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: ColoresApp.textoClaro,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Sin evaluaciones realizadas',
                    style: TextStyle(
                      fontSize: 13,
                      color: ColoresApp.textoMedio,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],

            // Total de tests
            if (estudiante.totalTests > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Total de evaluaciones: ${estudiante.totalTests}',
                style: const TextStyle(
                  fontSize: 12,
                  color: ColoresApp.textoClaro,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _obtenerIniciales(String nombreCompleto) {
    final partes = nombreCompleto.trim().split(' ');
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return '${partes[0][0]}${partes[partes.length - 1][0]}'.toUpperCase();
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
      return 'Hace $semanas ${semanas == 1 ? "semana" : "semanas"}';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _InfoItem({
    required this.icono,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icono,
          size: 16,
          color: ColoresApp.textoMedio,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 13,
              color: ColoresApp.textoMedio,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
