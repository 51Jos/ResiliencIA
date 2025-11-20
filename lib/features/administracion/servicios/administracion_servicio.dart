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

  /// Obtiene la lista de todos los estudiantes
  Future<List<EstudianteInfo>> obtenerEstudiantes({
    FiltrosAdministracion? filtros,
  }) async {
    try {
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
      var estudiantes = snapshot.docs
          .map((doc) => EstudianteInfo.fromFirestore(doc))
          .toList();

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
  Future<EstadisticasGlobales> obtenerEstadisticasGlobales({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      // Obtener todos los estudiantes
      final estudiantes = await obtenerEstudiantes();

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

      // Calcular distribución de niveles
      final distribucionNiveles = <NivelAnsiedad, int>{};
      int estudiantesConAnsiedad = 0;
      int estudiantesRequierenAtencion = 0;
      double sumaPuntajes = 0;
      DateTime? ultimaFecha;

      for (var estudiante in estudiantes) {
        if (estudiante.ultimoNivelAnsiedad != null) {
          final nivel = estudiante.ultimoNivelAnsiedad!;
          distribucionNiveles[nivel] = (distribucionNiveles[nivel] ?? 0) + 1;

          if (nivel != NivelAnsiedad.minima) {
            estudiantesConAnsiedad++;
          }

          if (estudiante.requiereAtencion) {
            estudiantesRequierenAtencion++;
          }

          if (estudiante.puntajeUltimoTest != null) {
            sumaPuntajes += estudiante.puntajeUltimoTest!;
          }

          if (ultimaFecha == null ||
              (estudiante.fechaUltimoTest != null &&
                  estudiante.fechaUltimoTest!.isAfter(ultimaFecha))) {
            ultimaFecha = estudiante.fechaUltimoTest;
          }
        }
      }

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

      final promedioGeneral = estudiantes.isEmpty
          ? 0.0
          : sumaPuntajes / estudiantes.where((e) => e.puntajeUltimoTest != null).length;

      return EstadisticasGlobales(
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
    } catch (e) {
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
          .orderBy('fechaCreacion', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Observacion.fromFirestore(doc))
          .toList();
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
          .orderBy('fechaCita', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CitaProgramada.fromFirestore(doc))
          .toList();
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
