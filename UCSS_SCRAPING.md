# Web Scraping del Portal UCSS - Documentación

## ⚠️ ADVERTENCIA IMPORTANTE

**Este sistema de web scraping está diseñado ÚNICAMENTE para fines educativos y de desarrollo.**

### Consideraciones Legales

1. **Requiere Autorización**: Debes obtener autorización oficial de la UCSS antes de usar este sistema en producción
2. **Protección de Datos**: Estás manejando credenciales y datos personales de estudiantes
3. **Términos de Servicio**: Verifica que no violes los términos de uso del portal UCSS
4. **Ley de Protección de Datos**: En Perú aplica la Ley N° 29733

### Riesgos

- ❌ Bloqueo de IP por múltiples intentos de login
- ❌ Violación de políticas de seguridad institucional
- ❌ Problemas legales si no tienes autorización
- ❌ Exposición de credenciales de estudiantes

## 🔧 Cómo Funciona

### Proceso de Scraping

El servicio `UcssScrappingServicio` realiza los siguientes pasos:

1. **Obtiene la página de login**
   ```dart
   GET https://intranet.ucss.edu.pe/ucss-intranet/login/ingresar.aspx
   ```

2. **Extrae ViewState de ASP.NET**
   - `__VIEWSTATE`
   - `__VIEWSTATEGENERATOR`
   - `__EVENTVALIDATION`

3. **Envía credenciales**
   ```dart
   POST https://intranet.ucss.edu.pe/ucss-intranet/login/ingresar.aspx
   Body:
     - __VIEWSTATE: [valor extraído]
     - __VIEWSTATEGENERATOR: [valor extraído]
     - __EVENTVALIDATION: [valor extraído]
     - txtUsuario: [código UCSS]
     - txtPassword: [contraseña]
     - btnIngresar: "Ingresar"
   ```

4. **Valida el resultado**
   - Verifica si el HTML contiene indicadores de éxito
   - Extrae mensajes de error si falló

5. **Extrae datos del estudiante** (si login fue exitoso)
   - Nombre completo
   - Facultad
   - Programa/Carrera

### Indicadores de Login Exitoso

El sistema considera que el login fue exitoso si:
- El HTML contiene: "cerrar sesión", "bienvenido", "portal del estudiante"
- La URL cambió de la página de login
- No contiene mensajes de error

### Indicadores de Login Fallido

El sistema detecta error si el HTML contiene:
- "usuario o contraseña"
- "credenciales incorrectas"
- "error de autenticación"
- "datos incorrectos"

## 📋 Uso del Sistema

### Registro de Usuario

```dart
// 1. El usuario ingresa su código UCSS y contraseña
final resultado = await authControlador.registrarUsuarioConUcss(
  codigo: '2020100001',
  password: 'mi_contraseña_ucss',
);

// 2. El sistema valida las credenciales contra el portal UCSS
// 3. Si son válidas, extrae los datos del estudiante
// 4. Crea la cuenta en Firebase
// 5. Guarda los datos en Firestore
```

### Datos Guardados en Firestore

```json
{
  "uid": "firebase_user_id",
  "codigo": "2020100001",
  "email": "2020100001@ucss.pe",
  "nombres": "Juan",
  "apellidos": "Pérez García",
  "nombreCompleto": "Juan Pérez García",
  "facultad": "Facultad de Ingeniería",
  "programa": "Ingeniería de Sistemas",
  "rol": "estudiante",
  "fechaRegistro": "2024-01-15T10:30:00Z",
  "verificadoUcss": true
}
```

## 🛡️ Seguridad

### Buenas Prácticas Implementadas

1. **Timeout**: Las peticiones tienen timeout de 10-15 segundos
2. **User-Agent**: Se envía un User-Agent válido
3. **Headers apropiados**: Referer, Content-Type, etc.
4. **No almacena contraseñas**: Solo se usa para validar, no se guarda

### Medidas de Seguridad Recomendadas

