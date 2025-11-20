# 🔥 CREAR PSICÓLOGO EN FIRESTORE

## Problema
Tu psicólogo existe en **Firebase Authentication** pero NO en **Firestore Database**.
Por eso la app se congela al intentar leer sus datos.

## ✅ Solución: Crear documento en Firestore

### Opción 1: Desde Firebase Console (RÁPIDO)

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Abre tu proyecto: **resiliencia-85ff4**
3. Ve a **Firestore Database** en el menú lateral
4. Haz clic en **"+ Iniciar colección"** (si es la primera vez) o busca la colección **"usuarios"**
5. Si es nueva colección, ponle el ID: `usuarios`
6. Haz clic en **"Agregar documento"**
7. **IMPORTANTE:** En "ID de documento" pon el **UID del usuario** que ves en Authentication
8. Agrega estos campos:

```
uid: (el mismo UID del usuario de Authentication)
email: (tu correo, ej: psicologo@ucss.edu.pe)
rol: psicologo
nombres: (tu nombre, ej: Juan)
apellidos: (tu apellido, ej: Pérez)
nombreCompleto: (nombre completo, ej: Juan Pérez)
fechaRegistro: (timestamp - usa el botón de reloj)
emailVerificado: false
```

9. Guarda el documento

### Opción 2: Ejecutar script en la consola del navegador

1. Abre tu app en el navegador (Chrome/Edge)
2. Presiona **F12** para abrir DevTools
3. Ve a la pestaña **Console**
4. Copia y pega este código (reemplaza los valores):

```javascript
// REEMPLAZA ESTOS VALORES
const UID = 'EL_UID_DE_TU_USUARIO'; // Cópialo de Firebase Auth
const EMAIL = 'psicologo@ucss.edu.pe';
const NOMBRES = 'Tu Nombre';
const APELLIDOS = 'Tu Apellido';

// Ejecuta esto
firebase.firestore().collection('usuarios').doc(UID).set({
  uid: UID,
  email: EMAIL,
  rol: 'psicologo',
  nombres: NOMBRES,
  apellidos: APELLIDOS,
  nombreCompleto: `${NOMBRES} ${APELLIDOS}`,
  fechaRegistro: firebase.firestore.FieldValue.serverTimestamp(),
  emailVerificado: false
}).then(() => {
  console.log('✅ Psicólogo creado en Firestore!');
}).catch(error => {
  console.error('❌ Error:', error);
});
```

5. Presiona Enter
6. Deberías ver: `✅ Psicólogo creado en Firestore!`

### Opción 3: Usar la app para registrarte (TEMPORAL)

Si quieres, puedo crear temporalmente una vista para que registres al psicólogo desde la app.

## 🔍 Verificar que funcionó

1. Ve a Firebase Console → Firestore Database
2. Busca la colección `usuarios`
3. Deberías ver tu documento con el UID del psicólogo
4. Verifica que tenga `rol: psicologo` y `email: xxx@ucss.edu.pe`

## 🚀 Después de crear el documento

1. Recarga la app con `flutter run` o `Ctrl+C` y volver a ejecutar
2. Intenta iniciar sesión nuevamente
3. Ahora SÍ debería redirigirte al panel de administración

---

## ⚠️ Campos OBLIGATORIOS en Firestore:

```
uid: string (el UID de Firebase Auth)
email: string (debe terminar en @ucss.edu.pe)
rol: "psicologo" (EXACTAMENTE así, en minúscula)
nombres: string
apellidos: string
nombreCompleto: string
```

**Sin estos campos, el código va a fallar.**
