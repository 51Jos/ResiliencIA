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
    );
  }
}
