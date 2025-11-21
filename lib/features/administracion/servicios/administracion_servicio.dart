import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/estudiante_info.dart';
import '../modelos/estadisticas_globales.dart';
import '../modelos/observacion.dart';
import '../../evaluaciones/modelos/pregunta_beck.dart';
import '../../evaluaciones/servicios/test_servicio.dart';

/// Servicio para gestionar funciones administrativas
class AdministracionServicio {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TestServicio _testServicio = TestServicio();

  // Cache para estadísticas globales
  EstadisticasGlobales? _estadisticasCache;
  DateTime? _estadisticasCacheTimestamp;

  // Cache para lista de estudiantes
  List<EstudianteInfo>? _estudiantesCache;
  DateTime? _estudiantesCacheTimestamp;

  static const Duration _cacheDuration = Duration(minutes: 5); // Cache por 5 minutos

  /// Verifica si el cache de estadísticas es válido
  bool _esCacheEstadisticasValido() {
    if (_estadisticasCache == null || _estadisticasCacheTimestamp == null) {
      return false;
    }
    final diferencia = DateTime.now().difference(_estadisticasCacheTimestamp!);
    return diferencia < _cacheDuration;
  }

  /// Verifica si el cache de estudiantes es válido
  bool _esCacheEstudiantesValido() {
    if (_estudiantesCache == null || _estudiantesCacheTimestamp == null) {
      return false;
    }
    final diferencia = DateTime.now().difference(_estudiantesCacheTimestamp!);
    return diferencia < _cacheDuration;
  }

  /// Invalida el cache de estadísticas
  void invalidarCacheEstadisticas() {
    _estadisticasCache = null;
    _estadisticasCacheTimestamp = null;
    print('🗑️ Cache de estadísticas invalidado');
  }

  /// Invalida el cache de estudiantes
  void invalidarCacheEstudiantes() {
    _estudiantesCache = null;
    _estudiantesCacheTimestamp = null;
    print('🗑️ Cache de estudiantes invalidado');
  }

  /// Invalida todos los caches
  void invalidarTodosLosCaches() {
    invalidarCacheEstadisticas();
    invalidarCacheEstudiantes();
  }

