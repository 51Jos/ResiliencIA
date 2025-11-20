import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../compartidos/tema/colores_app.dart';

/// Vista TEMPORAL para crear un psicólogo de prueba
/// NOTA: Esta vista debe eliminarse en producción
class CrearPsicologoVista extends StatefulWidget {
  const CrearPsicologoVista({super.key});

  @override
  State<CrearPsicologoVista> createState() => _CrearPsicologoVistaState();
}

class _CrearPsicologoVistaState extends State<CrearPsicologoVista> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController(text: 'Juan Carlos');
  final _apellidosController = TextEditingController(text: 'Pérez García');
  final _correoController = TextEditingController(text: 'psicologo@ucss.edu.pe');
  final _passwordController = TextEditingController(text: 'psicologo123');

  bool _cargando = false;
  String? _mensaje;
  bool? _exito;

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _crearPsicologo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _mensaje = null;
      _exito = null;
    });

    try {
      final correo = _correoController.text.trim();
      final password = _passwordController.text;
      final nombres = _nombresController.text;
      final apellidos = _apellidosController.text;
      final codigo = correo.split('@')[0];
      final nombreCompleto = '$nombres $apellidos';

      // Crear usuario en Firebase Auth
      final FirebaseAuth auth = FirebaseAuth.instance;
      final credencial = await auth.createUserWithEmailAndPassword(
        email: correo,
        password: password,
      );

      if (credencial.user != null) {
        // Actualizar displayName
        await credencial.user!.updateDisplayName(nombreCompleto);

        // Guardar en Firestore con rol psicologo
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        await firestore.collection('usuarios').doc(credencial.user!.uid).set({
          'uid': credencial.user!.uid,
          'codigo': codigo,
          'email': correo,
          'nombres': nombres,
          'apellidos': apellidos,
          'nombreCompleto': nombreCompleto,
          'facultad': 'Ciencias de la Salud',
          'carrera': 'Psicología',
          'filial': 'Nueva Cajamarca',
          'rol': 'psicologo', // ¡ROL DE PSICÓLOGO!
          'fechaRegistro': FieldValue.serverTimestamp(),
          'emailVerificado': false,
          'aceptoTerminos': true,
          'fechaAceptacionTerminos': FieldValue.serverTimestamp(),
          'aceptoPrivacidad': true,
          'fechaAceptacionPrivacidad': FieldValue.serverTimestamp(),
        });

        // Cerrar sesión automáticamente para que pueda hacer login
        await auth.signOut();

        setState(() {
          _cargando = false;
          _exito = true;
          _mensaje = 'Psicólogo creado exitosamente!\n\nEmail: $correo\nPassword: $password\n\nYa puedes hacer login con estas credenciales.';
        });
      }
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al crear psicólogo';
      if (e.code == 'email-already-in-use') {
        mensaje = 'Ya existe un usuario con este correo';
      } else if (e.code == 'weak-password') {
        mensaje = 'La contraseña es muy débil';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El correo no es válido';
      }

      setState(() {
        _cargando = false;
        _exito = false;
        _mensaje = mensaje;
      });
    } catch (e) {
      setState(() {
        _cargando = false;
        _exito = false;
        _mensaje = 'Error inesperado: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPrincipal,
      appBar: AppBar(
        title: const Text('Crear Psicólogo (TEMPORAL)'),
        backgroundColor: ColoresApp.error,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Advertencia
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColoresApp.advertencia.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColoresApp.advertencia),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: ColoresApp.advertencia),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Esta vista es TEMPORAL para crear un psicólogo de prueba. Debe eliminarse en producción.',
                        style: TextStyle(
                          fontSize: 13,
                          color: ColoresApp.textoOscuro,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Campos del formulario
              TextFormField(
                controller: _nombresController,
                decoration: const InputDecoration(
                  labelText: 'Nombres',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _apellidosController,
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(
                  labelText: 'Correo (debe ser @ucss.edu.pe)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Requerido';
                  if (!v!.endsWith('@ucss.edu.pe')) {
                    return 'Debe terminar en @ucss.edu.pe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (v) => (v?.length ?? 0) < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 24),

              // Botón de crear
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _cargando ? null : _crearPsicologo,
                  icon: _cargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.add),
                  label: Text(_cargando ? 'Creando...' : 'Crear Psicólogo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresApp.primario,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              // Mensaje de resultado
              if (_mensaje != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (_exito ?? false)
                        ? ColoresApp.exito.withValues(alpha: 0.1)
                        : ColoresApp.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (_exito ?? false) ? ColoresApp.exito : ColoresApp.error,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        (_exito ?? false) ? Icons.check_circle : Icons.error,
                        color: (_exito ?? false) ? ColoresApp.exito : ColoresApp.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _mensaje!,
                          style: TextStyle(
                            fontSize: 14,
                            color: (_exito ?? false) ? ColoresApp.exito : ColoresApp.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Instrucciones
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Instrucciones:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.textoOscuro,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Completa los campos con los datos del psicólogo\n'
                '2. El correo DEBE terminar en @ucss.edu.pe\n'
                '3. Presiona "Crear Psicólogo"\n'
                '4. Una vez creado, haz login con ese correo y contraseña\n'
                '5. Serás redirigido automáticamente al panel de administración\n\n'
                '⚠️ IMPORTANTE: Elimina esta vista después de crear el psicólogo de prueba.',
                style: TextStyle(
                  fontSize: 13,
                  color: ColoresApp.textoMedio,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
