import 'package:flutter/material.dart';
import '../../tema/colores_app.dart';

/// Modal reutilizable para mostrar mensajes de éxito o error
class ModalMensaje {
  /// Muestra un modal de éxito
  static Future<void> mostrarExito({
    required BuildContext context,
    required String titulo,
    required String mensaje,
    VoidCallback? alCerrar,
  }) {
    return _mostrarModal(
      context: context,
      titulo: titulo,
      mensaje: mensaje,
      tipo: TipoMensaje.exito,
      alCerrar: alCerrar,
    );
  }

  /// Muestra un modal de error
  static Future<void> mostrarError({
    required BuildContext context,
    required String titulo,
    required String mensaje,
    VoidCallback? alCerrar,
  }) {
    return _mostrarModal(
      context: context,
      titulo: titulo,
      mensaje: mensaje,
      tipo: TipoMensaje.error,
      alCerrar: alCerrar,
    );
  }

  /// Muestra un modal de advertencia
  static Future<void> mostrarAdvertencia({
    required BuildContext context,
    required String titulo,
    required String mensaje,
    VoidCallback? alCerrar,
  }) {
    return _mostrarModal(
      context: context,
      titulo: titulo,
      mensaje: mensaje,
      tipo: TipoMensaje.advertencia,
      alCerrar: alCerrar,
    );
  }

  /// Muestra un modal de información
  static Future<void> mostrarInfo({
    required BuildContext context,
    required String titulo,
    required String mensaje,
    VoidCallback? alCerrar,
  }) {
    return _mostrarModal(
      context: context,
      titulo: titulo,
      mensaje: mensaje,
      tipo: TipoMensaje.info,
      alCerrar: alCerrar,
    );
  }

  /// Método privado que muestra el modal
  static Future<void> _mostrarModal({
    required BuildContext context,
    required String titulo,
    required String mensaje,
    required TipoMensaje tipo,
    VoidCallback? alCerrar,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _obtenerColorFondo(tipo),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _obtenerIcono(tipo),
                    size: 32,
                    color: _obtenerColor(tipo),
                  ),
                ),
                const SizedBox(height: 20),

                // Título
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoOscuro,
                  ),
                ),
                const SizedBox(height: 12),

                // Mensaje
                Text(
                  mensaje,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ColoresApp.textoMedio,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Botón
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (alCerrar != null) {
                        alCerrar();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _obtenerColor(tipo),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Entendido',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Obtiene el color según el tipo de mensaje
  static Color _obtenerColor(TipoMensaje tipo) {
    switch (tipo) {
      case TipoMensaje.exito:
        return ColoresApp.exito;
      case TipoMensaje.error:
        return ColoresApp.error;
      case TipoMensaje.advertencia:
        return ColoresApp.advertencia;
      case TipoMensaje.info:
        return ColoresApp.primario;
    }
  }

  /// Obtiene el color de fondo según el tipo de mensaje
  static Color _obtenerColorFondo(TipoMensaje tipo) {
    switch (tipo) {
      case TipoMensaje.exito:
        return ColoresApp.exito.withValues(alpha: 0.1);
      case TipoMensaje.error:
        return ColoresApp.error.withValues(alpha: 0.1);
      case TipoMensaje.advertencia:
        return ColoresApp.advertencia.withValues(alpha: 0.1);
      case TipoMensaje.info:
        return ColoresApp.primario.withValues(alpha: 0.1);
    }
  }

  /// Obtiene el icono según el tipo de mensaje
  static IconData _obtenerIcono(TipoMensaje tipo) {
    switch (tipo) {
      case TipoMensaje.exito:
        return Icons.check_circle;
      case TipoMensaje.error:
        return Icons.error;
      case TipoMensaje.advertencia:
        return Icons.warning;
      case TipoMensaje.info:
        return Icons.info;
    }
  }
}

/// Tipos de mensaje posibles
enum TipoMensaje {
  exito,
  error,
  advertencia,
  info,
}
