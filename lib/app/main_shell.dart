import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/feed')) {
      return 1;
    }
    if (location.startsWith('/archive')) {
      return 2;
    }
    if (location.startsWith('/profile')) {
      return 3;
    }
    return 0; // Home
  }

  void _onItemTapped(int index, BuildContext context) {
    HapticFeedback.lightImpact();
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/feed');
        break;
      case 2:
        context.go('/archive');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      backgroundColor: FNColors.background,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: FNColors.border, width: 2),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => _onItemTapped(index, context),
          backgroundColor: FNColors.surface,
          selectedItemColor: FNColors.primaryViolet,
          unselectedItemColor: FNColors.textMuted,
          selectedLabelStyle: FNTypography.techLabelSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: FNTypography.techLabelSmall,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.house),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.newspaper),
              label: 'FEED',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.archive),
              label: 'ARQUIVO',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.user),
              label: 'PERFIL',
            ),
          ],
        ),
      ),
    );
  }
}
