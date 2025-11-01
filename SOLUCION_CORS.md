# Solución al Error de CORS

## 🔴 El Problema

```
Error de conexión: ClientException: Failed to fetch,
uri=https://intranet.ucss.edu.pe/ucss-intranet/login/ingresar.aspx
```

**Causa**: El portal UCSS bloquea peticiones desde navegadores web por políticas CORS (Cross-Origin Resource Sharing).

## ✅ Soluciones

### Solución 1: Windows Desktop (RECOMENDADO) ⭐

El scraping funciona **perfectamente** en Windows Desktop porque no hay restricciones CORS.

```bash
# Opción 1: Comando directo
flutter run -d windows

# Opción 2: Script
run_windows.bat
```

**Ventajas**:
- ✅ Funciona inmediatamente
- ✅ No requiere configuración
- ✅ Scraping funciona al 100%
- ✅ Mejor experiencia de desarrollo

### Solución 2: Android/iOS

También funciona perfectamente en móviles:

```bash
# Conecta tu dispositivo Android o abre un emulador
flutter run -d android

# Para iOS
flutter run -d ios
```

### Solución 3: Web con CORS Deshabilitado (Solo Desarrollo)

**Pasos**:

1. Ejecuta el script `run_web_dev.bat` (cierra Chrome y lo abre sin CORS)
2. Luego ejecuta: `flutter run -d chrome`

**Manual**:
```bash
# Cierra Chrome completamente

# Ejecuta Chrome con CORS deshabilitado
start chrome --disable-web-security --user-data-dir="%TEMP%\chrome_dev" --disable-site-isolation-trials

# En otra terminal
flutter run -d chrome
```

⚠️ **ADVERTENCIA**: Solo para desarrollo. Este Chrome NO es seguro para navegar.

### Solución 4: CORS Proxy (Producción)

Para producción en Web, necesitas un servidor proxy:

```
[Flutter Web] --> [Tu Servidor Proxy] --> [Portal UCSS]
```

#### Ejemplo con Node.js + Express:

```javascript
// proxy-server.js
const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
app.use(cors());
app.use(express.json());

app.post('/api/ucss/validate', async (req, res) => {
  try {
    const { codigo, password } = req.body;

    // Tu servidor hace la petición al portal UCSS
    const response = await axios.post(
      'https://intranet.ucss.edu.pe/ucss-intranet/login/ingresar.aspx',
      {
        txtUsuario: codigo,
        txtPassword: password,
        // ... otros campos ViewState
      },
      {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'Mozilla/5.0...'
        }
      }
    );

    res.json({
      success: true,
      html: response.data
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

app.listen(3000, () => {
  console.log('Proxy running on http://localhost:3000');
});
```

Luego modificar el servicio Flutter para usar el proxy:

```dart
// En ucss_scraping_servicio.dart
static const String _urlBase = kIsWeb
    ? 'http://localhost:3000/api/ucss'  // Proxy en desarrollo
    : 'https://intranet.ucss.edu.pe/ucss-intranet/login';
```

## 📊 Comparación de Soluciones

| Solución | Dificultad | Tiempo | Producción | Recomendado |
|----------|-----------|--------|------------|-------------|
| Windows Desktop | ⭐ Fácil | 1 min | ✅ Sí | ⭐⭐⭐⭐⭐ |
| Android/iOS | ⭐ Fácil | 2 min | ✅ Sí | ⭐⭐⭐⭐⭐ |
| Web + CORS Off | ⭐⭐ Media | 2 min | ❌ No | ⭐⭐ |
| CORS Proxy | ⭐⭐⭐ Difícil | 30 min | ✅ Sí | ⭐⭐⭐⭐ |

## 🚀 Pasos Recomendados AHORA

1. **Ejecuta en Windows Desktop** (la forma más fácil):
   ```bash
   flutter run -d windows
   ```

2. Prueba el registro con tus credenciales UCSS

3. Si funciona, ya tienes todo listo!

4. Para Web, implementa el proxy más adelante cuando lo necesites

## 🔍 Verificar Dispositivos Disponibles

```bash
flutter devices
```

Deberías ver:
```
Windows (desktop) • windows  • windows-x64    • Microsoft Windows
Chrome (web)      • chrome   • web-javascript • Google Chrome
[otros dispositivos]
```

## ❓ FAQ

### ¿Por qué no funciona en Web?
Los navegadores modernos bloquean peticiones a otros dominios por seguridad (CORS).

### ¿Es seguro deshabilitar CORS?
Solo en desarrollo. NUNCA distribuyas una app con CORS deshabilitado.

### ¿Cuál es la mejor solución para producción?
- **Móvil/Desktop**: Scraping directo (funciona perfecto)
- **Web**: Servidor proxy intermedio

### ¿El scraping funciona en móviles?
Sí, funciona perfectamente en Android e iOS sin problemas de CORS.

## 📝 Siguiente Paso

```bash
# Ejecuta esto ahora:
flutter run -d windows
```

Y prueba el registro! 🚀
