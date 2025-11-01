import 'package:flutter/material.dart';

/// Colores de la aplicación extraídos del diseño HTML
class ColoresApp {
  // Constructor privado para prevenir instanciación
  ColoresApp._();

  // Color primario principal
  static const Color primario = Color(0xFF4A9D94);
  static const Color primarioOscuro = Color(0xFF3D8479);
  static const Color primarioClaro = Color(0xFFF7FAF9);

  // Colores de texto
  static const Color textoOscuro = Color(0xFF1A202C);
  static const Color textoMedio = Color(0xFF4A5568);
  static const Color textoClaro = Color(0xFF718096);
  static const Color textoPlaceholder = Color(0xFFA0AEC0);

  // Colores de fondo
  static const Color fondoPrincipal = Color(0xFFF0F4F8);
  static const Color fondoBlanco = Color(0xFFFFFFFF);
  static const Color fondoTarjeta = Color(0xFFF7FAF9);

  // Colores de bordes
  static const Color borde = Color(0xFFCBD5E0);
  static const Color bordeDivisor = Color(0xFFE2E8F0);

  // Colores de estado
  static const Color exito = Color(0xFF48BB78);
  static const Color error = Color(0xFFF56565);
  static const Color advertencia = Color(0xFFED8936);
  static const Color informacion = Color(0xFF4299E1);

  // Colores de sombra
  static Color sombraLigera = Colors.black.withValues(alpha: 0.08);
  static Color sombraPrimaria = primario.withValues(alpha: 0.2);
  static Color sombraFoco = primario.withValues(alpha: 0.1);

  // Gradientes
  static const LinearGradient gradientePrimario = LinearGradient(
    colors: [primario, primarioOscuro],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
