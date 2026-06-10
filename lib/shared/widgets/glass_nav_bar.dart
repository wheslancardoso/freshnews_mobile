import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/fn_colors.dart';
import '../../core/theme/fn_theme.dart';

class GlassNavBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const GlassNavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? activeColor;

  static const items = [
    GlassNavBarItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'HOME',
    ),
    GlassNavBarItem(
      icon: Icons.archive_outlined,
      activeIcon: Icons.archive,
      label: 'ARQUIVO',
    ),
    GlassNavBarItem(
      icon: Icons.info_outline,
      activeIcon: Icons.info,
      label: 'SOBRE',
    ),
    GlassNavBarItem(
      icon: Icons.admin_panel_settings_outlined,
      activeIcon: Icons.admin_panel_settings,
      label: 'ADMIN',
    ),
  ];

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = activeColor ?? Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: FNColors.glassBg,
              border: Border.all(color: FNColors.glassBorder),
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isActive = index == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isActive
                            ? primary.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border(
                          top: BorderSide(
                            color: isActive ? primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            size: 20,
                            color: isActive
                                ? primary
                                : FNColors.mutedForeground,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: FNTypography.techLabelSmall.copyWith(
                              color: isActive
                                  ? primary
                                  : FNColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
