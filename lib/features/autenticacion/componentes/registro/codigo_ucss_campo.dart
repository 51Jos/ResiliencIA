import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../compartidos/componentes/campos/campo_texto.dart';

/// Campo para código UCSS (10 dígitos)
class CodigoUcssCampo extends StatelessWidget {
  final TextEditingController controlador;

  const CodigoUcssCampo({
    super.key,
    required this.controlador,
  });

  @override
  Widget build(BuildContext context) {
    return CampoTexto(
      etiqueta: 'Código UCSS',
      placeholder: '2020100001',
      textoAyuda: 'Ingresa tu código institucional de 10 dígitos',
      icono: Icons.badge_outlined,
      controlador: controlador,
      tipoTeclado: TextInputType.number,
      requerido: true,
      maxCaracteres: 10,
      formatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      validador: (valor) {
        if (valor == null || valor.isEmpty) {
          return 'El código UCSS es requerido';
        }
        if (valor.length != 10) {
          return 'El código debe tener 10 dígitos';
        }
        // Valida que los primeros 4 dígitos sean un año válido
        final anio = int.tryParse(valor.substring(0, 4));
        if (anio == null || anio < 2000 || anio > DateTime.now().year) {
          return 'El código UCSS no es válido';
        }
        return null;
      },
    );
  }
}
