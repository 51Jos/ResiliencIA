import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../../../compartidos/componentes/modales/modal_mensaje.dart';
import '../../autenticacion/controladores/auth_controlador.dart';

/// Vista de perfil del estudiante
class PerfilEstudiante extends StatefulWidget {
  const PerfilEstudiante({super.key});

  @override
  State<PerfilEstudiante> createState() => _PerfilEstudianteState();
}

class _PerfilEstudianteState extends State<PerfilEstudiante> {
  final _formKeyPerfil = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();

  // Controladores para datos del perfil
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();

  // Controladores para cambio de contraseña
  final _contrasenaActualController = TextEditingController();
  final _contrasenaNuevaController = TextEditingController();
  final _contrasenaConfirmarController = TextEditingController();

  // Datos no editables
  String _email = '';
  String _codigo = '';
  String _facultad = '';
  String _carrera = '';
  String _filial = '';

  bool _cargando = true;
  bool _modoEdicion = false;
  bool _mostrarPassword = false;
  bool _mostrarPasswordNueva = false;
  bool _mostrarPasswordConfirmar = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _contrasenaActualController.dispose();
    _contrasenaNuevaController.dispose();
    _contrasenaConfirmarController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);

    final authControlador = Provider.of<AuthControlador>(context, listen: false);
    final datos = await authControlador.obtenerDatosUsuario();

    if (datos != null && mounted) {
      setState(() {
        _nombresController.text = datos['nombres'] ?? '';
        _apellidosController.text = datos['apellidos'] ?? '';
        _email = datos['email'] ?? '';
        _codigo = datos['codigo'] ?? '';
        _facultad = datos['facultad'] ?? '';
        _carrera = datos['carrera'] ?? '';
        _filial = datos['filial'] ?? 'Nueva Cajamarca';
        _cargando = false;
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKeyPerfil.currentState!.validate()) return;

    final authControlador = Provider.of<AuthControlador>(context, listen: false);

    final resultado = await authControlador.actualizarNombreApellido(
      nombres: _nombresController.text.trim(),
      apellidos: _apellidosController.text.trim(),
    );

    if (!mounted) return;

    if (resultado.exito) {
      setState(() => _modoEdicion = false);
      await ModalMensaje.mostrarExito(
        context: context,
        titulo: 'Perfil actualizado',
        mensaje: resultado.mensaje,
      );
    } else {
      await ModalMensaje.mostrarError(
        context: context,
        titulo: 'Error',
        mensaje: resultado.mensaje,
      );
    }
  }

  Future<void> _cambiarContrasena() async {
    if (!_formKeyPassword.currentState!.validate()) return;

    final authControlador = Provider.of<AuthControlador>(context, listen: false);

    final resultado = await authControlador.cambiarContrasena(
      contrasenaActual: _contrasenaActualController.text,
      contrasenaNueva: _contrasenaNuevaController.text,
    );

    if (!mounted) return;

    if (resultado.exito) {
      // Limpiar campos
      _contrasenaActualController.clear();
      _contrasenaNuevaController.clear();
      _contrasenaConfirmarController.clear();

      await ModalMensaje.mostrarExito(
        context: context,
        titulo: 'Contraseña actualizada',
        mensaje: resultado.mensaje,
      );
    } else {
      await ModalMensaje.mostrarError(
        context: context,
        titulo: 'Error',
        mensaje: resultado.mensaje,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: ColoresApp.primario),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColoresApp.fondoPrincipal,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: ColoresApp.primario,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar y nombre
            _construirCabecera(),
            const SizedBox(height: 30),

            // Sección de datos personales editables
            _construirSeccionDatosEditables(),
            const SizedBox(height: 20),

            // Sección de información no editable
            _construirSeccionInformacionFija(),
            const SizedBox(height: 20),

            // Sección de cambio de contraseña
            _construirSeccionCambioContrasena(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _construirCabecera() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: ColoresApp.primario.withValues(alpha: 0.1),
            child: const Icon(
              Icons.person,
              size: 60,
              color: ColoresApp.primario,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            '${_nombresController.text} ${_apellidosController.text}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ColoresApp.textoOscuro,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            _codigo,
            style: const TextStyle(
              fontSize: 14,
              color: ColoresApp.textoMedio,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirSeccionDatosEditables() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKeyPerfil,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Datos Personales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoOscuro,
                  ),
                ),
                if (!_modoEdicion)
                  TextButton.icon(
                    onPressed: () => setState(() => _modoEdicion = true),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                    style: TextButton.styleFrom(
                      foregroundColor: ColoresApp.primario,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _nombresController,
              enabled: _modoEdicion,
              decoration: InputDecoration(
                labelText: 'Nombres',
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: _modoEdicion ? Colors.white : ColoresApp.fondoPrincipal,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa tus nombres';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _apellidosController,
              enabled: _modoEdicion,
              decoration: InputDecoration(
                labelText: 'Apellidos',
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: _modoEdicion ? Colors.white : ColoresApp.fondoPrincipal,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa tus apellidos';
                }
                return null;
              },
            ),
            if (_modoEdicion) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _modoEdicion = false);
                        _cargarDatos(); // Recargar datos originales
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColoresApp.textoMedio,
                        side: const BorderSide(color: ColoresApp.textoMedio),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _guardarCambios,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColoresApp.primario,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _construirSeccionInformacionFija() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información Académica',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColoresApp.textoOscuro,
            ),
          ),
          const SizedBox(height: 15),
          _construirItemInformacion(
            icono: Icons.email_outlined,
            etiqueta: 'Correo',
            valor: _email,
          ),
          const Divider(height: 25),
          _construirItemInformacion(
            icono: Icons.school_outlined,
            etiqueta: 'Facultad',
            valor: _facultad,
          ),
          const Divider(height: 25),
          _construirItemInformacion(
            icono: Icons.book_outlined,
            etiqueta: 'Carrera',
            valor: _carrera,
          ),
          const Divider(height: 25),
          _construirItemInformacion(
            icono: Icons.location_on_outlined,
            etiqueta: 'Filial',
            valor: _filial,
          ),
        ],
      ),
    );
  }

  Widget _construirItemInformacion({
    required IconData icono,
    required String etiqueta,
    required String valor,
  }) {
    return Row(
      children: [
        Icon(icono, color: ColoresApp.primario, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: const TextStyle(
                  fontSize: 12,
                  color: ColoresApp.textoMedio,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 15,
                  color: ColoresApp.textoOscuro,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirSeccionCambioContrasena() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKeyPassword,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cambiar Contraseña',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoOscuro,
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _contrasenaActualController,
              obscureText: !_mostrarPassword,
              decoration: InputDecoration(
                labelText: 'Contraseña actual',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _mostrarPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _mostrarPassword = !_mostrarPassword),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu contraseña actual';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _contrasenaNuevaController,
              obscureText: !_mostrarPasswordNueva,
              decoration: InputDecoration(
                labelText: 'Nueva contraseña',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _mostrarPasswordNueva ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _mostrarPasswordNueva = !_mostrarPasswordNueva),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: 'Mínimo 6 caracteres',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa la nueva contraseña';
                }
                if (value.length < 6) {
                  return 'Debe tener al menos 6 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _contrasenaConfirmarController,
              obscureText: !_mostrarPasswordConfirmar,
              decoration: InputDecoration(
                labelText: 'Confirmar nueva contraseña',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _mostrarPasswordConfirmar ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _mostrarPasswordConfirmar = !_mostrarPasswordConfirmar),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirma la nueva contraseña';
                }
                if (value != _contrasenaNuevaController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _cambiarContrasena,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primario,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.key),
                label: const Text('Actualizar Contraseña'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
