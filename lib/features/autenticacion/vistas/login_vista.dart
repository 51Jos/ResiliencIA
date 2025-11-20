import 'package:flutter/material.dart';
import '../../../compartidos/tema/colores_app.dart';
import '../../../compartidos/tema/tema_app.dart';
import '../componentes/login/login_cabecera.dart';
import '../componentes/login/login_formulario.dart';

/// Vista de inicio de sesión
class LoginVista extends StatelessWidget {
  const LoginVista({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPrincipal,
      body: Stack(
        children: [
          SafeArea(
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
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Cabecera con logo y título
                          LoginCabecera(),
                          SizedBox(height: 40),

                          // Formulario de login
                          LoginFormulario(),
                          SizedBox(height: 24),

                          // Tarjeta informativa
                          LoginTarjetaInfo(),
                          SizedBox(height: 30),

                          // Pie de página
                          LoginPiePagina(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Botón oculto para crear psicólogo (TEMPORAL - solo desarrollo)
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(
                  Icons.admin_panel_settings,
                  color: ColoresApp.textoClaro,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/temp/crear-psicologo');
                },
                tooltip: 'Crear psicólogo (TEMP)',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