  /// Obtiene la lista de todos los estudiantes
  /// Usa caché de 5 minutos para mejorar rendimiento
  Future<List<EstudianteInfo>> obtenerEstudiantes({
    FiltrosAdministracion? filtros,
    bool forzarRecarga = false,
  }) async {
    try {
      // Si no hay filtros y el cache es válido, devolver cache
      if (!forzarRecarga && filtros == null && _esCacheEstudiantesValido()) {
        print('⚡ Usando lista de estudiantes desde cache');
        return _estudiantesCache!;
      }

      print('📋 Obteniendo lista de estudiantes desde Firestore...');

      Query<Map<String, dynamic>> query = _firestore
          .collection('usuarios')
          .where('rol', isEqualTo: 'estudiante');

      // Aplicar filtros
      if (filtros != null) {
        if (filtros.carrera != null) {
          query = query.where('programa', isEqualTo: filtros.carrera);
        }
        if (filtros.facultad != null) {
          query = query.where('facultad', isEqualTo: filtros.facultad);
        }
        if (filtros.requiereAtencion == true) {
          query = query.where('requiereAtencion', isEqualTo: true);
        }
        if (filtros.nivelAnsiedad != null) {
          query = query.where(
            'ultimoNivelAnsiedad',
            isEqualTo: filtros.nivelAnsiedad!.name,
          );
        }
      }

      final snapshot = await query.get();
      print('📋 Estudiantes encontrados: ${snapshot.docs.length}');

      // Cargar estudiantes y calcular totalTests para cada uno
      var estudiantes = <EstudianteInfo>[];
      for (var doc in snapshot.docs) {
        var estudiante = EstudianteInfo.fromFirestore(doc);

        // Contar los tests del estudiante desde la colección tests_ansiedad
        final testsSnapshot = await _firestore
            .collection('tests_ansiedad')
            .where('usuarioId', isEqualTo: estudiante.uid)
            .get();

        final totalTests = testsSnapshot.docs.length;
        print('📊 Estudiante ${estudiante.nombreCompleto}: $totalTests tests');

        // Actualizar el totalTests con el valor real
        estudiante = estudiante.copyWith(totalTests: totalTests);
        estudiantes.add(estudiante);
      }

      // Aplicar filtro de búsqueda (cliente)
      if (filtros?.busqueda != null && filtros!.busqueda!.isNotEmpty) {
        final busqueda = filtros.busqueda!.toLowerCase();
        estudiantes = estudiantes.where((e) {
          return e.nombreCompleto.toLowerCase().contains(busqueda) ||
              e.codigo.toLowerCase().contains(busqueda) ||
              e.email.toLowerCase().contains(busqueda);
        }).toList();
      }

      // Aplicar filtro de fechas (cliente)
      if (filtros?.fechaDesde != null) {
        estudiantes = estudiantes.where((e) {
          return e.fechaUltimoTest != null &&
              e.fechaUltimoTest!.isAfter(filtros!.fechaDesde!);
        }).toList();
      }

      if (filtros?.fechaHasta != null) {
        estudiantes = estudiantes.where((e) {
          return e.fechaUltimoTest != null &&
              e.fechaUltimoTest!.isBefore(filtros!.fechaHasta!);
        }).toList();
      }

      // Aplicar ordenamiento
      if (filtros?.orden != null) {
        estudiantes = _ordenarEstudiantes(estudiantes, filtros!.orden);
      }

      // Guardar en cache solo si no hay filtros
      if (filtros == null) {
        _estudiantesCache = estudiantes;
        _estudiantesCacheTimestamp = DateTime.now();
        print('💾 Estudiantes guardados en cache (${estudiantes.length} estudiantes, válido por ${_cacheDuration.inMinutes} minutos)');
      }

      return estudiantes;
    } catch (e) {
      rethrow;
    }
  }

  /// Ordena la lista de estudiantes según el criterio
  List<EstudianteInfo> _ordenarEstudiantes(
    List<EstudianteInfo> estudiantes,
    OrdenEstudiantes orden,
  ) {
    switch (orden) {
      case OrdenEstudiantes.nombreAZ:
        estudiantes.sort((a, b) => a.nombreCompleto.compareTo(b.nombreCompleto));
        break;
      case OrdenEstudiantes.nombreZA:
        estudiantes.sort((a, b) => b.nombreCompleto.compareTo(a.nombreCompleto));
        break;
      case OrdenEstudiantes.codigoAsc:
        estudiantes.sort((a, b) => a.codigo.compareTo(b.codigo));
        break;
      case OrdenEstudiantes.codigoDesc:
        estudiantes.sort((a, b) => b.codigo.compareTo(a.codigo));
        break;
      case OrdenEstudiantes.fechaRegistroReciente:
        estudiantes.sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
        break;
      case OrdenEstudiantes.fechaRegistroAntiguo:
        estudiantes.sort((a, b) => a.fechaRegistro.compareTo(b.fechaRegistro));
        break;
      case OrdenEstudiantes.nivelAnsiedadMayor:
        estudiantes.sort((a, b) {
          if (a.ultimoNivelAnsiedad == null) return 1;
          if (b.ultimoNivelAnsiedad == null) return -1;
          return b.ultimoNivelAnsiedad!.index
              .compareTo(a.ultimoNivelAnsiedad!.index);
        });
        break;
      case OrdenEstudiantes.nivelAnsiedadMenor:
        estudiantes.sort((a, b) {
          if (a.ultimoNivelAnsiedad == null) return 1;
          if (b.ultimoNivelAnsiedad == null) return -1;
          return a.ultimoNivelAnsiedad!.index
              .compareTo(b.ultimoNivelAnsiedad!.index);
        });
        break;
    }
    return estudiantes;
  }

