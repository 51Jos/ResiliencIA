# 🚀 Cómo Probar el Scraping UCSS

## ✅ Estado Actual

El sistema ahora tiene una **página de prueba** para el scraping que funciona **SIN necesitar Firebase**.

### Lo que eliminé:
- ❌ Banner horrible de CORS
- ❌ Mensajes de error molestos
- ❌ Dependencia de Firebase para pruebas

### Lo que agregué:
- ✅ Proxy CORS automático (`corsproxy.io`)
- ✅ Vista de prueba simple
- ✅ Funciona en web, desktop, móvil

## 🎯 Cómo Probar AHORA

### 1. Ejecuta la app

```bash
flutter run -d chrome
```

### 2. Verás una pantalla:

```
╔═══════════════════════════════╗
║   Test Scraping UCSS          ║
║   Prueba la validación        ║
║   contra el portal            ║
╚═══════════════════════════════╝

Código UCSS: [__________]
Contraseña:   [__________]

    [  Probar Scraping  ]
```

### 3. Ingresa tus datos:

- **Código UCSS**: Tu código de 10 dígitos (ej: 2020100001)
- **Contraseña**: Tu contraseña del portal UCSS

### 4. Presiona "Probar Scraping"

El sistema:
1. Se conecta al portal UCSS (vía proxy CORS en web)
2. Valida tus credenciales
3. Extrae tus datos:
   - Nombre completo
   - Facultad
   - Programa

### 5. Verás el resultado:

Si es exitoso:
```
✅ Autenticación exitosa

✅ Datos Extraídos:
   nombres: Juan
   apellidos: Pérez García
   nombreCompleto: Juan Pérez García
   facultad: Facultad de Ingeniería
   programa: Ingeniería de Sistemas
```

Si falla:
```
❌ Código o contraseña incorrectos
```

## 📱 Funciona en TODAS las Plataformas

```bash
# Web
flutter run -d chrome

# Windows
flutter run -d windows

# Android
flutter run -d android
```

## 🔧 ¿Y Firebase?

Firebase está **comentado temporalmente** para que puedas probar el scraping primero.

### Cuando quieras agregar Firebase:

1. Configura tus credenciales en `lib/nucleo/configuracion_firebase.dart`
2. Descomenta el código en `lib/main.dart`
3. Usa la app completa con login/registro

## ✨ Ventajas de esta Solución

| Característica | Estado |
|----------------|--------|
| Funciona en Web | ✅ Sí |
| Sin mensajes feos | ✅ Sí |
| Sin Firebase requerido | ✅ Sí |
| Muestra datos extraídos | ✅ Sí |
| Proxy CORS automático | ✅ Sí |

## 🎊 ¡Ya está listo!

Solo ejecuta:
```bash
flutter run -d chrome
```

Y prueba con tus credenciales UCSS reales.
