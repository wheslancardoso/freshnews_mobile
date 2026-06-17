import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/world.dart';
import '../../core/theme/fn_colors.dart';
import '../../core/theme/fn_theme.dart';
import 'fn_badge.dart';
import 'glass_card.dart';

class NewsCardData {
  final String id;
  final String title;
  final String intro;
  final String? imageUrl;
  final String edition;
  final String date;
  final List<String> categories;
  final World? world;

  const NewsCardData({
    required this.id,
    required this.title,
    required this.intro,
    this.imageUrl,
    required this.edition,
    required this.date,
    this.categories = const [],
    this.world,
  });
}

class NewsCard extends StatelessWidget {
  final NewsCardData data;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const NewsCard({
    super.key,
    required this.data,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Descomente a linha abaixo para voltar a exibir a imagem nos cards:
          // if (data.imageUrl != null) _buildImage(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMeta(context),
                const SizedBox(height: 10),
                Text(
                  data.title,
                  style: FNTypography.h3.copyWith(
                    color: FNColors.foreground,
                    fontSize: 20,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  data.intro,
                  style: FNTypography.bodySmall.copyWith(
                    color: FNColors.mutedForeground,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                if (data.categories.isNotEmpty) _buildCategories(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: CachedNetworkImage(
        imageUrl: data.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: FNColors.surface,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 1),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          color: FNColors.surface,
          child: const Icon(Icons.broken_image_outlined,
              color: FNColors.mutedForeground),
        ),
      ),
    );
  }

  Widget _buildMeta(BuildContext context) {
    return Row(
      children: [
        Text(
          data.edition,
          style: FNTypography.techLabel.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Container(width: 1, height: 10, color: FNColors.glassBorder),
        const SizedBox(width: 12),
        Text(
          data.date,
          style: FNTypography.techLabelSmall.copyWith(
            color: FNColors.mutedForeground,
          ),
        ),
        const Spacer(),
        if (onEdit != null)
          GestureDetector(
            onTap: onEdit,
            child: const Icon(Icons.edit_outlined,
                size: 16, color: FNColors.mutedForeground),
          ),
      ],
    );
  }

  Widget _buildCategories() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: data.categories
          .map((c) => FNBadge.category(c, world: data.world))
          .toList(),
    );
  }
}
