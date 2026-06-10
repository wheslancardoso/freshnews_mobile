cat > /home/claude/fresh_news_design_system.txt << 'ENDOFFILE'
### ARQUIVO: `mobile/lib/core/constants/world.dart`
```dart
import 'package:flutter/material.dart';

enum World {
  tech,
  music,
  gear,
  game,
}

class WorldMeta {
  final World world;
  final String label;
  final String emoji;
  final Color primaryColor;
  final String tagline;
  final List<String> categories;

  const WorldMeta({
    required this.world,
    required this.label,
    required this.emoji,
    required this.primaryColor,
    required this.tagline,
    required this.categories,
  });
}

class WorldRegistry {
  static const Map<World, WorldMeta> all = {
    World.tech: WorldMeta(
      world: World.tech,
      label: 'TECH',
      emoji: '💻',
      primaryColor: Color(0xFF22C55E),
      tagline: 'CÓDIGO & IA',
      categories: ['DEV', 'IA', 'SEGURANÇA', 'STARTUPS', 'CLOUD'],
    ),
    World.music: WorldMeta(
      world: World.music,
      label: 'MUSIC',
      emoji: '🎵',
      primaryColor: Color(0xFFEAB308),
      tagline: 'BEATS & NOISE',
      categories: ['ARTISTAS', 'PRODUÇÃO', 'INDIE', 'CHARTS', 'LANÇAMENTOS'],
    ),
    World.gear: WorldMeta(
      world: World.gear,
      label: 'GEAR',
      emoji: '⚙️',
      primaryColor: Color(0xFFF59E0B),
      tagline: 'RPM & GADGETS',
      categories: ['AUTOMOTIVO', 'GADGETS', 'WEARABLES', 'DIY', 'INOVAÇÃO'],
    ),
    World.game: WorldMeta(
      world: World.game,
      label: 'GAME',
      emoji: '🎮',
      primaryColor: Color(0xFFA855F7),
      tagline: 'ARCADE & PIXEL',
      categories: ['PC', 'CONSOLE', 'MOBILE', 'ESPORTS', 'INDIE'],
    ),
  };

  static WorldMeta get(World world) => all[world]!;

  static World fromString(String value) {
    return World.values.firstWhere(
      (w) => w.name == value,
      orElse: () => World.tech,
    );
  }
}
```

### ARQUIVO: `mobile/lib/features/world_selector/application/world_controller.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/world.dart';

const _kActiveWorldKey = 'active_world';

class WorldState {
  final World activeWorld;
  final bool isLoading;

  const WorldState({
    this.activeWorld = World.tech,
    this.isLoading = true,
  });

  WorldState copyWith({World? activeWorld, bool? isLoading}) {
    return WorldState(
      activeWorld: activeWorld ?? this.activeWorld,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WorldController extends StateNotifier<WorldState> {
  final SharedPreferences _prefs;

  WorldController(this._prefs) : super(const WorldState()) {
    _loadPersistedWorld();
  }

  void _loadPersistedWorld() {
    final saved = _prefs.getString(_kActiveWorldKey);
    final world = saved != null ? WorldRegistry.fromString(saved) : World.tech;
    state = WorldState(activeWorld: world, isLoading: false);
  }

  Future<void> setWorld(World world) async {
    await _prefs.setString(_kActiveWorldKey, world.name);
    state = state.copyWith(activeWorld: world);
  }

  WorldMeta get activeMeta => WorldRegistry.get(state.activeWorld);
}

// Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

final worldControllerProvider =
    StateNotifierProvider<WorldController, WorldState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WorldController(prefs);
});

final activeWorldProvider = Provider<World>((ref) {
  return ref.watch(worldControllerProvider).activeWorld;
});

final activeWorldMetaProvider = Provider<WorldMeta>((ref) {
  final world = ref.watch(activeWorldProvider);
  return WorldRegistry.get(world);
});
```

### ARQUIVO: `mobile/lib/core/theme/fn_colors.dart`
```dart
import 'package:flutter/material.dart';

class FNColors {
  FNColors._();

