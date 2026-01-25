import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_theme.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.inkPrimary12, width: 0.5)),
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), // Fine line
              activeIcon: Icon(Icons.home),
              label: 'Inicio', // Spanish
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined), // Elegant for Services
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Servicios', // Spanish
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), // Fine line
              activeIcon: Icon(Icons.person),
              label: 'Perfil', // Spanish
            ),
          ],
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.inkInverse,
          selectedItemColor: AppTheme.navyPrimary, // Strict Navy
          unselectedItemColor: AppTheme.inkSecondary,
          selectedLabelStyle: AppTheme.captionNavyBold.copyWith(color: AppTheme.navyPrimary),
          unselectedLabelStyle: AppTheme.captionGreyRegular,
          elevation: AppTheme.elevacionNula,
        ),
      ),
    );
  }
}
