import 'package:flutter/material.dart';
import '../servicios/administracion_servicio.dart';
import '../../../compartidos/tema/colores_app.dart';

/// Guard para verificar que el usuario tiene permisos de administrador
/// Requiere: rol 'psicologo' o 'admin' Y email UCSS (@ucss.pe o @ucss.edu.pe)
class AdminGuard extends StatefulWidget {
  final String usuarioId;
  final Widget child;
  final Widget? vistaNoAutorizada;

  const AdminGuard({
    super.key,
    required this.usuarioId,
    required this.child,
    this.vistaNoAutorizada,
  });

  @override
  State<AdminGuard> createState() => _AdminGuardState();
}

class _AdminGuardState extends State<AdminGuard> {
  final AdministracionServicio _servicio = AdministracionServicio();
  bool _cargando = true;
  bool _esAutorizado = false;

  @override
  void initState() {
    super.initState();
    _verificarPermisos();
  }

  Future<void> _verificarPermisos() async {
    final esAdmin = await _servicio.esAdministrador(widget.usuarioId);

    if (mounted) {
      setState(() {
        _esAutorizado = esAdmin;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        backgroundColor: ColoresApp.fondoPrincipal,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColoresApp.primario),
          ),
        ),
      );
    }

    if (!_esAutorizado) {
      return widget.vistaNoAutorizada ?? _VistaNoAutorizada();
    }

    return widget.child;
  }
}

/// Vista por defecto cuando el usuario no está autorizado
class _VistaNoAutorizada extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPrincipal,
      appBar: AppBar(
        title: const Text('Acceso denegado'),
        backgroundColor: ColoresApp.primario,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ColoresApp.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.block,
                  size: 64,
                  color: ColoresApp.error,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Acceso restringido',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.textoOscuro,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'No tienes los permisos necesarios para acceder a esta sección.',
                style: TextStyle(
                  fontSize: 16,
                  color: ColoresApp.textoMedio,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta área es exclusiva para psicólogos con correo institucional UCSS',
                style: TextStyle(
                  fontSize: 14,
                  color: ColoresApp.textoClaro,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primario,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
