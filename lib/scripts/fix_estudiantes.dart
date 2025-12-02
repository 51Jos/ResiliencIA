import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// EJECUTAR SOLO UNA VEZ: dart run lib/scripts/fix_estudiantes.dart
void main() async {
  print('🔧 INICIANDO FIX...\n');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  // Obtener TODOS los estudiantes
  final estudiantes = await firestore
      .collection('usuarios')
      .where('rol', isEqualTo: 'estudiante')
      .get();

  print('📊 Total estudiantes: ${estudiantes.docs.length}\n');

  for (var estudianteDoc in estudiantes.docs) {
    final userId = estudianteDoc.id;
    final nombre = estudianteDoc.data()['nombreCompleto'] ?? 'Sin nombre';

    print('👤 $nombre ($userId)');

    // Obtener su último test
    final testsQuery = await firestore
        .collection('tests_ansiedad')
        .where('usuarioId', isEqualTo: userId)
        .orderBy('fechaRealizacion', descending: true)
        .limit(1)
        .get();

    if (testsQuery.docs.isEmpty) {
      print('   ⏭️  Sin tests\n');
      continue;
    }

    final testData = testsQuery.docs.first.data();
    final nivelAnsiedad = testData['nivelAnsiedad'] as String;
    final puntaje = testData['puntajeTotal'] as int;
    final fecha = testData['fechaRealizacion'] as Timestamp;

    // Contar total de tests
    final todosTests = await firestore
        .collection('tests_ansiedad')
        .where('usuarioId', isEqualTo: userId)
        .get();

    final totalTests = todosTests.docs.length;
    final requiereAtencion = nivelAnsiedad == 'moderadaGrave' || nivelAnsiedad == 'severa';

    print('   📝 Nivel: $nivelAnsiedad, Puntaje: $puntaje, Total tests: $totalTests');

    // ACTUALIZAR
    await firestore.collection('usuarios').doc(userId).update({
      'ultimoNivelAnsiedad': nivelAnsiedad,
      'puntajeUltimoTest': puntaje,
      'fechaUltimoTest': fecha,
      'totalTests': totalTests,
      'requiereAtencion': requiereAtencion,
    });

    print('   ✅ ACTUALIZADO\n');
  }

  print('🎉 TERMINADO');
}