  // === Base (Dark Theme) ===
  static const background      = Color(0xFF0A0A0B);
  static const surface         = Color(0xFF111113);
  static const card            = Color(0xFF141416);
  static const foreground      = Color(0xFFFAFAFA);
  static const mutedForeground = Color(0xFFA1A1AA);

  // === World Primaries ===
  static const primaryViolet = Color(0xFF8B5CF6);
  static const primaryGreen  = Color(0xFF22C55E);
  static const primaryYellow = Color(0xFFEAB308);
  static const primaryAmber  = Color(0xFFF59E0B);
  static const primaryPurple = Color(0xFFA855F7);

  // === Glass ===
  static Color glassBg     = Colors.white.withOpacity(0.03);
  static Color glassBorder = Colors.white.withOpacity(0.08);
  static const glassBlur   = 24.0;

  // === Semantic ===
  static const success = Color(0xFF10B981);
  static const error   = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const info    = Color(0xFF3B82F6);

  // === Categories ===
  static const catIA      = Color(0xFFA78BFA);
  static const catDev     = Color(0xFF10B981);
  static const catSec     = Color(0xFFF43F5E);
  static const catStartup = Color(0xFFF59E0B);
  static const catDefault = Color(0xFF8B5CF6);

  // === Hacker / CRT ===
  static const hackerGreen = Color(0xFF3DF13D);
  static const hackerBg    = Color(0xFF0A0A0A);

