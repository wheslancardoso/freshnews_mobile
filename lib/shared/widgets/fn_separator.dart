import 'package:flutter/material.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';

class FNSeparator extends StatelessWidget {
  final double verticalSpacing;

  const FNSeparator({
    super.key,
    this.verticalSpacing = FNSpacing.lg,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalSpacing),
      child: const Divider(color: FNColors.border, thickness: 1, height: 1),
    );
  }
}
