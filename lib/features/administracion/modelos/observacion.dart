import 'package:cloud_firestore/cloud_firestore.dart';

/// Observación del psicólogo sobre un estudiante
class Observacion {
  final String id;
  final String estudianteId;
  final String psicologoId;
  final String psicologoNombre;
  final String texto;
  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;
  final String? testRelacionadoId;

  const Observacion({
    required this.id,
    required this.estudianteId,
    required this.psicologoId,
    required this.psicologoNombre,
    required this.texto,
    required this.fechaCreacion,
    this.fechaModificacion,
    this.testRelacionadoId,
  });

  /// Convierte a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'estudianteId': estudianteId,
      'psicologoId': psicologoId,
      'psicologoNombre': psicologoNombre,
      'texto': texto,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaModificacion': fechaModificacion != null
          ? Timestamp.fromDate(fechaModificacion!)
          : null,
      'testRelacionadoId': testRelacionadoId,
    };
  }

  /// Crea desde Firestore
  factory Observacion.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return Observacion(
      id: snapshot.id,
      estudianteId: data['estudianteId'] as String,
      psicologoId: data['psicologoId'] as String,
      psicologoNombre: data['psicologoNombre'] as String,
      texto: data['texto'] as String,
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
      fechaModificacion: data['fechaModificacion'] != null
          ? (data['fechaModificacion'] as Timestamp).toDate()
          : null,
      testRelacionadoId: data['testRelacionadoId'] as String?,
    );
  }

  /// Copia con cambios
  Observacion copyWith({
    String? id,
    String? estudianteId,
    String? psicologoId,
    String? psicologoNombre,
    String? texto,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
    String? testRelacionadoId,
  }) {
    return Observacion(
      id: id ?? this.id,
      estudianteId: estudianteId ?? this.estudianteId,
      psicologoId: psicologoId ?? this.psicologoId,
      psicologoNombre: psicologoNombre ?? this.psicologoNombre,
      texto: texto ?? this.texto,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      testRelacionadoId: testRelacionadoId ?? this.testRelacionadoId,
    );
  }
}

/// Cita programada con un estudiante
class CitaProgramada {
  final String id;
  final String estudianteId;
  final String estudianteNombre;
  final String psicologoId;
  final String psicologoNombre;
  final DateTime fechaCita;
  final String? motivo;
  final String? observaciones;
  final EstadoCita estado;
  final DateTime fechaCreacion;

  const CitaProgramada({
    required this.id,
    required this.estudianteId,
    required this.estudianteNombre,
    required this.psicologoId,
    required this.psicologoNombre,
    required this.fechaCita,
    this.motivo,
    this.observaciones,
    required this.estado,
    required this.fechaCreacion,
  });

  /// Convierte a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'estudianteId': estudianteId,
      'estudianteNombre': estudianteNombre,
      'psicologoId': psicologoId,
      'psicologoNombre': psicologoNombre,
      'fechaCita': Timestamp.fromDate(fechaCita),
      'motivo': motivo,
      'observaciones': observaciones,
      'estado': estado.name,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }

  /// Crea desde Firestore
  factory CitaProgramada.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return CitaProgramada(
      id: snapshot.id,
      estudianteId: data['estudianteId'] as String,
      estudianteNombre: data['estudianteNombre'] as String,
      psicologoId: data['psicologoId'] as String,
      psicologoNombre: data['psicologoNombre'] as String,
      fechaCita: (data['fechaCita'] as Timestamp).toDate(),
      motivo: data['motivo'] as String?,
      observaciones: data['observaciones'] as String?,
      estado: EstadoCita.values.firstWhere(
        (e) => e.name == data['estado'],
      ),
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
    );
  }
}

/// Estado de la cita
enum EstadoCita {
  programada,
  completada,
  cancelada,
  noAsistio,
}

extension EstadoCitaExtension on EstadoCita {
  String get nombre {
    switch (this) {
      case EstadoCita.programada:
        return 'Programada';
      case EstadoCita.completada:
        return 'Completada';
      case EstadoCita.cancelada:
        return 'Cancelada';
      case EstadoCita.noAsistio:
        return 'No asistió';
    }
  }
}
