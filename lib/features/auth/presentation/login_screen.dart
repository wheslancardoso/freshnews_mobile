import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/features/auth/application/auth_notifier.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_button.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_input.dart';
import 'package:fresh_news_mobile/shared/widgets/glass_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final success = await ref.read(authProvider.notifier).login(_passwordController.text);
    if (success && mounted) {
      context.go('/admin/posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: FNColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrow_left, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(FNSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: GlassCard(
              borderRadius: BorderRadius.circular(4),
              borderColor: Colors.black,
              borderWidth: 2.5,
              padding: const EdgeInsets.all(FNSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: FNColors.surfaceVariant,
                      shape: BoxShape.circle,
                      border: Border.all(color: FNColors.border),
                    ),
                    child: const Icon(
                      LucideIcons.lock,
                      color: FNColors.textPrimary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: FNSpacing.xl),
                  Text(
                    'ÁREA RESTRITA',
                    textAlign: TextAlign.center,
                    style: FNTypography.headingLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: FNSpacing.sm),
                  Text(
                    'APENAS PARA EDITORES AUTORIZADOS.',
                    textAlign: TextAlign.center,
                    style: FNTypography.label,
                  ),
                  const SizedBox(height: FNSpacing.xxl),
                  FNInput(
                    controller: _passwordController,
                    hint: 'Senha de acesso',
                    obscureText: true,
                    onChanged: (_) {},
                  ),
                  if (authState.errorMessage != null) ...[
                    const SizedBox(height: FNSpacing.md),
                    Text(
                      authState.errorMessage!,
                      style: FNTypography.bodySmall.copyWith(color: FNColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: FNSpacing.xl),
                  FNButton(
                    label: 'ACESSAR_PAINEL',
                    onPressed: authState.isLoading ? null : _handleLogin,
                    isLoading: authState.isLoading,
                    fullWidth: true,
                  ),
                  const SizedBox(height: FNSpacing.xxl),
                  Text(
                    'Binary BroadSheet // Security Layer',
                    textAlign: TextAlign.center,
                    style: FNTypography.bodySmall.copyWith(color: FNColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
