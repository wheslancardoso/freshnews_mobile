import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/features/world_selector/application/world_controller.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/features/home/application/home_providers.dart';
import 'package:fresh_news_mobile/shared/domain/newsletter.entity.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_button.dart';
import 'package:fresh_news_mobile/core/theme/chameleon_theme_provider.dart';
import 'package:fresh_news_mobile/features/auth/application/auth_notifier.dart';
import 'package:fresh_news_mobile/features/archive/application/archive_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeWorld = ref.watch(activeWorldProvider);
    final latestNewsletterAsync = ref.watch(latestNewsletterProvider);

    return Scaffold(
      backgroundColor: FNColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          _buildBackground(latestNewsletterAsync),
          
          // Gradient Overlay to ensure text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopBar(context, ref, activeWorld),
                const SizedBox(height: FNSpacing.md),
                _buildWorldChips(ref, activeWorld),
                const Spacer(),
                _buildHeroContent(context, latestNewsletterAsync, activeWorld),
                const SizedBox(height: FNSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(AsyncValue<Newsletter?> latestNewsletterAsync) {
    return latestNewsletterAsync.when(
      data: (newsletter) {
        if (newsletter == null || newsletter.imageUrl == null) {
          return Container(color: FNColors.surface);
        }
        return CachedNetworkImage(
          imageUrl: newsletter.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: FNColors.surface),
          errorWidget: (context, url, error) => Container(color: FNColors.surface),
        ).animate().fadeIn(duration: 800.ms);
      },
      loading: () => Container(color: FNColors.surface),
      error: (_, __) => Container(color: FNColors.error.withValues(alpha: 0.3)),
    );
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref, World activeWorld) {
    final authState = ref.watch(authProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FNSpacing.lg, vertical: FNSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onLongPress: () {
              HapticFeedback.heavyImpact();
              context.push('/login');
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: activeWorld.config.primaryColor, width: 2.0),
                  ),
                  child: Text(
                    'FN',
                    style: FNTypography.headingSmall.copyWith(
                      color: activeWorld.config.primaryColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              if (authState.isAdmin)
                IconButton(
                  icon: const Icon(LucideIcons.terminal, color: Colors.white),
                  tooltip: 'Console Admin',
                  onPressed: () => context.push('/admin'),
                ),
              if (ref.watch(subscriberIdProvider) != null)
                IconButton(
                  icon: const Icon(LucideIcons.settings, color: Colors.white),
                  onPressed: () => context.push('/preferences/${ref.read(subscriberIdProvider)}'),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWorldChips(WidgetRef ref, World activeWorld) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: FNSpacing.lg),
        itemCount: World.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: FNSpacing.sm),
        itemBuilder: (context, index) {
          final world = World.values[index];
          final isSelected = world == activeWorld;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(worldControllerProvider.notifier).setWorld(world);
              ref.read(chameleonThemeProvider.notifier).updateThemeByWorld(world.config.slug);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? world.config.primaryColor 
                        : Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.2),
                      width: 2.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        world.config.icon,
                        size: 16,
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                      const SizedBox(width: FNSpacing.sm),
                      Text(
                        world.config.label.toUpperCase(),
                        style: FNTypography.label.copyWith(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroContent(BuildContext context, AsyncValue<Newsletter?> latestNewsletterAsync, World activeWorld) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FNSpacing.lg),
      child: latestNewsletterAsync.when(
        data: (newsletter) {
          if (newsletter == null) {
            return Center(
              child: Text(
                'Nenhuma edição publicada.',
                style: FNTypography.headingMedium.copyWith(color: Colors.white),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: activeWorld.config.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                child: Text(
                  'EDIÇÃO #${newsletter.editionNumber}',
                  style: FNTypography.techLabelSmall.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ).animate().slideY(begin: 0.5, end: 0).fadeIn(),
              const SizedBox(height: FNSpacing.md),
              Text(
                newsletter.title,
                style: FNTypography.displayLarge.copyWith(
                  color: Colors.white,
                  height: 1.1,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    )
                  ],
                ),
              ).animate().slideY(begin: 0.2, end: 0).fadeIn(delay: 100.ms),
              const SizedBox(height: FNSpacing.md),
              if (newsletter.summaryIntro != null)
                Text(
                  newsletter.summaryIntro!,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: FNTypography.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      )
                    ],
                  ),
                ).animate().slideY(begin: 0.2, end: 0).fadeIn(delay: 200.ms),
              const SizedBox(height: FNSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 64, // Botão massivo brutalista
                child: FNButton(
                  label: 'LER EDIÇÃO DA SEMANA',
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    context.push('/archive/${newsletter.id}');
                  },
                  trailing: const Icon(LucideIcons.arrow_right, size: 20),
                  variant: FNButtonVariant.primary,
                  fullWidth: true,
                ),
              ).animate().scale(delay: 300.ms, curve: Curves.elasticOut),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (e, _) => Text('Erro ao carregar edição.', style: FNTypography.bodyMedium.copyWith(color: FNColors.error)),
      ),
    );
  }
}
