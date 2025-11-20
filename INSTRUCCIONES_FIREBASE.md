# 🔥 Instrucciones para Configurar Firebase

## Problema Actual
Las credenciales de Firebase fueron excluidas del repositorio por seguridad (`.gitignore`), por lo que necesitas configurarlas localmente.

## 📋 Pasos para Configurar Firebase

### 1. Descargar google-services.json (Android)

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Abre tu proyecto: **resiliencia-85ff4**
3. Haz clic en el ícono de engranaje ⚙️ → **"Configuración del proyecto"**
4. Baja hasta **"Tus apps"**
5. Encuentra tu app Android: **com.example.resiliencia**
6. Haz clic en **"google-services.json"** para descargarlo
7. Coloca el archivo en: `android/app/google-services.json`

### 2. Actualizar configuracion_firebase.dart

Abre el archivo: `lib/nucleo/configuracion_firebase.dart`

#### Para obtener las credenciales de Android:

Del archivo `google-services.json` que descargaste, copia:

```dart
// Configuración para Android
return const FirebaseOptions(
  apiKey: '<current_key de google-services.json>',
  appId: '<mobilesdk_app_id de google-services.json>',
  messagingSenderId: '<project_number de google-services.json>',
  projectId: 'resiliencia-85ff4',
  storageBucket: 'resiliencia-85ff4.firebasestorage.app',
);
```

**Ejemplo de dónde encontrar cada valor en google-services.json:**

```json
{
  "project_info": {
    "project_number": "645906943963",  // ← messagingSenderId
    "project_id": "resiliencia-85ff4",  // ← projectId
    "storage_bucket": "resiliencia-85ff4.firebasestorage.app"  // ← storageBucket
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:645906943963:android:5cf2b35bc89a8c9a33a0b3"  // ← appId
      },
      "api_key": [
        {
          "current_key": "AIzaSyDIMUQoKjvqcthyAuI3FBKyGte4JSDDkZE"  // ← apiKey
        }
      ]
    }
  ]
}
```

#### Para Web (opcional):

1. En Firebase Console, ve a **"Configuración del proyecto"**
2. En **"Tus apps"**, agrega una app **Web** (si no existe)
3. Copia las credenciales del SDK de Firebase y pégalas en el bloque `if (kIsWeb)`

### 3. Habilitar Firebase Authentication

**⚠️ MUY IMPORTANTE:**

1. En Firebase Console, ve a **"Authentication"**
2. Haz clic en **"Comenzar"** (si es la primera vez)
3. Ve a la pestaña **"Sign-in method"**
4. Habilita **"Email/Password"** (debe estar en verde ✅)
5. Guarda los cambios

### 4. Configurar Firestore Database

1. En Firebase Console, ve a **"Firestore Database"**
2. Haz clic en **"Crear base de datos"**
3. Selecciona **"Modo de prueba"** (para desarrollo)
4. Elige la ubicación: **us-east1** (o la más cercana)
5. Haz clic en **"Habilitar"**

### 5. Limpiar y reconstruir

```bash
flutter clean
flutter pub get
flutter run
```

## 🔒 Seguridad

**NO SUBAS** estos archivos a GitHub:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/nucleo/configuracion_firebase.dart` (si tiene credenciales reales)

Estos archivos ya están en `.gitignore` para proteger tus credenciales.

## ✅ Verificar que todo funciona

1. Ejecuta la app: `flutter run`
2. Intenta iniciar sesión con tu cuenta de psicólogo
3. Deberías poder iniciar sesión sin el error "api-key-not-valid"

## 🆘 Si sigue sin funcionar

Verifica en Firebase Console:
1. **Authentication** está habilitado con Email/Password ✅
2. **Firestore Database** está creado ✅
3. Las **API Keys** no tienen restricciones en Google Cloud Console
4. Tu cuenta de psicólogo existe en **Authentication > Users**

---

**Proyecto Firebase:** resiliencia-85ff4
**Package Name:** com.example.resiliencia
