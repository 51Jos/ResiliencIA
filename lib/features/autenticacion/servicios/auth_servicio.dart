import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio de autenticación con Firebase
class AuthServicio {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene el usuario actual
  User? get usuarioActual => _auth.currentUser;

  /// Stream del estado de autenticación
  Stream<User?> get estadoAutenticacion => _auth.authStateChanges();

  /// Verifica si hay un usuario autenticado
  bool get estaAutenticado => _auth.currentUser != null;

  /// Inicia sesión con email y contraseña
  Future<ResultadoAuth> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      // Valida que sea email institucional UCSS
      if (!email.endsWith('@ucss.pe')) {
        return ResultadoAuth(
          exito: false,
          mensaje: 'Debes usar tu correo institucional UCSS (@ucss.pe)',
        );
      }

      // Intenta iniciar sesión
      final credencial = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credencial.user != null) {
        return ResultadoAuth(
          exito: true,
          mensaje: 'Inicio de sesión exitoso',
          usuario: credencial.user,
        );
      }

      return ResultadoAuth(
        exito: false,
        mensaje: 'Error al iniciar sesión',
      );
    } on FirebaseAuthException catch (e) {
      return ResultadoAuth(
        exito: false,
        mensaje: _manejarErrorAuth(e),
      );
    } catch (e) {
      return ResultadoAuth(
        exito: false,
        mensaje: 'Error inesperado: ${e.toString()}',
      );
    }
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
    try {
      // Valida que sea email institucional UCSS
      if (!correo.endsWith('@ucss.pe')) {
        return ResultadoAuth(
          exito: false,
          mensaje: 'Debes usar tu correo institucional UCSS (@ucss.pe)',
        );
      }

      // Extrae el código del correo (parte antes de @ucss.pe)
      final codigo = correo.split('@')[0];
      final nombreCompleto = '$nombres $apellidos';

      // Crea el usuario en Firebase Auth
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: correo.trim(),
        password: password,
      );

      if (credencial.user != null) {
        // Actualiza el nombre del usuario
        await credencial.user!.updateDisplayName(nombreCompleto);

        // Guarda información en Firestore
        await _firestore.collection('usuarios').doc(credencial.user!.uid).set({
          'uid': credencial.user!.uid,
          'codigo': codigo,
          'email': correo.trim(),
          'nombres': nombres,
          'apellidos': apellidos,
          'nombreCompleto': nombreCompleto,
          'facultad': facultad,
          'carrera': carrera,
          'filial': filial,
          'rol': 'estudiante',
          'fechaRegistro': FieldValue.serverTimestamp(),
          'emailVerificado': false,
          // Términos y condiciones
          'aceptoTerminos': true,
          'fechaAceptacionTerminos': FieldValue.serverTimestamp(),
          'aceptoPrivacidad': true,
          'fechaAceptacionPrivacidad': FieldValue.serverTimestamp(),
        });

        return ResultadoAuth(
          exito: true,
          mensaje: 'Cuenta creada exitosamente',
          usuario: credencial.user,
        );
      }

      return ResultadoAuth(
        exito: false,
        mensaje: 'Error al crear la cuenta',
      );
    } on FirebaseAuthException catch (e) {
      return ResultadoAuth(
        exito: false,
        mensaje: _manejarErrorAuth(e),
      );
    } catch (e) {
      return ResultadoAuth(
        exito: false,
        mensaje: 'Error inesperado: ${e.toString()}',
      );
    }
  }


  /// Cierra sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  /// Envía email para restablecer contraseña
  Future<ResultadoAuth> restablecerPassword(String email) async {
    try {
      if (!email.endsWith('@ucss.pe')) {
        return ResultadoAuth(
          exito: false,
          mensaje: 'Debes usar tu correo institucional UCSS (@ucss.pe)',
        );
      }

      await _auth.sendPasswordResetEmail(email: email.trim());

      return ResultadoAuth(
        exito: true,
        mensaje: 'Se ha enviado un correo para restablecer tu contraseña',
      );
    } on FirebaseAuthException catch (e) {
      return ResultadoAuth(
        exito: false,
        mensaje: _manejarErrorAuth(e),
      );
    } catch (e) {
      return ResultadoAuth(
        exito: false,
        mensaje: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Obtiene información del usuario desde Firestore
  Future<Map<String, dynamic>?> obtenerDatosUsuario(String uid) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  /// Maneja errores de Firebase Auth
  String _manejarErrorAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo electrónico';
      case 'weak-password':
        return 'La contraseña es demasiado débil. Debe tener al menos 8 caracteres';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta nuevamente más tarde';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'invalid-credential':
        return 'Las credenciales proporcionadas son incorrectas';
      default:
        return 'Error de autenticación: ${e.message ?? e.code}';
    }
  }
}

/// Resultado de una operación de autenticación
class ResultadoAuth {
  final bool exito;
  final String mensaje;
  final User? usuario;

  ResultadoAuth({
    required this.exito,
    required this.mensaje,
    this.usuario,
  });
}
