import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Configuración de Firebase para la aplicación
class ConfiguracionFirebase {
  // Constructor privado
  ConfiguracionFirebase._();

  /// Inicializa Firebase
  static Future<void> inicializar() async {
    // Verifica si Firebase ya está inicializado
    try {
      await Firebase.initializeApp(
        options: _obtenerOpciones(),
      );
    } catch (e) {
      // Si ya está inicializado, no hace nada
      if (e.toString().contains('duplicate-app')) {
        // Firebase ya inicializado, continuar
        return;
      }
      // Si es otro error, lo lanza
      rethrow;
    }
  }

  /// Obtiene las opciones de Firebase según la plataforma
  static FirebaseOptions _obtenerOpciones() {
    if (kIsWeb) {
      // Configuración para Web
      return const FirebaseOptions(
        apiKey: 'TU_API_KEY_WEB',
        appId: 'TU_APP_ID_WEB',
        messagingSenderId: 'TU_SENDER_ID',
        projectId: 'TU_PROJECT_ID',
        authDomain: 'TU_PROJECT_ID.firebaseapp.com',
        storageBucket: 'TU_PROJECT_ID.appspot.com',
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Configuración para Android
      return const FirebaseOptions(
        apiKey: 'TU_API_KEY_ANDROID',
        appId: 'TU_APP_ID_ANDROID',
        messagingSenderId: 'TU_SENDER_ID',
        projectId: 'TU_PROJECT_ID',
        storageBucket: 'TU_PROJECT_ID.appspot.com',
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Configuración para iOS
      return const FirebaseOptions(
        apiKey: 'TU_API_KEY_IOS',
        appId: 'TU_APP_ID_IOS',
        messagingSenderId: 'TU_SENDER_ID',
        projectId: 'TU_PROJECT_ID',
        storageBucket: 'TU_PROJECT_ID.appspot.com',
        iosBundleId: 'com.tuempresa.tuapp',
      );
    }

    throw UnsupportedError('Plataforma no soportada');
  }
}

/// INSTRUCCIONES PARA CONFIGURAR FIREBASE:
///
/// 1. Ve a la consola de Firebase: https://console.firebase.google.com/
/// 2. Crea un nuevo proyecto o selecciona uno existente
/// 3. Añade tu aplicación (Web, Android, iOS)
/// 4. Copia las credenciales de cada plataforma:
///    - Web: SDK configuration (apiKey, appId, etc.)
///    - Android: google-services.json
///    - iOS: GoogleService-Info.plist
/// 5. Reemplaza las constantes 'TU_*' con tus valores reales
/// 6. Activa Firebase Authentication en la consola:
///    - Ve a Authentication > Sign-in method
///    - Habilita Email/Password
/// 7. Activa Cloud Firestore para almacenar datos:
///    - Ve a Firestore Database
///    - Crea una base de datos
///
/// IMPORTANTE: No subas este archivo con credenciales reales a repositorios públicos.
/// Considera usar variables de entorno o archivos de configuración externos.
