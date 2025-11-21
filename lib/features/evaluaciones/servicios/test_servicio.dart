import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/pregunta_beck.dart';
import '../modelos/resultado_test.dart';
import 'encriptacion_servicio.dart';
import '../../notificaciones/servicios/notificaciones_servicio.dart';

/// Servicio para gestionar tests de ansiedad y sus resultados
class TestServicio {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificacionesServicio _notificacionesServicio = NotificacionesServicio();

  /// Verifica si el usuario necesita realizar el test
  /// Retorna true si:
  /// - No tiene ningún test previo
  /// - El último test fue hace más de 30 días
  Future<bool> necesitaRealizarTest(String usuarioId) async {
    try {
      final ultimoTest = await obtenerUltimoTest(usuarioId);

      // Si no hay test previo, necesita realizarlo
      if (ultimoTest == null) {
        return true;
      }
     
      // Verifica si han pasado más de 30 días
      final diasDesdeUltimoTest = DateTime.now().difference(
        ultimoTest.fechaRealizacion,
      ).inDays;

      final necesita = diasDesdeUltimoTest >= 30;
      
      return necesita;
    } catch (e) {
      // En caso de error, asumir que necesita el test
      return true;
    }
  }

  /// Obtiene el último test realizado por el usuario (desencriptado)
  Future<ResultadoTest?> obtenerUltimoTest(String usuarioId) async {
    try {
      final query = await _firestore
          .collection('tests_ansiedad')
          .where('usuarioId', isEqualTo: usuarioId)
          .orderBy('fechaRealizacion', descending: true)
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) {
        return null;
      }

      // Obtiene los datos
      final doc = query.docs.first;
      var datos = doc.data();

      // Desencripta si está encriptado
      if (datos['encriptado'] == true) {
        datos = EncriptacionServicio.desencriptarResultado(
          resultadoEncriptado: datos,
          usuarioId: usuarioId,
        );
      }

      // Construye el resultado manualmente con los datos desencriptados
      final test = _construirResultadoTest(doc.id, datos);

      return test;
    } catch (e) {
      return null;
    }
  }

  /// Construye un ResultadoTest desde datos desencriptados
  ResultadoTest _construirResultadoTest(String id, Map<String, dynamic> data) {
    return ResultadoTest(
      id: id,
      usuarioId: data['usuarioId'] as String,
      fechaRealizacion: (data['fechaRealizacion'] as Timestamp).toDate(),
      respuestas: (data['respuestas'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(int.parse(key), value as int),
      ),
      puntajeTotal: data['puntajeTotal'] as int,
      nivelAnsiedad: NivelAnsiedad.values.firstWhere(
        (e) => e.name == data['nivelAnsiedad'],
      ),
      requiereDerivacion: data['requiereDerivacion'] as bool,
      actividadesRecomendadas: List<String>.from(data['actividadesRecomendadas'] as List),
      observaciones: data['observaciones'] as String?,
      derivadoPsicologo: data['derivadoPsicologo'] as bool? ?? false,
      fechaDerivacion: data['fechaDerivacion'] != null
          ? (data['fechaDerivacion'] as Timestamp).toDate()
          : null,
    );
  }

  /// Obtiene el penúltimo test (para comparar con el actual)
  Future<ResultadoTest?> obtenerTestAnterior(String usuarioId) async {
    try {
      final query = await _firestore
          .collection('tests_ansiedad')
          .where('usuarioId', isEqualTo: usuarioId)
          .orderBy('fechaRealizacion', descending: true)
          .limit(2)
          .get();

      if (query.docs.length < 2) {
        return null;
      }

      // Obtiene el segundo documento
      final doc = query.docs[1];
      var datos = doc.data();

      // Desencripta si está encriptado
      if (datos['encriptado'] == true) {
        datos = EncriptacionServicio.desencriptarResultado(
          resultadoEncriptado: datos,
          usuarioId: usuarioId,
        );
      }

      return _construirResultadoTest(doc.id, datos);
    } catch (e) {
      return null;
    }
  }

  /// Guarda un nuevo resultado de test (encriptado)
  Future<String> guardarResultado(ResultadoTest resultado) async {

    // Convierte a Firestore
    final datos = resultado.toFirestore();

    // Encripta los campos sensibles
    final datosEncriptados = EncriptacionServicio.encriptarResultado(
      resultado: datos,
      usuarioId: resultado.usuarioId,
    );

    final docRef = await _firestore
        .collection('tests_ansiedad')
        .add(datosEncriptados);

    print('✅ Test guardado con ID: ${docRef.id}');

    // ⭐ ACTUALIZAR PERFIL DEL USUARIO con datos del último test
    await _actualizarPerfilUsuario(resultado);

    // RF23: Si el nivel de ansiedad es grave, crear alerta para psicólogo
    if (resultado.nivelAnsiedad == NivelAnsiedad.moderadaGrave ||
        resultado.nivelAnsiedad == NivelAnsiedad.severa) {

      
      try {
        // Obtener nombre del estudiante desde Firestore
        final usuarioDoc = await _firestore
            .collection('usuarios')
            .doc(resultado.usuarioId)
            .get();

        if (usuarioDoc.exists) {
          final nombreCompleto = usuarioDoc.data()?['nombreCompleto'] as String? ?? 'Estudiante';

          await _notificacionesServicio.crearAlertaAnsiedadGrave(
            estudianteId: resultado.usuarioId,
            estudianteNombre: nombreCompleto,
            nivelAnsiedad: resultado.nivelAnsiedad,
            puntajeTest: resultado.puntajeTotal,
          );

         }
      } catch (e) {
       // No lanzar error para no interrumpir el guardado del test
      }
    }

    return docRef.id;
  }

  /// Actualiza el perfil del usuario con datos del último test
  /// Esto permite mostrar el nivel de ansiedad en la lista de estudiantes
  /// sin hacer queries adicionales por cada estudiante
  Future<void> _actualizarPerfilUsuario(ResultadoTest resultado) async {
    try {
      print('📊 Actualizando perfil de usuario...');

      // Contar total de tests del estudiante
      final testsSnapshot = await _firestore
          .collection('tests_ansiedad')
          .where('usuarioId', isEqualTo: resultado.usuarioId)
          .get();

      final totalTests = testsSnapshot.docs.length;

      // Determinar si requiere atención (moderadaGrave o severa)
      final requiereAtencion = resultado.nivelAnsiedad == NivelAnsiedad.moderadaGrave ||
                               resultado.nivelAnsiedad == NivelAnsiedad.severa;

      // Actualizar documento del usuario con datos pre-calculados
      await _firestore.collection('usuarios').doc(resultado.usuarioId).update({
        'ultimoNivelAnsiedad': resultado.nivelAnsiedad.name,
        'puntajeUltimoTest': resultado.puntajeTotal,
        'fechaUltimoTest': Timestamp.fromDate(resultado.fechaRealizacion),
        'totalTests': totalTests,
        'requiereAtencion': requiereAtencion,
      });

      print('✅ Perfil actualizado: nivel=${resultado.nivelAnsiedad.name}, puntaje=${resultado.puntajeTotal}, total=$totalTests');
    } catch (e) {
      print('⚠️ Error al actualizar perfil: $e');
      // No lanzar error, es una operación secundaria
    }
  }

  /// Actualiza un resultado existente (para marcar derivación, etc.)
  Future<void> actualizarResultado(
    String testId,
    Map<String, dynamic> datos,
  ) async {
    await _firestore
        .collection('tests_ansiedad')
        .doc(testId)
        .update(datos);
  }

  /// Calcula el resultado basado en las respuestas
  ResultadoTest calcularResultado({
    required String usuarioId,
    required Map<int, int> respuestas,
  }) {
    // Calcula el puntaje total
    final puntajeTotal = respuestas.values.reduce((a, b) => a + b);

    // Determina el nivel de ansiedad
    final nivelAnsiedad = InventarioBeck.calcularNivel(puntajeTotal);

    // Obtiene actividades recomendadas
    final actividades = ActividadesRecomendadas.obtenerPorNivel(nivelAnsiedad);

    // Crea el resultado
    return ResultadoTest(
      id: '', // Se asignará al guardar
      usuarioId: usuarioId,
      fechaRealizacion: DateTime.now(),
      respuestas: respuestas,
      puntajeTotal: puntajeTotal,
      nivelAnsiedad: nivelAnsiedad,
      requiereDerivacion: nivelAnsiedad.requiereDerivacion,
      actividadesRecomendadas: actividades,
      derivadoPsicologo: nivelAnsiedad.requiereDerivacion,
      fechaDerivacion: nivelAnsiedad.requiereDerivacion
          ? DateTime.now()
          : null,
    );
  }

  /// Verifica si hubo mejora comparando con el test anterior
  Future<bool> huboMejora(String usuarioId, NivelAnsiedad nivelActual) async {
    final testAnterior = await obtenerTestAnterior(usuarioId);

    if (testAnterior == null) {
      // Si no hay test anterior, no se puede determinar mejora
      return false;
    }

    // Compara los niveles (índice menor = mejor)
    return nivelActual.index < testAnterior.nivelAnsiedad.index;
  }

  /// Verifica si se mantiene el mismo nivel grave
  Future<bool> mantienNivelGrave(
    String usuarioId,
    NivelAnsiedad nivelActual,
  ) async {
    final testAnterior = await obtenerTestAnterior(usuarioId);

    if (testAnterior == null) {
      return false;
    }

    // Verifica si ambos son graves (moderadaGrave o severa)
    final nivelesGraves = [
      NivelAnsiedad.moderada,
      NivelAnsiedad.moderadaGrave,
      NivelAnsiedad.severa
    ];

    return nivelesGraves.contains(nivelActual) &&
        nivelesGraves.contains(testAnterior.nivelAnsiedad) &&
        nivelActual.index >= testAnterior.nivelAnsiedad.index;
  }

  /// Obtiene el historial completo de tests del usuario (desencriptado)
  Future<List<ResultadoTest>> obtenerHistorial(String usuarioId) async {
    try {
      final query = await _firestore
          .collection('tests_ansiedad')
          .where('usuarioId', isEqualTo: usuarioId)
          .orderBy('fechaRealizacion', descending: true)
          .get();

      final resultados = query.docs.map((doc) {
        var datos = doc.data();

        // Desencripta si está encriptado
        if (datos['encriptado'] == true) {
          datos = EncriptacionServicio.desencriptarResultado(
            resultadoEncriptado: datos,
            usuarioId: usuarioId,
          );
        }

        return _construirResultadoTest(doc.id, datos);
      }).toList();

      return resultados;
    } catch (e) {
      return [];
    }
  }

  /// Marca un test como derivado al psicólogo
  Future<void> marcarComoDerivado(String testId) async {
    await actualizarResultado(testId, {
      'derivadoPsicologo': true,
      'fechaDerivacion': Timestamp.now(),
    });
  }

  /// Obtiene un test específico por ID (para psicólogos)
  /// Requiere el rol del usuario para verificar permisos
  Future<ResultadoTest?> obtenerTestPorId({
    required String testId,
    required String usuarioSolicitante,
    required String? rolUsuario,
  }) async {
    try {
     
      final doc = await _firestore
          .collection('tests_ansiedad')
          .doc(testId)
          .get();

      if (!doc.exists) {
        return null;
      }

      var datos = doc.data()!;
      final propietarioId = datos['usuarioId'] as String;

      // Verifica permisos
      final tienePermiso = EncriptacionServicio.tienePermiso(
        usuarioId: usuarioSolicitante,
        rolUsuario: rolUsuario,
        propietarioTestId: propietarioId,
      );

      if (!tienePermiso) {
        throw Exception('No tienes permisos para ver este test');
      }

      // Desencripta usando el ID del propietario (no del solicitante)
      if (datos['encriptado'] == true) {
        datos = EncriptacionServicio.desencriptarResultado(
          resultadoEncriptado: datos,
          usuarioId: propietarioId, // Usa el ID del dueño del test
        );
      }
      return _construirResultadoTest(doc.id, datos);
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene todos los tests derivados (para psicólogos)
  /// Solo accesible por usuarios con rol 'psicologo' o 'admin'
  Future<List<ResultadoTest>> obtenerTestsDerivados({
    required String usuarioSolicitante,
    required String? rolUsuario,
  }) async {
    try {
      // Verifica que sea psicólogo
      if (rolUsuario != 'psicologo' && rolUsuario != 'admin') {
        throw Exception('Solo los psicólogos pueden ver tests derivados');
      }

      final query = await _firestore
          .collection('tests_ansiedad')
          .where('derivadoPsicologo', isEqualTo: true)
          .orderBy('fechaDerivacion', descending: true)
          .get();

      final tests = query.docs.map((doc) {
        var datos = doc.data();
        final propietarioId = datos['usuarioId'] as String;

        // Desencripta usando el ID del propietario
        if (datos['encriptado'] == true) {
          datos = EncriptacionServicio.desencriptarResultado(
            resultadoEncriptado: datos,
            usuarioId: propietarioId,
          );
        }

        return _construirResultadoTest(doc.id, datos);
      }).toList();
      return tests;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene el historial de un estudiante (para psicólogos)
  Future<List<ResultadoTest>> obtenerHistorialEstudiante({
    required String estudianteId,
    required String usuarioSolicitante,
    required String? rolUsuario,
  }) async {
    try {
      // Verifica que sea psicólogo
      if (rolUsuario != 'psicologo' && rolUsuario != 'admin') {
        throw Exception('Solo los psicólogos pueden ver el historial de estudiantes');
      }


      final query = await _firestore
          .collection('tests_ansiedad')
          .where('usuarioId', isEqualTo: estudianteId)
          .orderBy('fechaRealizacion', descending: true)
          .get();

      final tests = query.docs.map((doc) {
        var datos = doc.data();

        // Desencripta usando el ID del estudiante
        if (datos['encriptado'] == true) {
          datos = EncriptacionServicio.desencriptarResultado(
            resultadoEncriptado: datos,
            usuarioId: estudianteId,
          );
        }

        return _construirResultadoTest(doc.id, datos);
      }).toList();

      return tests;
    } catch (e) {
      rethrow;
    }
  }
}
