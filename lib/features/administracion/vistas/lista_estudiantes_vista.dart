import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../../../compartidos/componentes/campos/campo_texto.dart';
import '../controladores/administracion_controlador.dart';
import '../componentes/tarjeta_estudiante.dart';
import '../componentes/panel_filtros.dart';
import 'perfil_estudiante_vista.dart';
import 'estadisticas_vista.dart';

/// Vista principal de lista de estudiantes (solo para administradores)
class ListaEstudiantesVista extends StatefulWidget {
  final String psicologoId;
  final String psicologoNombre;

  const ListaEstudiantesVista({
    super.key,
    required this.psicologoId,
    required this.psicologoNombre,
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
      appBar: AppBar(
        title: const Text('Gestión de Estudiantes'),
        backgroundColor: ColoresApp.primario,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
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
              // Barra de búsqueda
              Container(
                color: ColoresApp.fondoBlanco,
                padding: const EdgeInsets.all(16),
                child: CampoTexto(
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
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controlador.estudiantes.length,
        itemBuilder: (context, index) {
          final estudiante = controlador.estudiantes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TarjetaEstudiante(
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
            ),
          );
        },
      ),
    );
  }
}
