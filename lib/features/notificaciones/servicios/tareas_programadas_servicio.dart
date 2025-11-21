import 'dart:async';
import 'recordatorios_servicio.dart';

/// Servicio para ejecutar tareas programadas (background jobs)
class TareasProgramadasServicio {
  static TareasProgramadasServicio? _instance;
  static TareasProgramadasServicio get instance {
    _instance ??= TareasProgramadasServicio._();
    return _instance!;
  }

  TareasProgramadasServicio._();

  final RecordatoriosServicio _recordatoriosServicio = RecordatoriosServicio();
  Timer? _timer;
  bool _ejecutando = false;

  /// Inicia la ejecución periódica de tareas programadas
  /// Se ejecuta cada 12 horas
  void iniciar() {
    if (_timer != null) {
      return;
    }

    
    // Ejecutar inmediatamente al iniciar
    _ejecutarTareas();

    // Programar ejecución cada 12 horas
    _timer = Timer.periodic(const Duration(hours: 12), (_) {
      _ejecutarTareas();
    });

    }

  /// Detiene la ejecución de tareas programadas
  void detener() {
    _timer?.cancel();
    _timer = null;
    // ignore: avoid_print
    print('🛑 Tareas programadas detenidas');
  }

  /// Ejecuta todas las tareas programadas
  Future<void> _ejecutarTareas() async {
    if (_ejecutando) {
      return;
    }

    _ejecutando = true;

    try {
      
      // Tarea 1: Verificar y crear recordatorios de tests
      await _recordatoriosServicio.verificarYCrearRecordatorios();

      // Tarea 2: Limpiar recordatorios antiguos
      await _recordatoriosServicio.limpiarRecordatoriosAntiguos();
    } finally {
      _ejecutando = false;
    }
  }

  /// Ejecuta las tareas manualmente (útil para testing o admin)
  Future<void> ejecutarManualmente() async {
    await _ejecutarTareas();
  }
}
