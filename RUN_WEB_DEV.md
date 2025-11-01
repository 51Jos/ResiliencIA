# Ejecutar en Web con CORS Deshabilitado

## Problema

El portal UCSS no permite peticiones desde navegadores web (CORS bloqueado).

## Solución 1: Chrome con CORS Deshabilitado (Desarrollo)

### Windows

```bash
# Cierra todas las ventanas de Chrome primero

# Ejecuta Chrome con CORS deshabilitado
start chrome --disable-web-security --user-data-dir="C:\temp\chrome_dev" --disable-site-isolation-trials http://localhost:your_port

# Luego ejecuta Flutter
flutter run -d chrome
```

### Crear script batch (Windows)

Crea un archivo `run_web_dev.bat`:

```batch
@echo off
echo Cerrando Chrome...
taskkill /F /IM chrome.exe 2>nul

echo Esperando...
timeout /t 2 /nobreak > nul

echo Iniciando Chrome sin CORS...
start chrome --disable-web-security --user-data-dir="%TEMP%\chrome_dev" --disable-site-isolation-trials

echo Iniciando Flutter Web...
flutter run -d chrome
```

Ejecuta: `run_web_dev.bat`

## Solución 2: Ejecutar en Android/Desktop (RECOMENDADO)

El scraping funciona perfectamente en:
- Android
- iOS
- Windows Desktop
- macOS
- Linux

```bash
# Android
flutter run -d android

# Windows Desktop
flutter run -d windows

# Lista dispositivos disponibles
flutter devices
```

## Solución 3: CORS Proxy (Producción)

Para producción, necesitas un servidor proxy que haga las peticiones:

```
[Flutter Web] -> [Tu Server Proxy] -> [Portal UCSS]
```

### Implementar proxy en Node.js

```javascript
// server.js
const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
app.use(cors());
app.use(express.json());

app.post('/api/ucss/validate', async (req, res) => {
  const { codigo, password } = req.body;

  try {
    // Hacer petición al portal UCSS desde el servidor
    const response = await axios.post(
      'https://intranet.ucss.edu.pe/ucss-intranet/login/ingresar.aspx',
      {
        txtUsuario: codigo,
        txtPassword: password,
        // ... otros campos
      }
    );

    res.json({ success: true, data: response.data });
  } catch (error) {
    res.json({ success: false, error: error.message });
  }
});

app.listen(3000, () => console.log('Proxy running on port 3000'));
```

## Solución 4: Usar Extension de Chrome

1. Instala extensión: [CORS Unblock](https://chrome.google.com/webstore/detail/cors-unblock/)
2. Activa la extensión
3. Ejecuta: `flutter run -d chrome`

## Recomendación

**Para desarrollo**: Usa Android o Windows Desktop
**Para producción**: Implementa un servidor proxy

```bash
# Mejor opción para probar ahora:
flutter run -d windows
# o
flutter run -d android
```

## Verificar Dispositivos Disponibles

```bash
flutter devices
```

Deberías ver algo como:
```
Chrome (web)    • chrome    • web-javascript • Google Chrome 120.0
Windows (desktop) • windows  • windows-x64    • Microsoft Windows
Android SDK     • emulator-5554 • android   • Android 13
```

## Ejecutar en Dispositivo Específico

```bash
# Windows Desktop (RECOMENDADO PARA TI)
flutter run -d windows

# Android
flutter run -d android

# Web con Chrome
flutter run -d chrome
```
