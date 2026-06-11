import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/shared/infrastructure/subscriber_repository.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_button.dart';
import 'package:fresh_news_mobile/shared/widgets/glass_card.dart';

class UnsubscribeScreen extends ConsumerStatefulWidget {
  final String? token;
  const UnsubscribeScreen({super.key, this.token});

  @override
  ConsumerState<UnsubscribeScreen> createState() => _UnsubscribeScreenState();
}

class _UnsubscribeScreenState extends ConsumerState<UnsubscribeScreen> {
  bool? _success;
  String _message = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _processUnsubscribe();
  }

  Future<void> _processUnsubscribe() async {
    if (widget.token == null || widget.token!.isEmpty) {
      setState(() {
        _success = false;
        _message = 'Link inválido ou ausente.';
        _loading = false;
      });
      return;
    }

    final result = await ref.read(subscriberRepositoryProvider).unsubscribe(widget.token!);
    if (mounted) {
      setState(() {
        _success = result.success;
        _message = result.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: FNColors.background,
        body: Center(child: CircularProgressIndicator(color: FNColors.primaryViolet)),
      );
    }

    final isSuccess = _success ?? false;
    final glowColor = isSuccess 
        ? FNColors.success.withValues(alpha: 0.15)
        : FNColors.error.withValues(alpha: 0.1);

    return Scaffold(
      backgroundColor: FNColors.background,
      body: Stack(
        children: [
          // Background glow
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: glowColor,
              ),
            ),
          ).animate().fadeIn(duration: 1.seconds),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(FNSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: GlassCard(
                  borderRadius: BorderRadius.circular(56),
                  padding: const EdgeInsets.all(FNSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícone
                      GlassCard(
                        borderRadius: BorderRadius.circular(16),
                        padding: const EdgeInsets.all(20),
                        child: Icon(
                          isSuccess ? LucideIcons.circle_check : LucideIcons.circle_x,
                          size: 40,
                          color: isSuccess ? FNColors.success : FNColors.error,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Título
                      Text(
                        isSuccess ? 'INSCRIÇÃO_CANCELADA' : 'ERRO_DE_PROTOCOLO',
                        style: FNTypography.headingLarge.copyWith(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Mensagem
                      Text(
                        isSuccess 
                            ? 'Que pena ver você partir! Seu e-mail foi removido da nossa lista de envio.'
                            : _message,
                        style: FNTypography.bodyMedium.copyWith(
                          color: FNColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // CTA
                      FNButton(
                        label: isSuccess ? 'INSCREVER-SE_NOVAMENTE' : 'VOLTAR_AO_APP',
                        onPressed: () => context.go('/'),
                        fullWidth: true,
                      ),
                      const SizedBox(height: 48),

                      // Footer
                      Text(
                        'Fresh News // Protocol // 2026',
                        style: FNTypography.label.copyWith(
                          color: FNColors.textMuted.withValues(alpha: 0.3),
                          fontStyle: FontStyle.italic,
                          letterSpacing: 3,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
