import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tema/colores_app.dart';

/// Widget reutilizable para campos de texto
class CampoTexto extends StatelessWidget {
  final String? etiqueta;
  final String? placeholder;
  final String? textoAyuda;
  final IconData? icono;
  final TextEditingController? controlador;
  final String? Function(String?)? validador;
  final TextInputType tipoTeclado;
  final bool esPassword;
  final bool requerido;
  final bool soloLectura;
  final int? maxLineas;
  final int? maxCaracteres;
  final List<TextInputFormatter>? formatters;
  final void Function(String)? alCambiar;
  final void Function(String)? alEnviar;
  final Widget? sufijo;
  final Widget? prefijo;
  final bool habilitado;
  final String? textoInicial;
  final FocusNode? focusNode;

  const CampoTexto({
    super.key,
    this.etiqueta,
    this.placeholder,
    this.textoAyuda,
    this.icono,
    this.controlador,
    this.validador,
    this.tipoTeclado = TextInputType.text,
    this.esPassword = false,
    this.requerido = false,
    this.soloLectura = false,
    this.maxLineas = 1,
    this.maxCaracteres,
    this.formatters,
    this.alCambiar,
    this.alEnviar,
    this.sufijo,
    this.prefijo,
    this.habilitado = true,
    this.textoInicial,
    this.focusNode,
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

        // Campo de texto
        TextFormField(
          controller: controlador,
          initialValue: textoInicial,
          focusNode: focusNode,
          enabled: habilitado,
          readOnly: soloLectura,
          obscureText: esPassword,
          keyboardType: tipoTeclado,
          maxLines: esPassword ? 1 : maxLineas,
          maxLength: maxCaracteres,
          inputFormatters: formatters,
          style: const TextStyle(
            fontSize: 15,
            color: ColoresApp.textoOscuro,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            prefixIcon: prefijo ?? (icono != null ? Icon(icono, size: 20) : null),
            suffixIcon: sufijo,
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
          onFieldSubmitted: alEnviar,
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
