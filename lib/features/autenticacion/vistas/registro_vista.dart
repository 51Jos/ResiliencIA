import 'package:flutter/material.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../../../compartidos/tema/tema_app.dart';
import '../../../compartidos/componentes/layout/cabecera_pagina.dart';
import '../componentes/registro/registro_formulario.dart';

/// Vista de registro de usuarios con validación UCSS
class RegistroVista extends StatelessWidget {
  final String? codigo;
  final String? nombres;
  final String? apellidos;
  final String? facultad;

  const RegistroVista({
    super.key,
    this.codigo,
    this.nombres,
    this.apellidos,
    this.facultad,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPrincipal,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: TemaApp.anchoMaximoFormulario,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: ColoresApp.fondoBlanco,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ColoresApp.bordeDivisor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ColoresApp.sombraLigera,
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 50,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Cabecera
                      const CabeceraConLogo(
                        titulo: 'Crear Cuenta',
                        subtitulo: 'Registra tu cuenta usando tus credenciales del portal UCSS',
                        logo: Icon(
                          Icons.person_add,
                          size: 45,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Formulario de registro
                      RegistroFormulario(
                        codigo: codigo,
                        nombres: nombres,
                        apellidos: apellidos,
                        facultad: facultad,
                      ),
                      const SizedBox(height: 24),

                      // Advertencia de seguridad
                      _buildAdvertenciaSeguridad(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdvertenciaSeguridad() {
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
            Icons.shield_outlined,
            color: ColoresApp.primario,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacidad y Seguridad',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: ColoresApp.textoOscuro,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Validaremos tu identidad con el portal UCSS. Tu información está protegida y solo será usada para fines del sistema de bienestar estudiantil.',
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
