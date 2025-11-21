import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../../../compartidos/componentes/campos/campo_textarea.dart';
import '../../../compartidos/componentes/campos/campo_fecha.dart';
import '../../../compartidos/componentes/campos/campo_hora.dart';
import '../controladores/administracion_controlador.dart';
import '../modelos/estudiante_info.dart';
import '../componentes/grafica_evolucion.dart';
import '../../evaluaciones/servicios/test_servicio.dart';
import '../../evaluaciones/vistas/resultado_test_vista.dart';

/// Vista de perfil detallado de un estudiante
class PerfilEstudianteVista extends StatefulWidget {
  final EstudianteInfo estudiante;
  final String psicologoId;
  final String psicologoNombre;

  const PerfilEstudianteVista({
    super.key,
    required this.estudiante,
    required this.psicologoId,
    required this.psicologoNombre,
  });

  @override
  State<PerfilEstudianteVista> createState() => _PerfilEstudianteVistaState();
}

class _PerfilEstudianteVistaState extends State<PerfilEstudianteVista> {
  final TestServicio _testServicio = TestServicio();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controlador = context.read<AdministracionControlador>();
      controlador.seleccionarEstudiante(widget.estudiante);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPrincipal,
      appBar: AppBar(
        title: Text(widget.estudiante.nombreCompleto),
        backgroundColor: ColoresApp.primario,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AdministracionControlador>(
        builder: (context, controlador, _) {
          if (controlador.cargando) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ColoresApp.primario),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información general
                _InfoGeneralCard(estudiante: widget.estudiante),
                const SizedBox(height: 16),

                // Gráfica de evolución
                if (controlador.estadisticasEstudiante != null &&
                    controlador.estadisticasEstudiante!.evolucion.isNotEmpty)
                  GraficaEvolucion(
                    puntos: controlador.estadisticasEstudiante!.evolucion,
                  ),
                const SizedBox(height: 16),

                // Historial de tests
                _HistorialTests(
                  estudianteId: widget.estudiante.uid,
                  testServicio: _testServicio,
                  psicologoId: widget.psicologoId,
                  psicologoRol: 'psicologo', // Asumimos que es psicólogo ya que está en perfil de estudiante
                ),
                const SizedBox(height: 16),

                // Observaciones
                _ObservacionesSection(
                  observaciones: controlador.observaciones,
                  onAgregar: () => _mostrarDialogoObservacion(context),
                ),
                const SizedBox(height: 16),

                // Citas
                _CitasSection(
                  citas: controlador.citas,
                  onAgregar: () => _mostrarDialogoCita(context),
                  onCambiarEstado: (citaId, estado) {
                    controlador.actualizarEstadoCita(citaId, estado);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _mostrarDialogoObservacion(BuildContext context) {
    final controlador = context.read<AdministracionControlador>();
    final observacionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar observación'),
        content: CampoTextarea(
          controlador: observacionController,
          placeholder: 'Escribe tu observación aquí...',
          lineasMinimas: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (observacionController.text.trim().isEmpty) {
                return;
              }

              final exito = await controlador.guardarObservacion(
                estudianteId: widget.estudiante.uid,
                psicologoId: widget.psicologoId,
                psicologoNombre: widget.psicologoNombre,
                texto: observacionController.text.trim(),
              );

              if (context.mounted) {
                Navigator.pop(context);
                if (exito) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Observación guardada'),
                      backgroundColor: ColoresApp.exito,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.primario,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoCita(BuildContext context) {
    final controlador = context.read<AdministracionControlador>();
    final motivoController = TextEditingController();
    DateTime? fechaSeleccionada;
    TimeOfDay? horaSeleccionada;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Programar cita'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CampoFecha(
                  etiqueta: 'Fecha de la cita',
                  alSeleccionar: (fecha) {
                    setState(() {
                      fechaSeleccionada = fecha;
                    });
                  },
                  requerido: true,
                ),
                const SizedBox(height: 16),
                CampoHora(
                  etiqueta: 'Hora de la cita',
                  alSeleccionar: (hora) {
                    setState(() {
                      horaSeleccionada = hora;
                    });
                  },
                  requerido: true,
                ),
                const SizedBox(height: 16),
                CampoTextarea(
                  controlador: motivoController,
                  etiqueta: 'Motivo',
                  placeholder: 'Describe el motivo de la cita...',
                  lineasMinimas: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (fechaSeleccionada == null || horaSeleccionada == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor completa la fecha y hora'),
                      backgroundColor: ColoresApp.advertencia,
                    ),
                  );
                  return;
                }

                final fechaCita = DateTime(
                  fechaSeleccionada!.year,
                  fechaSeleccionada!.month,
                  fechaSeleccionada!.day,
                  horaSeleccionada!.hour,
                  horaSeleccionada!.minute,
                );

                final exito = await controlador.programarCita(
                  estudianteId: widget.estudiante.uid,
                  estudianteNombre: widget.estudiante.nombreCompleto,
                  psicologoId: widget.psicologoId,
                  psicologoNombre: widget.psicologoNombre,
                  fechaCita: fechaCita,
                  motivo: motivoController.text.trim(),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  if (exito) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cita programada'),
                        backgroundColor: ColoresApp.exito,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColoresApp.primario,
                foregroundColor: Colors.white,
              ),
              child: const Text('Programar'),
            ),
          ],
        ),
      ),
    );
  }
}

// Componentes internos
class _InfoGeneralCard extends StatelessWidget {
  final EstudianteInfo estudiante;

