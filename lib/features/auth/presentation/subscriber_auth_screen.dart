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

class SubscriberAuthScreen extends ConsumerStatefulWidget {
  const SubscriberAuthScreen({super.key});

  @override
  ConsumerState<SubscriberAuthScreen> createState() => _SubscriberAuthScreenState();
}

class _SubscriberAuthScreenState extends ConsumerState<SubscriberAuthScreen> {
  final _emailController = TextEditingController();
  bool _linkSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe seu e-mail de assinante.')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).sendMagicLink(email);
    if (success && mounted) {
      setState(() {
        _linkSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link de login enviado! Verifique sua caixa de entrada.')),
      );
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
              borderRadius: BorderRadius.circular(56),
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
                      LucideIcons.mail,
                      color: FNColors.textPrimary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: FNSpacing.xl),
                  Text(
                    _linkSent ? 'LINK ENVIADO!' : 'ÁREA DO LEITOR',
                    textAlign: TextAlign.center,
                    style: FNTypography.headingLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: FNSpacing.sm),
                  Text(
                    _linkSent 
                        ? 'Verifique seu e-mail para acessar suas preferências de leitura.'
                        : 'ACESSE SEU PERFIL E ESCOLHA SEUS INTERESSES.',
                    textAlign: TextAlign.center,
                    style: FNTypography.label,
                  ),
                  const SizedBox(height: FNSpacing.xxl),
                  if (!_linkSent) ...[
                    FNInput(
                      controller: _emailController,
                      hint: 'E-mail cadastrado',
                      keyboardType: TextInputType.emailAddress,
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
                      label: 'RECEBER_LINK_DE_ACESSO',
                      onPressed: authState.isLoading ? null : _handleSendLink,
                      isLoading: authState.isLoading,
                      fullWidth: true,
                    ),
                  ] else ...[
                    Text(
                      'Enviamos um Magic Link para o e-mail informado. Ao clicar no link, você será conectado automaticamente e redirecionado para a tela de configurações.',
                      style: FNTypography.bodyMedium.copyWith(color: FNColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: FNSpacing.xl),
                    FNButton(
                      label: 'VOLTAR_A_HOME',
                      onPressed: () => context.go('/'),
                      fullWidth: true,
                    ),
                  ],
                  const SizedBox(height: FNSpacing.xxl),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      'É um editor? Acessar área restrita →',
                      style: FNTypography.bodySmall.copyWith(
                        color: FNColors.primaryViolet,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: FNSpacing.md),
                  Text(
                    'Binary BroadSheet // Reader Session',
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
