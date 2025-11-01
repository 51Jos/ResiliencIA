import 'package:flutter/material.dart';
import '../../tema/colores_app.dart';

/// Botón primario reutilizable con estilo consistente
class BotonPrimario extends StatelessWidget {
  final String texto;
  final VoidCallback? alPresionar;
  final bool cargando;
  final bool expandir;
  final IconData? icono;
  final Color? color;
  final Color? colorTexto;
  final double? ancho;
  final double? alto;

  const BotonPrimario({
    super.key,
    required this.texto,
    this.alPresionar,
    this.cargando = false,
    this.expandir = true,
    this.icono,
    this.color,
    this.colorTexto,
    this.ancho,
    this.alto,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expandir ? double.infinity : ancho,
      height: alto ?? 48,
      child: ElevatedButton(
        onPressed: (cargando || alPresionar == null) ? null : alPresionar,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? ColoresApp.primario,
          foregroundColor: colorTexto ?? Colors.white,
          disabledBackgroundColor: ColoresApp.borde,
          disabledForegroundColor: ColoresApp.textoClaro,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ).copyWith(
          // Efecto hover
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return Colors.white.withValues(alpha: 0.1);
              }
              if (states.contains(WidgetState.pressed)) {
                return Colors.white.withValues(alpha: 0.2);
              }
              return null;
            },
          ),
        ),
        child: cargando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
