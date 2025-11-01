import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controladores/auth_controlador.dart';
import 'usuario_campo.dart';
import 'password_campo.dart';
import 'login_boton.dart';
import '../../../../compartidos/tema/colores_app.dart';
import '../../../evaluaciones/servicios/test_servicio.dart';
import '../../../evaluaciones/vistas/test_ansiedad_vista.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado.mensaje),
          backgroundColor: resultado.exito
              ? ColoresApp.exito
              : ColoresApp.error,
          duration: const Duration(seconds: 3),
        ),
      );

      // Si fue exitoso, verifica si necesita test
      if (resultado.exito && resultado.usuario != null) {
        await _verificarYRedirigir(resultado.usuario!.uid);
      }
    }
  }

  Future<void> _verificarYRedirigir(String usuarioId) async {
    try {
      print('🔐 Login exitoso, verificando test para usuario: $usuarioId');
      final testServicio = TestServicio();
      final necesitaTest = await testServicio.necesitaRealizarTest(usuarioId);

      print('🎯 Necesita test: $necesitaTest');

      if (mounted) {
        if (necesitaTest) {
          print('➡️ Redirigiendo al test de ansiedad');
          // Redirige al test de ansiedad
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TestAnsiedadVista(usuarioId: usuarioId),
            ),
          );
        } else {
          print('➡️ Redirigiendo al home');
          // Redirige al home
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      print('❌ Error al verificar test: $e');
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
                  // Navegar a la pantalla de registro
                  Navigator.pushNamed(context, '/registro');
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
