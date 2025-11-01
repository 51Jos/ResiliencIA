import 'package:flutter/material.dart';
import '../../tema/colores_app.dart';

/// Componente de cabecera reutilizable para páginas
class CabeceraPagina extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final Widget? icono;
  final List<Widget>? acciones;
  final bool mostrarBotonAtras;
  final VoidCallback? alPresionarAtras;

  const CabeceraPagina({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.icono,
    this.acciones,
    this.mostrarBotonAtras = false,
    this.alPresionarAtras,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: ColoresApp.fondoBlanco,
        border: Border(
          bottom: BorderSide(
            color: ColoresApp.bordeDivisor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila principal con título y acciones
          Row(
            children: [
              // Botón atrás
              if (mostrarBotonAtras) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: alPresionarAtras ?? () => Navigator.of(context).pop(),
                  color: ColoresApp.textoMedio,
                ),
                const SizedBox(width: 8),
              ],

              // Icono opcional
              if (icono != null) ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ColoresApp.primarioClaro,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: icono),
                ),
                const SizedBox(width: 16),
              ],

              // Título y subtítulo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: ColoresApp.textoOscuro,
                      ),
                    ),
                    if (subtitulo != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitulo!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ColoresApp.textoMedio,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Acciones
              if (acciones != null) ...[
                const SizedBox(width: 16),
                ...acciones!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Cabecera con logo para pantallas de autenticación
class CabeceraConLogo extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final Widget? logo;

  const CabeceraConLogo({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.logo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo
        if (logo != null) ...[
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: ColoresApp.primario,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ColoresApp.sombraPrimaria,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(child: logo),
          ),
          const SizedBox(height: 20),
        ],

        // Título
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: ColoresApp.textoOscuro,
          ),
        ),

        // Subtítulo
        if (subtitulo != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitulo!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: ColoresApp.textoMedio,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }
}
