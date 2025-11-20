import '../../evaluaciones/modelos/pregunta_beck.dart';

/// Estadísticas globales del sistema
class EstadisticasGlobales {
  final int totalEstudiantes;
  final int totalTests;
  final int estudiantesConAnsiedad;
  final int estudiantesRequierenAtencion;
  final Map<NivelAnsiedad, int> distribucionNiveles;
  final Map<String, int> distribucionPorCarrera;
  final Map<String, int> distribucionPorFacultad;
  final double promedioGeneral;
  final DateTime? fechaUltimoTest;

  const EstadisticasGlobales({
    required this.totalEstudiantes,
    required this.totalTests,
    required this.estudiantesConAnsiedad,
    required this.estudiantesRequierenAtencion,
    required this.distribucionNiveles,
    required this.distribucionPorCarrera,
    required this.distribucionPorFacultad,
    required this.promedioGeneral,
    this.fechaUltimoTest,
  });

  /// Estadísticas vacías
  factory EstadisticasGlobales.vacio() {
    return const EstadisticasGlobales(
      totalEstudiantes: 0,
      totalTests: 0,
      estudiantesConAnsiedad: 0,
      estudiantesRequierenAtencion: 0,
      distribucionNiveles: {},
      distribucionPorCarrera: {},
      distribucionPorFacultad: {},
      promedioGeneral: 0.0,
    );
  }

  /// Porcentaje de estudiantes que requieren atención
  double get porcentajeRequierenAtencion {
    if (totalEstudiantes == 0) return 0.0;
    return (estudiantesRequierenAtencion / totalEstudiantes) * 100;
  }

  /// Porcentaje de estudiantes con ansiedad
  double get porcentajeConAnsiedad {
    if (totalEstudiantes == 0) return 0.0;
    return (estudiantesConAnsiedad / totalEstudiantes) * 100;
  }
}

/// Estadísticas de evolución de un estudiante
class EstadisticasEstudiante {
  final String estudianteId;
  final List<PuntoEvolucion> evolucion;
  final NivelAnsiedad? nivelActual;
  final NivelAnsiedad? nivelAnterior;
  final bool haHabidoMejora;
  final double promedioPuntajes;
  final int totalTests;

  const EstadisticasEstudiante({
    required this.estudianteId,
    required this.evolucion,
    this.nivelActual,
    this.nivelAnterior,
    required this.haHabidoMejora,
    required this.promedioPuntajes,
    required this.totalTests,
  });

  /// Estadísticas vacías
  factory EstadisticasEstudiante.vacio(String estudianteId) {
    return EstadisticasEstudiante(
      estudianteId: estudianteId,
      evolucion: [],
      haHabidoMejora: false,
      promedioPuntajes: 0.0,
      totalTests: 0,
    );
  }
}

/// Punto de datos para la gráfica de evolución
class PuntoEvolucion {
  final DateTime fecha;
  final int puntaje;
  final NivelAnsiedad nivel;

  const PuntoEvolucion({
    required this.fecha,
    required this.puntaje,
    required this.nivel,
  });
}

/// Filtros para búsqueda y reportes
class FiltrosAdministracion {
  final String? busqueda;
  final NivelAnsiedad? nivelAnsiedad;
  final String? carrera;
  final String? facultad;
  final bool? requiereAtencion;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  final OrdenEstudiantes orden;

  const FiltrosAdministracion({
    this.busqueda,
    this.nivelAnsiedad,
    this.carrera,
    this.facultad,
    this.requiereAtencion,
    this.fechaDesde,
    this.fechaHasta,
    this.orden = OrdenEstudiantes.nombreAZ,
  });

  /// Copia con cambios
  FiltrosAdministracion copyWith({
    String? busqueda,
    NivelAnsiedad? nivelAnsiedad,
    String? carrera,
    String? facultad,
    bool? requiereAtencion,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    OrdenEstudiantes? orden,
  }) {
    return FiltrosAdministracion(
      busqueda: busqueda ?? this.busqueda,
      nivelAnsiedad: nivelAnsiedad ?? this.nivelAnsiedad,
      carrera: carrera ?? this.carrera,
      facultad: facultad ?? this.facultad,
      requiereAtencion: requiereAtencion ?? this.requiereAtencion,
      fechaDesde: fechaDesde ?? this.fechaDesde,
      fechaHasta: fechaHasta ?? this.fechaHasta,
      orden: orden ?? this.orden,
    );
  }

  /// Limpia todos los filtros
  FiltrosAdministracion limpiar() {
    return const FiltrosAdministracion();
  }

  /// Verifica si hay filtros activos
  bool get tienesFiltros {
    return busqueda != null ||
        nivelAnsiedad != null ||
        carrera != null ||
        facultad != null ||
        requiereAtencion != null ||
        fechaDesde != null ||
        fechaHasta != null;
  }
}

/// Opciones de ordenamiento
enum OrdenEstudiantes {
  nombreAZ,
  nombreZA,
  codigoAsc,
  codigoDesc,
  fechaRegistroReciente,
  fechaRegistroAntiguo,
  nivelAnsiedadMayor,
  nivelAnsiedadMenor,
}

extension OrdenEstudiantesExtension on OrdenEstudiantes {
  String get nombre {
    switch (this) {
      case OrdenEstudiantes.nombreAZ:
        return 'Nombre (A-Z)';
      case OrdenEstudiantes.nombreZA:
        return 'Nombre (Z-A)';
      case OrdenEstudiantes.codigoAsc:
        return 'Código (Ascendente)';
      case OrdenEstudiantes.codigoDesc:
        return 'Código (Descendente)';
      case OrdenEstudiantes.fechaRegistroReciente:
        return 'Más reciente';
      case OrdenEstudiantes.fechaRegistroAntiguo:
        return 'Más antiguo';
      case OrdenEstudiantes.nivelAnsiedadMayor:
        return 'Ansiedad mayor';
      case OrdenEstudiantes.nivelAnsiedadMenor:
        return 'Ansiedad menor';
    }
  }
}
