import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../../administracion/modelos/estudiante_info.dart';
import '../../administracion/vistas/perfil_estudiante_vista.dart';

/// Servicio para gestionar notificaciones push locales
/// Se usa para alertar al psicólogo cuando hay un test grave/severo
class NotificacionesLocalesServicio {
  static final NotificacionesLocalesServicio _instancia = NotificacionesLocalesServicio._internal();
  factory NotificacionesLocalesServicio() => _instancia;
  NotificacionesLocalesServicio._internal();

  final FlutterLocalNotificationsPlugin _notificaciones = FlutterLocalNotificationsPlugin();
  bool _inicializado = false;

  // NavigatorKey para poder navegar desde el servicio
  GlobalKey<NavigatorState>? _navigatorKey;
  String? _psicologoId;
  String? _psicologoNombre;

  /// Configura el NavigatorKey y datos del psicólogo
  void configurarNavegacion({
    required GlobalKey<NavigatorState> navigatorKey,
    required String psicologoId,
    required String psicologoNombre,
  }) {
    _navigatorKey = navigatorKey;
    _psicologoId = psicologoId;
    _psicologoNombre = psicologoNombre;
  }

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
  void _onNotificationTap(NotificationResponse response) async {
    // Verificar que tengamos el payload con el estudianteId
    if (response.payload == null || response.payload!.isEmpty) return;

    // Verificar que tengamos el NavigatorKey configurado
    if (_navigatorKey == null || _navigatorKey!.currentContext == null) {
      print('⚠️ NavigatorKey no configurado o sin contexto');
      return;
    }

    final BuildContext? context = _navigatorKey!.currentContext;
    if (context == null) return;

    try {
      final estudianteId = response.payload!;

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Obtener datos del estudiante desde Firestore
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(estudianteId)
          .get();

      // Cerrar loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final estudiante = EstudianteInfo(
          uid: docSnapshot.id,
          codigo: data['codigo'] as String? ?? '',
          email: data['email'] as String,
          nombres: data['nombres'] as String? ?? '',
          apellidos: data['apellidos'] as String? ?? '',
          nombreCompleto: data['nombreCompleto'] as String? ?? '',
          facultad: data['facultad'] as String?,
          programa: data['carrera'] as String?,
          rol: data['rol'] as String? ?? 'estudiante',
          fechaRegistro: (data['fechaRegistro'] as Timestamp).toDate(),
          ultimoNivelAnsiedad: data['ultimoNivelAnsiedad'] != null
              ? _parseNivelAnsiedad(data['ultimoNivelAnsiedad'])
              : null,
          fechaUltimoTest: data['fechaUltimoTest'] != null
              ? (data['fechaUltimoTest'] as Timestamp).toDate()
              : null,
          puntajeUltimoTest: data['puntajeUltimoTest'] as int?,
          requiereAtencion: data['requiereAtencion'] as bool? ?? false,
          totalTests: data['totalTests'] as int? ?? 0,
        );

        // Navegar al perfil del estudiante
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PerfilEstudianteVista(
                estudiante: estudiante,
                psicologoId: _psicologoId ?? '',
                psicologoNombre: _psicologoNombre ?? 'Psicólogo',
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo encontrar la información del estudiante'),
              backgroundColor: ColoresApp.error,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error al navegar desde notificación: $e');
      if (context.mounted) {
        // Cerrar loading si está abierto
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir perfil: $e'),
            backgroundColor: ColoresApp.error,
          ),
        );
      }
    }
  }

  /// Helper para parsear el nivel de ansiedad
  dynamic _parseNivelAnsiedad(dynamic value) {
    try {
      // Los valores posibles del enum NivelAnsiedad
      final niveles = ['minima', 'leve', 'moderada', 'moderadaGrave', 'severa'];
      if (niveles.contains(value)) {
        // Retornar el valor sin conversión ya que EstudianteInfo.fromFirestore lo maneja
        return value;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Muestra una notificación de ansiedad grave/severa
  Future<void> mostrarAlertaAnsiedadGrave({
    required String estudianteNombre,
    required String nivelAnsiedad,
    required int puntaje,
    String? estudianteId,
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
      payload: estudianteId, // ID del estudiante para navegar a su perfil
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
