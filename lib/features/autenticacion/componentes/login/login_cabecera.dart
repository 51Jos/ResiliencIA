import 'package:flutter/material.dart';
import '../../../../compartidos/componentes/layout/cabecera_pagina.dart';
import '../../../../compartidos/tema/colores_app.dart';

/// Cabecera del formulario de login
class LoginCabecera extends StatelessWidget {
  const LoginCabecera({super.key});

  @override
  Widget build(BuildContext context) {
    return CabeceraConLogo(
      titulo: 'Bienvenido',
      subtitulo: 'Sistema de Detección de Ansiedad y Acompañamiento Emocional',
      logo: const Icon(
        Icons.psychology,
        size: 45,
        color: Colors.white,
      ),
    );
  }
}

/// Tarjeta informativa debajo del formulario
class LoginTarjetaInfo extends StatelessWidget {
  const LoginTarjetaInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColoresApp.fondoTarjeta,
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(
            color: ColoresApp.primario,
            width: 3,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: ColoresApp.primario,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Espacio seguro y confidencial',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: ColoresApp.textoOscuro,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tu bienestar emocional es importante. Este sistema está diseñado para acompañarte y brindarte apoyo cuando lo necesites.',
                  style: TextStyle(
                    fontSize: 13,
                    color: ColoresApp.textoMedio,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

