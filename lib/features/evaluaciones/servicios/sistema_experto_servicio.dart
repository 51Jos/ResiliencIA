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
  final String mensajePrincipal;
  final String mensajeTipo;
  final List<String> recomendacionesPersonalizadas;
  final TipoAnsiedad tipoAnsiedad;
  final List<int> sintomasPrincipales;
  final bool requiereDerivacion;
  final String? mensajeDerivacion;

  AnalisisExperto({
    required this.mensajePrincipal,
    required this.mensajeTipo,
    required this.recomendacionesPersonalizadas,
    required this.tipoAnsiedad,
    required this.sintomasPrincipales,
    required this.requiereDerivacion,
    this.mensajeDerivacion,
  });
}

/// Servicio del sistema experto para generar recomendaciones personalizadas
class SistemaExpertoServicio {
  static BancoRecomendaciones? _banco;
  static final Random _random = Random();

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

    // 1. Verificar si requiere derivación profesional
    final requiereDerivacion = puntajeTotal >= _banco!.nivelesGlobales.derivacionProfesional.rango[0];
    String? mensajeDerivacion;

    if (requiereDerivacion) {
      final msg = _banco!.nivelesGlobales.derivacionProfesional.mensajeFijo;
      mensajeDerivacion = '${msg.titulo}\n\n${msg.cuerpo}\n\n${msg.accion}\n${msg.datosContacto}';
    }

    // 2. Obtener mensaje principal (sin ansiedad o nivel leve/moderado)
    String mensajePrincipal;
    if (puntajeTotal <= _banco!.nivelesGlobales.sinAnsiedad.rango[1]) {
      // Sin ansiedad - mensaje aleatorio
      final mensajes = _banco!.nivelesGlobales.sinAnsiedad.mensajes;
      mensajePrincipal = mensajes[_random.nextInt(mensajes.length)];
    } else {
      // Leve o moderado
      final esLeve = nivelAnsiedad == NivelAnsiedad.leve;
      final mensajes = esLeve ? _banco!.capa1General.leve : _banco!.capa1General.moderada;
      mensajePrincipal = mensajes[_random.nextInt(mensajes.length)];
    }

    // 3. Detectar tipo de ansiedad (física, cognitiva o mixta)
    final tipoAnsiedad = _detectarTipoAnsiedad(respuestas);

    // 4. Obtener mensaje de tipo
    String mensajeTipo = '';
    if (!requiereDerivacion && puntajeTotal > _banco!.nivelesGlobales.sinAnsiedad.rango[1]) {
      final esLeve = nivelAnsiedad == NivelAnsiedad.leve;
      final nivelKey = esLeve ? 'leve' : 'moderada';
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
      mensajeTipo = mensajesTipo[_random.nextInt(mensajesTipo.length)];
    }

    // 5. Identificar síntomas principales (puntaje >= 2)
    final sintomasPrincipales = <int>[];
    respuestas.forEach((preguntaId, puntaje) {
      if (puntaje >= 2) {
        sintomasPrincipales.add(preguntaId);
      }
    });

    // 6. Generar recomendaciones personalizadas basadas en síntomas
    final recomendacionesPersonalizadas = _generarRecomendacionesPersonalizadas(
      sintomasPrincipales: sintomasPrincipales,
      nivelAnsiedad: nivelAnsiedad,
      tipoAnsiedad: tipoAnsiedad,
    );

    return AnalisisExperto(
      mensajePrincipal: mensajePrincipal,
      mensajeTipo: mensajeTipo,
      recomendacionesPersonalizadas: recomendacionesPersonalizadas,
      tipoAnsiedad: tipoAnsiedad,
      sintomasPrincipales: sintomasPrincipales,
      requiereDerivacion: requiereDerivacion,
      mensajeDerivacion: mensajeDerivacion,
    );
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

  /// Genera recomendaciones personalizadas basadas en síntomas específicos
  static List<String> _generarRecomendacionesPersonalizadas({
    required List<int> sintomasPrincipales,
    required NivelAnsiedad nivelAnsiedad,
    required TipoAnsiedad tipoAnsiedad,
  }) {
    if (_banco == null) return [];

    final recomendaciones = <String>[];
    final ahora = DateTime.now();
    final esNoche = ahora.hour >= 18 || ahora.hour < 6;

    // Si no hay síntomas principales, retornar recomendaciones generales
    if (sintomasPrincipales.isEmpty) {
      return _obtenerRecomendacionesGenerales(nivelAnsiedad);
    }

    // Ordenar síntomas por puntaje descendente (los más graves primero)
    sintomasPrincipales.sort((a, b) => b.compareTo(a));

    // Tomar máximo los 5 síntomas más importantes
    final sintomasTop = sintomasPrincipales.take(5).toList();

    for (final sintomaId in sintomasTop) {
      final itemRec = _banco!.capa3Items.firstWhere(
        (item) => item.id == sintomaId,
        orElse: () => _banco!.capa3Items.first,
      );

      // Determinar nivel (leve o moderado/grave)
      final esLeve = nivelAnsiedad == NivelAnsiedad.minima ||
                     nivelAnsiedad == NivelAnsiedad.leve;

      final recPorNivel = esLeve
          ? itemRec.recomendaciones.leve
          : itemRec.recomendaciones.moderada;

      // Seleccionar recomendaciones según momento del día
      final recsDelMomento = esNoche ? recPorNivel.noche : recPorNivel.dia;

      // Agregar las recomendaciones tal cual están en el JSON
      final cantidad = sintomasTop.length <= 3 ? 2 : 1;
      for (int i = 0; i < cantidad && i < recsDelMomento.length; i++) {
        final rec = recsDelMomento[i];
        if (!recomendaciones.contains(rec)) {
          recomendaciones.add(rec);
        }
      }
    }

    // Limitar a máximo 8 recomendaciones
    return recomendaciones.take(8).toList();
  }

  /// Obtiene recomendaciones generales cuando no hay síntomas específicos
  static List<String> _obtenerRecomendacionesGenerales(NivelAnsiedad nivel) {
    switch (nivel) {
      case NivelAnsiedad.minima:
        return [
          'Mantén una rutina de sueño regular (7-8 horas diarias)',
          'Practica ejercicio físico moderado 3 veces por semana',
          'Dedica tiempo a actividades que disfrutas',
        ];
      case NivelAnsiedad.leve:
        return [
          'Practica técnicas de respiración profunda 10 minutos al día',
          'Realiza ejercicio físico regular (caminar, yoga, natación)',
          'Establece horarios fijos para dormir y despertar',
          'Limita el consumo de cafeína y alcohol',
        ];
      case NivelAnsiedad.moderada:
        return [
          'Practica técnicas de relajación muscular progresiva',
          'Realiza ejercicio aeróbico 30 minutos, 5 veces por semana',
          'Establece una rutina de meditación diaria (20 minutos)',
          'Evita sustancias estimulantes (café, bebidas energéticas)',
        ];
      case NivelAnsiedad.moderadaGrave:
      case NivelAnsiedad.severa:
        return [
          'IMPORTANTE: Agenda una cita con el psicólogo del servicio',
          'Practica respiración diafragmática varias veces al día',
          'Establece una rutina diaria muy estructurada',
          'NO te aísles, busca apoyo en personas de confianza',
        ];
    }
  }
}
