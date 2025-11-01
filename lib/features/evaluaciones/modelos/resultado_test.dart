import 'package:cloud_firestore/cloud_firestore.dart';
import 'pregunta_beck.dart';

/// Modelo para almacenar el resultado de un test de ansiedad
class ResultadoTest {
  final String id;
  final String usuarioId;
  final DateTime fechaRealizacion;
  final Map<int, int> respuestas; // preguntaId -> valorRespuesta
  final int puntajeTotal;
  final NivelAnsiedad nivelAnsiedad;
  final bool requiereDerivacion;
  final List<String> actividadesRecomendadas;
  final String? observaciones;
  final bool derivadoPsicologo;
  final DateTime? fechaDerivacion;

  const ResultadoTest({
    required this.id,
    required this.usuarioId,
    required this.fechaRealizacion,
    required this.respuestas,
    required this.puntajeTotal,
    required this.nivelAnsiedad,
    required this.requiereDerivacion,
    required this.actividadesRecomendadas,
    this.observaciones,
    this.derivadoPsicologo = false,
    this.fechaDerivacion,
  });

  /// Convierte el resultado a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'usuarioId': usuarioId,
      'fechaRealizacion': Timestamp.fromDate(fechaRealizacion),
      'respuestas': respuestas.map((key, value) => MapEntry(key.toString(), value)),
      'puntajeTotal': puntajeTotal,
      'nivelAnsiedad': nivelAnsiedad.name,
      'requiereDerivacion': requiereDerivacion,
      'actividadesRecomendadas': actividadesRecomendadas,
      'observaciones': observaciones,
      'derivadoPsicologo': derivadoPsicologo,
      'fechaDerivacion': fechaDerivacion != null
          ? Timestamp.fromDate(fechaDerivacion!)
          : null,
    };
  }

  /// Crea un ResultadoTest desde Firestore
  factory ResultadoTest.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return ResultadoTest(
      id: snapshot.id,
      usuarioId: data['usuarioId'] as String,
      fechaRealizacion: (data['fechaRealizacion'] as Timestamp).toDate(),
      respuestas: (data['respuestas'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(int.parse(key), value as int),
      ),
      puntajeTotal: data['puntajeTotal'] as int,
      nivelAnsiedad: NivelAnsiedad.values.firstWhere(
        (e) => e.name == data['nivelAnsiedad'],
      ),
      requiereDerivacion: data['requiereDerivacion'] as bool,
      actividadesRecomendadas: List<String>.from(data['actividadesRecomendadas'] as List),
      observaciones: data['observaciones'] as String?,
      derivadoPsicologo: data['derivadoPsicologo'] as bool? ?? false,
      fechaDerivacion: data['fechaDerivacion'] != null
          ? (data['fechaDerivacion'] as Timestamp).toDate()
          : null,
    );
  }

  /// Copia el resultado con cambios
  ResultadoTest copyWith({
    String? id,
    String? usuarioId,
    DateTime? fechaRealizacion,
    Map<int, int>? respuestas,
    int? puntajeTotal,
    NivelAnsiedad? nivelAnsiedad,
    bool? requiereDerivacion,
    List<String>? actividadesRecomendadas,
    String? observaciones,
    bool? derivadoPsicologo,
    DateTime? fechaDerivacion,
  }) {
    return ResultadoTest(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      fechaRealizacion: fechaRealizacion ?? this.fechaRealizacion,
      respuestas: respuestas ?? this.respuestas,
      puntajeTotal: puntajeTotal ?? this.puntajeTotal,
      nivelAnsiedad: nivelAnsiedad ?? this.nivelAnsiedad,
      requiereDerivacion: requiereDerivacion ?? this.requiereDerivacion,
      actividadesRecomendadas: actividadesRecomendadas ?? this.actividadesRecomendadas,
      observaciones: observaciones ?? this.observaciones,
      derivadoPsicologo: derivadoPsicologo ?? this.derivadoPsicologo,
      fechaDerivacion: fechaDerivacion ?? this.fechaDerivacion,
    );
  }
}

/// Generador de actividades recomendadas según el nivel de ansiedad
class ActividadesRecomendadas {
  static List<String> obtenerPorNivel(NivelAnsiedad nivel) {
    switch (nivel) {
      case NivelAnsiedad.minima:
        return [
          'Mantén una rutina de sueño regular (7-8 horas diarias)',
          'Practica ejercicio físico moderado 3 veces por semana',
          'Dedica tiempo a actividades que disfrutas',
          'Mantén contacto regular con amigos y familia',
        ];

      case NivelAnsiedad.leve:
        return [
          'Practica técnicas de respiración profunda 10 minutos al día',
          'Realiza ejercicio físico regular (caminar, yoga, natación)',
          'Establece horarios fijos para dormir y despertar',
          'Limita el consumo de cafeína y alcohol',
          'Dedica 15 minutos diarios a la meditación o mindfulness',
          'Escribe un diario de emociones para identificar patrones',
        ];

      case NivelAnsiedad.moderada:
        return [
          'Practica técnicas de relajación muscular progresiva',
          'Realiza ejercicio aeróbico 30 minutos, 5 veces por semana',
          'Establece una rutina de meditación diaria (20 minutos)',
          'Evita sustancias estimulantes (café, bebidas energéticas)',
          'Implementa técnicas de gestión del tiempo',
          'Practica mindfulness en actividades cotidianas',
          'Mantén una alimentación balanceada',
          'Busca actividades recreativas que te relajen',
        ];

      case NivelAnsiedad.grave:
        return [
          'PRIORIDAD: Agenda una cita con el psicólogo del servicio',
          'Practica respiración diafragmática varias veces al día',
          'Evita el aislamiento social, busca apoyo en personas de confianza',
          'Establece una rutina diaria estructurada',
          'Evita totalmente alcohol, cafeína y otras sustancias',
          'Practica técnicas de grounding cuando sientas ansiedad intensa',
          'Considera técnicas de relajación guiada (audio/video)',
          'Mantén un registro de situaciones que desencadenan ansiedad',
        ];
    }
  }

  static String obtenerConsejoInicial(NivelAnsiedad nivel) {
    switch (nivel) {
      case NivelAnsiedad.minima:
        return 'Tu nivel de ansiedad es bajo. Continúa con tus hábitos saludables y mantente atento a cualquier cambio.';

      case NivelAnsiedad.leve:
        return 'Presentas ansiedad leve. Las actividades recomendadas te ayudarán a manejarla eficazmente. Practícalas con regularidad.';

      case NivelAnsiedad.moderada:
        return 'Tu nivel de ansiedad es moderado. Es importante que sigas las recomendaciones de forma constante. Si los síntomas persisten después de 30 días, te derivaremos con un profesional.';

      case NivelAnsiedad.grave:
        return 'Tu nivel de ansiedad requiere atención profesional. Hemos programado una derivación con el psicólogo del servicio. Mientras tanto, sigue las recomendaciones proporcionadas.';
    }
  }
}
