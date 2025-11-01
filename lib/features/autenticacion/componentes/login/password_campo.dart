import 'package:flutter/material.dart';
import '../../../../compartidos/utilidades/validadores.dart';
import '../../../../compartidos/tema/colores_app.dart';

/// Campo de contraseña para el formulario de login
class PasswordCampo extends StatefulWidget {
  final TextEditingController controlador;

  const PasswordCampo({
    super.key,
    required this.controlador,
  });

  @override
  State<PasswordCampo> createState() => _PasswordCampoState();
}

class _PasswordCampoState extends State<PasswordCampo> {
  bool _ocultarPassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta
        const Row(
          children: [
            Text(
              'Contraseña',
              style: TextStyle(
                color: ColoresApp.textoMedio,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                color: ColoresApp.error,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Campo de contraseña
        TextFormField(
          controller: widget.controlador,
          obscureText: _ocultarPassword,
          style: const TextStyle(
            fontSize: 15,
            color: ColoresApp.textoOscuro,
          ),
          decoration: InputDecoration(
            hintText: 'Ingresa tu contraseña',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _ocultarPassword ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: ColoresApp.textoMedio,
              ),
              onPressed: () {
                setState(() {
                  _ocultarPassword = !_ocultarPassword;
                });
              },
            ),
          ),
          validator: (valor) {
            // Valida que no esté vacío
            final errorRequerido = Validadores.requerido(valor, 'La contraseña');
            if (errorRequerido != null) return errorRequerido;

            // Valida longitud mínima
            final errorPassword = Validadores.password(valor);
            if (errorPassword != null) return errorPassword;

            return null;
          },
        ),
      ],
    );
  }
}
