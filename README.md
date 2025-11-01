# Sistema de Psicología para Estudiantes UCSS

Sistema de Detección de Ansiedad y Acompañamiento Emocional para estudiantes de la Universidad Católica Sedes Sapientiae.

## ⚡ INICIO RÁPIDO

**¿Ves error de CORS en el navegador?** → Lee [LEEME_PRIMERO.txt](LEEME_PRIMERO.txt)

**Solución rápida:**
```bash
# Ejecuta en Windows Desktop (no web)
flutter run -d windows

# O haz doble clic en: EJECUTAR_AQUI.bat
```

⚠️ **IMPORTANTE**: El web scraping **NO funciona en navegadores web** (Chrome/Edge) por restricciones CORS. Usa Windows Desktop, Android o iOS.

## Características

- **Autenticación**: Login con correo institucional UCSS (@ucss.pe)
- **Registro de Citas**: Los estudiantes pueden agendar citas con psicólogos
- **Registro de Atenciones**: Los psicólogos pueden registrar las atenciones brindadas
- **Gestión de Usuarios**: Sistema de roles (estudiante/psicólogo)

## Tecnologías

- **Flutter** - Framework de desarrollo
- **Firebase Authentication** - Autenticación de usuarios
- **Cloud Firestore** - Base de datos NoSQL
- **Provider** - Gestión de estado

## Arquitectura del Proyecto

```
lib/
├── features/                    # Módulos por funcionalidad
│   ├── autenticacion/
│   │   ├── controladores/      # Lógica de negocio
│   │   ├── vistas/             # Pantallas
│   │   ├── componentes/        # Widgets específicos
│   │   └── servicios/          # Servicios de Firebase
│   ├── registro_atenciones/
│   └── registro_citas/
├── compartidos/                 # Componentes reutilizables
│   ├── componentes/
│   │   ├── campos/             # Inputs reutilizables
│   │   ├── botones/            # Botones reutilizables
│   │   └── layout/             # Layouts comunes
│   ├── utilidades/             # Validadores y formateadores
│   └── tema/                   # Colores y tema de la app
├── nucleo/                     # Configuración central
│   └── configuracion_firebase.dart
├── rutas/                      # Navegación
└── main.dart                   # Punto de entrada
```

## Instalación

### Requisitos Previos

- Flutter SDK (>=3.8.1)
- Dart SDK
- Cuenta de Firebase

### Pasos

1. **Clonar el repositorio**
   ```bash
   git clone <url-del-repositorio>
   cd resiliencia
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar Firebase**

   Sigue las instrucciones en [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

4. **Ejecutar la aplicación**

   **Opción A: Windows Desktop (RECOMENDADO)**
   ```bash
   flutter run -d windows
   # O ejecuta: run_windows.bat
   ```

   **Opción B: Android**
   ```bash
   flutter run -d android
   ```

   **Opción C: Web (requiere CORS deshabilitado)**
   ```bash
   # Ejecuta primero: run_web_dev.bat
   # Luego: flutter run -d chrome
   ```

   Ver [RUN_WEB_DEV.md](RUN_WEB_DEV.md) para más detalles sobre CORS.

## Estructura de Componentes Globales

### Campos de Formulario

- `CampoTexto` - Campo de texto general
- `CampoFecha` - Selector de fecha
- `CampoHora` - Selector de hora
- `CampoSelector` - Dropdown genérico
- `CampoTextarea` - Área de texto multilínea

### Botones

- `BotonPrimario` - Botón principal
- `BotonSecundario` - Botón secundario o con borde

### Layout

- `CabeceraPagina` - Cabecera para páginas internas
- `CabeceraConLogo` - Cabecera para login/registro

### Utilidades

- `Validadores` - Validaciones de formularios
- `Formateadores` - Formateo de datos

## Módulo de Autenticación

### Componentes

- `LoginVista` - Pantalla de inicio de sesión
- `LoginFormulario` - Formulario de login
- `LoginCabecera` - Cabecera con logo
- `UsuarioCampo` - Campo de email institucional
- `PasswordCampo` - Campo de contraseña con toggle

### Controlador

```dart
// Uso del controlador de autenticación
final authControlador = Provider.of<AuthControlador>(context);

// Iniciar sesión
final resultado = await authControlador.iniciarSesion(
  email: 'estudiante@ucss.pe',
  password: 'password123',
);

// Registrar usuario
final resultado = await authControlador.registrarUsuario(
  email: 'nuevo@ucss.pe',
  password: 'password123',
  nombres: 'Juan',
  apellidos: 'Pérez',
);

// Cerrar sesión
await authControlador.cerrarSesion();
```

### Servicio de Autenticación

El servicio `AuthServicio` maneja todas las operaciones de Firebase:

- `iniciarSesion()` - Login con email/password
- `registrarUsuario()` - Registro de nuevos usuarios
- `cerrarSesion()` - Logout
- `restablecerPassword()` - Recuperación de contraseña
- `obtenerDatosUsuario()` - Obtiene datos de Firestore

## Tema y Estilos

### Colores

```dart
ColoresApp.primario           // #4A9D94 - Verde azulado
ColoresApp.primarioOscuro     // #3D8479
ColoresApp.primarioClaro      // #F7FAF9
ColoresApp.textoOscuro        // #1A202C
ColoresApp.textoMedio         // #4A5568
ColoresApp.textoClaro         // #718096
ColoresApp.fondoPrincipal     // #F0F4F8
```

### Espaciados

```dart
TemaApp.espaciadoXS    // 4px
TemaApp.espaciadoS     // 8px
TemaApp.espaciadoM     // 16px
TemaApp.espaciadoL     // 24px
TemaApp.espaciadoXL    // 32px
TemaApp.espaciadoXXL   // 40px
```

## Validaciones

### Validadores Disponibles

```dart
// Email UCSS
Validadores.emailUCSS(valor)

// Teléfono (9 dígitos)
Validadores.telefono(valor)

// Solo letras
Validadores.soloLetras(valor)

// Contraseña segura
Validadores.passwordSegura(valor)

// Combinar múltiples validadores
Validadores.combinar([
  (v) => Validadores.requerido(v, 'Email'),
  Validadores.email,
  Validadores.emailUCSS,
])
```

## Estado del Proyecto

### Completado ✅

- [x] Estructura de carpetas
- [x] Tema y colores globales
- [x] Componentes reutilizables
- [x] Módulo de autenticación
- [x] Integración con Firebase
- [x] Validaciones de formularios

### Pendiente 📋

- [ ] Registro de usuarios (pantalla)
- [ ] Módulo de registro de citas
- [ ] Módulo de registro de atenciones
- [ ] Sistema de roles (estudiante/psicólogo)
- [ ] Navegación entre pantallas
- [ ] Recuperación de contraseña
- [ ] Perfil de usuario

## Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agrega nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## Licencia

Este proyecto es propiedad de la Universidad Católica Sedes Sapientiae.

## Contacto

Para soporte o consultas, contacta a: soporte@ucss.pe
