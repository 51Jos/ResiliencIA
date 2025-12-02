import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/evaluaciones/modelos/pregunta_beck.dart';

/// Script para sincronizar notificaciones de tests existentes
///
/// Este script revisa todos los tests que tienen niveles de ansiedad
/// moderada, moderadaGrave o severa y crea notificaciones para los
/// psicólogos si aún no existen.
class SincronizadorNotificacionesTests {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ejecuta la sincronización completa
  Future<void> ejecutar() async {
    print('╔══════════════════════════════════════════════════════════╗');
    print('║   SINCRONIZACIÓN DE NOTIFICACIONES DE TESTS EXISTENTES  ║');
    print('╚══════════════════════════════════════════════════════════╝');
    print('');

    try {
      // 1. Obtener todos los tests con niveles de alerta
      print('📊 Buscando tests con niveles de alerta...');
      final testsSnapshot = await _firestore
          .collection('tests_ansiedad')
          .where('nivelAnsiedad', whereIn: ['moderada', 'moderadaGrave', 'severa'])
          .get();

      print('   ✓ Encontrados: ${testsSnapshot.docs.length} tests');
      print('');

      if (testsSnapshot.docs.isEmpty) {
        print('✓ No hay tests que requieran notificaciones');
        return;
      }

      // 2. Obtener psicólogos
      final psicologosSnapshot = await _firestore
          .collection('usuarios')
          .where('rol', isEqualTo: 'psicologo')
          .get();

      print('👥 Psicólogos en el sistema: ${psicologosSnapshot.docs.length}');
      print('');

      if (psicologosSnapshot.docs.isEmpty) {
        print('⚠️  No hay psicólogos registrados. No se pueden crear notificaciones.');
        return;
      }

      // 3. Procesar cada test
      int notificacionesCreadas = 0;
      int notificacionesExistentes = 0;
      int errores = 0;

      for (var testDoc in testsSnapshot.docs) {
        try {
          final testData = testDoc.data();
          final testId = testDoc.id;
          final usuarioId = testData['usuarioId'] as String;
          final nivelAnsiedadStr = testData['nivelAnsiedad'] as String;
          final puntajeTotal = testData['puntajeTotal'] as int;
          final fechaRealizacion = (testData['fechaRealizacion'] as Timestamp).toDate();

          // Convertir string a enum
          final nivelAnsiedad = NivelAnsiedad.values.firstWhere(
            (e) => e.name == nivelAnsiedadStr,
          );

          print('─────────────────────────────────────────────────────────');
          print('Test ID: ${testId.substring(0, 8)}...');
          print('   Usuario: $usuarioId');
          print('   Nivel: ${nivelAnsiedad.nombre}');
          print('   Puntaje: $puntajeTotal/63');
          print('   Fecha: ${_formatearFecha(fechaRealizacion)}');

          // 4. Verificar si ya existen notificaciones para este test
          final notificacionesExistentesSnapshot = await _firestore
              .collection('notificaciones')
              .where('estudianteId', isEqualTo: usuarioId)
              .where('puntajeTest', isEqualTo: puntajeTotal)
              .get();

          // Filtrar por fecha cercana (mismo día)
          final notifMismoDia = notificacionesExistentesSnapshot.docs.where((doc) {
            final fechaNotif = (doc.data()['fechaCreacion'] as Timestamp).toDate();
            return fechaNotif.year == fechaRealizacion.year &&
                   fechaNotif.month == fechaRealizacion.month &&
                   fechaNotif.day == fechaRealizacion.day;
          }).toList();

          if (notifMismoDia.isNotEmpty) {
            print('   ⊘ Ya existe notificación para este test');
            notificacionesExistentes++;
            continue;
          }

          // 5. Obtener información del estudiante
          final usuarioDoc = await _firestore
              .collection('usuarios')
              .doc(usuarioId)
              .get();

          if (!usuarioDoc.exists) {
            print('   ⚠️  Usuario no encontrado, omitiendo...');
            errores++;
            continue;
          }

          final nombreCompleto = usuarioDoc.data()?['nombreCompleto'] as String? ?? 'Estudiante';

          // 6. Crear notificaciones para cada psicólogo
          int creadas = 0;
          for (var psicologoDoc in psicologosSnapshot.docs) {
            final psicologoId = psicologoDoc.id;

            // Verificar si ya existe notificación para este psicólogo
            final notifPsicologo = notificacionesExistentesSnapshot.docs.where((doc) {
              return doc.data()['destinatarioId'] == psicologoId;
            }).toList();

            if (notifPsicologo.isNotEmpty) {
              continue;
            }

            // Crear notificación
            final datos = {
              'tipo': 'ansiedadGrave',
              'prioridad': nivelAnsiedad == NivelAnsiedad.severa
                  ? 'urgente'
                  : nivelAnsiedad == NivelAnsiedad.moderadaGrave
                      ? 'alta'
                      : 'media',
              'titulo': nivelAnsiedad == NivelAnsiedad.severa
                  ? '⚠️ Nivel de Ansiedad Severo'
                  : nivelAnsiedad == NivelAnsiedad.moderadaGrave
                      ? '⚠️ Nivel de Ansiedad Grave'
                      : '⚠️ Nivel de Ansiedad Moderado',
              'mensaje': 'El estudiante $nombreCompleto ha completado un test con nivel de ansiedad ${nivelAnsiedad.nombre} ($puntajeTotal/63 pts). Se requiere atención profesional.',
              'destinatarioId': psicologoId,
              'estudianteId': usuarioId,
              'estudianteNombre': nombreCompleto,
              'nivelAnsiedad': nivelAnsiedad.nombre,
              'puntajeTest': puntajeTotal,
              'leida': false,
              'fechaCreacion': Timestamp.fromDate(fechaRealizacion), // Usar fecha del test
            };

            await _firestore.collection('notificaciones').add(datos);
            creadas++;
          }

          if (creadas > 0) {
            print('   ✓ Creadas $creadas notificaciones');
            notificacionesCreadas += creadas;
          }

        } catch (e) {
          print('   ❌ Error procesando test: $e');
          errores++;
        }
      }

      // 7. Resumen final
      print('');
      print('╔══════════════════════════════════════════════════════════╗');
      print('║                    RESUMEN FINAL                         ║');
      print('╚══════════════════════════════════════════════════════════╝');
      print('   Tests procesados: ${testsSnapshot.docs.length}');
      print('   Notificaciones creadas: $notificacionesCreadas');
      print('   Notificaciones ya existentes: $notificacionesExistentes');
      print('   Errores: $errores');
      print('');
      print('✅ Sincronización completada exitosamente');

    } catch (e, stack) {
      print('');
      print('❌ ERROR CRÍTICO: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}

/// Función helper para ejecutar desde consola o script
Future<void> ejecutarSincronizacion() async {
  final sincronizador = SincronizadorNotificacionesTests();
  await sincronizador.ejecutar();
}
