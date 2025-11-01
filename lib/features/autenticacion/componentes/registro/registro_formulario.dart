import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controladores/auth_controlador.dart';
import '../login/password_campo.dart';
import '../../../../compartidos/componentes/botones/boton_primario.dart';
import '../../../../compartidos/componentes/modales/modal_mensaje.dart';
import '../../../../compartidos/tema/colores_app.dart';
import '../../../legales/vistas/terminos_condiciones_vista.dart';
import '../../../legales/vistas/politica_privacidad_vista.dart';

/// Formulario de registro con validación UCSS
class RegistroFormulario extends StatefulWidget {
  const RegistroFormulario({super.key});

  @override
  State<RegistroFormulario> createState() => _RegistroFormularioState();
}

class _RegistroFormularioState extends State<RegistroFormulario> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _facultadSeleccionada;
  String? _carreraSeleccionada;
  final String _filialFija = 'Nueva Cajamarca';
  bool _aceptaTerminos = false;
  bool _aceptaPrivacidad = false;

  // Lista de facultades
  final List<String> _facultades = [
    'Ingeniería',
    'Ciencias de la Salud',
    'Ciencias Económicas y Comerciales',
    'Derecho y Ciencias Políticas',
    'Educación',
    'Comunicación',
  ];

  // Mapa de carreras por facultad
  final Map<String, List<String>> _carrerasPorFacultad = {
    'Ingeniería': [
      'Ingeniería de Sistemas',
      'Ingeniería Industrial',
      'Ingeniería Civil',
      'Ingeniería Ambiental',
    ],
    'Ciencias de la Salud': [
      'Psicología',
      'Enfermería',
      'Medicina Humana',
      'Estomatología',
    ],
    'Ciencias Económicas y Comerciales': [
      'Administración',
      'Contabilidad',
      'Economía',
      'Marketing',
    ],
    'Derecho y Ciencias Políticas': [
      'Derecho',
      'Ciencias Políticas',
    ],
    'Educación': [
      'Educación Inicial',
      'Educación Primaria',
      'Educación Secundaria',
    ],
    'Comunicación': [
      'Comunicación Audiovisual',
      'Periodismo',
      'Publicidad',
    ],
  };

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistro() async {
    // Valida el formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Valida que se haya seleccionado facultad y carrera
    if (_facultadSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una facultad'),
          backgroundColor: ColoresApp.error,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_carreraSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una carrera'),
          backgroundColor: ColoresApp.error,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Valida que las contraseñas coincidan
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: ColoresApp.error,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Valida que haya aceptado los términos y condiciones
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los Términos y Condiciones'),
          backgroundColor: ColoresApp.error,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Valida que haya aceptado la política de privacidad
    if (!_aceptaPrivacidad) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar la Política de Privacidad'),
          backgroundColor: ColoresApp.error,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Oculta el teclado
    FocusScope.of(context).unfocus();

    // Obtiene el controlador
    final authControlador = Provider.of<AuthControlador>(context, listen: false);

    // Muestra mensaje de registro
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Creando tu cuenta...'),
          ],
        ),
        duration: Duration(seconds: 30),
        backgroundColor: ColoresApp.primario,
      ),
    );

    // Intenta registrar usuario
    final resultado = await authControlador.registrarUsuarioDirecto(
      nombres: _nombresController.text,
      apellidos: _apellidosController.text,
      correo: _correoController.text,
      password: _passwordController.text,
      facultad: _facultadSeleccionada!,
      carrera: _carreraSeleccionada!,
      filial: _filialFija,
    );

    // Oculta el mensaje de validación
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    // Muestra el resultado
    if (mounted) {
      if (resultado.exito) {
        // Muestra modal de éxito
        await ModalMensaje.mostrarExito(
          context: context,
          titulo: 'Cuenta Creada',
          mensaje: 'Tu cuenta ha sido creada exitosamente. Ahora puedes iniciar sesión con tu correo y contraseña.',
          alCerrar: () {
            // Navega al login
            Navigator.of(context).pop();
          },
        );
      } else {
        // Muestra modal de error
        await ModalMensaje.mostrarError(
          context: context,
          titulo: 'Error al Crear Cuenta',
          mensaje: resultado.mensaje,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authControlador = Provider.of<AuthControlador>(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Campo de nombres
          _buildTextField(
            controller: _nombresController,
            label: 'Nombres',
            hint: 'Ingresa tus nombres',
            icon: Icons.person_outline,
            validator: (valor) {
              if (valor == null || valor.isEmpty) {
                return 'Los nombres son requeridos';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Campo de apellidos
          _buildTextField(
            controller: _apellidosController,
            label: 'Apellidos',
            hint: 'Ingresa tus apellidos',
            icon: Icons.person_outline,
            validator: (valor) {
              if (valor == null || valor.isEmpty) {
                return 'Los apellidos son requeridos';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Campo de correo universitario
          _buildTextField(
            controller: _correoController,
            label: 'Correo Universitario',
            hint: 'ejemplo@ucss.pe',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (valor) {
              if (valor == null || valor.isEmpty) {
                return 'El correo es requerido';
              }
              if (!valor.endsWith('@ucss.pe')) {
                return 'Debe ser un correo institucional (@ucss.pe)';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Selector de facultad
          _buildDropdownField(
            label: 'Facultad',
            value: _facultadSeleccionada,
            items: _facultades,
            hint: 'Selecciona tu facultad',
            icon: Icons.school_outlined,
            onChanged: (valor) {
              setState(() {
                _facultadSeleccionada = valor;
                _carreraSeleccionada = null; // Reset carrera al cambiar facultad
              });
            },
          ),
          const SizedBox(height: 20),

          // Selector de carrera
          _buildDropdownField(
            label: 'Carrera',
            value: _carreraSeleccionada,
            items: _facultadSeleccionada != null
                ? _carrerasPorFacultad[_facultadSeleccionada!] ?? []
                : [],
            hint: 'Selecciona tu carrera',
            icon: Icons.menu_book_outlined,
            enabled: _facultadSeleccionada != null,
            onChanged: (valor) {
              setState(() {
                _carreraSeleccionada = valor;
              });
            },
          ),
          const SizedBox(height: 20),

          // Campo de filial (no modificable)
          _buildTextField(
            controller: TextEditingController(text: _filialFija),
            label: 'Filial',
            hint: _filialFija,
            icon: Icons.location_on_outlined,
            enabled: false,
            validator: null,
          ),
          const SizedBox(height: 20),

          // Campo de contraseña
          PasswordCampo(controlador: _passwordController),
          const SizedBox(height: 20),

          // Campo de confirmar contraseña
          _buildConfirmPasswordField(),
          const SizedBox(height: 28),

          // Checkboxes de términos y condiciones
          _buildCheckboxTerminos(),
          const SizedBox(height: 12),
          _buildCheckboxPrivacidad(),
          const SizedBox(height: 28),

          // Botón de registro
          BotonPrimario(
            texto: 'Crear Cuenta',
            alPresionar: authControlador.cargando ? null : _handleRegistro,
            cargando: authControlador.cargando,
            expandir: true,
            icono: Icons.person_add,
          ),

          // Link de volver al login
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¿Ya tienes cuenta? ',
                style: TextStyle(
                  color: ColoresApp.textoClaro,
                  fontSize: 14,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    color: ColoresApp.primario,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: ColoresApp.textoMedio,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (validator != null)
              const Text(
                ' *',
                style: TextStyle(
                  color: ColoresApp.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 15,
            color: enabled ? ColoresApp.textoOscuro : ColoresApp.textoClaro,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            filled: !enabled,
            fillColor: !enabled ? ColoresApp.fondoTarjeta : null,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required void Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: ColoresApp.textoMedio,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(
                color: ColoresApp.error,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            filled: !enabled,
            fillColor: !enabled ? ColoresApp.fondoTarjeta : null,
          ),
          items: items.isEmpty
              ? null
              : items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
          onChanged: enabled ? onChanged : null,
          validator: (valor) {
            if (valor == null || valor.isEmpty) {
              return 'Este campo es requerido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Confirmar Contraseña',
              style: TextStyle(
                color: ColoresApp.textoMedio,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                color: ColoresApp.error,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          style: const TextStyle(
            fontSize: 15,
            color: ColoresApp.textoOscuro,
          ),
          decoration: const InputDecoration(
            hintText: 'Confirma tu contraseña',
            prefixIcon: Icon(Icons.lock_outline, size: 20),
          ),
          validator: (valor) {
            if (valor == null || valor.isEmpty) {
              return 'Debes confirmar tu contraseña';
            }
            if (valor != _passwordController.text) {
              return 'Las contraseñas no coinciden';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCheckboxTerminos() {
    return InkWell(
      onTap: () {
        setState(() {
          _aceptaTerminos = !_aceptaTerminos;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _aceptaTerminos,
            onChanged: (valor) {
              setState(() {
                _aceptaTerminos = valor ?? false;
              });
            },
            activeColor: ColoresApp.primario,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColoresApp.textoMedio,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'Acepto los '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TerminosCondicionesVista(),
                            ),
                          );
                        },
                        child: const Text(
                          'Términos y Condiciones',
                          style: TextStyle(
                            fontSize: 13,
                            color: ColoresApp.primario,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: ' de uso de la aplicación'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxPrivacidad() {
    return InkWell(
      onTap: () {
        setState(() {
          _aceptaPrivacidad = !_aceptaPrivacidad;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _aceptaPrivacidad,
            onChanged: (valor) {
              setState(() {
                _aceptaPrivacidad = valor ?? false;
              });
            },
            activeColor: ColoresApp.primario,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColoresApp.textoMedio,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'Acepto la '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PoliticaPrivacidadVista(),
                            ),
                          );
                        },
                        child: const Text(
                          'Política de Privacidad',
                          style: TextStyle(
                            fontSize: 13,
                            color: ColoresApp.primario,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: ' y el tratamiento de mis datos personales'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
