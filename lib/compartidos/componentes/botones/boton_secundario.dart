import 'package:flutter/material.dart';
import '../../tema/colores_app.dart';

/// Botón secundario reutilizable con estilo de texto
class BotonSecundario extends StatelessWidget {
  final String texto;
  final VoidCallback? alPresionar;
  final bool cargando;
  final bool expandir;
  final IconData? icono;
  final Color? color;
  final double? ancho;
  final double? alto;
  final bool conBorde;

  const BotonSecundario({
    super.key,
    required this.texto,
    this.alPresionar,
    this.cargando = false,
    this.expandir = false,
    this.icono,
    this.color,
    this.ancho,
    this.alto,
    this.conBorde = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorBoton = color ?? ColoresApp.primario;

    if (conBorde) {
      return SizedBox(
        width: expandir ? double.infinity : ancho,
        height: alto ?? 48,
        child: OutlinedButton(
          onPressed: (cargando || alPresionar == null) ? null : alPresionar,
          style: OutlinedButton.styleFrom(
            foregroundColor: colorBoton,
            disabledForegroundColor: ColoresApp.textoClaro,
            side: BorderSide(
              color: colorBoton,
              width: 1.5,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _buildContent(colorBoton),
        ),
      );
    }

    return SizedBox(
      width: expandir ? double.infinity : ancho,
      height: alto ?? 48,
      child: TextButton(
        onPressed: (cargando || alPresionar == null) ? null : alPresionar,
        style: TextButton.styleFrom(
          foregroundColor: colorBoton,
          disabledForegroundColor: ColoresApp.textoClaro,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _buildContent(colorBoton),
      ),
    );
  }

  Widget _buildContent(Color colorBoton) {
    return cargando
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(colorBoton),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icono != null) ...[
                Icon(icono, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                texto,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
  }
}
