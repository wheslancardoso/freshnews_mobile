import 'package:flutter/material.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_typography.dart';

class FNButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool fullWidth;

  const FNButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: FNColors.background),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label, style: FNTypography.headingSmall.copyWith(color: FNColors.background)),
            ],
          );

    final button = ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: child,
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
