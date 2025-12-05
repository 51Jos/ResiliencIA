import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../compartidos/tema/colores_app.dart';
import '../../../compartidos/componentes/campos/campo_texto.dart';
import '../../../compartidos/componentes/modales/modal_mensaje.dart';
import '../controladores/administracion_controlador.dart';
import '../componentes/tarjeta_estudiante.dart';
import '../componentes/panel_filtros.dart';
import '../modelos/estadisticas_globales.dart';
import '../servicios/exportacion_servicio.dart';
import 'perfil_estudiante_vista.dart';
import 'estadisticas_vista.dart';

/// Vista principal de lista de estudiantes (solo para administradores)
class ListaEstudiantesVista extends StatefulWidget {
  final String psicologoId;
  final String psicologoNombre;
  final bool ocultarAppBar;

  const ListaEstudiantesVista({
    super.key,
    required this.psicologoId,
    required this.psicologoNombre,
    this.ocultarAppBar = false,
  });

  @override
  State<ListaEstudiantesVista> createState() => _ListaEstudiantesVistaState();
}

class _ListaEstudiantesVistaState extends State<ListaEstudiantesVista> {
  final TextEditingController _busquedaController = TextEditingController();
  bool _mostrarFiltros = false;

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
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPrincipal,
      appBar: widget.ocultarAppBar ? null : AppBar(
        title: const Text('Gestión de Estudiantes'),
        backgroundColor: ColoresApp.primario,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Botón de exportar
          Consumer<AdministracionControlador>(
            builder: (context, controlador, _) {
              return IconButton(
                icon: const Icon(Icons.file_download_outlined),
                tooltip: 'Exportar a Excel',
                onPressed: controlador.estudiantes.isEmpty
                    ? null
                    : () => _exportarAExcel(context, controlador),
              );
            },
          ),
          // Botón de estadísticas
          IconButton(
            icon: const Icon(Icons.assessment_outlined),
            tooltip: 'Ver estadísticas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EstadisticasVista(
                    psicologoId: widget.psicologoId,
                    psicologoNombre: widget.psicologoNombre,
                  ),
                ),
              );
            },
          ),
          // Botón de filtros
          IconButton(
            icon: Icon(_mostrarFiltros ? Icons.filter_list_off : Icons.filter_list),
            tooltip: _mostrarFiltros ? 'Ocultar filtros' : 'Mostrar filtros',
            onPressed: () {
              setState(() {
                _mostrarFiltros = !_mostrarFiltros;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<AdministracionControlador>(
        builder: (context, controlador, _) {
          return Column(
            children: [
              // Barra de búsqueda y filtro de fecha
              Container(
                color: ColoresApp.fondoBlanco,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Selector de rango de fechas
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: ColoresApp.textoMedio,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<RangoFecha>(
                            value: controlador.filtros.rangoFecha,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: RangoFecha.values.map((rango) {
                              return DropdownMenuItem(
                                value: rango,
                                child: Text(rango.nombre),
                              );
                            }).toList(),
                            onChanged: (valor) {
                              if (valor != null) {
                                if (valor == RangoFecha.personalizado) {
                                  _mostrarSelectorFechaPersonalizada(context, controlador);
                                } else {
                                  controlador.actualizarFiltro(rangoFecha: valor);
                                }
                              }
                            },
                          ),
                        ),
                        if (controlador.filtros.rangoFecha == RangoFecha.personalizado &&
                            (controlador.filtros.fechaDesde != null || controlador.filtros.fechaHasta != null))
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            tooltip: 'Editar fechas',
                            onPressed: () => _mostrarSelectorFechaPersonalizada(context, controlador),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Campo de búsqueda
                    CampoTexto(
                      controlador: _busquedaController,
                      placeholder: 'Buscar por nombre, código o email...',
                      icono: Icons.search,
                      alCambiar: (valor) {
                        controlador.buscar(valor);
                      },
                      sufijo: _busquedaController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _busquedaController.clear();
                                controlador.buscar('');
                              },
                            )
                          : null,
                    ),
                  ],
                ),
              ),

              // Panel de filtros (colapsable)
              if (_mostrarFiltros)
                Container(
                  color: ColoresApp.fondoPrincipal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: PanelFiltros(
                    filtrosActuales: controlador.filtros,
                    carreras: controlador.carreras,
                    facultades: controlador.facultades,
                    onFiltrosChanged: (filtros) {
                      controlador.aplicarFiltros(filtros);
                    },
                    onLimpiar: () {
                      controlador.limpiarFiltros();
                    },
                  ),
                ),

              // Resumen de resultados
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: ColoresApp.fondoBlanco,
                  border: Border(
                    bottom: BorderSide(color: ColoresApp.bordeDivisor),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${controlador.estudiantes.length} estudiante${controlador.estudiantes.length != 1 ? 's' : ''} encontrado${controlador.estudiantes.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColoresApp.textoMedio,
                        ),
                      ),
                    ),
                    if (controlador.filtros.tienesFiltros)
                      TextButton.icon(
                        onPressed: () {
                          _busquedaController.clear();
                          controlador.limpiarFiltros();
                        },
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Limpiar todo'),
                        style: TextButton.styleFrom(
                          foregroundColor: ColoresApp.primario,
                        ),
                      ),
                  ],
                ),
              ),

              // Lista de estudiantes
              Expanded(
                child: _buildListaEstudiantes(controlador),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListaEstudiantes(AdministracionControlador controlador) {
    if (controlador.cargando) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ColoresApp.primario),
        ),
      );
    }

    if (controlador.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: ColoresApp.error,
              ),
              const SizedBox(height: 16),
              Text(
                controlador.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: ColoresApp.textoMedio,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  controlador.limpiarError();
                  controlador.cargarEstudiantes();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primario,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (controlador.estudiantes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                controlador.filtros.tienesFiltros
                    ? Icons.search_off
                    : Icons.people_outline,
                size: 64,
                color: ColoresApp.textoClaro,
              ),
              const SizedBox(height: 16),
              Text(
                controlador.filtros.tienesFiltros
                    ? 'No se encontraron estudiantes\ncon los filtros aplicados'
                    : 'No hay estudiantes registrados',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: ColoresApp.textoMedio,
                ),
              ),
              if (controlador.filtros.tienesFiltros) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    _busquedaController.clear();
                    controlador.limpiarFiltros();
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Limpiar filtros'),
                  style: TextButton.styleFrom(
                    foregroundColor: ColoresApp.primario,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: ColoresApp.primario,
      onRefresh: () async {
        await controlador.cargarEstudiantes();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final anchoPantalla = constraints.maxWidth;
          int columnas;
          double espaciado;

          if (anchoPantalla >= 1400) {
            // Pantallas muy grandes: 4 columnas
            columnas = 4;
            espaciado = 20;
          } else if (anchoPantalla >= 1100) {
            // Pantallas grandes: 3 columnas
            columnas = 3;
            espaciado = 18;
          } else if (anchoPantalla >= 768) {
            // Tablets: 2 columnas
            columnas = 2;
            espaciado = 16;
          } else {
            // Móviles: 1 columna
            columnas = 1;
            espaciado = 16;
          }

          return MasonryGridView.count(
            padding: EdgeInsets.all(espaciado),
            crossAxisCount: columnas,
            crossAxisSpacing: espaciado,
            mainAxisSpacing: espaciado,
            itemCount: controlador.estudiantes.length,
            itemBuilder: (context, index) {
              final estudiante = controlador.estudiantes[index];
              return TarjetaEstudiante(
                estudiante: estudiante,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PerfilEstudianteVista(
                        estudiante: estudiante,
                        psicologoId: widget.psicologoId,
                        psicologoNombre: widget.psicologoNombre,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Muestra un diálogo para seleccionar un rango de fechas personalizado
  void _mostrarSelectorFechaPersonalizada(
    BuildContext context,
    AdministracionControlador controlador,
  ) async {
    DateTime? fechaDesde = controlador.filtros.fechaDesde;
    DateTime? fechaHasta = controlador.filtros.fechaHasta;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar rango de fechas'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fecha desde
                ListTile(
                  title: const Text('Desde'),
                  subtitle: Text(
                    fechaDesde != null
                        ? '${fechaDesde!.day}/${fechaDesde!.month}/${fechaDesde!.year}'
                        : 'Sin fecha',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final fecha = await showDatePicker(
                      context: context,
                      initialDate: fechaDesde ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (fecha != null) {
                      setState(() {
                        fechaDesde = fecha;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                // Fecha hasta
                ListTile(
                  title: const Text('Hasta'),
                  subtitle: Text(
                    fechaHasta != null
                        ? '${fechaHasta!.day}/${fechaHasta!.month}/${fechaHasta!.year}'
                        : 'Sin fecha',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final fecha = await showDatePicker(
                      context: context,
                      initialDate: fechaHasta ?? DateTime.now(),
                      firstDate: fechaDesde ?? DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (fecha != null) {
                      setState(() {
                        fechaHasta = fecha;
                      });
                    }
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (fechaDesde != null || fechaHasta != null) {
                controlador.actualizarFiltro(
                  rangoFecha: RangoFecha.personalizado,
                  fechaDesde: fechaDesde,
                  fechaHasta: fechaHasta,
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  /// Exporta la lista de estudiantes a Excel
  Future<void> _exportarAExcel(
    BuildContext context,
    AdministracionControlador controlador,
  ) async {
    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ColoresApp.primario),
                ),
                SizedBox(height: 16),
                Text(
                  'Generando archivo Excel...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ColoresApp.textoOscuro,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final servicio = ExportacionServicio();
      final resultado = await servicio.exportarEstudiantesAExcel(
        estudiantes: controlador.estudiantes,
      );

      // Cerrar diálogo de carga
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (kIsWeb) {
        // En web, se descarga automáticamente
        // El paquete excel ya maneja la descarga en web
        if (context.mounted) {
          await ModalMensaje.mostrarExito(
            context: context,
            titulo: 'Exportación exitosa',
            mensaje: 'Se ha descargado el archivo Excel con ${controlador.estudiantes.length} estudiante${controlador.estudiantes.length != 1 ? 's' : ''}.',
          );
        }
      } else {
        // En móvil/desktop, compartir el archivo
        final filePath = resultado as String;
        final file = File(filePath);

        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Datos de Estudiantes',
          text: 'Exportación de ${controlador.estudiantes.length} estudiante${controlador.estudiantes.length != 1 ? 's' : ''}',
        );

        if (context.mounted) {
          await ModalMensaje.mostrarExito(
            context: context,
            titulo: 'Exportación exitosa',
            mensaje: 'Se ha exportado el archivo Excel con ${controlador.estudiantes.length} estudiante${controlador.estudiantes.length != 1 ? 's' : ''}.',
          );
        }
      }
    } catch (e) {
      // Cerrar diálogo de carga si está abierto
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Mostrar error
      if (context.mounted) {
        await ModalMensaje.mostrarError(
          context: context,
          titulo: 'Error al exportar',
          mensaje: 'No se pudo generar el archivo Excel. Por favor, intenta nuevamente.',
        );
      }
    }
  }
}
