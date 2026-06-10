import 'package:flutter/material.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_typography.dart';

enum FNBadgeStatus { draft, published, error, info }

class FNBadge extends StatelessWidget {
  final String label;
  final FNBadgeStatus status;

  const FNBadge({
    super.key,
    required this.label,
    this.status = FNBadgeStatus.info,
  });

  Color get _color {
    switch (status) {
      case FNBadgeStatus.draft:
        return FNColors.warning;
      case FNBadgeStatus.published:
        return FNColors.success;
      case FNBadgeStatus.error:
        return FNColors.error;
      case FNBadgeStatus.info:
        return FNColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: FNTypography.label.copyWith(color: color),
      ),
    );
  }
}
