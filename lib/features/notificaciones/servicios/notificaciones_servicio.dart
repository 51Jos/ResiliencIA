import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/notificacion.dart';
import '../../evaluaciones/modelos/pregunta_beck.dart';

/// Servicio para gestionar notificaciones del sistema
class NotificacionesServicio {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crea una notificación de ansiedad grave y la guarda en Firebase
  Future<String> crearAlertaAnsiedadGrave({
    required String estudianteId,
    required String estudianteNombre,
    required NivelAnsiedad nivelAnsiedad,
    required int puntajeTest,
  }) async {

    try {
      // 1. Buscar psicólogos
      final psicologosQuery = await _firestore
          .collection('usuarios')
          .where('rol', isEqualTo: 'psicologo')
          .get();


      if (psicologosQuery.docs.isEmpty) {
        return '';
      }

      // 2. Crear notificación para cada psicólogo
      String ultimoId = '';
      for (var psicologoDoc in psicologosQuery.docs) {
        final psicologoId = psicologoDoc.id;

        // Crear mapa de datos directamente
        final datos = {
          'tipo': 'ansiedadGrave',
          'prioridad': nivelAnsiedad == NivelAnsiedad.severa ? 'urgente' : 'alta',
          'titulo': '⚠️ Nivel de Ansiedad ${nivelAnsiedad == NivelAnsiedad.severa ? "Severo" : "Grave"}',
          'mensaje': 'El estudiante $estudianteNombre ha completado un test con nivel de ansiedad ${nivelAnsiedad.nombre} ($puntajeTest/63 pts). Se requiere atención profesional inmediata.',
          'destinatarioId': psicologoId,
          'estudianteId': estudianteId,
          'estudianteNombre': estudianteNombre,
          'nivelAnsiedad': nivelAnsiedad.nombre,
          'puntajeTest': puntajeTest,
          'leida': false,
          'fechaCreacion': Timestamp.now(),
        };

        // GUARDAR EN FIREBASE
        final docRef = await _firestore
            .collection('notificaciones')
            .add(datos);

        ultimoId = docRef.id;
      }

      // NOTA: Las notificaciones push locales las maneja el ListenerNotificacionesServicio
      // que escucha los cambios en Firestore en tiempo real

      return ultimoId;

    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene notificaciones de un psicólogo
  Future<List<Notificacion>> obtenerNotificaciones(
    String psicologoId, {
    bool soloNoLeidas = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('notificaciones')
          .where('destinatarioId', isEqualTo: psicologoId);

      if (soloNoLeidas) {
        query = query.where('leida', isEqualTo: false);
      }

      final snapshot = await query.get();

      final notificaciones = snapshot.docs
          .map((doc) => Notificacion.fromFirestore(doc))
          .toList();

      notificaciones.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));

      return notificaciones;
    } catch (e) {
      return [];
    }
  }

  /// Stream de notificaciones en tiempo real
  Stream<List<Notificacion>> streamNotificaciones(
    String psicologoId, {
    bool soloNoLeidas = false,
  }) {

    Query<Map<String, dynamic>> query = _firestore
        .collection('notificaciones')
        .where('destinatarioId', isEqualTo: psicologoId);

    if (soloNoLeidas) {
      query = query
          .where('leida', isEqualTo: false)
          .orderBy('fechaCreacion', descending: true);
    } else {
      query = query.orderBy('fechaCreacion', descending: true);
    }

    return query.snapshots().map((snapshot) {

      final notificaciones = snapshot.docs
          .map((doc) => Notificacion.fromFirestore(doc))
          .toList();      

      return notificaciones;
    });
  }

  /// Stream del conteo de notificaciones no leídas
  Stream<int> streamContadorNoLeidas(String psicologoId) {

    return _firestore
        .collection('notificaciones')
        .where('destinatarioId', isEqualTo: psicologoId)
        .where('leida', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final contador = snapshot.docs.length;
          return contador;
        });
  }

  /// Marca una notificación como leída
  Future<void> marcarComoLeida(String notificacionId) async {
    try {
      await _firestore.collection('notificaciones').doc(notificacionId).update({
        'leida': true,
        'fechaLeida': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Marca todas las notificaciones de un psicólogo como leídas
  Future<void> marcarTodasComoLeidas(String psicologoId) async {
    try {
      final snapshot = await _firestore
          .collection('notificaciones')
          .where('destinatarioId', isEqualTo: psicologoId)
          .where('leida', isEqualTo: false)
          .get();

      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'leida': true,
          'fechaLeida': Timestamp.now(),
        });
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Cuenta las notificaciones no leídas de un psicólogo
  Future<int> contarNoLeidas(String psicologoId) async {
    try {
      final snapshot = await _firestore
          .collection('notificaciones')
          .where('destinatarioId', isEqualTo: psicologoId)
          .where('leida', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Elimina una notificación
  Future<void> eliminarNotificacion(String notificacionId) async {
    try {
      await _firestore.collection('notificaciones').doc(notificacionId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// RF24: Crea un recordatorio de test para un estudiante
  Future<String> crearRecordatorioTest({
    required String estudianteId,
    required String estudianteNombre,
    required String estudianteEmail,
  }) async {
    try {
      // Crear datos del recordatorio
      final datos = {
        'tipo': TipoNotificacion.recordatorioTest.name,
        'prioridad': 'media',
        'titulo': '📅 Recordatorio: Test de Ansiedad',
        'mensaje': 'Hola $estudianteNombre, es momento de realizar tu test de ansiedad mensual. Mantener un seguimiento regular es importante para tu bienestar.',
        'destinatarioId': estudianteId,
        'estudianteId': estudianteId,
        'estudianteNombre': estudianteNombre,
        'leida': false,
        'fechaCreacion': Timestamp.now(),
      };

      // Guardar en Firebase
      final docRef = await _firestore
          .collection('notificaciones')
          .add(datos);

      // NOTA: Las notificaciones push locales las maneja el ListenerNotificacionesServicio
      // que escucha los cambios en Firestore en tiempo real

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }
}