  // === Category color helper ===
  static Color forCategory(String category) {
    switch (category.toUpperCase()) {
      case 'IA':
        return catIA;
      case 'DEV':
        return catDev;
      case 'SEGURANÇA':
        return catSec;
      case 'STARTUPS':
        return catStartup;
      default:
        return catDefault;
    }
  }
}
```

### ARQUIVO: `mobile/lib/core/theme/fn_theme.dart`
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fn_colors.dart';

// ─── Typography ─────────────────────────────────────────────────────────────

class FNTypography {
  FNTypography._();

  static TextStyle get body    => GoogleFonts.inter();
  static TextStyle get heading => GoogleFonts.outfit();
  static TextStyle get mono    => GoogleFonts.jetBrainsMono();

  // Headlines
  static TextStyle h1 = GoogleFonts.outfit(
    fontSize: 48, fontWeight: FontWeight.w900,
    letterSpacing: -2, height: 0.85,
  );
  static TextStyle h2 = GoogleFonts.outfit(
    fontSize: 36, fontWeight: FontWeight.w900,
    letterSpacing: -1.5, height: 0.9,
  );
  static TextStyle h3 = GoogleFonts.outfit(
    fontSize: 28, fontWeight: FontWeight.w800,
    letterSpacing: -1,
  );

  // Body
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w500, height: 1.6,
  );
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w400, height: 1.5,
  );
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.4,
  );

  // Tech labels
  static TextStyle techLabel = GoogleFonts.inter(
    fontSize: 10, fontWeight: FontWeight.w900,
    letterSpacing: 3, height: 1,
  );
  static TextStyle techLabelSmall = GoogleFonts.inter(
    fontSize: 9, fontWeight: FontWeight.w900,
    letterSpacing: 4, height: 1,
  );

  // Mono
  static TextStyle code = GoogleFonts.jetBrainsMono(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.6,
  );
}

// ─── Spacing ────────────────────────────────────────────────────────────────

class FNSpacing {
  FNSpacing._();

  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double base = 16;
  static const double lg   = 24;
  static const double xl   = 32;
  static const double xxl  = 48;
  static const double xxxl = 64;

  static const pagePadding    = EdgeInsets.symmetric(horizontal: 24);
  static const sectionPadding = EdgeInsets.symmetric(vertical: 48);
}

// ─── Theme ──────────────────────────────────────────────────────────────────

class FNTheme {
  FNTheme._();

  static ThemeData darkTheme({Color? primaryColor}) {
    final primary = primaryColor ?? FNColors.primaryViolet;

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: FNColors.background,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: primary.withOpacity(0.7),
        surface: FNColors.surface,
        onPrimary: Colors.white,
        onSurface: FNColors.foreground,
        error: FNColors.error,
      ),
      textTheme: TextTheme(
        displayLarge:  FNTypography.h1.copyWith(color: FNColors.foreground),
        displayMedium: FNTypography.h2.copyWith(color: FNColors.foreground),
        displaySmall:  FNTypography.h3.copyWith(color: FNColors.foreground),
        bodyLarge:     FNTypography.bodyLarge.copyWith(color: FNColors.foreground),
        bodyMedium:    FNTypography.bodyMedium.copyWith(color: FNColors.foreground),
        bodySmall:     FNTypography.bodySmall.copyWith(color: FNColors.mutedForeground),
        labelSmall:    FNTypography.techLabel.copyWith(color: FNColors.mutedForeground),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: FNTypography.h3.copyWith(
          color: FNColors.foreground,
          fontStyle: FontStyle.italic,
        ),
      ),
      cardTheme: CardThemeData(
        color: FNColors.card,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Color(0x14FFFFFF)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: FNColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary.withOpacity(0.5), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        hintStyle: FNTypography.bodyMedium.copyWith(
          color: FNColors.mutedForeground.withOpacity(0.3),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: FNColors.glassBorder,
        thickness: 1,
      ),
    );
  }
}
```

### ARQUIVO: `mobile/lib/shared/widgets/glass_card.dart`
```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/fn_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double blur;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.blur = FNColors.glassBlur,
    this.borderColor,
    this.backgroundColor,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.zero;

    Widget card = ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? FNColors.glassBg,
            borderRadius: effectiveBorderRadius,
            border: Border.all(
              color: borderColor ?? FNColors.glassBorder,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      card = GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }
}
```

### ARQUIVO: `mobile/lib/shared/widgets/fn_button.dart`
```dart
import 'package:flutter/material.dart';
import '../../core/theme/fn_colors.dart';
import '../../core/theme/fn_theme.dart';

enum FNButtonVariant { primary, outline, ghost, destructive }

class FNButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final FNButtonVariant variant;
  final Widget? leading;
  final Widget? trailing;
  final bool isLoading;
  final bool fullWidth;
  final Color? primaryColor;

  const FNButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = FNButtonVariant.primary,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.fullWidth = false,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final schemeColor =
        primaryColor ?? Theme.of(context).colorScheme.primary;

    final Widget content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 8)],
        if (isLoading)
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _labelColor(schemeColor),
            ),
          )
        else
          Text(
            label.toUpperCase(),
            style: FNTypography.techLabel.copyWith(color: _labelColor(schemeColor)),
          ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: _decoration(schemeColor),
          child: content,
        ),
      ),
    );
  }

  BoxDecoration _decoration(Color primary) {
    switch (variant) {
      case FNButtonVariant.primary:
        return BoxDecoration(
          color: onPressed == null ? primary.withOpacity(0.4) : primary,
        );
      case FNButtonVariant.outline:
        return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: primary, width: 1.5),
        );
      case FNButtonVariant.ghost:
        return BoxDecoration(
          color: primary.withOpacity(0.08),
        );
      case FNButtonVariant.destructive:
        return const BoxDecoration(
          color: FNColors.error,
        );
    }
  }

  Color _labelColor(Color primary) {
    switch (variant) {
      case FNButtonVariant.primary:
        return Colors.white;
      case FNButtonVariant.outline:
        return primary;
      case FNButtonVariant.ghost:
        return primary;
      case FNButtonVariant.destructive:
        return Colors.white;
    }
  }
}
```

### ARQUIVO: `mobile/lib/shared/widgets/fn_badge.dart`
```dart
import 'package:flutter/material.dart';
import '../../core/theme/fn_colors.dart';
import '../../core/theme/fn_theme.dart';

class FNBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? backgroundColor;

  const FNBadge({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
  });

  factory FNBadge.category(String category) {
    final color = FNColors.forCategory(category);
    return FNBadge(
      label: category,
      color: color,
      backgroundColor: color.withOpacity(0.12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? effectiveColor.withOpacity(0.12),
        border: Border.all(color: effectiveColor.withOpacity(0.4), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: FNTypography.techLabelSmall.copyWith(color: effectiveColor),
      ),
    );
  }
}
```

### ARQUIVO: `mobile/lib/shared/widgets/news_card.dart`
```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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

  const NewsCardData({
    required this.id,
    required this.title,
    required this.intro,
    this.imageUrl,
    required this.edition,
    required this.date,
    this.categories = const [],
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
          if (data.imageUrl != null) _buildImage(),
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
          .map((c) => FNBadge.category(c))
          .toList(),
    );
  }
}
```

### ARQUIVO: `mobile/lib/shared/widgets/fn_input.dart`
```dart
import 'package:flutter/material.dart';
import '../../core/theme/fn_colors.dart';
import '../../core/theme/fn_theme.dart';

class FNInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool readOnly;
  final FocusNode? focusNode;

  const FNInput({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.obscureText = false,
    this.keyboardType,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: FNTypography.techLabelSmall.copyWith(
              color: FNColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          maxLines: obscureText ? 1 : maxLines,
          readOnly: readOnly,
          focusNode: focusNode,
          style: FNTypography.bodyMedium.copyWith(color: FNColors.foreground),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
```

### ARQUIVO: `mobile/lib/shared/widgets/glass_nav_bar.dart`
```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/fn_colors.dart';
import '../../core/theme/fn_theme.dart';

class GlassNavBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const GlassNavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? activeColor;

  static const items = [
    GlassNavBarItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'HOME',
    ),
    GlassNavBarItem(
      icon: Icons.archive_outlined,
      activeIcon: Icons.archive,
      label: 'ARQUIVO',
    ),
    GlassNavBarItem(
      icon: Icons.info_outline,
      activeIcon: Icons.info,
      label: 'SOBRE',
    ),
    GlassNavBarItem(
      icon: Icons.admin_panel_settings_outlined,
      activeIcon: Icons.admin_panel_settings,
      label: 'ADMIN',
    ),
  ];

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = activeColor ?? Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: FNColors.glassBg,
              border: Border.all(color: FNColors.glassBorder),
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isActive = index == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isActive
                            ? primary.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border(
                          top: BorderSide(
                            color: isActive ? primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            size: 20,
                            color: isActive
                                ? primary
                                : FNColors.mutedForeground,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: FNTypography.techLabelSmall.copyWith(
                              color: isActive
                                  ? primary
                                  : FNColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
```

### ARQUIVO: `mobile/lib/core/utils/animations.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension FNAnimations on Widget {
  Widget fnFadeUp({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 400),
    double offsetY = 24,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: Curves.easeOut)
        .slideY(
          begin: offsetY / 100,
          end: 0,
          duration: duration,
          curve: Curves.easeOut,
        );
  }

  Widget fnFade({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: Curves.easeOut);
  }

  Widget fnPop({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return animate(delay: delay)
        .scale(
          begin: const Offset(0.88, 0.88),
          end: const Offset(1, 1),
          duration: duration,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: duration ~/ 2);
  }

  Widget fnShimmer({Color? baseColor, Color? highlightColor}) {
    return animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1200),
          color: highlightColor ?? Colors.white.withOpacity(0.08),
        );
  }

  Widget fnStagger(int index, {int baseDelayMs = 60}) {
    return fnFadeUp(delay: Duration(milliseconds: baseDelayMs * index));
  }
}

class FNDuration {
  FNDuration._();
  static const fast   = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 300);
  static const slow   = Duration(milliseconds: 500);
  static const xslow  = Duration(milliseconds: 800);
}

class FNCurves {
  FNCurves._();
  static const enter  = Curves.easeOut;
  static const exit   = Curves.easeIn;
  static const spring = Curves.elasticOut;
  static const smooth = Curves.easeInOutCubic;
}
```
ENDOFFILE
echo "ok"
Saída

ok
Concluído

