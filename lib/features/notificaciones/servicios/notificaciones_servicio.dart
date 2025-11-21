import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/notificacion.dart';
import '../../evaluaciones/modelos/pregunta_beck.dart';

/// Servicio para gestionar notificaciones del sistema
/// Las notificaciones se muestran dentro de la app mediante Streams
class NotificacionesServicio {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crea una notificación de ansiedad grave
  /// RF23: Alerta inmediata al psicólogo si estudiante presenta ansiedad grave
  Future<String> crearAlertaAnsiedadGrave({
    required String estudianteId,
    required String estudianteNombre,
    required NivelAnsiedad nivelAnsiedad,
    required int puntajeTest,
  }) async {
    try {
      print('🚨 Creando alerta de ansiedad grave para $estudianteNombre');

      // Obtener todos los psicólogos activos
      final psicologos = await _obtenerPsicologosActivos();

      if (psicologos.isEmpty) {
        print('⚠️ No hay psicólogos activos en el sistema');
        return '';
      }

      // Determinar prioridad según nivel
      final prioridad = nivelAnsiedad == NivelAnsiedad.severa
          ? PrioridadNotificacion.urgente
          : PrioridadNotificacion.alta;

      // Crear notificación para cada psicólogo
      String ultimoId = '';
      for (var psicologo in psicologos) {
        final notificacion = Notificacion(
          id: '', // Se asignará automáticamente
          tipo: TipoNotificacion.ansiedadGrave,
          prioridad: prioridad,
          titulo: '⚠️ Nivel de Ansiedad ${nivelAnsiedad == NivelAnsiedad.severa ? "Severo" : "Grave"}',
          mensaje:
              'El estudiante $estudianteNombre ha completado un test con nivel de ansiedad ${nivelAnsiedad.nombre} (${puntajeTest}/63 pts). Se requiere atención profesional inmediata.',
          destinatarioId: psicologo['uid'],
          estudianteId: estudianteId,
          estudianteNombre: estudianteNombre,
          nivelAnsiedad: nivelAnsiedad.nombre,
          puntajeTest: puntajeTest,
          fechaCreacion: DateTime.now(),
        );

        final docRef = await _firestore
            .collection('notificaciones')
            .add(notificacion.toFirestore());

        ultimoId = docRef.id;
        print('✅ Notificación creada para psicólogo: ${psicologo['nombreCompleto']}');
        print('📱 Notificación visible en la app mediante Streams');
      }

      return ultimoId;
    } catch (e) {
      print('❌ Error al crear alerta de ansiedad: $e');
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

      // Ordenar en memoria para evitar index compuesto
      final notificaciones = snapshot.docs
          .map((doc) => Notificacion.fromFirestore(doc))
          .toList();

      notificaciones.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));

      return notificaciones;
    } catch (e) {
      print('❌ Error al obtener notificaciones: $e');
      return [];
    }
  }

  /// Marca una notificación como leída
  Future<void> marcarComoLeida(String notificacionId) async {
    try {
      await _firestore.collection('notificaciones').doc(notificacionId).update({
        'leida': true,
        'fechaLeida': Timestamp.now(),
      });
    } catch (e) {
      print('❌ Error al marcar notificación como leída: $e');
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
      print('❌ Error al marcar todas las notificaciones como leídas: $e');
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
      print('❌ Error al contar notificaciones no leídas: $e');
      return 0;
    }
  }

  /// Elimina una notificación
  Future<void> eliminarNotificacion(String notificacionId) async {
    try {
      await _firestore.collection('notificaciones').doc(notificacionId).delete();
    } catch (e) {
      print('❌ Error al eliminar notificación: $e');
      rethrow;
    }
  }

  /// Obtiene lista de psicólogos activos (con rol psicologo y email @ucss.edu.pe)
  Future<List<Map<String, dynamic>>> _obtenerPsicologosActivos() async {
    try {
      final snapshot = await _firestore
          .collection('usuarios')
          .where('rol', isEqualTo: 'psicologo')
          .get();

      // Filtrar solo los que tienen email @ucss.edu.pe
      final psicologos = snapshot.docs
          .where((doc) {
            final email = doc.data()['email'] as String?;
            return email != null && email.endsWith('@ucss.edu.pe');
          })
          .map((doc) => doc.data())
          .toList();

      return psicologos;
    } catch (e) {
      print('❌ Error al obtener psicólogos activos: $e');
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
      query = query.where('leida', isEqualTo: false);
    }

    return query.snapshots().map((snapshot) {
      final notificaciones = snapshot.docs
          .map((doc) => Notificacion.fromFirestore(doc))
          .toList();

      notificaciones.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));

      return notificaciones;
    });
  }

  /// Crea una notificación de recordatorio para estudiante
  /// RF24: Recordatorios automáticos para completar test
  Future<String> crearRecordatorioTest({
    required String estudianteId,
    required String estudianteNombre,
    required String estudianteEmail,
  }) async {
    try {
      print('📅 Creando recordatorio de test para $estudianteNombre');

      // Crear notificación en Firestore (para historial)
      final notificacion = Notificacion(
        id: '',
        tipo: TipoNotificacion.recordatorioTest,
        prioridad: PrioridadNotificacion.media,
        titulo: '📋 Recordatorio: Evaluación de Bienestar',
        mensaje:
            'Hola $estudianteNombre, han pasado más de 30 días desde tu última evaluación. Es momento de completar un nuevo test de ansiedad para seguir monitoreando tu bienestar.',
        destinatarioId: estudianteId,
        fechaCreacion: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('notificaciones')
          .add(notificacion.toFirestore());

      print('✅ Notificación de recordatorio creada para $estudianteNombre');
      print('📱 Notificación visible en la app mediante Streams');

      return docRef.id;
    } catch (e) {
      print('❌ Error al crear recordatorio de test: $e');
      rethrow;
    }
  }
}
