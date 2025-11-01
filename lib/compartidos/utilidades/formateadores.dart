import 'package:flutter/services.dart';

/// Utilidades para formatear datos
class Formateadores {
  // Constructor privado para prevenir instanciación
  Formateadores._();

  /// Formatea un número de teléfono (XXX XXX XXX)
  static String formatearTelefono(String telefono) {
    final digitos = telefono.replaceAll(RegExp(r'\D'), '');
    if (digitos.length != 9) return telefono;

    return '${digitos.substring(0, 3)} ${digitos.substring(3, 6)} ${digitos.substring(6)}';
  }

  /// Formatea una fecha a dd/MM/yyyy
  static String formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    return '$dia/$mes/$anio';
  }

  /// Formatea una fecha a formato largo (ej: 15 de enero de 2024)
  static String formatearFechaLarga(DateTime fecha) {
    final meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];

    final dia = fecha.day;
    final mes = meses[fecha.month - 1];
    final anio = fecha.year;

    return '$dia de $mes de $anio';
  }

  /// Formatea una hora a HH:mm
  static String formatearHora(DateTime fecha) {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  /// Capitaliza la primera letra de un texto
  static String capitalizarPrimera(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  /// Capitaliza cada palabra de un texto
  static String capitalizarPalabras(String texto) {
    if (texto.isEmpty) return texto;

    return texto.split(' ').map((palabra) {
      if (palabra.isEmpty) return palabra;
      return palabra[0].toUpperCase() + palabra.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Formatea un nombre completo (capitaliza cada palabra)
  static String formatearNombreCompleto(String nombre) {
    return capitalizarPalabras(nombre.trim());
  }

  /// Elimina espacios extras de un texto
  static String limpiarEspacios(String texto) {
    return texto.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Formatea un número con separadores de miles
  static String formatearNumero(int numero) {
    final texto = numero.toString();
    final buffer = StringBuffer();
    var contador = 0;

    for (var i = texto.length - 1; i >= 0; i--) {
      if (contador > 0 && contador % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(texto[i]);
      contador++;
    }

    return buffer.toString().split('').reversed.join();
  }

  /// Trunca un texto a una longitud específica
  static String truncar(String texto, int longitud, {String sufijo = '...'}) {
    if (texto.length <= longitud) return texto;
    return '${texto.substring(0, longitud)}$sufijo';
  }
}

/// InputFormatter para teléfono (9 dígitos)
class TelefonoInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final texto = newValue.text;
    final digitos = texto.replaceAll(RegExp(r'\D'), '');

    // Limita a 9 dígitos
    if (digitos.length > 9) {
      return oldValue;
    }

    // Formatea: XXX XXX XXX
    String formateado = '';
    for (var i = 0; i < digitos.length; i++) {
      if (i == 3 || i == 6) {
        formateado += ' ';
      }
      formateado += digitos[i];
    }

    return TextEditingValue(
      text: formateado,
      selection: TextSelection.collapsed(offset: formateado.length),
    );
  }
}

/// InputFormatter para solo letras (incluyendo acentos)
class SoloLetrasInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final texto = newValue.text;
    final letrasRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]*$');

    if (letrasRegex.hasMatch(texto)) {
      return newValue;
    }

    return oldValue;
  }
}

/// InputFormatter para solo números
class SoloNumerosInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final texto = newValue.text;
    final numerosRegex = RegExp(r'^\d*$');

    if (numerosRegex.hasMatch(texto)) {
      return newValue;
    }

    return oldValue;
  }
}

/// InputFormatter para capitalizar primera letra
class CapitalizarInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final texto = Formateadores.capitalizarPrimera(newValue.text);

    return TextEditingValue(
      text: texto,
      selection: newValue.selection,
    );
  }
}

/// InputFormatter para capitalizar cada palabra
class CapitalizarPalabrasInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final texto = Formateadores.capitalizarPalabras(newValue.text);

    return TextEditingValue(
      text: texto,
      selection: newValue.selection,
    );
  }
}
