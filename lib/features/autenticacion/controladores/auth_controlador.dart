import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../servicios/auth_servicio.dart';

/// Controlador para manejar el estado de autenticación
class AuthControlador extends ChangeNotifier {
  final AuthServicio _authServicio = AuthServicio();

  // Estado de carga
  bool _cargando = false;
  bool get cargando => _cargando;

  // Usuario actual
  User? get usuarioActual => _authServicio.usuarioActual;

  // Verifica si está autenticado
  bool get estaAutenticado => _authServicio.estaAutenticado;

  // Stream del estado de autenticación
  Stream<User?> get estadoAutenticacion => _authServicio.estadoAutenticacion;

  /// Inicia sesión
  Future<ResultadoAuth> iniciarSesion({
    required String email,
    required String password,
  }) async {
    _setCargando(true);

    final resultado = await _authServicio.iniciarSesion(
      email: email,
      password: password,
    );

    _setCargando(false);
    return resultado;
  }


  /// Registra un nuevo usuario directamente con todos los datos
  Future<ResultadoAuth> registrarUsuarioDirecto({
    required String nombres,
    required String apellidos,
    required String correo,
    required String password,
    required String facultad,
    required String carrera,
    required String filial,
  }) async {
    _setCargando(true);

    final resultado = await _authServicio.registrarUsuarioDirecto(
      nombres: nombres,
      apellidos: apellidos,
      correo: correo,
      password: password,
      facultad: facultad,
      carrera: carrera,
      filial: filial,
    );

    _setCargando(false);
    return resultado;
  }

  /// Cierra sesión
  Future<void> cerrarSesion() async {
    _setCargando(true);
    await _authServicio.cerrarSesion();
    _setCargando(false);
  }

  /// Restablece la contraseña
  Future<ResultadoAuth> restablecerPassword(String email) async {
    _setCargando(true);

    final resultado = await _authServicio.restablecerPassword(email);

    _setCargando(false);
    return resultado;
  }

  /// Obtiene los datos del usuario desde Firestore
  Future<Map<String, dynamic>?> obtenerDatosUsuario() async {
    if (usuarioActual == null) return null;
    return await _authServicio.obtenerDatosUsuario(usuarioActual!.uid);
  }

  /// Actualiza el estado de carga
  void _setCargando(bool valor) {
    _cargando = valor;
    notifyListeners();
  }
}
