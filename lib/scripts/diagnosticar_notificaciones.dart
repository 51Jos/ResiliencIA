import 'package:cloud_firestore/cloud_firestore.dart';

/// Script para diagnosticar y probar el guardado de notificaciones
void main() async {

  final firestore = FirebaseFirestore.instance;

  // 1. Verificar si hay psicólogos
  final psicologosSnapshot = await firestore
      .collection('usuarios')
      .where('rol', isEqualTo: 'psicologo')
      .get();

  // ignore: unused_local_variable
  for (var doc in psicologosSnapshot.docs) {

    }

  if (psicologosSnapshot.docs.isEmpty) {
    return;
  }

  // 2. Intentar crear notificación de prueba
  try {
    final notificacionData = {
      'tipo': 'ansiedadGrave',
      'prioridad': 'urgente',
      'titulo': '⚠️ PRUEBA - Nivel de Ansiedad Severo',
      'mensaje': 'Esta es una notificación de prueba para verificar el sistema',
      'destinatarioId': psicologosSnapshot.docs.first.id,
      'estudianteId': 'TEST_ESTUDIANTE_ID',
      'estudianteNombre': 'Estudiante de Prueba',
      'nivelAnsiedad': 'Severa',
      'puntajeTest': 60,
      'leida': false,
      'fechaCreacion': Timestamp.now(),
    };

    notificacionData.forEach((key, value) {
    });

    final docRef = await firestore
        .collection('notificaciones')
        .add(notificacionData);


    // 3. Verificar que se guardó
    final verificacion = await docRef.get();
    if (verificacion.exists) {
      verificacion.data()?.forEach((key, value) {
      });
    } else {
    }

    // 4. Listar todas las notificaciones
    final todasSnapshot = await firestore
        .collection('notificaciones')
        .get();

   for (var doc in todasSnapshot.docs) {
      doc.data();
    }

  // ignore: empty_catches
  } catch (e) {
  }
}
