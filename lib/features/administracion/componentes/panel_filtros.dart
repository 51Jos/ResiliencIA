import 'package:flutter/material.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../../../compartidos/componentes/campos/campo_selector.dart';
import '../../evaluaciones/modelos/pregunta_beck.dart';
import '../modelos/estadisticas_globales.dart';

/// Panel de filtros para la lista de estudiantes
class PanelFiltros extends StatefulWidget {
  final FiltrosAdministracion filtrosActuales;
  final List<String> carreras;
  final List<String> facultades;
  final Function(FiltrosAdministracion) onFiltrosChanged;
  final VoidCallback onLimpiar;

  const PanelFiltros({
    super.key,
    required this.filtrosActuales,
    required this.carreras,
    required this.facultades,
    required this.onFiltrosChanged,
    required this.onLimpiar,
  });

  @override
  State<PanelFiltros> createState() => _PanelFiltrosState();
}

class _PanelFiltrosState extends State<PanelFiltros> {
  late FiltrosAdministracion _filtros;

  @override
  void initState() {
    super.initState();
    _filtros = widget.filtrosActuales;
  }

  @override
  void didUpdateWidget(PanelFiltros oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filtrosActuales != oldWidget.filtrosActuales) {
      setState(() {
        _filtros = widget.filtrosActuales;
      });
    }
  }

  void _actualizarFiltro(FiltrosAdministracion nuevosFiltros) {
    setState(() {
      _filtros = nuevosFiltros;
    });
    widget.onFiltrosChanged(_filtros);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.fondoBlanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.bordeDivisor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera
          Row(
            children: [
              const Icon(
                Icons.filter_list,
                color: ColoresApp.primario,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Filtros',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoOscuro,
                  ),
                ),
              ),
              if (_filtros.tienesFiltros)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _filtros = const FiltrosAdministracion();
                    });
                    widget.onLimpiar();
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Limpiar'),
                  style: TextButton.styleFrom(
                    foregroundColor: ColoresApp.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Nivel de ansiedad
          CampoSelector<NivelAnsiedad>(
            etiqueta: 'Nivel de ansiedad',
            valorInicial: _filtros.nivelAnsiedad,
            opciones: NivelAnsiedad.values
                .map((nivel) => OpcionSelector(
                      valor: nivel,
                      etiqueta: nivel.nombre,
                    ))
                .toList(),
            alSeleccionar: (nivel) {
              _actualizarFiltro(_filtros.copyWith(nivelAnsiedad: nivel));
            },
            placeholder: 'Todos los niveles',
          ),
          const SizedBox(height: 12),

          // Carrera
          if (widget.carreras.isNotEmpty)
            CampoSelector<String>(
              etiqueta: 'Carrera',
              valorInicial: _filtros.carrera,
              opciones: widget.carreras
                  .map((c) => OpcionSelector(
                        valor: c,
                        etiqueta: c,
                      ))
                  .toList(),
              alSeleccionar: (carrera) {
                _actualizarFiltro(_filtros.copyWith(carrera: carrera));
              },
              placeholder: 'Todas las carreras',
            ),
          if (widget.carreras.isNotEmpty) const SizedBox(height: 12),

          // Facultad
          if (widget.facultades.isNotEmpty)
            CampoSelector<String>(
              etiqueta: 'Facultad',
              valorInicial: _filtros.facultad,
              opciones: widget.facultades
                  .map((f) => OpcionSelector(
                        valor: f,
                        etiqueta: f,
                      ))
                  .toList(),
              alSeleccionar: (facultad) {
                _actualizarFiltro(_filtros.copyWith(facultad: facultad));
              },
              placeholder: 'Todas las facultades',
            ),
          if (widget.facultades.isNotEmpty) const SizedBox(height: 12),

          // Requiere atención
          CheckboxListTile(
            value: _filtros.requiereAtencion ?? false,
            onChanged: (value) {
              _actualizarFiltro(
                _filtros.copyWith(requiereAtencion: value == true ? value : null),
              );
            },
            title: const Text(
              'Solo estudiantes que requieren atención',
              style: TextStyle(fontSize: 14),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeColor: ColoresApp.primario,
          ),

          const SizedBox(height: 12),

          // Ordenamiento
          CampoSelector<OrdenEstudiantes>(
            etiqueta: 'Ordenar por',
            valorInicial: _filtros.orden,
            opciones: OrdenEstudiantes.values
                .map((orden) => OpcionSelector(
                      valor: orden,
                      etiqueta: orden.nombre,
                    ))
                .toList(),
            alSeleccionar: (orden) {
              _actualizarFiltro(_filtros.copyWith(orden: orden));
            },
          ),

          // Indicador de filtros activos
          if (_filtros.tienesFiltros) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _FiltrosActivos(filtros: _filtros),
          ],
        ],
      ),
    );
  }
}

/// Muestra los filtros activos como chips
class _FiltrosActivos extends StatelessWidget {
  final FiltrosAdministracion filtros;

  const _FiltrosActivos({required this.filtros});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (filtros.nivelAnsiedad != null) {
      chips.add(_Chip(texto: filtros.nivelAnsiedad!.nombre));
    }

    if (filtros.carrera != null) {
      chips.add(_Chip(texto: filtros.carrera!));
    }

    if (filtros.facultad != null) {
      chips.add(_Chip(texto: filtros.facultad!));
    }

    if (filtros.requiereAtencion == true) {
      chips.add(const _Chip(texto: 'Requiere atención'));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filtros activos:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ColoresApp.textoMedio,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String texto;

  const _Chip({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ColoresApp.primario.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColoresApp.primario.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 12,
          color: ColoresApp.primario,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
