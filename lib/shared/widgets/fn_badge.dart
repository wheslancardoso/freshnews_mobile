import 'package:flutter/material.dart';
import '../../core/theme/fn_colors.dart';
import '../../core/theme/fn_theme.dart';

class FNBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? backgroundColor;

  const FNBadge({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
  });

  factory FNBadge.category(String category) {
    final color = FNColors.forCategory(category);
    return FNBadge(
      label: category,
      color: color,
      backgroundColor: color.withOpacity(0.12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? effectiveColor.withOpacity(0.12),
        border: Border.all(color: effectiveColor.withOpacity(0.4), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: FNTypography.techLabelSmall.copyWith(color: effectiveColor),
      ),
    );
  }
}
