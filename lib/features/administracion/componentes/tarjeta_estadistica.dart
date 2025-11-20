import 'package:flutter/material.dart';
import '../../../compartidos/tema/colores_app.dart';

/// Tarjeta para mostrar una estadística individual
class TarjetaEstadistica extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color? colorIcono;
  final String? subtitulo;
  final VoidCallback? onTap;

  const TarjetaEstadistica({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    this.colorIcono,
    this.subtitulo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColoresApp.fondoBlanco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColoresApp.bordeDivisor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (colorIcono ?? ColoresApp.primario)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icono,
                    color: colorIcono ?? ColoresApp.primario,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 13,
                      color: ColoresApp.textoMedio,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoOscuro,
              ),
            ),
            if (subtitulo != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitulo!,
                style: const TextStyle(
                  fontSize: 12,
                  color: ColoresApp.textoClaro,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
