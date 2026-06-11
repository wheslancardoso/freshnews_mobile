import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';

class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/admin/newsletters')) {
      return 2;
    }
    if (location.startsWith('/admin/posts')) {
      return 1;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/admin/posts');
        break;
      case 2:
        context.go('/admin/newsletters');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      backgroundColor: FNColors.background,
      appBar: AppBar(
        title: Text(
          'ADMIN CONSOLE',
          style: FNTypography.headingMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: FNColors.background.withValues(alpha: 0.85),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.log_out, color: FNColors.error),
            onPressed: () {
              // Poderia chamar o logout do admin
              context.go('/');
            },
          ),
        ],
      ),
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
          selectedLabelStyle: FNTypography.techLabelSmall,
          unselectedLabelStyle: FNTypography.techLabelSmall,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.house),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.inbox),
              label: 'CURADORIA',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.mail),
              label: 'EDIÇÕES',
            ),
          ],
        ),
      ),
    );
  }
}
