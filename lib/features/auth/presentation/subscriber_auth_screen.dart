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
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(LucideIcons.arrow_left, color: Colors.white),
                onPressed: () => context.pop(),
              )
            : null,
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
                    const CircularProgressIndicator(
                      color: FNColors.primaryViolet,
                    ),
                    const SizedBox(height: FNSpacing.xl),
                    Text(
                      'AGUARDANDO CONFIRMAÇÃO...',
                      textAlign: TextAlign.center,
                      style: FNTypography.label.copyWith(
                        color: FNColors.primaryViolet,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: FNSpacing.md),
                    Text(
                      'Enviamos um link seguro para o seu e-mail.\nMinimize este aplicativo, abra sua caixa de entrada e clique no link para ser conectado automaticamente.',
                      style: FNTypography.bodyMedium.copyWith(color: FNColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: FNSpacing.xl),
                  ],
                  const SizedBox(height: FNSpacing.lg),
                  FNButton(
                    label: 'LER_MANIFESTO_EDITORIAL',
                    variant: FNButtonVariant.outline,
                    onPressed: () => _showManifesto(context),
                    fullWidth: true,
                  ),
                  const SizedBox(height: FNSpacing.xl),
                  TextButton(
                    onPressed: () => context.push('/login'),
                    child: Text(
                      'É um editor? Acessar área restrita →',
                      style: FNTypography.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.primary,
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

  void _showManifesto(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: FNColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        side: BorderSide(color: FNColors.border, width: 2),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(FNSpacing.xl),
          color: FNColors.background,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MANIFESTO EDITORIAL // FRESH NEWS',
                style: FNTypography.headingMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: FNColors.primaryViolet,
                ),
              ),
              const SizedBox(height: FNSpacing.md),
              const Divider(color: FNColors.border, thickness: 1.5),
              const SizedBox(height: FNSpacing.md),
              Text(
                'A informação no século XXI é abundante, mas ruidosa. O excesso de conteúdo obscurece o sinal real. O Fresh News é um portal de inteligência e curadoria direta.',
                style: FNTypography.bodyMedium.copyWith(height: 1.5, color: FNColors.textPrimary),
              ),
              const SizedBox(height: FNSpacing.sm),
              Text(
                'Nossos algoritmos varrem diariamente dezenas de fontes selecionadas de alta fidelidade e relevância nos mundos de Tech, Games, Música e Gear. A inteligência artificial destila e organiza o fluxo, entregando apenas o que é essencial.',
                style: FNTypography.bodyMedium.copyWith(height: 1.5, color: FNColors.textPrimary),
              ),
              const SizedBox(height: FNSpacing.xl),
              FNButton(
                label: 'FECHAR_MANIFESTO',
                onPressed: () => Navigator.pop(context),
                fullWidth: true,
              ),
            ],
          ),
        );
      },
    );
  }
}
