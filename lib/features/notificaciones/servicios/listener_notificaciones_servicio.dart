import 'package:cloud_firestore/cloud_firestore.dart';
import 'notificaciones_locales_servicio.dart';
import '../modelos/notificacion.dart';

/// Servicio que escucha cambios en notificaciones de Firestore
/// y muestra notificaciones push locales en tiempo real
class ListenerNotificacionesServicio {
  static final ListenerNotificacionesServicio _instancia = ListenerNotificacionesServicio._internal();
  factory ListenerNotificacionesServicio() => _instancia;
  ListenerNotificacionesServicio._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificacionesLocalesServicio _notificacionesLocales = NotificacionesLocalesServicio();

  // Stream subscription para poder cancelarlo después
  var _subscription;
  bool _escuchando = false;
  bool _primeraEjecucion = true; // Flag para ignorar la primera carga

  /// Inicia el listener para un psicólogo específico
  /// Escucha nuevas notificaciones no leídas y muestra push local
  void iniciarListener(String psicologoId) {
    if (_escuchando) {
      print('⚠️ Listener ya está activo');
      return;
    }

    print('🎧 Iniciando listener de notificaciones para: $psicologoId');
    _primeraEjecucion = true;

    _subscription = _firestore
        .collection('notificaciones')
        .where('destinatarioId', isEqualTo: psicologoId)
        .where('leida', isEqualTo: false)
        .orderBy('fechaCreacion', descending: true)
        .limit(50) // Limitar a las últimas 50 para performance
        .snapshots()
        .listen(
          (snapshot) {
            // En la primera ejecución, ignorar todos los documentos existentes
            if (_primeraEjecucion) {
              print('📦 Primera carga: ignorando ${snapshot.docs.length} notificaciones existentes');
              _primeraEjecucion = false;
              return; // Ignorar completamente la primera carga
            }

            // Procesar solo documentos AGREGADOS (nuevos) después de la primera carga
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                final notificacion = Notificacion.fromFirestore(change.doc);

                print('🔔 Nueva notificación en tiempo real: ${notificacion.titulo}');
                _mostrarNotificacionPushLocal(notificacion);
              }
            }
          },
          onError: (error) {
            print('❌ Error en listener de notificaciones: $error');
          },
        );

    _escuchando = true;
    print('✅ Listener de notificaciones activo');
  }

  /// Muestra una notificación push local basada en la notificación de Firestore
  Future<void> _mostrarNotificacionPushLocal(Notificacion notificacion) async {
    try {
      print('📱 Nueva notificación detectada: ${notificacion.titulo}');

      // Usar directamente los campos de la notificación
      final estudianteNombre = notificacion.estudianteNombre ?? 'Estudiante';
      final nivelAnsiedad = notificacion.nivelAnsiedad ?? 'moderada';
      final puntaje = notificacion.puntajeTest ?? 0;

      // Mostrar notificación push local
      await _notificacionesLocales.mostrarAlertaAnsiedadGrave(
        estudianteNombre: estudianteNombre,
        nivelAnsiedad: nivelAnsiedad,
        puntaje: puntaje,
      );

      print('✅ Notificación push local mostrada');
    } catch (e) {
      print('❌ Error al mostrar notificación push: $e');
    }
  }

  /// Detiene el listener
  void detenerListener() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
      _escuchando = false;
      _primeraEjecucion = true; // Reset para próxima vez
      print('🛑 Listener de notificaciones detenido');
    }
  }

  /// Verifica si el listener está activo
  bool get estaEscuchando => _escuchando;
}
