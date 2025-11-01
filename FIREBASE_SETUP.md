# Configuración de Firebase

Este documento explica cómo configurar Firebase para el proyecto del Sistema de Psicología UCSS.

## Paso 1: Crear Proyecto en Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Agregar proyecto"
3. Nombre del proyecto: `sistema-psicologia-ucss` (o el que prefieras)
4. Sigue los pasos del asistente

## Paso 2: Configurar Firebase Authentication

1. En la consola de Firebase, ve a **Authentication**
2. Haz clic en "Comenzar"
3. Ve a la pestaña **Sign-in method**
4. Habilita **Correo electrónico/Contraseña**
5. Guarda los cambios

## Paso 3: Configurar Cloud Firestore

1. En la consola de Firebase, ve a **Firestore Database**
2. Haz clic en "Crear base de datos"
3. Selecciona **Modo de prueba** (por ahora)
4. Elige la ubicación: `us-central` o la más cercana
5. Haz clic en "Habilitar"

### Reglas de Seguridad (Opcional - para producción)

Cuando estés listo para producción, actualiza las reglas en Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios solo pueden leer/escribir sus propios datos
    match /usuarios/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Solo usuarios autenticados pueden leer datos de facultades y programas
    match /facultades/{document=**} {
      allow read: if request.auth != null;
      allow write: if false; // Solo admins desde consola
    }

    // Citas - usuarios pueden crear y ver sus propias citas
    match /citas/{citaId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null &&
        resource.data.userId == request.auth.uid;
    }

    // Atenciones - solo psicólogos pueden crear/editar
    match /atenciones/{atencionId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
        get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol == 'psicologo';
    }
  }
}
```

## Paso 4: Agregar tu aplicación a Firebase

### Para Web

1. En la consola de Firebase, haz clic en el ícono **</>** (Web)
2. Registra tu app con un nombre
3. Copia las credenciales de configuración
4. Abre el archivo `lib/nucleo/configuracion_firebase.dart`
5. Reemplaza los valores en la sección Web:

```dart
if (kIsWeb) {
  return const FirebaseOptions(
    apiKey: 'TU_API_KEY_WEB',           // Reemplaza con tu apiKey
    appId: 'TU_APP_ID_WEB',             // Reemplaza con tu appId
    messagingSenderId: 'TU_SENDER_ID',   // Reemplaza con tu messagingSenderId
    projectId: 'TU_PROJECT_ID',          // Reemplaza con tu projectId
    authDomain: 'TU_PROJECT_ID.firebaseapp.com',
    storageBucket: 'TU_PROJECT_ID.appspot.com',
  );
}
```

### Para Android (Opcional)

1. En la consola de Firebase, haz clic en el ícono de Android
2. Registra tu app con el package name: `com.ucss.sistema_psicologia`
3. Descarga el archivo `google-services.json`
4. Colócalo en: `android/app/google-services.json`
5. Actualiza las credenciales en `configuracion_firebase.dart`

### Para iOS (Opcional)

1. En la consola de Firebase, haz clic en el ícono de iOS
2. Registra tu app con el bundle ID: `com.ucss.sistemaPsicologia`
3. Descarga el archivo `GoogleService-Info.plist`
4. Colócalo en: `ios/Runner/GoogleService-Info.plist`
5. Actualiza las credenciales en `configuracion_firebase.dart`

## Paso 5: Crear Colecciones Iniciales en Firestore

Puedes crear estas colecciones manualmente desde la consola de Firebase:

### Colección: `facultades`

Documento de ejemplo:
```json
{
  "id": "facultad_1",
  "nombre": "Facultad de Ingeniería",
  "activo": true
}
```

### Colección: `programas`

Documento de ejemplo:
```json
{
  "id": "programa_1",
  "nombre": "Ingeniería de Sistemas",
  "facultadId": "facultad_1",
  "activo": true
}
```

### Colección: `usuarios`

Se crea automáticamente cuando los usuarios se registran.

## Paso 6: Probar la Aplicación

1. Ejecuta la aplicación: `flutter run`
2. Intenta crear una cuenta con un correo @ucss.pe
3. Verifica que el usuario se haya creado en Firebase Authentication
4. Verifica que los datos del usuario aparezcan en Firestore

## Notas de Seguridad

⚠️ **IMPORTANTE**:

1. **NO subas** el archivo `configuracion_firebase.dart` con credenciales reales a repositorios públicos
2. Considera usar variables de entorno para las credenciales
3. Actualiza las reglas de seguridad de Firestore antes de producción
4. Habilita la verificación de email para mayor seguridad
5. Configura dominios autorizados en Firebase Authentication

## Solución de Problemas

### Error: "Firebase not initialized"
- Verifica que hayas llamado a `ConfiguracionFirebase.inicializar()` en `main.dart`
- Asegúrate de que las credenciales sean correctas

### Error: "Email already in use"
- El email ya está registrado. Usa otro email o inicia sesión

### Error: "Wrong password"
- La contraseña es incorrecta

### No recibo el email de verificación
- Verifica la carpeta de spam
- Verifica que el dominio esté autorizado en Firebase Console

## Recursos

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
