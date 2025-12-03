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
      // Valida que sea email institucional UCSS (acepta @ucss.pe y @ucss.edu.pe)
      if (!email.endsWith('@ucss.pe') && !email.endsWith('@ucss.edu.pe')) {
        return ResultadoAuth(
          exito: false,
          mensaje: 'Debes usar tu correo institucional UCSS (@ucss.pe o @ucss.edu.pe)',
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
      // Valida que sea email institucional UCSS (acepta @ucss.pe y @ucss.edu.pe)
      if (!correo.endsWith('@ucss.pe') && !correo.endsWith('@ucss.edu.pe')) {
        return ResultadoAuth(
          exito: false,
          mensaje: 'Debes usar tu correo institucional UCSS (@ucss.pe o @ucss.edu.pe)',
        );
      }

      // Extrae el código del correo (parte antes de @ucss.edu.pe)
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
      // Valida que sea email institucional UCSS (acepta @ucss.pe y @ucss.edu.pe)
      if (!email.endsWith('@ucss.pe') && !email.endsWith('@ucss.edu.pe')) {
        return ResultadoAuth(
          exito: false,
          mensaje: 'Debes usar tu correo institucional UCSS (@ucss.pe o @ucss.edu.pe)',
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

  /// Actualiza el nombre y apellido del usuario
  Future<ResultadoAuth> actualizarNombreApellido({
    required String uid,
    required String nombres,
    required String apellidos,
  }) async {
    try {
      final nombreCompleto = '$nombres $apellidos';

      // Actualizar en Firebase Auth
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(nombreCompleto);
      }

      // Actualizar en Firestore
      await _firestore.collection('usuarios').doc(uid).update({
        'nombres': nombres,
        'apellidos': apellidos,
        'nombreCompleto': nombreCompleto,
      });

      return ResultadoAuth(
        exito: true,
        mensaje: 'Perfil actualizado correctamente',
      );
    } catch (e) {
      return ResultadoAuth(
        exito: false,
        mensaje: 'Error al actualizar perfil: ${e.toString()}',
      );
    }
  }

  /// Cambia la contraseña del usuario
  Future<ResultadoAuth> cambiarContrasena({
    required String contrasenaActual,
    required String contrasenaNueva,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return ResultadoAuth(
          exito: false,
          mensaje: 'No hay usuario autenticado',
        );
      }

      // Re-autenticar al usuario con su contraseña actual
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: contrasenaActual,
      );

      try {
        await user.reauthenticateWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          return ResultadoAuth(
            exito: false,
            mensaje: 'La contraseña actual es incorrecta',
          );
        }
        rethrow;
      }

      // Validar que la nueva contraseña tenga al menos 6 caracteres
      if (contrasenaNueva.length < 6) {
        return ResultadoAuth(
          exito: false,
          mensaje: 'La nueva contraseña debe tener al menos 6 caracteres',
        );
      }

      // Actualizar la contraseña
      await user.updatePassword(contrasenaNueva);

      return ResultadoAuth(
        exito: true,
        mensaje: 'Contraseña actualizada correctamente',
      );
    } on FirebaseAuthException catch (e) {
      return ResultadoAuth(
        exito: false,
        mensaje: _manejarErrorAuth(e),
      );
    } catch (e) {
      return ResultadoAuth(
        exito: false,
        mensaje: 'Error al cambiar contraseña: ${e.toString()}',
      );
    }
  }

  /// Maneja errores de Firebase Auth
  String _manejarErrorAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return '❌ No existe una cuenta con este correo.\n\n'
            '💡 ¿Es tu primera vez? Haz clic en "Crear cuenta" para registrarte.\n'
            '💡 Verifica que escribiste correctamente tu correo institucional UCSS';

      case 'wrong-password':
        return '❌ Contraseña incorrecta.\n\n'
            '💡 Verifica que escribiste correctamente tu contraseña.\n'
            '💡 Recuerda que las contraseñas distinguen mayúsculas y minúsculas.';

      case 'invalid-credential':
        return '❌ Correo o contraseña incorrectos.\n\n'
            '💡 Verifica que escribiste correctamente ambos campos.\n'
            '💡 Asegúrate de usar tu correo institucional UCSS';

      case 'email-already-in-use':
        return '❌ Ya existe una cuenta con este correo.\n\n'
            '💡 Si ya tienes cuenta, usa "Iniciar sesión".\n'
            '💡 Si olvidaste tu contraseña, contacta a soporte.';

      case 'weak-password':
        return '❌ Contraseña muy débil.\n\n'
            '💡 Debe tener al menos 6 caracteres.\n'
            '💡 Usa una combinación de letras, números y símbolos.';

      case 'invalid-email':
        return '❌ Formato de correo inválido.\n\n'
            '💡 Verifica que sea un correo válido.\n'
            '💡 Debe ser un correo institucional UCSS (@ucss.pe o @ucss.edu.pe)';

      case 'user-disabled':
        return '❌ Esta cuenta ha sido deshabilitada.\n\n'
            '💡 Contacta al administrador del sistema.\n'
            '📧 soporte@ucss.edu.pe';

      case 'too-many-requests':
        return '⏸️ Demasiados intentos fallidos.\n\n'
            '💡 Por seguridad, espera unos minutos antes de intentar de nuevo.\n'
            '💡 Si el problema persiste, contacta a soporte.';

      case 'operation-not-allowed':
        return '❌ Operación no permitida.\n\n'
            '💡 Este método de autenticación no está habilitado.\n'
            '💡 Contacta al administrador del sistema.';

      case 'network-request-failed':
        return '🌐 Error de conexión.\n\n'
            '💡 Verifica tu conexión a internet.\n'
            '💡 Intenta nuevamente en unos momentos.';

      default:
        // Mostrar código de error para debugging
        return '❌ Error de autenticación: ${e.code}\n\n'
            '💡 Si el problema persiste, contacta a soporte.\n'
            '📧 soporte@ucss.edu.pe\n\n'
            'Código de error: ${e.code}';
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
