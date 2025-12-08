import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../compartidos/tema/colores_app.dart';
import '../../controladores/auth_controlador.dart';

/// Diálogo para recuperar contraseña
class RecuperarPasswordDialogo extends StatefulWidget {
  const RecuperarPasswordDialogo({super.key});

  @override
  State<RecuperarPasswordDialogo> createState() =>
      _RecuperarPasswordDialogoState();
}

class _RecuperarPasswordDialogoState extends State<RecuperarPasswordDialogo> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailEnviado = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleEnviarEmail() async {
    // Valida el formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Oculta el teclado
    FocusScope.of(context).unfocus();

    // Obtiene el controlador
    final authControlador =
        Provider.of<AuthControlador>(context, listen: false);

    // Intenta enviar el email de recuperación
    final resultado = await authControlador.restablecerPassword(
      _emailController.text.trim(),
    );

    // Muestra el resultado
    if (mounted) {
      if (resultado.exito) {
        setState(() {
          _emailEnviado = true;
        });
      } else {
        // Mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado.mensaje),
            backgroundColor: ColoresApp.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authControlador = Provider.of<AuthControlador>(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(32),
        child: _emailEnviado
            ? _buildExitoContent()
            : _buildFormularioContent(authControlador),
      ),
    );
  }

  Widget _buildFormularioContent(AuthControlador authControlador) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono y título
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColoresApp.primario.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset,
              size: 48,
              color: ColoresApp.primario,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recuperar contraseña',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ColoresApp.textoOscuro,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
            style: TextStyle(
              fontSize: 14,
              color: ColoresApp.textoMedio,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Campo de email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              hintText: 'ejemplo@ucss.edu.pe',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ColoresApp.bordeDivisor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: ColoresApp.primario, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu correo';
              }
              if (!value.contains('@')) {
                return 'Ingresa un correo válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),

          // Botones
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 15,
                      color: ColoresApp.textoMedio,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed:
                      authControlador.cargando ? null : _handleEnviarEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresApp.primario,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: authControlador.cargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Enviar enlace',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExitoContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icono de éxito
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColoresApp.exito.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 64,
            color: ColoresApp.exito,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '¡Correo enviado!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: ColoresApp.textoOscuro,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Hemos enviado un enlace de recuperación a:\n${_emailController.text}',
          style: const TextStyle(
            fontSize: 14,
            color: ColoresApp.textoMedio,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Información adicional
        Container(
          decoration: BoxDecoration(
            color: ColoresApp.fondoTarjeta,
            borderRadius: BorderRadius.circular(8),
            border: const Border(
              left: BorderSide(
                color: ColoresApp.primario,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: ColoresApp.primario,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Importante',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: ColoresApp.textoOscuro,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '• Revisa tu bandeja de entrada\n'
                '• Si no lo encuentras, revisa spam\n'
                '• El enlace expirará en 1 hora',
                style: TextStyle(
                  fontSize: 13,
                  color: ColoresApp.textoMedio,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Botones
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _emailEnviado = false;
                  });
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Reenviar',
                  style: TextStyle(
                    fontSize: 15,
                    color: ColoresApp.textoMedio,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primario,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
