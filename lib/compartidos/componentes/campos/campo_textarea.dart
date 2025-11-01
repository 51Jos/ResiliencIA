import 'package:flutter/material.dart';
import '../../tema/colores_app.dart';

/// Widget reutilizable para área de texto multilínea
class CampoTextarea extends StatelessWidget {
  final String? etiqueta;
  final String? placeholder;
  final String? textoAyuda;
  final TextEditingController? controlador;
  final String? Function(String?)? validador;
  final bool requerido;
  final bool habilitado;
  final int lineasMinimas;
  final int? lineasMaximas;
  final int? maxCaracteres;
  final void Function(String)? alCambiar;
  final String? textoInicial;

  const CampoTextarea({
    super.key,
    this.etiqueta,
    this.placeholder,
    this.textoAyuda,
    this.controlador,
    this.validador,
    this.requerido = false,
    this.habilitado = true,
    this.lineasMinimas = 4,
    this.lineasMaximas,
    this.maxCaracteres,
    this.alCambiar,
    this.textoInicial,
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

        // Campo de texto multilínea
        TextFormField(
          controller: controlador,
          initialValue: textoInicial,
          enabled: habilitado,
          keyboardType: TextInputType.multiline,
          minLines: lineasMinimas,
          maxLines: lineasMaximas,
          maxLength: maxCaracteres,
          style: const TextStyle(
            fontSize: 15,
            color: ColoresApp.textoOscuro,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            alignLabelWithHint: true,
            counterText: maxCaracteres != null ? null : '',
          ),
          validator: (valor) {
            // Validación de campo requerido
            if (requerido && (valor == null || valor.trim().isEmpty)) {
              return '${etiqueta ?? 'Este campo'} es requerido';
            }
            // Validación personalizada
            if (validador != null) {
              return validador!(valor);
            }
            return null;
          },
          onChanged: alCambiar,
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
