import 'package:flutter/material.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../modelos/estadisticas_globales.dart';
import '../../evaluaciones/modelos/pregunta_beck.dart';

/// Gráfica simple de evolución del nivel de ansiedad
/// TODO: Considerar usar fl_chart para una implementación más robusta
class GraficaEvolucion extends StatelessWidget {
  final List<PuntoEvolucion> puntos;
  final double altura;

  const GraficaEvolucion({
    super.key,
    required this.puntos,
    this.altura = 300,
  });

  @override
  Widget build(BuildContext context) {
    if (puntos.isEmpty) {
      return Container(
        height: altura,
        decoration: BoxDecoration(
          color: ColoresApp.fondoBlanco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColoresApp.bordeDivisor),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart,
                size: 48,
                color: ColoresApp.textoClaro,
              ),
              SizedBox(height: 16),
              Text(
                'No hay datos suficientes para mostrar',
                style: TextStyle(
                  color: ColoresApp.textoMedio,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: altura,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.fondoBlanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.bordeDivisor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evolución del nivel de ansiedad',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColoresApp.textoOscuro,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${puntos.length} evaluaciones realizadas',
            style: const TextStyle(
              fontSize: 13,
              color: ColoresApp.textoMedio,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _GraficaLinea(puntos: puntos),
          ),
        ],
      ),
    );
  }
}

class _GraficaLinea extends StatelessWidget {
  final List<PuntoEvolucion> puntos;

  const _GraficaLinea({required this.puntos});

  @override
  Widget build(BuildContext context) {
    // Ordenar puntos por fecha
    final puntosOrdenados = [...puntos]
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    final maxPuntaje = puntosOrdenados
        .map((p) => p.puntaje)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final minPuntaje = puntosOrdenados
        .map((p) => p.puntaje)
        .reduce((a, b) => a < b ? a : b)
        .toDouble();

    return CustomPaint(
      painter: _LineaPainter(
        puntos: puntosOrdenados,
        maxPuntaje: maxPuntaje > 0 ? maxPuntaje : 63,
        minPuntaje: minPuntaje >= 0 ? minPuntaje : 0,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _LineaPainter extends CustomPainter {
  final List<PuntoEvolucion> puntos;
  final double maxPuntaje;
  final double minPuntaje;

  _LineaPainter({
    required this.puntos,
    required this.maxPuntaje,
    required this.minPuntaje,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (puntos.isEmpty) return;

    final paint = Paint()
      ..color = ColoresApp.primario
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Dibujar líneas de referencia
    _dibujarLineasReferencia(canvas, size);

    // Calcular posiciones
    final anchoPorPunto = size.width / (puntos.length - 1).clamp(1, double.infinity);
    final rangoPuntaje = (maxPuntaje - minPuntaje).clamp(1, double.infinity);

    final path = Path();
    final posiciones = <Offset>[];

    for (var i = 0; i < puntos.length; i++) {
      final x = i * anchoPorPunto;
      final normalizado = (puntos[i].puntaje - minPuntaje) / rangoPuntaje;
      final y = size.height - (normalizado * size.height);

      posiciones.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Dibujar línea
    canvas.drawPath(path, paint);

    // Dibujar puntos
    for (var i = 0; i < posiciones.length; i++) {
      final offset = posiciones[i];
      final punto = puntos[i];

      // Punto exterior con color del nivel
      canvas.drawCircle(
        offset,
        6,
        Paint()
          ..color = _getColorNivel(punto.nivel)
          ..style = PaintingStyle.fill,
      );

      // Punto interior blanco
      canvas.drawCircle(
        offset,
        3,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );

      // Etiqueta del puntaje
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${punto.puntaje}',
          style: const TextStyle(
            color: ColoresApp.textoOscuro,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(offset.dx - textPainter.width / 2, offset.dy - 20),
      );
    }
  }

  void _dibujarLineasReferencia(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ColoresApp.bordeDivisor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Línea horizontal en el medio
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Líneas horizontales superior e inferior
    canvas.drawLine(
      Offset(0, size.height * 0.25),
      Offset(size.width, size.height * 0.25),
      paint..color = ColoresApp.bordeDivisor.withValues(alpha: 0.5),
    );

    canvas.drawLine(
      Offset(0, size.height * 0.75),
      Offset(size.width, size.height * 0.75),
      paint,
    );
  }

  Color _getColorNivel(NivelAnsiedad nivel) {
    switch (nivel) {
      case NivelAnsiedad.minima:
        return ColoresApp.exito;
      case NivelAnsiedad.leve:
        return Colors.blue;
      case NivelAnsiedad.moderada:
        return ColoresApp.advertencia;
      case NivelAnsiedad.moderadaGrave:
        return Colors.deepOrange;
      case NivelAnsiedad.severa:
        return ColoresApp.error;
    }
  }

  @override
  bool shouldRepaint(_LineaPainter oldDelegate) {
    return oldDelegate.puntos != puntos;
  }
}
