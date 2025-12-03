import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../modelos/banco_recomendaciones.dart';
import '../modelos/pregunta_beck.dart';

/// Tipos de ansiedad detectados por el sistema experto
enum TipoAnsiedad {
  fisico,
  cognitivo,
  mixto,
}

/// Resultado del análisis del sistema experto
class AnalisisExperto {
  final List<String> mensajes;
  final TipoAnsiedad? tipoAnsiedad;
  final bool esSinAnsiedad;
  final bool requiereDerivacion;
  final String? tituloDerivacion;
  final String? cuerpoDerivacion;
  final String? accionDerivacion;
  final String? datosContactoDerivacion;

  AnalisisExperto({
    required this.mensajes,
    this.tipoAnsiedad,
    required this.esSinAnsiedad,
    required this.requiereDerivacion,
    this.tituloDerivacion,
    this.cuerpoDerivacion,
    this.accionDerivacion,
    this.datosContactoDerivacion,
  });
}

/// Servicio del sistema experto para generar recomendaciones personalizadas
class SistemaExpertoServicio {
  static BancoRecomendaciones? _banco;
  static final Random _random = Random();
  static DateTime? _ultimaFechaSinAnsiedad;
  static int? _ultimoIndiceSinAnsiedad;

  /// Carga el banco de recomendaciones desde los assets
  static Future<void> cargarBanco() async {
    if (_banco != null) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/banco_recomendaciones.json');
      _banco = BancoRecomendaciones.fromJsonString(jsonString);
    } catch (e) {
      throw Exception('Error al cargar banco de recomendaciones: $e');
    }
  }

  /// Analiza los resultados del test y genera recomendaciones personalizadas
  static Future<AnalisisExperto> analizarResultados({
    required Map<int, int> respuestas,
    required int puntajeTotal,
    required NivelAnsiedad nivelAnsiedad,
  }) async {
    await cargarBanco();

    if (_banco == null) {
      throw Exception('Banco de recomendaciones no cargado');
    }

    final mensajes = <String>[];

    // 1. SIN ANSIEDAD (Mínima): Mostrar mensaje aleatorio diario
    if (nivelAnsiedad == NivelAnsiedad.minima) {
      final mensajeDiario = _obtenerMensajeSinAnsiedadDiario();
      mensajes.add(mensajeDiario);

      return AnalisisExperto(
        mensajes: mensajes,
        tipoAnsiedad: null,
        esSinAnsiedad: true,
        requiereDerivacion: false,
      );
    }

    // 2. GRAVE (Moderada-Grave o Severa): Solo derivación profesional
    if (nivelAnsiedad == NivelAnsiedad.moderadaGrave || nivelAnsiedad == NivelAnsiedad.severa) {
      final derivacion = _banco!.nivelesGlobales.derivacionProfesional.mensajeFijo;

      return AnalisisExperto(
        mensajes: [],
        tipoAnsiedad: null,
        esSinAnsiedad: false,
        requiereDerivacion: true,
        tituloDerivacion: derivacion.titulo,
        cuerpoDerivacion: derivacion.cuerpo,
        accionDerivacion: derivacion.accion,
        datosContactoDerivacion: derivacion.datosContacto,
      );
    }

    // 3. LEVE o MODERADA: Generar recomendaciones completas

    // Determinar nivel para filtrar
    final esLeve = nivelAnsiedad == NivelAnsiedad.leve;
    final nivelKey = esLeve ? 'leve' : 'moderada';

    // 3.1 CAPA 1: Mensaje general
    final mensajesGenerales = esLeve
        ? _banco!.capa1General.leve
        : _banco!.capa1General.moderada;
    final mensajeGeneral = mensajesGenerales[_random.nextInt(mensajesGenerales.length)];
    mensajes.add(mensajeGeneral);

    // 3.2 Detectar tipo de ansiedad
    final tipoAnsiedad = _detectarTipoAnsiedad(respuestas);

    // 3.3 CAPA 2: Mensaje por tipo
    final capa2 = _banco!.capa2Tipo[nivelKey]!;
    List<String> mensajesTipo;
    switch (tipoAnsiedad) {
      case TipoAnsiedad.fisico:
        mensajesTipo = capa2.fisico;
        break;
      case TipoAnsiedad.cognitivo:
        mensajesTipo = capa2.cognitivo;
        break;
      case TipoAnsiedad.mixto:
        mensajesTipo = capa2.mixto;
        break;
    }
    final mensajeTipo = mensajesTipo[_random.nextInt(mensajesTipo.length)];
    mensajes.add(mensajeTipo);

    // 3.4 CAPA 3: Recomendaciones por ítems donde respondió 3
    final recomendacionesItems = _obtenerRecomendacionesItems(
      respuestas: respuestas,
      nivelKey: nivelKey,
    );
    mensajes.addAll(recomendacionesItems);

    return AnalisisExperto(
      mensajes: mensajes,
      tipoAnsiedad: tipoAnsiedad,
      esSinAnsiedad: false,
      requiereDerivacion: false,
    );
  }

  /// Obtiene mensaje sin ansiedad (diferente cada día)
  static String _obtenerMensajeSinAnsiedadDiario() {
    final hoy = DateTime.now();
    final mensajes = _banco!.nivelesGlobales.sinAnsiedad.mensajes;

    // Si es un nuevo día, generar nuevo índice aleatorio
    if (_ultimaFechaSinAnsiedad == null ||
        _ultimaFechaSinAnsiedad!.day != hoy.day ||
        _ultimaFechaSinAnsiedad!.month != hoy.month ||
        _ultimaFechaSinAnsiedad!.year != hoy.year) {
      _ultimaFechaSinAnsiedad = hoy;
      _ultimoIndiceSinAnsiedad = _random.nextInt(mensajes.length);
    }

    return mensajes[_ultimoIndiceSinAnsiedad!];
  }

  /// Obtiene recomendaciones solo de ítems donde el usuario respondió 3
  static List<String> _obtenerRecomendacionesItems({
    required Map<int, int> respuestas,
    required String nivelKey,
  }) {
    final recomendaciones = <String>[];
    final ahora = DateTime.now();
    final esNoche = ahora.hour >= 18 || ahora.hour < 6;
    final momentoDelDia = esNoche ? 'noche' : 'dia';

    // Filtrar solo ítems con puntaje = 3
    final itemsCon3 = <int>[];
    respuestas.forEach((preguntaId, puntaje) {
      if (puntaje == 3) {
        itemsCon3.add(preguntaId);
      }
    });

    // Si no hay ítems con 3, retornar vacío
    if (itemsCon3.isEmpty) {
      return recomendaciones;
    }

    // Para cada ítem con puntaje 3, obtener recomendaciones
    for (final itemId in itemsCon3) {
      final itemRec = _banco!.capa3Items.firstWhere(
        (item) => item.id == itemId,
        orElse: () => _banco!.capa3Items.first,
      );

      // Obtener recomendaciones del nivel correcto (leve o moderada)
      Map<String, List<String>> recsPorNivel;
      if (nivelKey == 'leve') {
        recsPorNivel = {
          'dia': itemRec.recomendaciones.leve.dia,
          'noche': itemRec.recomendaciones.leve.noche,
        };
      } else {
        recsPorNivel = {
          'dia': itemRec.recomendaciones.moderada.dia,
          'noche': itemRec.recomendaciones.moderada.noche,
        };
      }

      // Filtrar por momento del día
      final recsDelMomento = recsPorNivel[momentoDelDia]!;

      // Agregar todas las recomendaciones de este ítem
      for (final rec in recsDelMomento) {
        if (!recomendaciones.contains(rec)) {
          recomendaciones.add(rec);
        }
      }
    }

    return recomendaciones;
  }

  /// Detecta el tipo de ansiedad predominante
  static TipoAnsiedad _detectarTipoAnsiedad(Map<int, int> respuestas) {
    // Síntomas físicos: items 1, 2, 3, 6, 7, 8, 15, 18, 19, 20, 21
    final sintFisicos = [1, 2, 3, 6, 7, 8, 15, 18, 19, 20, 21];

    // Síntomas cognitivos: items 5, 9, 11, 14, 16, 17
    final sintCognitivos = [5, 9, 11, 14, 16, 17];

    // Síntomas mixtos: items 4, 10, 12, 13
    final sintMixtos = [4, 10, 12, 13];

    int puntajeFisico = 0;
    int puntajeCognitivo = 0;

    respuestas.forEach((preguntaId, puntaje) {
      if (sintFisicos.contains(preguntaId)) {
        puntajeFisico += puntaje;
      }
      if (sintCognitivos.contains(preguntaId)) {
        puntajeCognitivo += puntaje;
      }
      if (sintMixtos.contains(preguntaId)) {
        puntajeFisico += puntaje ~/ 2;
        puntajeCognitivo += puntaje ~/ 2;
      }
    });

    // Determinar tipo predominante
    final diferencia = (puntajeFisico - puntajeCognitivo).abs();
    if (diferencia <= 3) {
      return TipoAnsiedad.mixto;
    } else if (puntajeFisico > puntajeCognitivo) {
      return TipoAnsiedad.fisico;
    } else {
      return TipoAnsiedad.cognitivo;
    }
  }
}
