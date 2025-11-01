/// Modelo para una pregunta del Inventario de Ansiedad de Beck
class PreguntaBeck {
  final int id;
  final String categoria;
  final String texto;
  final List<OpcionRespuesta> opciones;

  const PreguntaBeck({
    required this.id,
    required this.categoria,
    required this.texto,
    required this.opciones,
  });
}

/// Opciones de respuesta para cada pregunta
class OpcionRespuesta {
  final int valor;
  final String texto;

  const OpcionRespuesta({
    required this.valor,
    required this.texto,
  });
}

/// Lista completa de preguntas del Inventario de Ansiedad de Beck (BAI)
class InventarioBeck {
  static const List<PreguntaBeck> preguntas = [
    // Sección 1: Síntomas Físicos (1-7)
    PreguntaBeck(
      id: 1,
      categoria: 'Síntomas Físicos',
      texto: 'Torpe o entumecido',
      opciones: _opcionesEstandar,
    ),
    PreguntaBeck(
      id: 2,
      categoria: 'Síntomas Físicos',
      texto: 'Acalorado',
      opciones: _opcionesEstandar,
    ),
    PreguntaBeck(
      id: 3,
      categoria: 'Síntomas Físicos',
      texto: 'Con temblor en las piernas',
      opciones: _opcionesEstandar,
    ),
    PreguntaBeck(
      id: 4,
      categoria: 'Síntomas Físicos',
      texto: 'Incapaz de relajarse',
      opciones: _opcionesEstandar,
    ),
    PreguntaBeck(
      id: 5,
      categoria: 'Síntomas Físicos',
      texto: 'Con temor a que ocurra lo peor',
      opciones: _opcionesEstandar,
    ),
    PreguntaBeck(
      id: 6,
      categoria: 'Síntomas Físicos',
      texto: 'Mareado, o que se le va la cabeza',
      opciones: _opcionesEstandar,
    ),
    PreguntaBeck(
      id: 7,
      categoria: 'Síntomas Físicos',
      texto: 'Con latidos del corazón fuertes y acelerados',
      opciones: _opcionesEstandar,
    ),

    // Sección 2: Síntomas Cognitivos (8-14)
    PreguntaBeck(
      id: 8,
      categoria: 'Síntomas Cognitivos',
      texto: 'Inestable',
      opciones: _opcionesEstandar,
    ),
    PreguntaBeck(
      id: 9,
      categoria: 'Síntomas Cognitivos',
      texto: 'Atemorizado o asustado',
      opciones: _opcionesEstandar,
    ),
    PreguntaBeck(
      id: 10,
      categoria: 'Síntomas Cognitivos',
      texto: 'Nervioso',
      opciones: _opcionesEstandar,
    ),
    PreguntaBeck(
      id: 11,
      categoria: 'Síntomas Cognitivos',
      texto: 'Con sensación de bloqueo',
      opciones: _opcionesEstandar,
    ),
    PreguntaBeck(
      id: 12,
      categoria: 'Síntomas Cognitivos',
      texto: 'Con temblores en las manos',
      opciones: _opcionesEstandar,
    ),
    PreguntaBeck(
      id: 13,
      categoria: 'Síntomas Cognitivos',
      texto: 'Inquieto, inseguro',
      opciones: _opcionesEstandar,
    ),
    PreguntaBeck(
      id: 14,
      categoria: 'Síntomas Cognitivos',
      texto: 'Con miedo a perder el control',
      opciones: _opcionesEstandar,
    ),

    // Sección 3: Síntomas Autonómicos (15-21)
    PreguntaBeck(
      id: 15,
      categoria: 'Síntomas Autonómicos',
      texto: 'Con sensación de ahogo',
      opciones: _opcionesEstandar,
    ),
    PreguntaBeck(
      id: 16,
      categoria: 'Síntomas Autonómicos',
      texto: 'Con temor a morir',
      opciones: _opcionesEstandar,
    ),
    PreguntaBeck(
      id: 17,
      categoria: 'Síntomas Autonómicos',
      texto: 'Con miedo',
      opciones: _opcionesEstandar,
    ),
    PreguntaBeck(
      id: 18,
      categoria: 'Síntomas Autonómicos',
      texto: 'Con problemas digestivos',
      opciones: _opcionesEstandar,
    ),
    PreguntaBeck(
      id: 19,
      categoria: 'Síntomas Autonómicos',
      texto: 'Con desvanecimientos',
      opciones: _opcionesEstandar,
    ),
    PreguntaBeck(
      id: 20,
      categoria: 'Síntomas Autonómicos',
      texto: 'Con rubor facial',
      opciones: _opcionesEstandar,
    ),
    PreguntaBeck(
      id: 21,
      categoria: 'Síntomas Autonómicos',
      texto: 'Con sudores fríos o calientes',
      opciones: _opcionesEstandar,
    ),
  ];

  /// Opciones estándar para cada pregunta del BAI
  static const List<OpcionRespuesta> _opcionesEstandar = [
    OpcionRespuesta(valor: 0, texto: 'En absoluto'),
    OpcionRespuesta(valor: 1, texto: 'Levemente (no me molesta mucho)'),
    OpcionRespuesta(valor: 2, texto: 'Moderadamente (es desagradable pero puedo soportarlo)'),
    OpcionRespuesta(valor: 3, texto: 'Severamente (casi no puedo soportarlo)'),
  ];

  /// Obtiene las preguntas por categoría
  static Map<String, List<PreguntaBeck>> obtenerPorCategoria() {
    final Map<String, List<PreguntaBeck>> categorias = {};

    for (var pregunta in preguntas) {
      if (!categorias.containsKey(pregunta.categoria)) {
        categorias[pregunta.categoria] = [];
      }
      categorias[pregunta.categoria]!.add(pregunta);
    }

    return categorias;
  }

  /// Calcula el nivel de ansiedad basado en el puntaje total
  static NivelAnsiedad calcularNivel(int puntajeTotal) {
    if (puntajeTotal <= 7) {
      return NivelAnsiedad.minima;
    } else if (puntajeTotal <= 15) {
      return NivelAnsiedad.leve;
    } else if (puntajeTotal <= 25) {
      return NivelAnsiedad.moderada;
    } else {
      return NivelAnsiedad.grave;
    }
  }
}

/// Niveles de ansiedad según el Inventario de Beck
enum NivelAnsiedad {
  minima,
  leve,
  moderada,
  grave;

  String get nombre {
    switch (this) {
      case NivelAnsiedad.minima:
        return 'Ansiedad Mínima';
      case NivelAnsiedad.leve:
        return 'Ansiedad Leve';
      case NivelAnsiedad.moderada:
        return 'Ansiedad Moderada';
      case NivelAnsiedad.grave:
        return 'Ansiedad Grave';
    }
  }

  String get descripcion {
    switch (this) {
      case NivelAnsiedad.minima:
        return 'Nivel muy bajo de ansiedad. Es normal y manejable.';
      case NivelAnsiedad.leve:
        return 'Nivel bajo de ansiedad. Puede manejarse con técnicas de relajación.';
      case NivelAnsiedad.moderada:
        return 'Nivel moderado de ansiedad. Se recomienda seguir las actividades sugeridas.';
      case NivelAnsiedad.grave:
        return 'Nivel alto de ansiedad. Se recomienda atención profesional.';
    }
  }

  bool get requiereDerivacion {
    return this == NivelAnsiedad.grave;
  }
}
