import 'package:flutter/material.dart';
import '../nucleo/configuracion_firebase.dart';
import 'sincronizar_notificaciones_tests.dart';

/// Script ejecutable para sincronizar notificaciones de tests existentes
///
/// USO:
/// 1. En consola: flutter run lib/scripts/ejecutar_sincronizacion_notificaciones.dart
/// 2. Presiona el botón "Sincronizar Notificaciones"
/// 3. Espera a que termine el proceso
/// 4. Revisa el resultado en la pantalla

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfiguracionFirebase.inicializar();
  runApp(const AppSincronizacionNotificaciones());
}

class AppSincronizacionNotificaciones extends StatelessWidget {
  const AppSincronizacionNotificaciones({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sincronización de Notificaciones',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PantallaSincronizacion(),
    );
  }
}

class PantallaSincronizacion extends StatefulWidget {
  const PantallaSincronizacion({super.key});

  @override
  State<PantallaSincronizacion> createState() => _PantallaSincronizacionState();
}

class _PantallaSincronizacionState extends State<PantallaSincronizacion> {
  bool _ejecutando = false;
  String _resultado = '';
  bool _completado = false;
  bool _error = false;

  Future<void> _ejecutarSincronizacion() async {
    setState(() {
      _ejecutando = true;
      _resultado = '';
      _completado = false;
      _error = false;
    });

    try {
      final sincronizador = SincronizadorNotificacionesTests();
      await sincronizador.ejecutar();

      setState(() {
        _ejecutando = false;
        _completado = true;
        _resultado = '✅ Sincronización completada exitosamente';
      });
    } catch (e) {
      setState(() {
        _ejecutando = false;
        _error = true;
        _resultado = '❌ Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronización de Notificaciones'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sync,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Sincronización de Notificaciones para Tests Existentes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Este script creará notificaciones para todos los tests con niveles de ansiedad moderada, moderada-grave o severa que no tengan notificaciones asociadas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              if (_ejecutando) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Sincronizando...'),
              ] else if (_resultado.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _error
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _error ? Colors.red : Colors.green,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _error ? Icons.error : Icons.check_circle,
                        color: _error ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _resultado,
                          style: TextStyle(
                            color: _error ? Colors.red : Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Revisa la consola para ver los detalles completos',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: _ejecutarSincronizacion,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sincronizar Notificaciones'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              if (_completado) ...[
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _resultado = '';
                      _completado = false;
                      _error = false;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Ejecutar de Nuevo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
