import 'package:flutter/material.dart';
import '../features/splash/splash_vista.dart';
import '../features/autenticacion/vistas/login_vista.dart';
import '../features/autenticacion/vistas/registro_vista.dart';
import '../features/home/home_vista.dart';
import '../features/perfil/vistas/perfil_estudiante.dart';

/// Configuración de rutas de la aplicación
class RutasApp {
  // Constructor privado
  RutasApp._();

  // Nombres de rutas
  static const String splash = '/';
  static const String login = '/login';
  static const String registro = '/registro';
  static const String home = '/home';
  static const String perfil = '/perfil';

  // Rutas de administración (protegidas)
  static const String administracionPanel = '/admin/panel';
  static const String administracionEstudiantes = '/admin/estudiantes';
  static const String administracionEstadisticas = '/admin/estadisticas';

  /// Mapa de rutas
  static Map<String, WidgetBuilder> obtenerRutas() {
    return {
      splash: (context) => const SplashVista(),
      login: (context) => const LoginVista(),
      registro: (context) => const RegistroVista(),
      home: (context) => const HomeVista(),
      perfil: (context) => const PerfilEstudiante(),
    };
  }

  /// Ruta inicial
  static String get rutaInicial => splash;

  /// Manejo de rutas desconocidas
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(
          child: Text('Ruta no encontrada: ${settings.name}'),
        ),
      ),
    );
  }
}
