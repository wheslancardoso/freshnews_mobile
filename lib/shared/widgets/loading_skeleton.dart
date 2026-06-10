import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';

class LoadingSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry borderRadius;

  const LoadingSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: FNColors.surfaceVariant,
      highlightColor: FNColors.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: FNColors.surfaceVariant,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