  /// Obtiene estadísticas globales del sistema
  /// Calcula estadísticas directamente desde la colección de tests
  /// Usa caché de 5 minutos para mejorar rendimiento
  Future<EstadisticasGlobales> obtenerEstadisticasGlobales({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    bool forzarRecarga = false,
  }) async {
    try {
      // Si no se especifican fechas y el cache es válido, devolver cache
      if (!forzarRecarga && fechaDesde == null && fechaHasta == null && _esCacheEstadisticasValido()) {
        print('⚡ Usando estadísticas desde cache');
        return _estadisticasCache!;
      }

      print('📊 Calculando estadísticas globales...');

      // Obtener todos los estudiantes
      final estudiantes = await obtenerEstudiantes();
      print('📋 Total estudiantes: ${estudiantes.length}');

      // Obtener todos los tests
      Query<Map<String, dynamic>> testsQuery = _firestore
          .collection('tests_ansiedad');

      if (fechaDesde != null) {
        testsQuery = testsQuery.where(
          'fechaRealizacion',
          isGreaterThanOrEqualTo: Timestamp.fromDate(fechaDesde),
        );
      }

      if (fechaHasta != null) {
        testsQuery = testsQuery.where(
          'fechaRealizacion',
          isLessThanOrEqualTo: Timestamp.fromDate(fechaHasta),
        );
      }

      final testsSnapshot = await testsQuery.get();
      print('📊 Total tests en colección: ${testsSnapshot.docs.length}');

      // Agrupar tests por estudiante para obtener solo el último de cada uno
      final ultimosTestsPorEstudiante = <String, Map<String, dynamic>>{};

      for (var testDoc in testsSnapshot.docs) {
        final testData = testDoc.data();
        final usuarioId = testData['usuarioId'] as String;
        final fechaRealizacion = (testData['fechaRealizacion'] as Timestamp).toDate();

        if (!ultimosTestsPorEstudiante.containsKey(usuarioId) ||
            fechaRealizacion.isAfter(
              (ultimosTestsPorEstudiante[usuarioId]!['fechaRealizacion'] as Timestamp).toDate()
            )) {
          ultimosTestsPorEstudiante[usuarioId] = testData;
        }
      }

      print('👥 Estudiantes con tests: ${ultimosTestsPorEstudiante.length}');

      // Calcular estadísticas basadas en los últimos tests de cada estudiante
      final distribucionNiveles = <NivelAnsiedad, int>{};
      int estudiantesConAnsiedad = 0;
      int estudiantesRequierenAtencion = 0;
      double sumaPuntajes = 0;
      DateTime? ultimaFecha;
      int contadorPuntajes = 0;

      for (var testData in ultimosTestsPorEstudiante.values) {
        // Obtener nivel de ansiedad
        final nivelString = testData['nivelAnsiedad'] as String;
        final nivel = NivelAnsiedad.values.firstWhere(
          (e) => e.name == nivelString,
          orElse: () => NivelAnsiedad.minima,
        );

        // Contar distribución de niveles
        distribucionNiveles[nivel] = (distribucionNiveles[nivel] ?? 0) + 1;

        // Contar estudiantes con ansiedad
        if (nivel != NivelAnsiedad.minima) {
          estudiantesConAnsiedad++;
        }

        // Contar estudiantes que requieren atención (moderada-grave o severa)
        if (nivel == NivelAnsiedad.moderadaGrave || nivel == NivelAnsiedad.severa) {
          estudiantesRequierenAtencion++;
        }

        // Sumar puntajes
        final puntaje = testData['puntajeTotal'] as int;
        sumaPuntajes += puntaje;
        contadorPuntajes++;

        // Actualizar última fecha
        final fechaTest = (testData['fechaRealizacion'] as Timestamp).toDate();
        if (ultimaFecha == null || fechaTest.isAfter(ultimaFecha)) {
          ultimaFecha = fechaTest;
        }
      }

      print('📈 Estudiantes con ansiedad: $estudiantesConAnsiedad');
      print('⚠️ Estudiantes que requieren atención: $estudiantesRequierenAtencion');

      // Distribución por carrera
      final distribucionPorCarrera = <String, int>{};
      for (var estudiante in estudiantes) {
        if (estudiante.programa != null) {
          distribucionPorCarrera[estudiante.programa!] =
              (distribucionPorCarrera[estudiante.programa!] ?? 0) + 1;
        }
      }

      // Distribución por facultad
      final distribucionPorFacultad = <String, int>{};
      for (var estudiante in estudiantes) {
        if (estudiante.facultad != null) {
          distribucionPorFacultad[estudiante.facultad!] =
              (distribucionPorFacultad[estudiante.facultad!] ?? 0) + 1;
        }
      }

      final promedioGeneral = contadorPuntajes == 0
          ? 0.0
          : sumaPuntajes / contadorPuntajes;

      print('✅ Estadísticas calculadas exitosamente');
      print('   - Distribución niveles: $distribucionNiveles');
      print('   - Promedio general: ${promedioGeneral.toStringAsFixed(1)}');

      final estadisticas = EstadisticasGlobales(
        totalEstudiantes: estudiantes.length,
        totalTests: testsSnapshot.docs.length,
        estudiantesConAnsiedad: estudiantesConAnsiedad,
        estudiantesRequierenAtencion: estudiantesRequierenAtencion,
        distribucionNiveles: distribucionNiveles,
        distribucionPorCarrera: distribucionPorCarrera,
        distribucionPorFacultad: distribucionPorFacultad,
        promedioGeneral: promedioGeneral,
        fechaUltimoTest: ultimaFecha,
      );

      // Guardar en cache solo si no hay filtros de fecha
      if (fechaDesde == null && fechaHasta == null) {
        _estadisticasCache = estadisticas;
        _estadisticasCacheTimestamp = DateTime.now();
        print('💾 Estadísticas guardadas en cache (válido por ${_cacheDuration.inMinutes} minutos)');
      }

      return estadisticas;
    } catch (e) {
      print('❌ Error al obtener estadísticas globales: $e');
      rethrow;
    }
  }

