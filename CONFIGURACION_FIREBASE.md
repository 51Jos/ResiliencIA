# Configuración de Firebase - Sistema de Psicología UCSS

## Estado Actual ✅

Firebase está **HABILITADO** y listo para usar. Sin embargo, necesitas configurar las credenciales de Firebase para que funcione correctamente.

## Archivos Configurados

### 1. Main.dart ✅
- Firebase inicializado en el arranque de la aplicación
- Archivo: `lib/main.dart`

### 2. Auth Servicio ✅
- Firebase Auth habilitado
- Cloud Firestore habilitado
- Métodos de autenticación activos:
  - `iniciarSesion()` - Login con email/password
  - `registrarUsuarioDirecto()` - Registro directo con datos completos
  - `cerrarSesion()` - Cierre de sesión
- Archivo: `lib/features/autenticacion/servicios/auth_servicio.dart`

### 3. Modal Reutilizable ✅
- Modal para mensajes de éxito/error/advertencia/info
- Archivo: `lib/compartidos/componentes/modales/modal_mensaje.dart`
- Uso:
  ```dart
  await ModalMensaje.mostrarExito(
    context: context,
    titulo: 'Éxito',
    mensaje: 'Operación completada',
  );
  ```

### 4. Pantalla de Prueba (Home) ✅
- Pantalla simple para probar el login
- Muestra información del usuario autenticado
- Permite cerrar sesión
- Ver datos de Firestore
- Archivo: `lib/features/home/home_vista.dart`

### 5. Rutas Actualizadas ✅
- `/login` - Pantalla de inicio de sesión
- `/registro` - Pantalla de registro
- `/home` - Pantalla de prueba (después del login)

## Pasos para Configurar Firebase

### 1. Crear Proyecto en Firebase Console

1. Ve a: https://console.firebase.google.com/
2. Click en "Agregar proyecto"
3. Nombre del proyecto: `ucss-psicologia` (o el que prefieras)
4. Sigue los pasos del asistente

### 2. Configurar Firebase para tu Plataforma

#### Para Web:
1. En Firebase Console, click en el ícono de Web (</>)
2. Registra tu app
3. Copia las credenciales que te proporciona
4. Pega en `lib/nucleo/configuracion_firebase.dart` en la sección Web:
   ```dart
   apiKey: 'TU_API_KEY_WEB',
   appId: 'TU_APP_ID_WEB',
   messagingSenderId: 'TU_SENDER_ID',
   projectId: 'TU_PROJECT_ID',
   // etc...
   ```

#### Para Android:
1. En Firebase Console, click en el ícono de Android
2. Registra tu app (paquete: com.ejemplo.tuapp)
3. Descarga el archivo `google-services.json`
4. Coloca el archivo en: `android/app/google-services.json`
5. Actualiza credenciales en `lib/nucleo/configuracion_firebase.dart` sección Android

### 3. Habilitar Autenticación en Firebase

1. En Firebase Console, ve a **Authentication**
2. Click en "Comenzar"
3. Ve a la pestaña "Sign-in method"
4. Habilita **Email/Password**
5. Click en "Guardar"

### 4. Habilitar Cloud Firestore

1. En Firebase Console, ve a **Firestore Database**
2. Click en "Crear base de datos"
3. Selecciona el modo (recomendado: modo de prueba para desarrollo)
4. Elige la ubicación (recomendado: us-central)
5. Click en "Habilitar"

### 5. Configurar Reglas de Seguridad (Opcional pero recomendado)

En Firestore, ve a "Reglas" y usa esto para desarrollo:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir lectura/escritura solo a usuarios autenticados
    match /usuarios/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Otras colecciones...
  }
}
```

## Estructura de Datos en Firestore

Cuando un usuario se registra, se guarda en Firestore con esta estructura:

**Colección:** `usuarios`
**Documento ID:** UID del usuario

```json
{
  "uid": "abc123...",
  "codigo": "2024001234",
  "email": "estudiante@ucss.pe",
  "nombres": "Juan",
  "apellidos": "Pérez García",
  "nombreCompleto": "Juan Pérez García",
  "facultad": "Ciencias de la Salud",
  "carrera": "Psicología",
  "filial": "Nueva Cajamarca",
  "rol": "estudiante",
  "fechaRegistro": Timestamp,
  "emailVerificado": false
}
```

## Probar la Aplicación

### 1. Registro de Usuario
1. Ejecuta la app: `flutter run`
2. Ve a "Crear cuenta"
3. Llena el formulario con:
   - Nombres: Tu nombre
   - Apellidos: Tus apellidos
   - Correo: ejemplo@ucss.pe
   - Facultad: Selecciona una
   - Carrera: Selecciona una
   - Filial: Nueva Cajamarca (fijo)
   - Contraseña: mínimo 6 caracteres
4. Click en "Crear Cuenta"
5. Deberías ver un modal de éxito

### 2. Inicio de Sesión
1. Ingresa el correo: ejemplo@ucss.pe
2. Ingresa la contraseña
3. Click en "Iniciar Sesión"
4. Deberías ser redirigido a la pantalla Home

### 3. Verificar en Firebase Console
1. Ve a Authentication > Users
2. Deberías ver el usuario recién creado
3. Ve a Firestore Database > usuarios
4. Deberías ver el documento con todos los datos

## Problemas Comunes

### Error: "Firebase not initialized"
**Solución:** Verifica que las credenciales en `configuracion_firebase.dart` estén correctas

### Error: "auth/email-already-in-use"
**Solución:** El correo ya está registrado. Usa otro correo o elimina el usuario desde Firebase Console

### Error: "Permission denied"
**Solución:** Revisa las reglas de seguridad de Firestore

### La app no compila
**Solución:**
1. Ejecuta: `flutter clean`
2. Ejecuta: `flutter pub get`
3. Ejecuta: `flutter run`

## Siguiente Paso

Una vez configuradas las credenciales de Firebase, la aplicación estará completamente funcional y podrás:
- ✅ Registrar usuarios
- ✅ Iniciar sesión
- ✅ Guardar datos en Firestore
- ✅ Cerrar sesión
- ✅ Ver información del usuario

¡Todo está listo para que lo pruebes! 🚀
