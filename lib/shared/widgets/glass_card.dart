import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_spacing.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blurSigma;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.blurSigma = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding ?? const EdgeInsets.all(FNSpacing.lg),
          decoration: BoxDecoration(
            color: FNColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: FNColors.border.withOpacity(0.6)),
          ),
          child: child,
        ),
      ),
    );
  }
}
