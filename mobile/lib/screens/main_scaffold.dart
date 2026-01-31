import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.inkPrimary12, width: 0.5)),
        ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shield_outlined),
              activeIcon: const Icon(Icons.shield),
              label: 'Risk',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: l10n.profile,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.help_outline),
              activeIcon: const Icon(Icons.help),
              label: 'Ayuda',
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
