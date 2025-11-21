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
      print('⚠️ Las tareas programadas ya están en ejecución');
      return;
    }

    print('🚀 Iniciando tareas programadas...');

    // Ejecutar inmediatamente al iniciar
    _ejecutarTareas();

    // Programar ejecución cada 12 horas
    _timer = Timer.periodic(const Duration(hours: 12), (_) {
      _ejecutarTareas();
    });

    print('✅ Tareas programadas iniciadas (cada 12 horas)');
  }

  /// Detiene la ejecución de tareas programadas
  void detener() {
    _timer?.cancel();
    _timer = null;
    print('🛑 Tareas programadas detenidas');
  }

  /// Ejecuta todas las tareas programadas
  Future<void> _ejecutarTareas() async {
    if (_ejecutando) {
      print('⏳ Ya hay tareas en ejecución, omitiendo...');
      return;
    }

    _ejecutando = true;

    try {
      print('⏰ Ejecutando tareas programadas...');

      // Tarea 1: Verificar y crear recordatorios de tests
      await _recordatoriosServicio.verificarYCrearRecordatorios();

      // Tarea 2: Limpiar recordatorios antiguos
      await _recordatoriosServicio.limpiarRecordatoriosAntiguos();

      print('✅ Tareas programadas completadas exitosamente');
    } catch (e) {
      print('❌ Error al ejecutar tareas programadas: $e');
    } finally {
      _ejecutando = false;
    }
  }

  /// Ejecuta las tareas manualmente (útil para testing o admin)
  Future<void> ejecutarManualmente() async {
    print('🔧 Ejecución manual de tareas programadas solicitada');
    await _ejecutarTareas();
  }
}
