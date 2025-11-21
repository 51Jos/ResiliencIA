import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipos de notificación
enum TipoNotificacion {
  ansiedadGrave,
  recordatorioTest,
  citaProgramada,
  observacionNueva,
}

/// Prioridad de la notificación
enum PrioridadNotificacion {
  baja,
  media,
  alta,
  urgente,
}

/// Modelo para una notificación
class Notificacion {
  final String id;
  final TipoNotificacion tipo;
  final PrioridadNotificacion prioridad;
  final String titulo;
  final String mensaje;
  final String destinatarioId; // ID del psicólogo
  final String? estudianteId; // ID del estudiante relacionado
  final String? estudianteNombre;
  final String? nivelAnsiedad; // Para notificaciones de ansiedad
  final int? puntajeTest; // Puntaje del test
  final DateTime fechaCreacion;
  final bool leida;
  final DateTime? fechaLeida;

  const Notificacion({
    required this.id,
    required this.tipo,
    required this.prioridad,
    required this.titulo,
    required this.mensaje,
    required this.destinatarioId,
    this.estudianteId,
    this.estudianteNombre,
    this.nivelAnsiedad,
    this.puntajeTest,
    required this.fechaCreacion,
    this.leida = false,
    this.fechaLeida,
  });

  /// Convierte la notificación a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'tipo': tipo.name,
      'prioridad': prioridad.name,
      'titulo': titulo,
      'mensaje': mensaje,
      'destinatarioId': destinatarioId,
      'estudianteId': estudianteId,
      'estudianteNombre': estudianteNombre,
      'nivelAnsiedad': nivelAnsiedad,
      'puntajeTest': puntajeTest,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'leida': leida,
      'fechaLeida': fechaLeida != null ? Timestamp.fromDate(fechaLeida!) : null,
    };
  }

  /// Crea una notificación desde Firestore
  factory Notificacion.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return Notificacion(
      id: snapshot.id,
      tipo: TipoNotificacion.values.firstWhere(
        (e) => e.name == data['tipo'],
      ),
      prioridad: PrioridadNotificacion.values.firstWhere(
        (e) => e.name == data['prioridad'],
      ),
      titulo: data['titulo'] as String,
      mensaje: data['mensaje'] as String,
      destinatarioId: data['destinatarioId'] as String,
      estudianteId: data['estudianteId'] as String?,
      estudianteNombre: data['estudianteNombre'] as String?,
      nivelAnsiedad: data['nivelAnsiedad'] as String?,
      puntajeTest: data['puntajeTest'] as int?,
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
      leida: data['leida'] as bool? ?? false,
      fechaLeida: data['fechaLeida'] != null
          ? (data['fechaLeida'] as Timestamp).toDate()
          : null,
    );
  }

  /// Copia la notificación con cambios
  Notificacion copyWith({
    String? id,
    TipoNotificacion? tipo,
    PrioridadNotificacion? prioridad,
    String? titulo,
    String? mensaje,
    String? destinatarioId,
    String? estudianteId,
    String? estudianteNombre,
    String? nivelAnsiedad,
    int? puntajeTest,
    DateTime? fechaCreacion,
    bool? leida,
    DateTime? fechaLeida,
  }) {
    return Notificacion(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      prioridad: prioridad ?? this.prioridad,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      destinatarioId: destinatarioId ?? this.destinatarioId,
      estudianteId: estudianteId ?? this.estudianteId,
      estudianteNombre: estudianteNombre ?? this.estudianteNombre,
      nivelAnsiedad: nivelAnsiedad ?? this.nivelAnsiedad,
      puntajeTest: puntajeTest ?? this.puntajeTest,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      leida: leida ?? this.leida,
      fechaLeida: fechaLeida ?? this.fechaLeida,
    );
  }
}
