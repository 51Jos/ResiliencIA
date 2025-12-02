import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'compartidos/tema/tema_app.dart';
import 'features/autenticacion/controladores/auth_controlador.dart';
import 'features/administracion/controladores/administracion_controlador.dart';
import 'features/notificaciones/servicios/notificaciones_locales_servicio.dart';
import 'rutas/rutas_app.dart';
import 'nucleo/configuracion_firebase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfiguracionFirebase.inicializar();

  // Inicializar notificaciones push locales
  await NotificacionesLocalesServicio().inicializar();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthControlador(),
        ),
        ChangeNotifierProvider(
          create: (_) => AdministracionControlador(),
        ),
      ],
      child: MaterialApp(
        title: 'Sistema de Psicología - UCSS',
        debugShowCheckedModeBanner: false,
        theme: TemaApp.temaClaro,
        initialRoute: RutasApp.rutaInicial,
        routes: RutasApp.obtenerRutas(),
        onUnknownRoute: RutasApp.onUnknownRoute,
      ),
    );
  }
}
