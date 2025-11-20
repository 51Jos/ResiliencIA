import 'package:flutter/foundation.dart';
import '../modelos/estudiante_info.dart';
import '../modelos/estadisticas_globales.dart';
import '../modelos/observacion.dart';
import '../servicios/administracion_servicio.dart';
import '../../evaluaciones/modelos/pregunta_beck.dart';

/// Controlador para gestión administrativa
class AdministracionControlador extends ChangeNotifier {
  final AdministracionServicio _servicio = AdministracionServicio();

  // Estado
  List<EstudianteInfo> _estudiantes = [];
  EstadisticasGlobales? _estadisticasGlobales;
  EstudianteInfo? _estudianteSeleccionado;
  EstadisticasEstudiante? _estadisticasEstudiante;
  List<Observacion> _observaciones = [];
  List<CitaProgramada> _citas = [];
  FiltrosAdministracion _filtros = const FiltrosAdministracion();
  bool _cargando = false;
  String? _error;

  // Listas para filtros
  List<String> _carreras = [];
  List<String> _facultades = [];

  // Getters
  List<EstudianteInfo> get estudiantes => _estudiantes;
  EstadisticasGlobales? get estadisticasGlobales => _estadisticasGlobales;
  EstudianteInfo? get estudianteSeleccionado => _estudianteSeleccionado;
  EstadisticasEstudiante? get estadisticasEstudiante => _estadisticasEstudiante;
  List<Observacion> get observaciones => _observaciones;
  List<CitaProgramada> get citas => _citas;
  FiltrosAdministracion get filtros => _filtros;
  bool get cargando => _cargando;
  String? get error => _error;
  List<String> get carreras => _carreras;
  List<String> get facultades => _facultades;

  /// Verifica si el usuario tiene permisos de administrador
  Future<bool> verificarPermisos(String usuarioId) async {
    try {
      return await _servicio.esAdministrador(usuarioId);
    } catch (e) {
      return false;
    }
  }

  /// Carga la lista de estudiantes
  Future<void> cargarEstudiantes() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _estudiantes = await _servicio.obtenerEstudiantes(filtros: _filtros);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar estudiantes: ${e.toString()}';
      _estudiantes = [];
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Carga estadísticas globales
  Future<void> cargarEstadisticasGlobales({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _estadisticasGlobales = await _servicio.obtenerEstadisticasGlobales(
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
      _error = null;
    } catch (e) {
      _error = 'Error al cargar estadísticas: ${e.toString()}';
      _estadisticasGlobales = null;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Carga listas para filtros
  Future<void> cargarListasFiltros() async {
    try {
      _carreras = await _servicio.obtenerCarreras();
      _facultades = await _servicio.obtenerFacultades();
      notifyListeners();
    } catch (e) {
      // Silencioso, no es crítico
    }
  }

  /// Selecciona un estudiante y carga sus datos
  Future<void> seleccionarEstudiante(EstudianteInfo estudiante) async {
    _estudianteSeleccionado = estudiante;
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      // Cargar estadísticas del estudiante
      _estadisticasEstudiante =
          await _servicio.obtenerEstadisticasEstudiante(estudiante.uid);

      // Cargar observaciones
      _observaciones = await _servicio.obtenerObservaciones(estudiante.uid);

      // Cargar citas
      _citas = await _servicio.obtenerCitasEstudiante(estudiante.uid);

      _error = null;
    } catch (e) {
      _error = 'Error al cargar datos del estudiante: ${e.toString()}';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Limpia la selección del estudiante
  void limpiarSeleccion() {
    _estudianteSeleccionado = null;
    _estadisticasEstudiante = null;
    _observaciones = [];
    _citas = [];
    notifyListeners();
  }

  /// Aplica filtros
  void aplicarFiltros(FiltrosAdministracion nuevosFiltros) {
    _filtros = nuevosFiltros;
    cargarEstudiantes();
  }

  /// Limpia filtros
  void limpiarFiltros() {
    _filtros = const FiltrosAdministracion();
    cargarEstudiantes();
  }

  /// Actualiza un filtro específico
  void actualizarFiltro({
    String? busqueda,
    NivelAnsiedad? nivelAnsiedad,
    String? carrera,
    String? facultad,
    bool? requiereAtencion,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    OrdenEstudiantes? orden,
  }) {
    _filtros = _filtros.copyWith(
      busqueda: busqueda,
      nivelAnsiedad: nivelAnsiedad,
      carrera: carrera,
      facultad: facultad,
      requiereAtencion: requiereAtencion,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      orden: orden,
    );
    cargarEstudiantes();
  }

  /// Guarda una observación
  Future<bool> guardarObservacion({
    required String estudianteId,
    required String psicologoId,
    required String psicologoNombre,
    required String texto,
    String? testRelacionadoId,
  }) async {
    try {
      final observacion = Observacion(
        id: '',
        estudianteId: estudianteId,
        psicologoId: psicologoId,
        psicologoNombre: psicologoNombre,
        texto: texto,
        fechaCreacion: DateTime.now(),
        testRelacionadoId: testRelacionadoId,
      );

      await _servicio.guardarObservacion(observacion);

      // Recargar observaciones si es el estudiante seleccionado
      if (_estudianteSeleccionado?.uid == estudianteId) {
        _observaciones = await _servicio.obtenerObservaciones(estudianteId);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Error al guardar observación: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Actualiza una observación
  Future<bool> actualizarObservacion(
    String observacionId,
    String nuevoTexto,
  ) async {
    try {
      await _servicio.actualizarObservacion(observacionId, nuevoTexto);

      // Recargar observaciones
      if (_estudianteSeleccionado != null) {
        _observaciones =
            await _servicio.obtenerObservaciones(_estudianteSeleccionado!.uid);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Error al actualizar observación: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Elimina una observación
  Future<bool> eliminarObservacion(String observacionId) async {
    try {
      await _servicio.eliminarObservacion(observacionId);

      // Recargar observaciones
      if (_estudianteSeleccionado != null) {
        _observaciones =
            await _servicio.obtenerObservaciones(_estudianteSeleccionado!.uid);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Error al eliminar observación: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Programa una cita
  Future<bool> programarCita({
    required String estudianteId,
    required String estudianteNombre,
    required String psicologoId,
    required String psicologoNombre,
    required DateTime fechaCita,
    String? motivo,
    String? observaciones,
  }) async {
    try {
      final cita = CitaProgramada(
        id: '',
        estudianteId: estudianteId,
        estudianteNombre: estudianteNombre,
        psicologoId: psicologoId,
        psicologoNombre: psicologoNombre,
        fechaCita: fechaCita,
        motivo: motivo,
        observaciones: observaciones,
        estado: EstadoCita.programada,
        fechaCreacion: DateTime.now(),
      );

      await _servicio.programarCita(cita);

      // Recargar citas si es el estudiante seleccionado
      if (_estudianteSeleccionado?.uid == estudianteId) {
        _citas = await _servicio.obtenerCitasEstudiante(estudianteId);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Error al programar cita: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Actualiza el estado de una cita
  Future<bool> actualizarEstadoCita(
    String citaId,
    EstadoCita nuevoEstado,
  ) async {
    try {
      await _servicio.actualizarEstadoCita(citaId, nuevoEstado);

      // Recargar citas
      if (_estudianteSeleccionado != null) {
        _citas =
            await _servicio.obtenerCitasEstudiante(_estudianteSeleccionado!.uid);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Error al actualizar cita: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Busca estudiantes
  void buscar(String termino) {
    actualizarFiltro(busqueda: termino);
  }

  /// Limpia el error
  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}
