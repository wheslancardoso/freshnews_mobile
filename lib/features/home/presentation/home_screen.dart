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
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image
          _buildBackground(latestNewsletterAsync),
          
          // 2. Subtle Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          
          // 3. Giant Masthead Logo
          _buildMasthead(),

          // 4. Content Area (Glassmorphism Bottom Card)
          _buildGlassContent(context, latestNewsletterAsync, activeWorld),

          // 5. Vertical Spine Navigation
          _buildVerticalWorldSelector(ref, activeWorld),

          // 6. Top Bar (Settings / Admin)
          _buildTopBar(context, ref, activeWorld),
        ],
      ),
    );
  }

  Widget _buildBackground(AsyncValue<Newsletter?> latestNewsletterAsync) {
    return latestNewsletterAsync.when(
      data: (newsletter) {
        if (newsletter == null || newsletter.imageUrl == null) {
          return Container(color: const Color(0xFF111111));
        }
        return CachedNetworkImage(
          imageUrl: newsletter.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: const Color(0xFF111111)),
          errorWidget: (context, url, error) => Container(color: const Color(0xFF111111)),
        ).animate().fadeIn(duration: 800.ms);
      },
      loading: () => Container(color: const Color(0xFF111111)),
      error: (_, __) => Container(color: FNColors.error.withValues(alpha: 0.3)),
    );
  }

  Widget _buildMasthead() {
    return Positioned(
      top: 60,
      left: 48, // offset spine
      right: 0,
      child: Center(
        child: Text(
          'FRESH\nNEWS',
          textAlign: TextAlign.center,
          style: FNTypography.headingMedium.copyWith(
            fontSize: 90,
            height: 0.85,
            fontWeight: FontWeight.w900,
            letterSpacing: -4,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
      ).animate().fadeIn(delay: 200.ms, duration: 1.seconds),
    );
  }

  Widget _buildVerticalWorldSelector(WidgetRef ref, World activeWorld) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: 48,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: World.values.map((world) {
                final isSelected = world == activeWorld;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(worldControllerProvider.notifier).setWorld(world);
                      ref.read(chameleonThemeProvider.notifier).updateThemeByWorld(world.config.slug);
                    },
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          world.config.label.toUpperCase(),
                          style: FNTypography.techLabel.copyWith(
                            color: isSelected ? world.config.primaryColor : Colors.white.withValues(alpha: 0.4),
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    ).animate().slideX(begin: -1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref, World activeWorld) {
    final authState = ref.watch(authProvider);
    
    return Positioned(
      top: 50,
      right: 16,
      child: Row(
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
          GestureDetector(
            onLongPress: () {
              HapticFeedback.heavyImpact();
              context.push('/login');
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(LucideIcons.user, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContent(BuildContext context, AsyncValue<Newsletter?> latestNewsletterAsync, World activeWorld) {
    return Positioned(
      bottom: 0,
      left: 48, // offset spine
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 48), // extra bottom padding for SafeArea
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              border: const Border(top: BorderSide(color: Colors.white24, width: 1)),
            ),
            child: latestNewsletterAsync.when(
              data: (newsletter) {
                if (newsletter == null) {
                  return const Center(child: Text('Nenhuma edição.', style: TextStyle(color: Colors.white)));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barcode & Edition row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VOL. ${newsletter.editionNumber.toString().padLeft(3, '0')}',
                              style: FNTypography.code.copyWith(
                                color: activeWorld.config.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              newsletter.category ?? 'MASTER',
                              style: FNTypography.techLabelSmall.copyWith(
                                color: Colors.white54,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '||||||||| | |||||', // Fake barcode
                          style: FNTypography.headingMedium.copyWith(
                            letterSpacing: 2,
                            color: Colors.white30,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ],
                    ).animate().slideY(begin: 0.5, end: 0).fadeIn(),
                    
                    const SizedBox(height: 24),
                    
                    // Headline
                    Text(
                      newsletter.title,
                      style: FNTypography.displayLarge.copyWith(
                        color: Colors.white,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ).animate().slideY(begin: 0.2, end: 0).fadeIn(delay: 100.ms),
                    
                    const SizedBox(height: 16),
                    
                    // Intro
                    if (newsletter.summaryIntro != null)
                      Text(
                        newsletter.summaryIntro!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: FNTypography.bodyLarge.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ).animate().slideY(begin: 0.2, end: 0).fadeIn(delay: 200.ms),
                      
                    const SizedBox(height: 32),
                    
                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 64, // Botão massivo brutalista
                      child: FNButton(
                        label: 'ACESSAR EDIÇÃO',
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
              loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.white))),
              error: (e, _) => const SizedBox(height: 100, child: Text('Erro', style: TextStyle(color: Colors.red))),
            ),
          ),
        ),
      ),
    );
  }
}
