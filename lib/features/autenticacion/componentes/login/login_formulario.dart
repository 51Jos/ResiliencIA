import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controladores/auth_controlador.dart';
import 'usuario_campo.dart';
import 'password_campo.dart';
import 'login_boton.dart';
import 'recuperar_password_dialogo.dart';
import '../../../../compartidos/tema/colores_app.dart';
import '../../../evaluaciones/servicios/test_servicio.dart';
import '../../../evaluaciones/vistas/test_ansiedad_vista.dart';
import '../../../administracion/servicios/administracion_servicio.dart';
import '../../../administracion/vistas/panel_admin_vista.dart';
import '../../../administracion/guards/admin_guard.dart';

/// Formulario de inicio de sesión
class LoginFormulario extends StatefulWidget {
  const LoginFormulario({super.key});

  @override
  State<LoginFormulario> createState() => _LoginFormularioState();
}

class _LoginFormularioState extends State<LoginFormulario> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Valida el formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Oculta el teclado
    FocusScope.of(context).unfocus();

    // Obtiene el controlador
    final authControlador = Provider.of<AuthControlador>(context, listen: false);

    // Intenta iniciar sesión
    final resultado = await authControlador.iniciarSesion(
      email: _emailController.text,
      password: _passwordController.text,
    );

    // Muestra el resultado
    if (mounted) {
      if (resultado.exito) {
        // Mensaje de éxito simple
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado.mensaje),
            backgroundColor: ColoresApp.exito,
            duration: const Duration(seconds: 2),
          ),
        );

        // Si fue exitoso, verifica si necesita test
        if (resultado.usuario != null) {
          await _verificarYRedirigir(resultado.usuario!.uid);
        }
      } else {
        // Mensaje de error detallado en un diálogo
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: ColoresApp.error, size: 28),
                SizedBox(width: 12),
                Text('Error al iniciar sesión'),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(
                resultado.mensaje,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _verificarYRedirigir(String usuarioId) async {
    try {
      
      // Obtener datos del usuario PRIMERO para debugging
      final authControlador = Provider.of<AuthControlador>(context, listen: false);
      final datosUsuario = await authControlador.obtenerDatosUsuario();

      
      // Primero verificar si es administrador
      final administracionServicio = AdministracionServicio();
      final esAdmin = await administracionServicio.esAdministrador(usuarioId);

     
      if (mounted) {
        if (esAdmin) {
          // ES ADMINISTRADOR (psicólogo) -> Panel de administración
          
          final nombres = datosUsuario?['nombres'] ?? '';
          final apellidos = datosUsuario?['apellidos'] ?? '';
          final nombreCompleto = '$nombres $apellidos'.trim();
          final nombreFinal = nombreCompleto.isNotEmpty ? nombreCompleto : 'Psicólogo';

          if (!mounted) return;

          // Redirige al panel de administración con guard
          final rol = datosUsuario?['rol'] as String?;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminGuard(
                usuarioId: usuarioId,
                child: PanelAdminVista(
                  psicologoId: usuarioId,
                  psicologoNombre: nombreFinal,
                  psicologoRol: rol,
                ),
              ),
            ),
          );
          return;
        }

        // NO ES ADMIN -> Verificar si es ESTUDIANTE
        final rol = datosUsuario?['rol'] as String?;

        if (rol == 'estudiante') {
          // ES ESTUDIANTE -> Verificar si necesita hacer el test
          final testServicio = TestServicio();
          final necesitaTest = await testServicio.necesitaRealizarTest(usuarioId);

          
          if (!mounted) return;

          if (necesitaTest) {
            // Redirige al test de ansiedad
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TestAnsiedadVista(usuarioId: usuarioId),
              ),
            );
          } else {
            // Redirige al home
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          // Rol desconocido o no autorizado
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      // En caso de error, redirige al home
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authControlador = Provider.of<AuthControlador>(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Campo de email
          UsuarioCampo(controlador: _emailController),
          const SizedBox(height: 28),

          // Campo de contraseña
          PasswordCampo(controlador: _passwordController),
          const SizedBox(height: 12),

          // Link de recuperar contraseña
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                // Mostrar modal de recuperar contraseña
                showDialog(
                  context: context,
                  builder: (context) => const RecuperarPasswordDialogo(),
                );
              },
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  color: ColoresApp.primario,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Botón de login
          LoginBoton(
            alPresionar: authControlador.cargando ? null : _handleLogin,
            cargando: authControlador.cargando,
          ),

          // Link de crear cuenta
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¿No tienes cuenta? ',
                style: TextStyle(
                  color: ColoresApp.textoClaro,
                  fontSize: 14,
                ),
              ),
              InkWell(
                onTap: () {
                  // Navegar a IntranetVista para validar estudiante
                  Navigator.pushNamed(context, '/intranet');
                },
                child: const Text(
                  'Crear cuenta',
                  style: TextStyle(
                    color: ColoresApp.primario,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