1. **Rate Limiting**: Limita el número de intentos de registro por IP
2. **CAPTCHA**: Implementa CAPTCHA después de varios intentos fallidos
3. **Logs**: Registra todos los intentos de validación
4. **Encriptación**: Usa HTTPS en todas las conexiones
5. **Monitoreo**: Alerta si hay múltiples fallos desde la misma IP

## 🔍 Debugging

### Problemas Comunes

#### 1. ViewState no se extrae correctamente

```dart
// El regex para extraer ViewState puede fallar si el HTML cambia
// Solución: Verificar el HTML actual del portal
final viewState = _extraerCampo(responseInicial.body, '__VIEWSTATE');
if (viewState.isEmpty) {
  // El portal cambió su estructura
}
```

#### 2. Login parece exitoso pero no lo es

```dart
// Ajustar los indicadores de éxito/error
if (html.contains('cerrar sesión') ||
    html.contains('bienvenido') ||
    html.contains('portal del estudiante')) {
  return true;
}
```

#### 3. No se extraen datos del estudiante

```dart
// Los regex para extraer nombre/facultad pueden no coincidir
// Inspecciona el HTML después del login para ajustar los regex
final regexNombre = RegExp(
  r'(?:Alumno|Estudiante|Bienvenido)[:\s]*([A-ZÁÉÍÓÚÑ\s]+)',
  caseSensitive: false,
);
```

### Logging de Debugging

```dart
// Agregar en ucss_scraping_servicio.dart
print('HTML Response: ${response.body}');
print('ViewState: $viewState');
print('Status Code: ${response.statusCode}');
print('Redirect URL: ${response.request?.url}');
```

## 🔄 Alternativas Recomendadas

### Opción 1: API Oficial (MEJOR)

Solicita a UCSS que proporcione una API REST:

```
POST /api/auth/validate
{
  "codigo": "2020100001",
  "password": "***"
}

Response:
{
  "valid": true,
  "data": {
    "nombres": "Juan",
    "apellidos": "Pérez",
    "facultad": "Ingeniería",
    "programa": "Sistemas"
  }
}
```

### Opción 2: LDAP/Active Directory

```dart
// Autenticar contra el servidor LDAP de UCSS
final ldapConnection = await LdapConnection.connect(
  'ldap.ucss.edu.pe',
  389,
);
```

### Opción 3: OAuth 2.0 / SAML

```
1. Usuario hace clic en "Ingresar con UCSS"
2. Redirige al portal UCSS
3. Usuario inicia sesión en UCSS
4. UCSS redirige de vuelta con token
5. App valida el token
```

## 📊 Monitoreo

### Métricas a Monitorear

1. **Tasa de éxito/fallo** de validaciones
2. **Tiempo de respuesta** del portal UCSS
3. **Errores de timeout**
4. **Cambios en la estructura HTML** del portal

### Alertas

Configura alertas para:
- Más de 50% de validaciones fallidas
- Timeouts frecuentes
- Cambios detectados en el HTML (ViewState no encontrado)

## 🚀 Testing

### Test Manual

```bash
# Probar con credenciales válidas
flutter run
# Ir a registro
# Ingresar código: 2020100001
# Ingresar contraseña: tu_contraseña
# Verificar que se crea la cuenta
```

### Test de Integración

```dart
test('Validar credenciales UCSS', () async {
  final servicio = UcssScrappingServicio();

  final resultado = await servicio.autenticarUcss(
    codigo: '2020100001',
    password: 'test_password',
  );

  expect(resultado.exito, isTrue);
  expect(resultado.datosEstudiante, isNotNull);
});
```

## 📝 Notas Finales

1. Este sistema puede dejar de funcionar si UCSS cambia su portal
2. Requiere mantenimiento constante
3. **Obtén autorización oficial antes de usar en producción**
4. Considera las alternativas más seguras y oficiales
5. No uses este código si no estás autorizado

## 📧 Contacto con UCSS

Para solicitar acceso oficial a APIs o integración:

- **Departamento de TI UCSS**
- **Email**: sistemas@ucss.edu.pe
- **Teléfono**: (contactar a la universidad)

Presenta tu proyecto y solicita:
1. API oficial para validación de estudiantes
2. Acceso a Active Directory/LDAP
3. Implementación de OAuth/SSO
