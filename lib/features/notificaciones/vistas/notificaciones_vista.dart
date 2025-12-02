import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../servicios/notificaciones_servicio.dart';
import '../modelos/notificacion.dart';
import '../../administracion/modelos/estudiante_info.dart';
import '../../administracion/vistas/perfil_estudiante_vista.dart';
import '../../evaluaciones/modelos/pregunta_beck.dart';

/// Vista de notificaciones para psicólogos/administradores
class NotificacionesVista extends StatefulWidget {
  final String psicologoId;
  final String? psicologoNombre;

  const NotificacionesVista({
    super.key,
    required this.psicologoId,
    this.psicologoNombre,
  });

  @override
  State<NotificacionesVista> createState() => _NotificacionesVistaState();
}

class _NotificacionesVistaState extends State<NotificacionesVista> {
  final NotificacionesServicio _servicio = NotificacionesServicio();
  bool _soloNoLeidas = false;

  @override
  void initState() {
    super.initState();
    print('🔍 NotificacionesVista - psicologoId: ${widget.psicologoId}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColoresApp.fondoPrincipal,
      child: Column(
        children: [
          // Controles superiores
          Container(
            color: ColoresApp.fondoBlanco,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: StreamBuilder<int>(
                    stream: _servicio.streamContadorNoLeidas(widget.psicologoId),
                    builder: (context, snapshot) {
                      final contador = snapshot.data ?? 0;
                      return Row(
                        children: [
                          Text(
                            _soloNoLeidas ? 'Notificaciones no leídas' : 'Todas las notificaciones',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ColoresApp.textoOscuro,
                            ),
                          ),
                          if (contador > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ColoresApp.primario,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$contador',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
                // Toggle para filtrar no leídas
                FilterChip(
                  label: const Text('Solo no leídas'),
                  selected: _soloNoLeidas,
                  onSelected: (valor) {
                    setState(() {
                      _soloNoLeidas = valor;
                    });
                  },
                  selectedColor: ColoresApp.primario.withValues(alpha: 0.2),
                  checkmarkColor: ColoresApp.primario,
                ),
                const SizedBox(width: 8),
                // Botón marcar todas como leídas
                IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: 'Marcar todas como leídas',
                  onPressed: () => _marcarTodasComoLeidas(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Lista de notificaciones
          Expanded(
            child: StreamBuilder<List<Notificacion>>(
              stream: _servicio.streamNotificaciones(
                widget.psicologoId,
                soloNoLeidas: _soloNoLeidas,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(ColoresApp.primario),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: ColoresApp.error),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar notificaciones',
                          style: TextStyle(
                            fontSize: 16,
                            color: ColoresApp.textoMedio.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final notificaciones = snapshot.data ?? [];

                if (notificaciones.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _soloNoLeidas ? Icons.notifications_off_outlined : Icons.notifications_none,
                          size: 64,
                          color: ColoresApp.textoMedio.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _soloNoLeidas ? 'No tienes notificaciones sin leer' : 'No hay notificaciones',
                          style: TextStyle(
                            fontSize: 16,
                            color: ColoresApp.textoMedio.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notificaciones.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notificacion = notificaciones[index];
                    return _TarjetaNotificacion(
                      notificacion: notificacion,
                      alTocar: () => _abrirNotificacion(notificacion),
                      alEliminar: () => _eliminarNotificacion(notificacion.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _marcarTodasComoLeidas() async {
    try {
      await _servicio.marcarTodasComoLeidas(widget.psicologoId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas las notificaciones marcadas como leídas'),
            backgroundColor: ColoresApp.exito,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: ColoresApp.error,
          ),
        );
      }
    }
  }

  Future<void> _abrirNotificacion(Notificacion notificacion) async {
    // Marcar como leída si no lo está
    if (!notificacion.leida) {
      await _servicio.marcarComoLeida(notificacion.id);
    }

    // Si tiene estudiante asociado, abrir su perfil
    if (notificacion.estudianteId != null && mounted) {
      try {
        // Mostrar loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ColoresApp.primario),
            ),
          ),
        );

        // Obtener información completa del estudiante desde Firestore
        final estudianteDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(notificacion.estudianteId)
            .get();

        if (!mounted) return;

        // Cerrar loading
        Navigator.of(context).pop();

        if (estudianteDoc.exists) {
          final data = estudianteDoc.data()!;

          // Crear objeto EstudianteInfo
          final estudiante = EstudianteInfo(
            uid: notificacion.estudianteId!,
            codigo: data['codigo'] as String? ?? '',
            email: data['email'] as String? ?? '',
            nombres: data['nombres'] as String? ?? '',
            apellidos: data['apellidos'] as String? ?? '',
            nombreCompleto: data['nombreCompleto'] as String? ?? 'Estudiante',
            facultad: data['facultad'] as String?,
            programa: data['programa'] as String?,
            rol: data['rol'] as String? ?? 'estudiante',
            fechaRegistro: data['fechaRegistro'] != null
                ? (data['fechaRegistro'] as Timestamp).toDate()
                : DateTime.now(),
            ultimoNivelAnsiedad: data['ultimoNivelAnsiedad'] != null
                ? NivelAnsiedad.values.firstWhere(
                    (e) => e.name == data['ultimoNivelAnsiedad'],
                    orElse: () => NivelAnsiedad.minima,
                  )
                : null,
            fechaUltimoTest: data['fechaUltimoTest'] != null
                ? (data['fechaUltimoTest'] as Timestamp).toDate()
                : null,
            puntajeUltimoTest: data['puntajeUltimoTest'] as int?,
            requiereAtencion: data['requiereAtencion'] as bool? ?? false,
            totalTests: data['totalTests'] as int? ?? 0,
          );

          // Navegar al perfil del estudiante
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PerfilEstudianteVista(
                  estudiante: estudiante,
                  psicologoId: widget.psicologoId,
                  psicologoNombre: widget.psicologoNombre ?? 'Psicólogo',
                ),
              ),
            );
          }
        } else {
          // Si no existe el estudiante, mostrar error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo encontrar la información del estudiante'),
                backgroundColor: ColoresApp.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          // Cerrar loading si está abierto
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al abrir perfil: $e'),
              backgroundColor: ColoresApp.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _eliminarNotificacion(String notificacionId) async {
    try {
      await _servicio.eliminarNotificacion(notificacionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificación eliminada'),
            backgroundColor: ColoresApp.exito,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: ColoresApp.error,
          ),
        );
      }
    }
  }
}

class _TarjetaNotificacion extends StatelessWidget {
  final Notificacion notificacion;
  final VoidCallback alTocar;
  final VoidCallback alEliminar;

  const _TarjetaNotificacion({
    required this.notificacion,
    required this.alTocar,
    required this.alEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final color = _obtenerColorPrioridad(notificacion.prioridad);
    final icono = _obtenerIconoTipo(notificacion.tipo);

    return Dismissible(
      key: Key(notificacion.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => alEliminar(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: ColoresApp.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: alTocar,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notificacion.leida
                ? ColoresApp.fondoBlanco
                : ColoresApp.primario.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notificacion.leida
                  ? ColoresApp.bordeDivisor
                  : ColoresApp.primario.withValues(alpha: 0.3),
              width: notificacion.leida ? 1 : 2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono según tipo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notificacion.titulo,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notificacion.leida ? FontWeight.w500 : FontWeight.bold,
                              color: ColoresApp.textoOscuro,
                            ),
                          ),
                        ),
                        if (!notificacion.leida)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: ColoresApp.primario,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notificacion.mensaje.split('|tipo:')[0], // Eliminar metadata
                      style: const TextStyle(
                        fontSize: 13,
                        color: ColoresApp.textoMedio,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatearFecha(notificacion.fechaCreacion),
                      style: const TextStyle(
                        fontSize: 11,
                        color: ColoresApp.textoClaro,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _obtenerColorPrioridad(PrioridadNotificacion prioridad) {
    switch (prioridad) {
      case PrioridadNotificacion.urgente:
        return ColoresApp.error;
      case PrioridadNotificacion.alta:
        return ColoresApp.advertencia;
      case PrioridadNotificacion.media:
        return Colors.blue;
      case PrioridadNotificacion.baja:
        return ColoresApp.textoMedio;
    }
  }

  IconData _obtenerIconoTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.ansiedadGrave:
        return Icons.warning_amber_rounded;
      case TipoNotificacion.recordatorioTest:
        return Icons.assignment_outlined;
      case TipoNotificacion.citaProgramada:
        return Icons.event;
      case TipoNotificacion.observacionNueva:
        return Icons.message;
    }
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inMinutes < 1) {
      return 'Ahora';
    } else if (diferencia.inHours < 1) {
      return 'Hace ${diferencia.inMinutes} min';
    } else if (diferencia.inDays < 1) {
      return 'Hace ${diferencia.inHours} h';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} días';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }
}
