import 'package:flutter/material.dart';
import '../../tema/colores_app.dart';

/// Widget reutilizable para selección de fecha
class CampoFecha extends StatefulWidget {
  final String? etiqueta;
  final String? placeholder;
  final String? textoAyuda;
  final DateTime? fechaInicial;
  final DateTime? fechaMinima;
  final DateTime? fechaMaxima;
  final void Function(DateTime?) alSeleccionar;
  final String? Function(DateTime?)? validador;
  final bool requerido;
  final bool habilitado;

  const CampoFecha({
    super.key,
    this.etiqueta,
    this.placeholder,
    this.textoAyuda,
    this.fechaInicial,
    this.fechaMinima,
    this.fechaMaxima,
    required this.alSeleccionar,
    this.validador,
    this.requerido = false,
    this.habilitado = true,
  });

  @override
  State<CampoFecha> createState() => _CampoFechaState();
}

class _CampoFechaState extends State<CampoFecha> {
  DateTime? _fechaSeleccionada;
  final TextEditingController _controlador = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.fechaInicial != null) {
      _fechaSeleccionada = widget.fechaInicial;
      _actualizarTexto();
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    return '$dia/$mes/$anio';
  }

  void _actualizarTexto() {
    if (_fechaSeleccionada != null) {
      _controlador.text = _formatearFecha(_fechaSeleccionada!);
    } else {
      _controlador.clear();
    }
  }

  Future<void> _seleccionarFecha() async {
    if (!widget.habilitado) return;

    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: widget.fechaMinima ?? DateTime(1900),
      lastDate: widget.fechaMaxima ?? DateTime(2100),
      locale: const Locale('es', 'ES'),
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

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
        _actualizarTexto();
      });
      widget.alSeleccionar(fecha);
    }
  }

  void _limpiarFecha() {
    setState(() {
      _fechaSeleccionada = null;
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

        // Campo de fecha
        TextFormField(
          controller: _controlador,
          readOnly: true,
          enabled: widget.habilitado,
          style: const TextStyle(
            fontSize: 15,
            color: ColoresApp.textoOscuro,
          ),
          decoration: InputDecoration(
            hintText: widget.placeholder ?? 'Seleccionar fecha',
            prefixIcon: const Icon(Icons.calendar_today, size: 20),
            suffixIcon: _fechaSeleccionada != null
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: widget.habilitado ? _limpiarFecha : null,
                  )
                : null,
          ),
          onTap: _seleccionarFecha,
          validator: (valor) {
            if (widget.requerido && _fechaSeleccionada == null) {
              return '${widget.etiqueta ?? 'La fecha'} es requerida';
            }
            if (widget.validador != null) {
              return widget.validador!(_fechaSeleccionada);
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
