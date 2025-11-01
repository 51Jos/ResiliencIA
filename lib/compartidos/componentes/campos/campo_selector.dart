import 'package:flutter/material.dart';
import '../../tema/colores_app.dart';

/// Widget reutilizable para selector dropdown
class CampoSelector<T> extends StatelessWidget {
  final String? etiqueta;
  final String? placeholder;
  final String? textoAyuda;
  final T? valorInicial;
  final List<OpcionSelector<T>> opciones;
  final void Function(T?) alSeleccionar;
  final String? Function(T?)? validador;
  final bool requerido;
  final bool habilitado;
  final Widget? icono;

  const CampoSelector({
    super.key,
    this.etiqueta,
    this.placeholder,
    this.textoAyuda,
    this.valorInicial,
    required this.opciones,
    required this.alSeleccionar,
    this.validador,
    this.requerido = false,
    this.habilitado = true,
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta
        if (etiqueta != null) ...[
          Row(
            children: [
              Text(
                etiqueta!,
                style: const TextStyle(
                  color: ColoresApp.textoMedio,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (requerido)
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
        ],

        // Dropdown
        DropdownButtonFormField<T>(
          value: valorInicial,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: placeholder ?? 'Seleccionar opción',
            prefixIcon: icono,
          ),
          style: const TextStyle(
            fontSize: 15,
            color: ColoresApp.textoOscuro,
          ),
          icon: const Icon(Icons.arrow_drop_down, color: ColoresApp.textoMedio),
          dropdownColor: ColoresApp.fondoBlanco,
          items: opciones.map((opcion) {
            return DropdownMenuItem<T>(
              value: opcion.valor,
              child: Row(
                children: [
                  if (opcion.icono != null) ...[
                    opcion.icono!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      opcion.etiqueta,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: habilitado ? alSeleccionar : null,
          validator: (valor) {
            if (requerido && valor == null) {
              return '${etiqueta ?? 'Este campo'} es requerido';
            }
            if (validador != null) {
              return validador!(valor);
            }
            return null;
          },
        ),

        // Texto de ayuda
        if (textoAyuda != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: ColoresApp.primario,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  textoAyuda!,
                  style: const TextStyle(
                    color: ColoresApp.textoClaro,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Clase para representar una opción del selector
class OpcionSelector<T> {
  final T valor;
  final String etiqueta;
  final Widget? icono;

  const OpcionSelector({
    required this.valor,
    required this.etiqueta,
    this.icono,
  });
}
