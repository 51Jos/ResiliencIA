import 'package:flutter/material.dart';
import '../../../compartidos/tema/colores_app.dart';

/// Barra de navegación adaptativa para administradores
/// Muestra un NavigationRail en web/tablet y un BottomNavigationBar en móvil
class BarraNavegacionAdmin extends StatelessWidget {
  final int indiceActual;
  final Function(int) alCambiar;

  const BarraNavegacionAdmin({
    super.key,
    required this.indiceActual,
    required this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    final esWeb = MediaQuery.of(context).size.width >= 768;

    if (esWeb) {
      // Navegación lateral para web/tablet
      return NavigationRail(
        selectedIndex: indiceActual,
        onDestinationSelected: alCambiar,
        labelType: NavigationRailLabelType.all,
        backgroundColor: ColoresApp.fondoBlanco,
        selectedIconTheme: const IconThemeData(
          color: ColoresApp.primario,
          size: 28,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: ColoresApp.primario,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedIconTheme: IconThemeData(
          color: ColoresApp.textoMedio.withValues(alpha: 0.6),
          size: 24,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: ColoresApp.textoMedio.withValues(alpha: 0.6),
          fontSize: 12,
        ),
        destinations: _obtenerDestinos(esWeb: true),
      );
    } else {
      // Barra inferior para móvil
      return BottomNavigationBar(
        currentIndex: indiceActual,
        onTap: alCambiar,
        type: BottomNavigationBarType.fixed,
        backgroundColor: ColoresApp.fondoBlanco,
        selectedItemColor: ColoresApp.primario,
        unselectedItemColor: ColoresApp.textoMedio.withValues(alpha: 0.6),
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: _obtenerItemsNavegacion(),
      );
    }
  }

  /// Destinos para NavigationRail (web/tablet)
  List<NavigationRailDestination> _obtenerDestinos({required bool esWeb}) {
    return const [
      NavigationRailDestination(
        icon: Icon(Icons.people_outline),
        selectedIcon: Icon(Icons.people),
        label: Text('Estudiantes'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.assessment_outlined),
        selectedIcon: Icon(Icons.assessment),
        label: Text('Estadísticas'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.notifications_outlined),
        selectedIcon: Icon(Icons.notifications),
        label: Text('Notificaciones'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: Text('Configuración'),
      ),
    ];
  }

  /// Items para BottomNavigationBar (móvil)
  List<BottomNavigationBarItem> _obtenerItemsNavegacion() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.people_outline),
        activeIcon: Icon(Icons.people),
        label: 'Estudiantes',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.assessment_outlined),
        activeIcon: Icon(Icons.assessment),
        label: 'Estadísticas',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.notifications_outlined),
        activeIcon: Icon(Icons.notifications),
        label: 'Notificaciones',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        activeIcon: Icon(Icons.settings),
        label: 'Configuración',
      ),
    ];
  }
}

/// Scaffold adaptativo que integra la barra de navegación
/// Usa layout lateral en web/tablet y layout con barra inferior en móvil
class ScaffoldAdminAdaptativo extends StatelessWidget {
  final int indiceNavegacion;
  final Function(int) alCambiarNavegacion;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const ScaffoldAdminAdaptativo({
    super.key,
    required this.indiceNavegacion,
    required this.alCambiarNavegacion,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final esWeb = MediaQuery.of(context).size.width >= 768;

    if (esWeb) {
      // Layout web: NavigationRail lateral + contenido
      return Scaffold(
        backgroundColor: backgroundColor ?? ColoresApp.fondoPrincipal,
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        body: Row(
          children: [
            // Barra de navegación lateral
            BarraNavegacionAdmin(
              indiceActual: indiceNavegacion,
              alCambiar: alCambiarNavegacion,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Contenido principal
            Expanded(child: body),
          ],
        ),
      );
    } else {
      // Layout móvil: contenido + BottomNavigationBar
      return Scaffold(
        backgroundColor: backgroundColor ?? ColoresApp.fondoPrincipal,
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        body: body,
        bottomNavigationBar: BarraNavegacionAdmin(
          indiceActual: indiceNavegacion,
          alCambiar: alCambiarNavegacion,
        ),
      );
    }
  }
}
