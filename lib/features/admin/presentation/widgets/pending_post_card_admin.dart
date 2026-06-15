import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/shared/domain/post.entity.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_badge.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_button.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_input.dart';
import 'package:fresh_news_mobile/shared/widgets/glass_card.dart';

class PendingPostCardAdmin extends StatefulWidget {
  final Post post;
  final Future<void> Function(String) onApprove;
  final Future<void> Function(String) onReject;
  final Future<void> Function(String, {String? title, String? summary, String? content, String? category}) onUpdate;

  const PendingPostCardAdmin({
    super.key,
    required this.post,
    required this.onApprove,
    required this.onReject,
    required this.onUpdate,
  });

  @override
  State<PendingPostCardAdmin> createState() => _PendingPostCardAdminState();
}

class _PendingPostCardAdminState extends State<PendingPostCardAdmin> {
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _titleController;
  late TextEditingController _summaryController;
  late TextEditingController _contentController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _titleController = TextEditingController(text: widget.post.title);
    _summaryController = TextEditingController(text: widget.post.summary);
    _contentController = TextEditingController(text: widget.post.content);
    _categoryController = TextEditingController(text: widget.post.category);
  }

  @override
  void didUpdateWidget(covariant PendingPostCardAdmin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {
      _initControllers();
      _isEditing = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      await widget.onUpdate(
        widget.post.id,
        title: _titleController.text,
        summary: _summaryController.text,
        content: _contentController.text,
        category: _categoryController.text,
      );
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post editado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao editar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(FNSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    FNBadge(
                      label: widget.post.category,
                      color: FNColors.primaryViolet,
                      backgroundColor: FNColors.primaryViolet.withValues(alpha: 0.12),
                    ),
                    FNBadge(label: 'SCORE: ${widget.post.score}'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.post.source?.toUpperCase() ?? 'WEB',
                  style: FNTypography.techLabelSmall.copyWith(color: FNColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: FNSpacing.sm),
          
          if (_isEditing) ...[
            FNInput(
              controller: _titleController,
              label: 'TÍTULO',
            ),
            const SizedBox(height: FNSpacing.sm),
            FNInput(
              controller: _summaryController,
              label: 'RESUMO / SUMMARY',
              maxLines: 2,
            ),
            const SizedBox(height: FNSpacing.sm),
            FNInput(
              controller: _contentController,
              label: 'CONTEÚDO / CONTENT',
              maxLines: 4,
            ),
            const SizedBox(height: FNSpacing.sm),
            FNInput(
              controller: _categoryController,
              label: 'CATEGORIA',
            ),
            const SizedBox(height: FNSpacing.md),
            Row(
              children: [
                Expanded(
                  child: FNButton(
                    label: 'CANCELAR',
                    variant: FNButtonVariant.outline,
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _initControllers();
                      });
                    },
                  ),
                ),
                const SizedBox(width: FNSpacing.base),
                Expanded(
                  child: FNButton(
                    label: 'SALVAR',
                    isLoading: _isSaving,
                    onPressed: _handleSave,
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              widget.post.title,
              style: FNTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.post.summary.isNotEmpty ? widget.post.summary : widget.post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: FNTypography.bodySmall.copyWith(color: FNColors.textSecondary),
            ),
            const SizedBox(height: FNSpacing.md),
            Row(
              children: [
                Expanded(
                  child: FNButton(
                    label: 'REJEITAR',
                    variant: FNButtonVariant.outline,
                    primaryColor: FNColors.error,
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      await widget.onReject(widget.post.id);
                    },
                  ),
                ),
                const SizedBox(width: FNSpacing.sm),
                FNButton(
                  label: 'EDITAR',
                  variant: FNButtonVariant.outline,
                  leading: const Icon(Icons.edit_outlined, size: 16),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _isEditing = true);
                  },
                ),
                const SizedBox(width: FNSpacing.sm),
                Expanded(
                  child: FNButton(
                    label: 'APROVAR',
                    primaryColor: FNColors.success,
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      await widget.onApprove(widget.post.id);
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
