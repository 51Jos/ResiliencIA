import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../compartidos/tema/colores_app.dart';
/// Servicio para gestionar notificaciones push locales
/// Se usa para alertar al psicólogo cuando hay un test grave/severo
class NotificacionesLocalesServicio {
  static final NotificacionesLocalesServicio _instancia = NotificacionesLocalesServicio._internal();
  factory NotificacionesLocalesServicio() => _instancia;
  NotificacionesLocalesServicio._internal();

  final FlutterLocalNotificationsPlugin _notificaciones = FlutterLocalNotificationsPlugin();
  bool _inicializado = false;

  /// Inicializa el servicio de notificaciones locales
  Future<void> inicializar() async {
    if (_inicializado) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificaciones.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Solicitar permisos en Android 13+
    await _solicitarPermisos();

    _inicializado = true;
  }

  /// Solicita permisos de notificaciones (Android 13+)
  Future<void> _solicitarPermisos() async {
    final androidPlugin = _notificaciones.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _notificaciones.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Callback cuando el usuario toca una notificación
  void _onNotificationTap(NotificationResponse response) {
    // Aquí podrías navegar a la vista de notificaciones
    // o a los detalles del estudiante
  }

  /// Muestra una notificación de ansiedad grave/severa
  Future<void> mostrarAlertaAnsiedadGrave({
    required String estudianteNombre,
    required String nivelAnsiedad,
    required int puntaje,
  }) async {
    if (!_inicializado) {
      await inicializar();
    }

    const androidDetails = AndroidNotificationDetails(
      'ansiedad_grave',
      'Alertas de Ansiedad Grave',
      channelDescription: 'Notificaciones cuando un estudiante presenta ansiedad grave o severa',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      color: ColoresApp.error, // Rojo para urgencia
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      badgeNumber: 1,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final titulo = nivelAnsiedad == 'severa'
        ? '🚨 Nivel de Ansiedad SEVERO'
        : '⚠️ Nivel de Ansiedad GRAVE';

    final mensaje = '$estudianteNombre ha completado un test con nivel de ansiedad $nivelAnsiedad ($puntaje/63 pts). Se requiere atención inmediata.';

    await _notificaciones.show(
      DateTime.now().millisecondsSinceEpoch % 100000, // ID único
      titulo,
      mensaje,
      details,
      payload: 'ansiedad_grave', // Datos para el callback
    );
  }

  /// Muestra una notificación de recordatorio de test
  Future<void> mostrarRecordatorioTest({
    required String estudianteNombre,
  }) async {
    if (!_inicializado) {
      await inicializar();
    }

    const androidDetails = AndroidNotificationDetails(
      'recordatorio_test',
      'Recordatorios de Test',
      channelDescription: 'Recordatorios para realizar el test de ansiedad mensual',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      color: ColoresApp.primario,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      badgeNumber: 1,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    const titulo = '📅 Recordatorio: Test de Ansiedad';
    final mensaje = 'Hola $estudianteNombre, es momento de realizar tu test de ansiedad mensual.';

    await _notificaciones.show(
      DateTime.now().millisecondsSinceEpoch % 100000, // ID único
      titulo,
      mensaje,
      details,
      payload: 'recordatorio_test',
    );

  }

  /// Cancela todas las notificaciones
  Future<void> cancelarTodas() async {
    await _notificaciones.cancelAll();
  }

  /// Cancela una notificación específica
  Future<void> cancelar(int id) async {
    await _notificaciones.cancel(id);
  }
}
