import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_spacing.dart';
import 'package:fresh_news_mobile/core/theme/fn_typography.dart';
import 'package:fresh_news_mobile/core/utils/formatters.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_card.dart';

class NewsCard extends StatelessWidget {
  final String title;
  final String summary;
  final String? imageUrl;
  final DateTime date;
  final String category;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.title,
    required this.summary,
    this.imageUrl,
    required this.date,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FNCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 160,
                  color: FNColors.surfaceVariant,
                ),
                errorWidget: (context, url, error) => Container(
                  height: 160,
                  color: FNColors.surfaceVariant,
                  child: const Icon(Icons.image_not_supported, color: FNColors.textMuted),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(FNSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.toUpperCase(), style: FNTypography.label),
                const SizedBox(height: FNSpacing.sm),
                Text(
                  title,
                  style: FNTypography.headingSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: FNSpacing.sm),
                Text(
                  summary,
                  style: FNTypography.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: FNSpacing.md),
                Text(
                  Formatters.formatRelativeDate(date),
                  style: FNTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