  const _InfoGeneralCard({required this.estudiante});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColoresApp.fondoBlanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.bordeDivisor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: ColoresApp.primario.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _obtenerIniciales(estudiante.nombreCompleto),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.primario,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      estudiante.nombreCompleto,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.textoOscuro,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Código: ${estudiante.codigo}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: ColoresApp.textoMedio,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _InfoItem(
            icono: Icons.email_outlined,
            titulo: 'Email',
            valor: estudiante.email,
          ),
          if (estudiante.programa != null) ...[
            const SizedBox(height: 12),
            _InfoItem(
              icono: Icons.school_outlined,
              titulo: 'Programa',
              valor: estudiante.programa!,
            ),
          ],
          if (estudiante.facultad != null) ...[
            const SizedBox(height: 12),
            _InfoItem(
              icono: Icons.business_outlined,
              titulo: 'Facultad',
              valor: estudiante.facultad!,
            ),
          ],
          const SizedBox(height: 12),
          _InfoItem(
            icono: Icons.calendar_today_outlined,
            titulo: 'Fecha de registro',
            valor: _formatearFecha(estudiante.fechaRegistro),
          ),
          if (estudiante.ultimoNivelAnsiedad != null) ...[
            const SizedBox(height: 12),
            _InfoItem(
              icono: Icons.psychology_outlined,
              titulo: 'Último nivel de ansiedad',
              valor: estudiante.ultimoNivelAnsiedad!.nombre,
              color: _getColorNivel(estudiante.ultimoNivelAnsiedad!),
            ),
          ],
        ],
      ),
    );
  }

  String _obtenerIniciales(String nombreCompleto) {
    final partes = nombreCompleto.trim().split(' ');
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return '${partes[0][0]}${partes[partes.length - 1][0]}'.toUpperCase();
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  Color _getColorNivel(nivel) {
    // Implementar según los niveles
    return ColoresApp.primario;
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;
  final Color? color;

  const _InfoItem({
    required this.icono,
    required this.titulo,
    required this.valor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 20, color: ColoresApp.textoMedio),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 12,
                  color: ColoresApp.textoClaro,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color ?? ColoresApp.textoOscuro,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistorialTests extends StatelessWidget {
  final String estudianteId;
  final TestServicio testServicio;
  final String psicologoId;
  final String psicologoRol;

  const _HistorialTests({
    required this.estudianteId,
    required this.testServicio,
    required this.psicologoId,
    required this.psicologoRol,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: testServicio.obtenerHistorialEstudiante(
        estudianteId: estudianteId,
        usuarioSolicitante: psicologoId,
        rolUsuario: psicologoRol,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColoresApp.fondoBlanco,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColoresApp.bordeDivisor),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ColoresApp.primario),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColoresApp.fondoBlanco,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColoresApp.bordeDivisor),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: ColoresApp.error, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Error al cargar historial: ${snapshot.error}',
                  style: const TextStyle(color: ColoresApp.error, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final tests = snapshot.data!;
        if (tests.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColoresApp.fondoBlanco,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColoresApp.bordeDivisor),
            ),
            child: const Column(
              children: [
                Icon(Icons.assignment_outlined, color: ColoresApp.textoMedio, size: 32),
                SizedBox(height: 8),
                Text(
                  'No hay evaluaciones registradas',
                  style: TextStyle(
                    color: ColoresApp.textoMedio,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }

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
              const Text(
                'Historial de evaluaciones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.textoOscuro,
                ),
              ),
              const SizedBox(height: 16),
              ...tests.take(5).map((test) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: ColoresApp.primario.withValues(alpha: 0.1),
                    child: Text(
                      '${test.puntajeTotal}',
                      style: const TextStyle(
                        color: ColoresApp.primario,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(test.nivelAnsiedad.nombre),
                  subtitle: Text(
                    '${test.fechaRealizacion.day}/${test.fechaRealizacion.month}/${test.fechaRealizacion.year}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultadoTestVista(
                          resultado: test,
                          usuarioId: estudianteId,
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _ObservacionesSection extends StatelessWidget {
  final List observaciones;
  final VoidCallback onAgregar;

  const _ObservacionesSection({
    required this.observaciones,
    required this.onAgregar,
  });

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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Observaciones',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoOscuro,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: ColoresApp.primario,
                onPressed: onAgregar,
              ),
            ],
          ),
          if (observaciones.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No hay observaciones registradas',
                style: TextStyle(
                  color: ColoresApp.textoMedio,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...observaciones.map((obs) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColoresApp.fondoTarjeta,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        obs.texto,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${obs.psicologoNombre} - ${_formatearFecha(obs.fechaCreacion)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColoresApp.textoClaro,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}

class _CitasSection extends StatelessWidget {
  final List citas;
  final VoidCallback onAgregar;
  final Function(String, dynamic) onCambiarEstado;

  const _CitasSection({
    required this.citas,
    required this.onAgregar,
    required this.onCambiarEstado,
  });

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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Citas programadas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoOscuro,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: ColoresApp.primario,
                onPressed: onAgregar,
              ),
            ],
          ),
          if (citas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No hay citas programadas',
                style: TextStyle(
                  color: ColoresApp.textoMedio,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...citas.map((cita) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColoresApp.fondoTarjeta,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.event, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${cita.fechaCita.day}/${cita.fechaCita.month}/${cita.fechaCita.year} - ${cita.fechaCita.hour}:${cita.fechaCita.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (cita.motivo != null) ...[
                        const SizedBox(height: 8),
                        Text(cita.motivo!),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Estado: ${cita.estado.nombre}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColoresApp.textoClaro,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
