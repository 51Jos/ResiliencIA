import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../componentes/barra_navegacion_admin.dart';
import '../controladores/administracion_controlador.dart';
import 'lista_estudiantes_vista.dart';
import 'estadisticas_vista.dart';
import '../../notificaciones/vistas/notificaciones_vista.dart';
import '../../notificaciones/servicios/listener_notificaciones_servicio.dart';

/// Panel principal de administración con navegación integrada
/// Punto de entrada para administradores/psicólogos
class PanelAdminVista extends StatefulWidget {
  final String psicologoId;
  final String psicologoNombre;
  final String? psicologoRol;

  const PanelAdminVista({
    super.key,
    required this.psicologoId,
    required this.psicologoNombre,
    this.psicologoRol,
  });

  @override
  State<PanelAdminVista> createState() => _PanelAdminVistaState();
}

class _PanelAdminVistaState extends State<PanelAdminVista> {
  int _indiceActual = 0;
  final ListenerNotificacionesServicio _listenerNotificaciones = ListenerNotificacionesServicio();

  @override
  void initState() {
    super.initState();
    // Iniciar listener de notificaciones en tiempo real
    _listenerNotificaciones.iniciarListener(widget.psicologoId);
  }

  @override
  void dispose() {
    // Detener listener cuando se cierre la vista
    _listenerNotificaciones.detenerListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldAdminAdaptativo(
      indiceNavegacion: _indiceActual,
      alCambiarNavegacion: (indice) {
        setState(() {
          _indiceActual = indice;
        });
      },
      psicologoId: widget.psicologoId,
      appBar: AppBar(
        title: Text(_obtenerTitulo()),
        backgroundColor: ColoresApp.primario,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Información del usuario
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                widget.psicologoNombre,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Menú de usuario
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (valor) {
              if (valor == 'cerrar_sesion') {
                _cerrarSesion(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'perfil',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 20),
                    const SizedBox(width: 12),
                    Text(widget.psicologoNombre),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'rol',
                enabled: false,
                child: Row(
                  children: [
                    const Icon(Icons.badge_outlined, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      widget.psicologoRol == 'admin' ? 'Administrador' : 'Psicólogo',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColoresApp.textoMedio,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'cerrar_sesion',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: ColoresApp.error),
                    SizedBox(width: 12),
                    Text(
                      'Cerrar sesión',
                      style: TextStyle(color: ColoresApp.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _obtenerVista(),
    );
  }

  String _obtenerTitulo() {
    switch (_indiceActual) {
      case 0:
        return 'Gestión de Estudiantes';
      case 1:
        return 'Estadísticas';
      case 2:
        return 'Notificaciones';
      case 3:
        return 'Configuración';
      default:
        return 'Panel de Administración';
    }
  }

  Widget _obtenerVista() {
    switch (_indiceActual) {
      case 0:
        // Vista de estudiantes (extrae solo el body)
        return _ContenidoListaEstudiantes(
          psicologoId: widget.psicologoId,
          psicologoNombre: widget.psicologoNombre,
        );
      case 1:
        // Vista de estadísticas (extrae solo el body)
        return _ContenidoEstadisticas(
          psicologoId: widget.psicologoId,
          psicologoNombre: widget.psicologoNombre,
        );
      case 2:
        // Vista de notificaciones
        return NotificacionesVista(
          psicologoId: widget.psicologoId,
          psicologoNombre: widget.psicologoNombre,
        );
      case 3:
        // Vista de configuración (placeholder)
        return const _ConfiguracionVista();
      default:
        return const Center(child: Text('Vista no encontrada'));
    }
  }

  void _cerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

/// Contenido de lista de estudiantes sin AppBar
/// Extrae solo el body del ListaEstudiantesVista
class _ContenidoListaEstudiantes extends StatefulWidget {
  final String psicologoId;
  final String psicologoNombre;

  const _ContenidoListaEstudiantes({
    required this.psicologoId,
    required this.psicologoNombre,
  });

  @override
  State<_ContenidoListaEstudiantes> createState() => _ContenidoListaEstudiantesState();
}

class _ContenidoListaEstudiantesState extends State<_ContenidoListaEstudiantes> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controlador = context.read<AdministracionControlador>();
      controlador.cargarEstudiantes();
      controlador.cargarListasFiltros();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListaEstudiantesVista(
      psicologoId: widget.psicologoId,
      psicologoNombre: widget.psicologoNombre,
      ocultarAppBar: true, // Ocultar AppBar porque el panel ya tiene uno
    );
  }
}

/// Contenido de estadísticas sin AppBar
/// Extrae solo el body del EstadisticasVista
class _ContenidoEstadisticas extends StatefulWidget {
  final String psicologoId;
  final String psicologoNombre;

  const _ContenidoEstadisticas({
    required this.psicologoId,
    required this.psicologoNombre,
  });

  @override
  State<_ContenidoEstadisticas> createState() => _ContenidoEstadisticasState();
}

class _ContenidoEstadisticasState extends State<_ContenidoEstadisticas> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdministracionControlador>().cargarEstadisticasGlobales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return EstadisticasVista(
      psicologoId: widget.psicologoId,
      psicologoNombre: widget.psicologoNombre,
      ocultarAppBar: true, // Ocultar AppBar porque el panel ya tiene uno
    );
  }
}

/// Vista de configuración (placeholder por ahora)
class _ConfiguracionVista extends StatelessWidget {
  const _ConfiguracionVista();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColoresApp.fondoPrincipal,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings_outlined,
              size: 80,
              color: ColoresApp.textoMedio.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Configuración',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColoresApp.textoMedio.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Próximamente...',
              style: TextStyle(
                fontSize: 14,
                color: ColoresApp.textoMedio.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
