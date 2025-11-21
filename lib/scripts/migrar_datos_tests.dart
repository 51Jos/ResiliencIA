import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// Script para migrar datos existentes
/// Actualiza los perfiles de usuarios con datos de sus últimos tests
///
/// EJECUTAR UNA SOLA VEZ con:
/// flutter run lib/scripts/migrar_datos_tests.dart
void main() async {
  print('🚀 Iniciando migración de datos...\n');

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  try {
    // Obtener todos los estudiantes
    print('📊 Obteniendo lista de estudiantes...');
    final usuariosSnapshot = await firestore
        .collection('usuarios')
        .where('rol', isEqualTo: 'estudiante')
        .get();

    print('✅ Encontrados ${usuariosSnapshot.docs.length} estudiantes\n');

    int actualizados = 0;
    int sinTests = 0;
    int errores = 0;

    for (var userDoc in usuariosSnapshot.docs) {
      final userId = userDoc.id;
      final nombreCompleto = userDoc.data()['nombreCompleto'] ?? 'Sin nombre';

      try {
        // Obtener todos los tests del estudiante
        final testsSnapshot = await firestore
            .collection('tests_ansiedad')
            .where('usuarioId', isEqualTo: userId)
            .get();

        if (testsSnapshot.docs.isEmpty) {
          print('⏭️  $nombreCompleto: sin tests');
          sinTests++;
          continue;
        }

        // Encontrar el test más reciente
        var ultimoTest = testsSnapshot.docs.first.data();
        var ultimaFecha = (ultimoTest['fechaRealizacion'] as Timestamp).toDate();

        for (var testDoc in testsSnapshot.docs) {
          final testData = testDoc.data();
          final fecha = (testData['fechaRealizacion'] as Timestamp).toDate();
          if (fecha.isAfter(ultimaFecha)) {
            ultimoTest = testData;
            ultimaFecha = fecha;
          }
        }

        // Preparar datos para actualización
        final nivelAnsiedad = ultimoTest['nivelAnsiedad'] as String;
        final puntajeTotal = ultimoTest['puntajeTotal'] as int;
        final requiereAtencion = nivelAnsiedad == 'moderadaGrave' ||
                                 nivelAnsiedad == 'severa';

        // Actualizar usuario
        await firestore.collection('usuarios').doc(userId).update({
          'ultimoNivelAnsiedad': nivelAnsiedad,
          'puntajeUltimoTest': puntajeTotal,
          'fechaUltimoTest': ultimoTest['fechaRealizacion'],
          'totalTests': testsSnapshot.docs.length,
          'requiereAtencion': requiereAtencion,
        });

        print('✅ $nombreCompleto: migrado (${testsSnapshot.docs.length} tests, nivel: $nivelAnsiedad)');
        actualizados++;
      } catch (e) {
        print('❌ $nombreCompleto: ERROR - $e');
        errores++;
      }
    }

    print('\n' + '=' * 60);
    print('🎉 MIGRACIÓN COMPLETADA');
    print('=' * 60);
    print('✅ Estudiantes actualizados: $actualizados');
    print('⏭️  Estudiantes sin tests: $sinTests');
    print('❌ Errores: $errores');
    print('📊 Total procesados: ${usuariosSnapshot.docs.length}');
    print('=' * 60);
  } catch (e) {
    print('\n❌ ERROR FATAL: $e');
  }
}