  /// Obtiene estadísticas de evolución de un estudiante
  Future<EstadisticasEstudiante> obtenerEstadisticasEstudiante(
    String estudianteId,
  ) async {
    try {
      final tests = await _testServicio.obtenerHistorial(estudianteId);

      if (tests.isEmpty) {
        return EstadisticasEstudiante.vacio(estudianteId);
      }

      // Crear puntos de evolución
      final evolucion = tests.map((test) {
        return PuntoEvolucion(
          fecha: test.fechaRealizacion,
          puntaje: test.puntajeTotal,
          nivel: test.nivelAnsiedad,
        );
      }).toList();

      // Ordenar por fecha ascendente
      evolucion.sort((a, b) => a.fecha.compareTo(b.fecha));

      // Calcular promedio
      final promedio = tests.map((t) => t.puntajeTotal).reduce((a, b) => a + b) /
          tests.length;

      // Verificar mejora
      final haHabidoMejora = tests.length >= 2 &&
          tests.first.nivelAnsiedad.index < tests[1].nivelAnsiedad.index;

      return EstadisticasEstudiante(
        estudianteId: estudianteId,
        evolucion: evolucion,
        nivelActual: tests.first.nivelAnsiedad,
        nivelAnterior: tests.length >= 2 ? tests[1].nivelAnsiedad : null,
        haHabidoMejora: haHabidoMejora,
        promedioPuntajes: promedio,
        totalTests: tests.length,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Guarda una observación del psicólogo
  Future<String> guardarObservacion(Observacion observacion) async {
    try {
      final docRef = await _firestore
          .collection('observaciones')
          .add(observacion.toFirestore());

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene observaciones de un estudiante
  Future<List<Observacion>> obtenerObservaciones(String estudianteId) async {
    try {
      final snapshot = await _firestore
          .collection('observaciones')
          .where('estudianteId', isEqualTo: estudianteId)
          .get();

      // Ordenar en memoria para evitar necesidad de index compuesto
      final observaciones = snapshot.docs
          .map((doc) => Observacion.fromFirestore(doc))
          .toList();

      observaciones.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));

      return observaciones;
    } catch (e) {
      rethrow;
    }
  }

  /// Actualiza una observación
  Future<void> actualizarObservacion(
    String observacionId,
    String nuevoTexto,
  ) async {
    try {
      await _firestore.collection('observaciones').doc(observacionId).update({
        'texto': nuevoTexto,
        'fechaModificacion': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Elimina una observación
  Future<void> eliminarObservacion(String observacionId) async {
    try {
      await _firestore.collection('observaciones').doc(observacionId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Programa una cita con un estudiante
  Future<String> programarCita(CitaProgramada cita) async {
    try {
      final docRef = await _firestore
          .collection('citas')
          .add(cita.toFirestore());

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene citas de un estudiante
  Future<List<CitaProgramada>> obtenerCitasEstudiante(
    String estudianteId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('citas')
          .where('estudianteId', isEqualTo: estudianteId)
          .get();

      // Ordenar en memoria para evitar necesidad de index compuesto
      final citas = snapshot.docs
          .map((doc) => CitaProgramada.fromFirestore(doc))
          .toList();

      citas.sort((a, b) => b.fechaCita.compareTo(a.fechaCita));

      return citas;
    } catch (e) {
      rethrow;
    }
  }

  /// Actualiza el estado de una cita
  Future<void> actualizarEstadoCita(
    String citaId,
    EstadoCita nuevoEstado,
  ) async {
    try {
      await _firestore.collection('citas').doc(citaId).update({
        'estado': nuevoEstado.name,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene todas las carreras únicas
  Future<List<String>> obtenerCarreras() async {
    try {
      final snapshot = await _firestore
          .collection('usuarios')
          .where('rol', isEqualTo: 'estudiante')
          .get();

      final carreras = <String>{};
      for (var doc in snapshot.docs) {
        final programa = doc.data()['programa'] as String?;
        if (programa != null && programa.isNotEmpty) {
          carreras.add(programa);
        }
      }

      final lista = carreras.toList();
      lista.sort();
      return lista;
    } catch (e) {
      return [];
    }
  }

  /// Obtiene todas las facultades únicas
  Future<List<String>> obtenerFacultades() async {
    try {
      final snapshot = await _firestore
          .collection('usuarios')
          .where('rol', isEqualTo: 'estudiante')
          .get();

      final facultades = <String>{};
      for (var doc in snapshot.docs) {
        final facultad = doc.data()['facultad'] as String?;
        if (facultad != null && facultad.isNotEmpty) {
          facultades.add(facultad);
        }
      }

      final lista = facultades.toList();
      lista.sort();
      return lista;
    } catch (e) {
      return [];
    }
  }

  /// Verifica si el usuario es administrador
  Future<bool> esAdministrador(String usuarioId) async {
    try {
      final doc = await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .get();

      if (!doc.exists) return false;

      final data = doc.data()!;
      final rol = data['rol'] as String?;
      final email = data['email'] as String?;

      // Debe ser psicólogo/admin Y tener correo @ucss.edu.pe (administradores institucionales)
      return (rol == 'psicologo' || rol == 'admin') &&
          (email != null && email.endsWith('@ucss.edu.pe'));
    } catch (e) {
      return false;
    }
  }
}
