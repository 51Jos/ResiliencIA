import 'package:flutter/material.dart';
import '../../../../compartidos/componentes/botones/boton_primario.dart';

/// Botón de inicio de sesión
class LoginBoton extends StatelessWidget {
  final VoidCallback? alPresionar;
  final bool cargando;

  const LoginBoton({
    super.key,
    required this.alPresionar,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    return BotonPrimario(
      texto: 'Iniciar Sesión',
      alPresionar: alPresionar,
      cargando: cargando,
      expandir: true,
    );
  }
}
