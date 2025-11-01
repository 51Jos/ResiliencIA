import 'package:flutter/material.dart';
import '../../../../compartidos/componentes/campos/campo_texto.dart';
import '../../../../compartidos/utilidades/validadores.dart';

/// Campo de usuario/email para el formulario de login
class UsuarioCampo extends StatelessWidget {
  final TextEditingController controlador;

  const UsuarioCampo({
    super.key,
    required this.controlador,
  });

  @override
  Widget build(BuildContext context) {
    return CampoTexto(
      etiqueta: 'Correo Institucional UCSS',
      placeholder: 'codigo@ucss.pe',
      textoAyuda: 'Usa tu correo institucional @ucss.pe',
      icono: Icons.email_outlined,
      controlador: controlador,
      tipoTeclado: TextInputType.emailAddress,
      requerido: true,
      validador: (valor) {
        // Valida que no esté vacío
        final errorRequerido = Validadores.requerido(valor, 'El correo');
        if (errorRequerido != null) return errorRequerido;

        // Valida formato de email
        final errorEmail = Validadores.email(valor);
        if (errorEmail != null) return errorEmail;

        // Valida que sea email UCSS
        final errorUCSS = Validadores.emailUCSS(valor);
        if (errorUCSS != null) return errorUCSS;

        return null;
      },
    );
  }
}
