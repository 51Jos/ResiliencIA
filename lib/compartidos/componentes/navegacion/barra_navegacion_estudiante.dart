import 'package:flutter/material.dart';
import '../../tema/colores_app.dart';

/// Barra de navegación inferior para estudiantes
class BarraNavegacionEstudiante extends StatelessWidget {
  final int indiceActual;

  const BarraNavegacionEstudiante({
    super.key,
    required this.indiceActual,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: indiceActual,
      onTap: (index) => _navegarA(context, index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: ColoresApp.primario,
      unselectedItemColor: ColoresApp.textoMedio,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }

  void _navegarA(BuildContext context, int index) {
    // Si ya está en la página actual, no hacer nada
    if (index == indiceActual) return;

    switch (index) {
      case 0:
        // Navegar al home (reemplazar para evitar stack)
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        // Navegar al perfil (reemplazar para evitar stack)
        Navigator.of(context).pushReplacementNamed('/perfil');
        break;
    }
  }
}
