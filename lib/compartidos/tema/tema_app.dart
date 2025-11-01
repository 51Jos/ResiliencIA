import 'package:flutter/material.dart';
import 'colores_app.dart';

/// Tema de la aplicación basado en el diseño HTML
class TemaApp {
  // Constructor privado
  TemaApp._();

  /// Tema claro de la aplicación
  static ThemeData get temaClaro {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: ColoresApp.primario,
        secondary: ColoresApp.primarioOscuro,
        surface: ColoresApp.fondoBlanco,
        error: ColoresApp.error,
      ),
      scaffoldBackgroundColor: ColoresApp.fondoPrincipal,

      // Tipografía
      fontFamily: 'Segoe UI',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: ColoresApp.textoOscuro,
        ),
        displayMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: ColoresApp.textoOscuro,
        ),
        displaySmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: ColoresApp.textoOscuro,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ColoresApp.textoOscuro,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ColoresApp.textoOscuro,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: ColoresApp.textoMedio,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: ColoresApp.textoMedio,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: ColoresApp.textoMedio,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: ColoresApp.textoClaro,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: ColoresApp.textoMedio,
        ),
      ),

      // Configuración de AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: ColoresApp.fondoBlanco,
        foregroundColor: ColoresApp.textoOscuro,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ColoresApp.textoOscuro,
        ),
      ),

      // Configuración de Cards
      cardTheme: CardThemeData(
        color: ColoresApp.fondoBlanco,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: ColoresApp.bordeDivisor, width: 1),
        ),
        shadowColor: ColoresApp.sombraLigera,
      ),

      // Configuración de InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColoresApp.fondoBlanco,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: ColoresApp.borde,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: ColoresApp.borde,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: ColoresApp.primario,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: ColoresApp.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: ColoresApp.error,
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(
          color: ColoresApp.textoMedio,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: ColoresApp.textoPlaceholder,
          fontSize: 15,
        ),
        helperStyle: const TextStyle(
          color: ColoresApp.textoClaro,
          fontSize: 13,
        ),
        errorStyle: const TextStyle(
          color: ColoresApp.error,
          fontSize: 13,
        ),
      ),

      // Configuración de botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColoresApp.primario,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Configuración de botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColoresApp.primario,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Configuración de Divider
      dividerTheme: const DividerThemeData(
        color: ColoresApp.bordeDivisor,
        thickness: 1,
        space: 1,
      ),

      // Configuración de Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: ColoresApp.fondoBlanco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
      ),

      // Configuración de SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ColoresApp.textoOscuro,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Espaciados estándar
  static const double espaciadoXS = 4;
  static const double espaciadoS = 8;
  static const double espaciadoM = 16;
  static const double espaciadoL = 24;
  static const double espaciadoXL = 32;
  static const double espaciadoXXL = 40;

  /// Radios de borde
  static const double radioS = 8;
  static const double radioM = 12;
  static const double radioL = 16;

  /// Elevaciones
  static const double elevacionBaja = 2;
  static const double elevacionMedia = 4;
  static const double elevacionAlta = 8;

  /// Tamaños de iconos
  static const double iconoS = 16;
  static const double iconoM = 24;
  static const double iconoL = 32;
  static const double iconoXL = 48;

  /// Anchos máximos
  static const double anchoMaximoFormulario = 440;
  static const double anchoMaximoContenido = 1200;
}
