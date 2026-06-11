import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/features/preferences/application/preferences_provider.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_button.dart';
import 'package:fresh_news_mobile/shared/widgets/glass_card.dart';

class DangerZone extends ConsumerWidget {
  final String subscriberId;

  const DangerZone({super.key, required this.subscriberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      borderColor: FNColors.error.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(FNSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ZONA_DE_PERIGO',
            style: FNTypography.techLabel.copyWith(
              color: FNColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FNSpacing.base),
          Text(
            'Ao cancelar sua inscrição, você deixará de receber as newsletters e notificações push.',
            style: FNTypography.bodySmall.copyWith(color: FNColors.textSecondary),
          ),
          const SizedBox(height: FNSpacing.base),
          FNButton(
            label: 'CANCELAR_INSCRIÇÃO',
            leading: Icon(LucideIcons.triangle_alert, size: 16, color: Colors.white),
            primaryColor: FNColors.error,
            variant: FNButtonVariant.outline,
            fullWidth: true,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: FNColors.surface,
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: FNColors.border, width: 2.5),
                  ),
                  title: Text(
                    'Tem certeza?',
                    style: FNTypography.headingMedium.copyWith(fontStyle: FontStyle.italic),
                  ),
                  content: Text(
                    'Você deseja realmente cancelar sua inscrição no Fresh News?',
                    style: FNTypography.bodyMedium,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancelar',
                        style: FNTypography.label.copyWith(color: FNColors.textSecondary),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Sim, cancelar',
                        style: FNTypography.label.copyWith(color: FNColors.error),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final success = await ref
                    .read(preferencesProvider(subscriberId).notifier)
                    .unsubscribe();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inscrição cancelada. Esperamos você de volta!'),
                    ),
                  );
                  context.go('/');
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
