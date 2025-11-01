import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

/// Servicio para encriptar y desencriptar resultados de tests
/// Solo el estudiante dueño y los psicólogos pueden desencriptar
class EncriptacionServicio {
  // Clave maestra de la aplicación (en producción, debe estar en variables de entorno)
  static const String _masterKey = 'UCSS_Psicologia_2025_SecureKey_32';

  /// Genera una clave de encriptación derivada del ID del usuario
  static encrypt.Key _generarClave(String usuarioId) {
    // Combina la clave maestra con el ID del usuario
    final combinado = '$_masterKey:$usuarioId';

    // Genera un hash SHA-256
    final bytes = utf8.encode(combinado);
    final digest = sha256.convert(bytes);

    // Toma los primeros 32 bytes para AES-256
    final keyString = digest.toString().substring(0, 32);

    return encrypt.Key.fromUtf8(keyString);
  }

  /// Genera un IV (Initialization Vector) estático basado en el usuario
  static encrypt.IV _generarIV(String usuarioId) {
    // Genera un hash del usuario para el IV
    final bytes = utf8.encode('IV:$usuarioId:$_masterKey');
    final digest = sha256.convert(bytes);

    // Toma los primeros 16 bytes para el IV
    final ivString = digest.toString().substring(0, 16);

    return encrypt.IV.fromUtf8(ivString);
  }

  /// Encripta un mapa de datos usando el ID del usuario
  static String encriptar({
    required Map<String, dynamic> datos,
    required String usuarioId,
  }) {
    try {

      // Convierte el mapa a JSON
      final jsonString = jsonEncode(datos);

      // Genera clave e IV
      final key = _generarClave(usuarioId);
      final iv = _generarIV(usuarioId);

      // Crea el encriptador
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      // Encripta
      final encrypted = encrypter.encrypt(jsonString, iv: iv);
      return encrypted.base64;
    } catch (e) {
      rethrow;
    }
  }

  /// Desencripta datos usando el ID del usuario
  static Map<String, dynamic> desencriptar({
    required String datosEncriptados,
    required String usuarioId,
  }) {
    try {

      // Genera clave e IV
      final key = _generarClave(usuarioId);
      final iv = _generarIV(usuarioId);

      // Crea el encriptador
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      // Desencripta
      final decrypted = encrypter.decrypt64(datosEncriptados, iv: iv);

      // Convierte de JSON a mapa
      final datos = jsonDecode(decrypted) as Map<String, dynamic>;
      return datos;
    } catch (e) {
      rethrow;
    }
  }

  /// Verifica si un usuario tiene permiso para ver un test
  /// - El dueño del test siempre tiene permiso
  /// - Los usuarios con rol 'psicologo' tienen permiso
  static bool tienePermiso({
    required String usuarioId,
    required String? rolUsuario,
    required String propietarioTestId,
  }) {
    // El dueño siempre tiene permiso
    if (usuarioId == propietarioTestId) {
      return true;
    }

    // Los psicólogos tienen permiso para ver todos los tests
    if (rolUsuario == 'psicologo' || rolUsuario == 'admin') {
      return true;
    }

    return false;
  }

  /// Encripta campos sensibles de un resultado de test
  /// Encripta: respuestas, observaciones
  static Map<String, dynamic> encriptarResultado({
    required Map<String, dynamic> resultado,
    required String usuarioId,
  }) {
    try {
      // Extrae los campos sensibles
      final datosSensibles = {
        'respuestas': resultado['respuestas'],
        'observaciones': resultado['observaciones'],
      };

      // Encripta los datos sensibles
      final datosEncriptados = encriptar(
        datos: datosSensibles,
        usuarioId: usuarioId,
      );

      // Crea una copia del resultado sin los campos sensibles
      final resultadoEncriptado = Map<String, dynamic>.from(resultado);
      resultadoEncriptado.remove('respuestas');
      resultadoEncriptado.remove('observaciones');

      // Agrega los datos encriptados
      resultadoEncriptado['datosEncriptados'] = datosEncriptados;
      resultadoEncriptado['encriptado'] = true;
      return resultadoEncriptado;
    } catch (e) {
      rethrow;
    }
  }

  /// Desencripta campos sensibles de un resultado de test
  static Map<String, dynamic> desencriptarResultado({
    required Map<String, dynamic> resultadoEncriptado,
    required String usuarioId,
  }) {
    try {
      // Si no está encriptado, retorna tal cual
      if (resultadoEncriptado['encriptado'] != true) {
        return resultadoEncriptado;
      }

      // Obtiene los datos encriptados
      final datosEncriptados = resultadoEncriptado['datosEncriptados'] as String;

      // Desencripta
      final datosSensibles = desencriptar(
        datosEncriptados: datosEncriptados,
        usuarioId: usuarioId,
      );

      // Crea una copia del resultado
      final resultadoDesencriptado = Map<String, dynamic>.from(resultadoEncriptado);
      resultadoDesencriptado.remove('datosEncriptados');
      resultadoDesencriptado.remove('encriptado');

      // Agrega los datos desencriptados
      resultadoDesencriptado['respuestas'] = datosSensibles['respuestas'];
      resultadoDesencriptado['observaciones'] = datosSensibles['observaciones'];

      return resultadoDesencriptado;
    } catch (e) {
      rethrow;
    }
  }
}
