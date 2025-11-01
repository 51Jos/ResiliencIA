/// Utilidades para validación de formularios
class Validadores {
  // Constructor privado para prevenir instanciación
  Validadores._();

  /// Valida que un campo no esté vacío
  static String? requerido(String? valor, [String? nombreCampo]) {
    if (valor == null || valor.trim().isEmpty) {
      return '${nombreCampo ?? 'Este campo'} es requerido';
    }
    return null;
  }

  /// Valida formato de email
  static String? email(String? valor) {
    if (valor == null || valor.isEmpty) {
      return null;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(valor)) {
      return 'Ingresa un correo electrónico válido';
    }

    return null;
  }

  /// Valida formato de email institucional UCSS
  static String? emailUCSS(String? valor) {
    if (valor == null || valor.isEmpty) {
      return null;
    }

    final ucssEmailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@ucss\.pe$',
    );

    if (!ucssEmailRegex.hasMatch(valor)) {
      return 'Usa tu correo institucional UCSS (ejemplo@ucss.pe)';
    }

    return null;
  }

  /// Valida longitud mínima de caracteres
  static String? longitudMinima(String? valor, int minimo, [String? nombreCampo]) {
    if (valor == null || valor.isEmpty) {
      return null;
    }

    if (valor.length < minimo) {
      return '${nombreCampo ?? 'Este campo'} debe tener al menos $minimo caracteres';
    }

    return null;
  }

  /// Valida longitud máxima de caracteres
  static String? longitudMaxima(String? valor, int maximo, [String? nombreCampo]) {
    if (valor == null || valor.isEmpty) {
      return null;
    }

    if (valor.length > maximo) {
      return '${nombreCampo ?? 'Este campo'} no puede exceder $maximo caracteres';
    }

    return null;
  }

  /// Valida rango de longitud
  static String? longitudRango(String? valor, int minimo, int maximo, [String? nombreCampo]) {
    if (valor == null || valor.isEmpty) {
      return null;
    }

    if (valor.length < minimo || valor.length > maximo) {
      return '${nombreCampo ?? 'Este campo'} debe tener entre $minimo y $maximo caracteres';
    }

    return null;
  }

  /// Valida formato de teléfono (9 dígitos en Perú)
  static String? telefono(String? valor) {
    if (valor == null || valor.isEmpty) {
      return null;
    }

    final telefonoRegex = RegExp(r'^[9]\d{8}$');

    if (!telefonoRegex.hasMatch(valor)) {
      return 'Ingresa un número de teléfono válido (9 dígitos)';
    }

    return null;
  }

  /// Valida que sea solo números
  static String? soloNumeros(String? valor, [String? nombreCampo]) {
    if (valor == null || valor.isEmpty) {
      return null;
    }

    final numerosRegex = RegExp(r'^\d+$');

    if (!numerosRegex.hasMatch(valor)) {
      return '${nombreCampo ?? 'Este campo'} debe contener solo números';
    }

    return null;
  }

  /// Valida que sea solo letras
  static String? soloLetras(String? valor, [String? nombreCampo]) {
    if (valor == null || valor.isEmpty) {
      return null;
    }

    final letrasRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');

    if (!letrasRegex.hasMatch(valor)) {
      return '${nombreCampo ?? 'Este campo'} debe contener solo letras';
    }

    return null;
  }

  /// Valida contraseña (mínimo 8 caracteres)
  static String? password(String? valor) {
    if (valor == null || valor.isEmpty) {
      return null;
    }

    if (valor.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    return null;
  }

  /// Valida contraseña segura (letras, números y caracteres especiales)
  static String? passwordSegura(String? valor) {
    if (valor == null || valor.isEmpty) {
      return null;
    }

    if (valor.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    // Valida que tenga al menos una letra mayúscula
    if (!RegExp(r'[A-Z]').hasMatch(valor)) {
      return 'La contraseña debe contener al menos una letra mayúscula';
    }

    // Valida que tenga al menos una letra minúscula
    if (!RegExp(r'[a-z]').hasMatch(valor)) {
      return 'La contraseña debe contener al menos una letra minúscula';
    }

    // Valida que tenga al menos un número
    if (!RegExp(r'\d').hasMatch(valor)) {
      return 'La contraseña debe contener al menos un número';
    }

    return null;
  }

  /// Valida que dos campos coincidan (ej: confirmar contraseña)
  static String? coincidenCampos(String? valor1, String? valor2, [String? nombreCampo]) {
    if (valor1 != valor2) {
      return '${nombreCampo ?? 'Los campos'} no coinciden';
    }
    return null;
  }

  /// Valida fecha no futura
  static String? fechaNoFutura(DateTime? fecha) {
    if (fecha == null) {
      return null;
    }

    final ahora = DateTime.now();
    if (fecha.isAfter(ahora)) {
      return 'La fecha no puede ser futura';
    }

    return null;
  }

  /// Valida fecha no pasada
  static String? fechaNoPasada(DateTime? fecha) {
    if (fecha == null) {
      return null;
    }

    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final fechaSeleccionada = DateTime(fecha.year, fecha.month, fecha.day);

    if (fechaSeleccionada.isBefore(hoy)) {
      return 'La fecha no puede ser pasada';
    }

    return null;
  }

  /// Combina múltiples validadores
  static String? Function(String?) combinar(List<String? Function(String?)> validadores) {
    return (valor) {
      for (final validador in validadores) {
        final error = validador(valor);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }
}
