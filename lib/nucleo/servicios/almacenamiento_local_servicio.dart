import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para almacenar datos localmente
/// En web: usa SharedPreferences (localStorage)
/// En móvil/desktop: usa archivos JSON en directorio de documentos
class AlmacenamientoLocalServicio {
  static const String _keyUsuarios = 'usuarios_registrados';
  static const String _keyUsuarioActual = 'usuario_actual';
  static const String _nombreArchivoJson = 'usuarios_ucss.json';

  /// Guarda un usuario registrado con todos sus datos
  Future<bool> guardarUsuario({
    required String codigo,
    required Map<String, dynamic> datosCompletos,
  }) async {
    try {
      // Agregar timestamp y metadata
      final usuarioCompleto = {
        ...datosCompletos,
        'codigo': codigo,
        'fechaRegistro': DateTime.now().toIso8601String(),
        'ultimaActualizacion': DateTime.now().toIso8601String(),
      };

      if (kIsWeb) {
        // Web: Usar SharedPreferences (localStorage)
        return await _guardarEnSharedPreferences(codigo, usuarioCompleto);
      } else {
        // Móvil/Desktop: Usar archivo JSON
        return await _guardarEnArchivo(codigo, usuarioCompleto);
      }
    } catch (e) {
      return false;
    }
  }

  /// Guarda en SharedPreferences (para web y como respaldo)
  Future<bool> _guardarEnSharedPreferences(
    String codigo,
    Map<String, dynamic> usuario,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Obtener usuarios existentes
      final usuariosJson = prefs.getString(_keyUsuarios) ?? '{}';
      final usuarios = Map<String, dynamic>.from(json.decode(usuariosJson));

      // Agregar/actualizar usuario
      usuarios[codigo] = usuario;

      // Guardar de vuelta
      await prefs.setString(_keyUsuarios, json.encode(usuarios));

      // Marcar como usuario actual
      await prefs.setString(_keyUsuarioActual, codigo);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Guarda en archivo JSON (para móvil/desktop)
  Future<bool> _guardarEnArchivo(
    String codigo,
    Map<String, dynamic> usuario,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_nombreArchivoJson');

      // Leer archivo existente o crear uno nuevo
      Map<String, dynamic> usuarios = {};
      if (await file.exists()) {
        final contenido = await file.readAsString();
        usuarios = Map<String, dynamic>.from(json.decode(contenido));
      }

      // Agregar/actualizar usuario
      usuarios[codigo] = usuario;

      // Guardar archivo con formato bonito
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(usuarios),
      );

      // También guardar en SharedPreferences como respaldo
      await _guardarEnSharedPreferences(codigo, usuario);

      return true;
    } catch (e) {
      // Intentar guardar solo en SharedPreferences
      return await _guardarEnSharedPreferences(codigo, usuario);
    }
  }

  /// Obtiene un usuario por su código
  Future<Map<String, dynamic>?> obtenerUsuario(String codigo) async {
    try {
      if (kIsWeb) {
        return await _obtenerDeSharedPreferences(codigo);
      } else {
        final usuario = await _obtenerDeArchivo(codigo);
        return usuario ?? await _obtenerDeSharedPreferences(codigo);
      }
    } catch (e) {
      return null;
    }
  }

  /// Obtiene de SharedPreferences
  Future<Map<String, dynamic>?> _obtenerDeSharedPreferences(
    String codigo,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuariosJson = prefs.getString(_keyUsuarios);

      if (usuariosJson == null) return null;

      final usuarios = Map<String, dynamic>.from(json.decode(usuariosJson));
      return usuarios[codigo] as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  /// Obtiene de archivo JSON
  Future<Map<String, dynamic>?> _obtenerDeArchivo(String codigo) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_nombreArchivoJson');

      if (!await file.exists()) return null;

      final contenido = await file.readAsString();
      final usuarios = Map<String, dynamic>.from(json.decode(contenido));

      return usuarios[codigo] as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  /// Obtiene todos los usuarios registrados
  Future<Map<String, dynamic>> obtenerTodosLosUsuarios() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final usuariosJson = prefs.getString(_keyUsuarios) ?? '{}';
        return Map<String, dynamic>.from(json.decode(usuariosJson));
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$_nombreArchivoJson');

        if (!await file.exists()) return {};

        final contenido = await file.readAsString();
        return Map<String, dynamic>.from(json.decode(contenido));
      }
    } catch (e) {
      return {};
    }
  }

  /// Obtiene el usuario actual (último que inició sesión)
  Future<Map<String, dynamic>?> obtenerUsuarioActual() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final codigoActual = prefs.getString(_keyUsuarioActual);

      if (codigoActual == null) return null;

      return await obtenerUsuario(codigoActual);
    } catch (e) {
      return null;
    }
  }

  /// Marca un usuario como actual
  Future<bool> establecerUsuarioActual(String codigo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUsuarioActual, codigo);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Elimina un usuario
  Future<bool> eliminarUsuario(String codigo) async {
    try {
      if (kIsWeb) {
        return await _eliminarDeSharedPreferences(codigo);
      } else {
        final resultadoArchivo = await _eliminarDeArchivo(codigo);
        await _eliminarDeSharedPreferences(codigo);
        return resultadoArchivo;
      }
    } catch (e) {
      return false;
    }
  }

  /// Elimina de SharedPreferences
  Future<bool> _eliminarDeSharedPreferences(String codigo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuariosJson = prefs.getString(_keyUsuarios);

      if (usuariosJson == null) return true;

      final usuarios = Map<String, dynamic>.from(json.decode(usuariosJson));
      usuarios.remove(codigo);

      await prefs.setString(_keyUsuarios, json.encode(usuarios));

      // Si era el usuario actual, limpiar
      final usuarioActual = prefs.getString(_keyUsuarioActual);
      if (usuarioActual == codigo) {
        await prefs.remove(_keyUsuarioActual);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Elimina de archivo JSON
  Future<bool> _eliminarDeArchivo(String codigo) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_nombreArchivoJson');

      if (!await file.exists()) return true;

      final contenido = await file.readAsString();
      final usuarios = Map<String, dynamic>.from(json.decode(contenido));
      usuarios.remove(codigo);

      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(usuarios),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Limpia todos los datos
  Future<bool> limpiarTodo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUsuarios);
      await prefs.remove(_keyUsuarioActual);

      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$_nombreArchivoJson');
        if (await file.exists()) {
          await file.delete();
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Exporta todos los datos como JSON string (útil para backup)
  Future<String?> exportarJSON() async {
    try {
      final usuarios = await obtenerTodosLosUsuarios();
      return const JsonEncoder.withIndent('  ').convert(usuarios);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene la ruta del archivo JSON (solo para móvil/desktop)
  Future<String?> obtenerRutaArchivoJSON() async {
    try {
      if (kIsWeb) return null;

      final directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/$_nombreArchivoJson';
    } catch (e) {
      return null;
    }
  }
}
