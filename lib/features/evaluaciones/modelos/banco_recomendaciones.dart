import 'dart:convert';

/// Modelo para el banco de recomendaciones del sistema experto
class BancoRecomendaciones {
  final Map<String, dynamic> metadata;
  final NivelesGlobales nivelesGlobales;
  final Capa1General capa1General;
  final Map<String, Capa2Tipo> capa2Tipo;
  final List<ItemRecomendacion> capa3Items;

  BancoRecomendaciones({
    required this.metadata,
    required this.nivelesGlobales,
    required this.capa1General,
    required this.capa2Tipo,
    required this.capa3Items,
  });

  factory BancoRecomendaciones.fromJson(Map<String, dynamic> json) {
    return BancoRecomendaciones(
      metadata: json['metadata'] as Map<String, dynamic>,
      nivelesGlobales: NivelesGlobales.fromJson(json['niveles_globales']),
      capa1General: Capa1General.fromJson(json['capa_1_general']),
      capa2Tipo: (json['capa_2_tipo'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, Capa2Tipo.fromJson(value)),
      ),
      capa3Items: (json['capa_3_items'] as List)
          .map((item) => ItemRecomendacion.fromJson(item))
          .toList(),
    );
  }

  factory BancoRecomendaciones.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return BancoRecomendaciones.fromJson(json);
  }
}

/// Niveles globales de ansiedad
class NivelesGlobales {
  final NivelGlobal sinAnsiedad;
  final DerivacionProfesional derivacionProfesional;

  NivelesGlobales({
    required this.sinAnsiedad,
    required this.derivacionProfesional,
  });

  factory NivelesGlobales.fromJson(Map<String, dynamic> json) {
    return NivelesGlobales(
      sinAnsiedad: NivelGlobal.fromJson(json['sin_ansiedad']),
      derivacionProfesional: DerivacionProfesional.fromJson(json['derivacion_profesional']),
    );
  }
}

class NivelGlobal {
  final List<int> rango;
  final List<String> mensajes;

  NivelGlobal({
    required this.rango,
    required this.mensajes,
  });

  factory NivelGlobal.fromJson(Map<String, dynamic> json) {
    return NivelGlobal(
      rango: List<int>.from(json['rango']),
      mensajes: List<String>.from(json['mensajes']),
    );
  }
}

class DerivacionProfesional {
  final List<int> rango;
  final MensajeFijo mensajeFijo;

  DerivacionProfesional({
    required this.rango,
    required this.mensajeFijo,
  });

  factory DerivacionProfesional.fromJson(Map<String, dynamic> json) {
    return DerivacionProfesional(
      rango: List<int>.from(json['rango']),
      mensajeFijo: MensajeFijo.fromJson(json['mensaje_fijo']),
    );
  }
}

class MensajeFijo {
  final String titulo;
  final String cuerpo;
  final String accion;
  final String datosContacto;

  MensajeFijo({
    required this.titulo,
    required this.cuerpo,
    required this.accion,
    required this.datosContacto,
  });

  factory MensajeFijo.fromJson(Map<String, dynamic> json) {
    return MensajeFijo(
      titulo: json['titulo'],
      cuerpo: json['cuerpo'],
      accion: json['accion'],
      datosContacto: json['datos_contacto'],
    );
  }
}

/// Capa 1: Mensajes generales por nivel
class Capa1General {
  final List<String> leve;
  final List<String> moderada;

  Capa1General({
    required this.leve,
    required this.moderada,
  });

  factory Capa1General.fromJson(Map<String, dynamic> json) {
    return Capa1General(
      leve: List<String>.from(json['leve']),
      moderada: List<String>.from(json['moderada']),
    );
  }
}

/// Capa 2: Mensajes por tipo de ansiedad
class Capa2Tipo {
  final List<String> fisico;
  final List<String> cognitivo;
  final List<String> mixto;

  Capa2Tipo({
    required this.fisico,
    required this.cognitivo,
    required this.mixto,
  });

  factory Capa2Tipo.fromJson(Map<String, dynamic> json) {
    return Capa2Tipo(
      fisico: List<String>.from(json['fisico']),
      cognitivo: List<String>.from(json['cognitivo']),
      mixto: List<String>.from(json['mixto']),
    );
  }
}

/// Capa 3: Recomendaciones por ítem/síntoma
class ItemRecomendacion {
  final int id;
  final String sintoma;
  final RecomendacionesPorNivel recomendaciones;
  final String? nota;

  ItemRecomendacion({
    required this.id,
    required this.sintoma,
    required this.recomendaciones,
    this.nota,
  });

  factory ItemRecomendacion.fromJson(Map<String, dynamic> json) {
    return ItemRecomendacion(
      id: json['id'],
      sintoma: json['sintoma'],
      recomendaciones: RecomendacionesPorNivel.fromJson(json['recomendaciones']),
      nota: json['nota'],
    );
  }
}

class RecomendacionesPorNivel {
  final RecomendacionPorMomento leve;
  final RecomendacionPorMomento moderada;

  RecomendacionesPorNivel({
    required this.leve,
    required this.moderada,
  });

  factory RecomendacionesPorNivel.fromJson(Map<String, dynamic> json) {
    return RecomendacionesPorNivel(
      leve: RecomendacionPorMomento.fromJson(json['leve']),
      moderada: RecomendacionPorMomento.fromJson(json['moderada']),
    );
  }
}

class RecomendacionPorMomento {
  final List<String> dia;
  final List<String> noche;

  RecomendacionPorMomento({
    required this.dia,
    required this.noche,
  });

  factory RecomendacionPorMomento.fromJson(Map<String, dynamic> json) {
    return RecomendacionPorMomento(
      dia: List<String>.from(json['dia']),
      noche: List<String>.from(json['noche']),
    );
  }
}
