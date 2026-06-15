import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/shared/domain/subscriber.entity.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_badge.dart';
import 'package:fresh_news_mobile/shared/widgets/glass_card.dart';

class ProfileCard extends StatelessWidget {
  final Subscriber subscriber;

  const ProfileCard({super.key, required this.subscriber});

  @override
  Widget build(BuildContext context) {
    final email = subscriber.email;
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

    return GlassCard(
      padding: const EdgeInsets.all(FNSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: FNColors.primaryViolet.withValues(alpha: 0.2),
            child: Text(
              initial,
              style: FNTypography.headingMedium.copyWith(color: FNColors.primaryViolet),
            ),
          ),
          const SizedBox(width: FNSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: FNTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FNBadge(
                      label: subscriber.active ? 'ATIVO' : 'INATIVO',
                      color: subscriber.active ? FNColors.success : FNColors.error,
                      backgroundColor: (subscriber.active ? FNColors.success : FNColors.error)
                          .withValues(alpha: 0.12),
                    ),
                    Text(
                      'Desde ${DateFormat('dd/MM/yyyy').format(subscriber.createdAt)}',
                      style: FNTypography.techLabel.copyWith(color: FNColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
