import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/fn_colors.dart';
import '../../core/theme/fn_theme.dart';

enum FNButtonVariant { primary, outline, ghost, destructive }

class FNButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final FNButtonVariant variant;
  final Widget? leading;
  final Widget? trailing;
  final bool isLoading;
  final bool fullWidth;
  final Color? primaryColor;

  const FNButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = FNButtonVariant.primary,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.fullWidth = false,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final schemeColor =
        primaryColor ?? Theme.of(context).colorScheme.primary;

    final Widget content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 8)],
        if (isLoading)
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _labelColor(schemeColor),
            ),
          )
        else
          Text(
            label.toUpperCase(),
            style: FNTypography.techLabel.copyWith(color: _labelColor(schemeColor)),
          ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: GestureDetector(
        onTap: (isLoading || onPressed == null)
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: _decoration(schemeColor),
          child: content,
        ),
      ),
    );
  }

  BoxDecoration _decoration(Color primary) {
    switch (variant) {
      case FNButtonVariant.primary:
        return BoxDecoration(
          color: onPressed == null ? primary.withOpacity(0.4) : primary,
        );
      case FNButtonVariant.outline:
        return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: primary, width: 1.5),
        );
      case FNButtonVariant.ghost:
        return BoxDecoration(
          color: primary.withOpacity(0.08),
        );
      case FNButtonVariant.destructive:
        return const BoxDecoration(
          color: FNColors.error,
        );
    }
  }

  Color _labelColor(Color primary) {
    switch (variant) {
      case FNButtonVariant.primary:
        return Colors.white;
      case FNButtonVariant.outline:
        return primary;
      case FNButtonVariant.ghost:
        return primary;
      case FNButtonVariant.destructive:
        return Colors.white;
    }
  }
}
