import 'package:flutter/material.dart';
import '../../tema/colores_app.dart';

/// Widget reutilizable para selección de hora
class CampoHora extends StatefulWidget {
  final String? etiqueta;
  final String? placeholder;
  final String? textoAyuda;
  final TimeOfDay? horaInicial;
  final void Function(TimeOfDay?) alSeleccionar;
  final String? Function(TimeOfDay?)? validador;
  final bool requerido;
  final bool habilitado;

  const CampoHora({
    super.key,
    this.etiqueta,
    this.placeholder,
    this.textoAyuda,
    this.horaInicial,
    required this.alSeleccionar,
    this.validador,
    this.requerido = false,
    this.habilitado = true,
  });

  @override
  State<CampoHora> createState() => _CampoHoraState();
}

class _CampoHoraState extends State<CampoHora> {
  TimeOfDay? _horaSeleccionada;
  final TextEditingController _controlador = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.horaInicial != null) {
      _horaSeleccionada = widget.horaInicial;
      _actualizarTexto();
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  String _formatearHora(TimeOfDay hora) {
    final horas = hora.hour.toString().padLeft(2, '0');
    final minutos = hora.minute.toString().padLeft(2, '0');
    return '$horas:$minutos';
  }

  void _actualizarTexto() {
    if (_horaSeleccionada != null) {
      _controlador.text = _formatearHora(_horaSeleccionada!);
    } else {
      _controlador.clear();
    }
  }

  Future<void> _seleccionarHora() async {
    if (!widget.habilitado) return;

    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColoresApp.primario,
              onPrimary: Colors.white,
              surface: ColoresApp.fondoBlanco,
            ),
          ),
          child: child!,
        );
      },
    );

    if (hora != null) {
      setState(() {
        _horaSeleccionada = hora;
        _actualizarTexto();
      });
      widget.alSeleccionar(hora);
    }
  }

  void _limpiarHora() {
    setState(() {
      _horaSeleccionada = null;
      _controlador.clear();
    });
    widget.alSeleccionar(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta
        if (widget.etiqueta != null) ...[
          Row(
            children: [
              Text(
                widget.etiqueta!,
                style: const TextStyle(
                  color: ColoresApp.textoMedio,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.requerido)
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

        // Campo de hora
        TextFormField(
          controller: _controlador,
          readOnly: true,
          enabled: widget.habilitado,
          style: const TextStyle(
            fontSize: 15,
            color: ColoresApp.textoOscuro,
          ),
          decoration: InputDecoration(
            hintText: widget.placeholder ?? 'Seleccionar hora',
            prefixIcon: const Icon(Icons.access_time, size: 20),
            suffixIcon: _horaSeleccionada != null
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: widget.habilitado ? _limpiarHora : null,
                  )
                : null,
          ),
          onTap: _seleccionarHora,
          validator: (valor) {
            if (widget.requerido && _horaSeleccionada == null) {
              return '${widget.etiqueta ?? 'La hora'} es requerida';
            }
            if (widget.validador != null) {
              return widget.validador!(_horaSeleccionada);
            }
            return null;
          },
        ),

        // Texto de ayuda
        if (widget.textoAyuda != null) ...[
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
                  widget.textoAyuda!,
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
