import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/notificacion.dart';
import 'notificaciones_servicio.dart';

/// Servicio para gestionar recordatorios automáticos de tests
class RecordatoriosServicio {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificacionesServicio _notificacionesServicio = NotificacionesServicio();

  /// RF24: Crea recordatorios para estudiantes que necesitan hacer el test
  /// Verifica todos los estudiantes y envía recordatorios según días restantes
  Future<void> verificarYCrearRecordatorios() async {
    try {
      
      // Obtener todos los estudiantes
      final estudiantesSnapshot = await _firestore
          .collection('usuarios')
          .where('rol', isEqualTo: 'estudiante')
          .get();

      // ignore: unused_local_variable
      int recordatoriosCreados = 0;

      for (var estudianteDoc in estudiantesSnapshot.docs) {
        final estudianteId = estudianteDoc.id;
        final nombreCompleto = estudianteDoc.data()['nombreCompleto'] as String? ?? 'Estudiante';

        // Obtener el último test del estudiante
        final ultimoTestQuery = await _firestore
            .collection('tests_ansiedad')
            .where('usuarioId', isEqualTo: estudianteId)
            .orderBy('fechaRealizacion', descending: true)
            .limit(1)
            .get();

        DateTime? fechaUltimoTest;

        if (ultimoTestQuery.docs.isEmpty) {
          // No tiene tests, debe hacer uno ahora
          fechaUltimoTest = DateTime.now().subtract(const Duration(days: 31));
        } else {
          final testData = ultimoTestQuery.docs.first.data();
          fechaUltimoTest = (testData['fechaRealizacion'] as Timestamp).toDate();
        }

        // Calcular días desde el último test
        final diasDesdeUltimoTest = DateTime.now().difference(fechaUltimoTest).inDays;
        final diasRestantes = 30 - diasDesdeUltimoTest;

        
        // Determinar si necesita recordatorio
        String? tipoRecordatorio;
        if (diasRestantes <= 0) {
          tipoRecordatorio = 'urgente'; // Ya pasó el plazo
        } else if (diasRestantes == 1) {
          tipoRecordatorio = 'manana';
        } else if (diasRestantes <= 3) {
          tipoRecordatorio = '3dias';
        } else if (diasRestantes <= 5) {
          tipoRecordatorio = '5dias';
        }

        // Si necesita recordatorio, verificar que no se haya enviado uno reciente del mismo tipo
        if (tipoRecordatorio != null) {
          final yaEnviado = await _verificarRecordatorioExistente(
            estudianteId,
            tipoRecordatorio,
          );

          if (!yaEnviado) {
            // Usar el servicio de notificaciones que incluye push
            final email = estudianteDoc.data()['email'] as String? ?? '';
            await _notificacionesServicio.crearRecordatorioTest(
              estudianteId: estudianteId,
              estudianteNombre: nombreCompleto,
              estudianteEmail: email,
            );
            recordatoriosCreados++;
          }
        }
      }

      // ignore: empty_catches
      } catch (e) {
      }
  }

  /// Verifica si ya existe un recordatorio reciente del mismo tipo
  Future<bool> _verificarRecordatorioExistente(
    String estudianteId,
    String tipoRecordatorio,
  ) async {
    try {
      // Buscar recordatorios del último día con el mismo tipo
      final ahora = DateTime.now();
      final ayer = ahora.subtract(const Duration(days: 1));

      final recordatoriosSnapshot = await _firestore
          .collection('notificaciones')
          .where('estudianteId', isEqualTo: estudianteId)
          .where('tipo', isEqualTo: TipoNotificacion.recordatorioTest.name)
          .where('fechaCreacion', isGreaterThan: Timestamp.fromDate(ayer))
          .get();

      // Verificar si alguno tiene el mismo tipo en el mensaje
      for (var doc in recordatoriosSnapshot.docs) {
        final mensaje = doc.data()['mensaje'] as String;
        if (mensaje.contains(tipoRecordatorio)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene recordatorios de un estudiante
  Future<List<Notificacion>> obtenerRecordatoriosEstudiante(
    String estudianteId, {
    bool soloNoLeidos = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('notificaciones')
          .where('destinatarioId', isEqualTo: estudianteId)
          .where('tipo', isEqualTo: TipoNotificacion.recordatorioTest.name);

      if (soloNoLeidos) {
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

  /// Marca un recordatorio como leído
  Future<void> marcarRecordatorioLeido(String notificacionId) async {
    try {
      await _firestore.collection('notificaciones').doc(notificacionId).update({
        'leida': true,
        'fechaLeida': Timestamp.now(),
      });
    } catch (e) {
      // ignore: avoid_print
    }
  }

  /// Stream de recordatorios en tiempo real para un estudiante
  Stream<List<Notificacion>> streamRecordatorios(
    String estudianteId, {
    bool soloNoLeidos = false,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('notificaciones')
        .where('destinatarioId', isEqualTo: estudianteId)
        .where('tipo', isEqualTo: TipoNotificacion.recordatorioTest.name);

    if (soloNoLeidos) {
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

  /// Elimina recordatorios antiguos (más de 7 días)
  Future<void> limpiarRecordatoriosAntiguos() async {
    try {
      final hace7Dias = DateTime.now().subtract(const Duration(days: 7));

      final recordatoriosViejos = await _firestore
          .collection('notificaciones')
          .where('tipo', isEqualTo: TipoNotificacion.recordatorioTest.name)
          .where('fechaCreacion', isLessThan: Timestamp.fromDate(hace7Dias))
          .get();

      final batch = _firestore.batch();

      for (var doc in recordatoriosViejos.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      } catch (e) {
      // ignore: avoid_print
    }
  }
}
