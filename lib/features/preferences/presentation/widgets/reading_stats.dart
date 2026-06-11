import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/features/archive/application/archive_providers.dart';
import 'package:fresh_news_mobile/shared/infrastructure/tracking_repository.dart';
import 'package:fresh_news_mobile/shared/widgets/glass_card.dart';

class ReadingStats extends ConsumerWidget {
  const ReadingStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriberId = ref.watch(subscriberIdProvider);
    if (subscriberId == null) return const SizedBox.shrink();

    return FutureBuilder<Map<String, int>>(
      future: ref.read(trackingRepositoryProvider).getCategoryStats(subscriberId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const GlassCard(
            padding: EdgeInsets.all(FNSpacing.lg),
            child: Center(
              child: CircularProgressIndicator(color: FNColors.primaryViolet),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final stats = snapshot.data!;
        final total = stats.values.fold(0, (a, b) => a + b);

        // Ordenar estatísticas da maior frequência para a menor
        final sortedEntries = stats.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return GlassCard(
          padding: const EdgeInsets.all(FNSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SEU PERFIL DE LEITURA',
                style: FNTypography.techLabel.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: FNSpacing.base),
              ...sortedEntries.map((entry) {
                final percentage = total > 0 ? (entry.value / total * 100).round() : 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: FNSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key.toUpperCase(), style: FNTypography.bodySmall),
                          Text(
                            '$percentage%',
                            style: FNTypography.techLabel.copyWith(
                              color: FNColors.primaryViolet,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        valueColor: const AlwaysStoppedAnimation<Color>(FNColors.primaryViolet),
                        minHeight: 4,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
