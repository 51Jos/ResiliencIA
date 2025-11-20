import 'package:cloud_firestore/cloud_firestore.dart';
import '../../evaluaciones/modelos/pregunta_beck.dart';

/// Información completa de un estudiante para el panel de administración
class EstudianteInfo {
  final String uid;
  final String codigo;
  final String email;
  final String nombres;
  final String apellidos;
  final String nombreCompleto;
  final String? facultad;
  final String? programa;
  final String rol;
  final DateTime fechaRegistro;
  final NivelAnsiedad? ultimoNivelAnsiedad;
  final DateTime? fechaUltimoTest;
  final int? puntajeUltimoTest;
  final bool requiereAtencion;
  final int totalTests;

  const EstudianteInfo({
    required this.uid,
    required this.codigo,
    required this.email,
    required this.nombres,
    required this.apellidos,
    required this.nombreCompleto,
    this.facultad,
    this.programa,
    required this.rol,
    required this.fechaRegistro,
    this.ultimoNivelAnsiedad,
    this.fechaUltimoTest,
    this.puntajeUltimoTest,
    required this.requiereAtencion,
    required this.totalTests,
  });

  /// Crea una instancia desde Firestore
  factory EstudianteInfo.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return EstudianteInfo(
      uid: snapshot.id,
      codigo: data['codigo'] as String? ?? '',
      email: data['email'] as String,
      nombres: data['nombres'] as String? ?? '',
      apellidos: data['apellidos'] as String? ?? '',
      nombreCompleto: data['nombreCompleto'] as String? ?? '',
      facultad: data['facultad'] as String?,
      programa: data['programa'] as String?,
      rol: data['rol'] as String? ?? 'estudiante',
      fechaRegistro: (data['fechaRegistro'] as Timestamp).toDate(),
      ultimoNivelAnsiedad: data['ultimoNivelAnsiedad'] != null
          ? NivelAnsiedad.values.firstWhere(
              (e) => e.name == data['ultimoNivelAnsiedad'],
            )
          : null,
      fechaUltimoTest: data['fechaUltimoTest'] != null
          ? (data['fechaUltimoTest'] as Timestamp).toDate()
          : null,
      puntajeUltimoTest: data['puntajeUltimoTest'] as int?,
      requiereAtencion: data['requiereAtencion'] as bool? ?? false,
      totalTests: data['totalTests'] as int? ?? 0,
    );
  }

  /// Copia con cambios
  EstudianteInfo copyWith({
    String? uid,
    String? codigo,
    String? email,
    String? nombres,
    String? apellidos,
    String? nombreCompleto,
    String? facultad,
    String? programa,
    String? rol,
    DateTime? fechaRegistro,
    NivelAnsiedad? ultimoNivelAnsiedad,
    DateTime? fechaUltimoTest,
    int? puntajeUltimoTest,
    bool? requiereAtencion,
    int? totalTests,
  }) {
    return EstudianteInfo(
      uid: uid ?? this.uid,
      codigo: codigo ?? this.codigo,
      email: email ?? this.email,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      facultad: facultad ?? this.facultad,
      programa: programa ?? this.programa,
      rol: rol ?? this.rol,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      ultimoNivelAnsiedad: ultimoNivelAnsiedad ?? this.ultimoNivelAnsiedad,
      fechaUltimoTest: fechaUltimoTest ?? this.fechaUltimoTest,
      puntajeUltimoTest: puntajeUltimoTest ?? this.puntajeUltimoTest,
      requiereAtencion: requiereAtencion ?? this.requiereAtencion,
      totalTests: totalTests ?? this.totalTests,
    );
  }
}
