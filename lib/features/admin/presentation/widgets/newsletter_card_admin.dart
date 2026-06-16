import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/shared/domain/newsletter.entity.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/features/admin/application/admin_providers.dart';
import 'package:fresh_news_mobile/features/admin/application/image_prompt_generator.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_button.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_input.dart';
import 'package:fresh_news_mobile/shared/widgets/glass_card.dart';

class NewsletterCardAdmin extends ConsumerStatefulWidget {
  final Newsletter draft;
  final VoidCallback? onPublished;
  final VoidCallback? onRejected;

  const NewsletterCardAdmin({
    super.key,
    required this.draft,
    this.onPublished,
    this.onRejected,
  });

  @override
  ConsumerState<NewsletterCardAdmin> createState() => _NewsletterCardAdminState();
}

class _NewsletterCardAdminState extends ConsumerState<NewsletterCardAdmin> {
  late TextEditingController _titleController;
  late TextEditingController _summaryController;
  late TextEditingController _imagePromptController;
  late TextEditingController _imageUrlController;

  bool _showItems = false;
  bool _isSaving = false;
  bool _isUploading = false;
  bool _isGeneratingImage = false;
  late NewsletterContent _content;
  final List<TextEditingController> _quickTakesControllers = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.draft.title);
    _summaryController = TextEditingController(text: widget.draft.summaryIntro ?? '');
    _imagePromptController = TextEditingController(text: widget.draft.imagePrompt ?? '');
    _imageUrlController = TextEditingController(text: widget.draft.imageUrl ?? '');
    _content = widget.draft.contentJson ?? const NewsletterContent(title: '', intro: '');
    for (final take in _content.quickTakes) {
      _quickTakesControllers.add(TextEditingController(text: take));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _imagePromptController.dispose();
    _imageUrlController.dispose();
    for (final controller in _quickTakesControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    // Atualiza quickTakes antes de salvar
    _content = NewsletterContent(
      title: _content.title,
      intro: _content.intro,
      quickTakes: _quickTakesControllers.map((c) => c.text).toList(),
      categories: _content.categories,
      imagePrompt: _content.imagePrompt,
    );
    try {
      await ref.read(adminNewsletterControllerProvider).saveDraft(
        widget.draft.id,
        title: _titleController.text,
        summaryIntro: _summaryController.text,
        imagePrompt: _imagePromptController.text,
        imageUrl: _imageUrlController.text,
        contentJson: _content.toJson(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rascunho salvo com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAndUploadImage({int? categoryIndex, int? itemIndex}) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1000);
    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final bytes = await image.readAsBytes();
      final compressed = await FlutterImageCompress.compressWithList(
        bytes,
        quality: 60,
        format: CompressFormat.webp,
      );

      final fileName = 'edition-${widget.draft.editionNumber}-${DateTime.now().millisecondsSinceEpoch}.webp';
      final supabase = Supabase.instance.client;

      await supabase.storage.from('newsletter-covers').uploadBinary(
        fileName,
        Uint8List.fromList(compressed),
        fileOptions: const FileOptions(contentType: 'image/webp'),
      );

      final publicUrl = supabase.storage.from('newsletter-covers').getPublicUrl(fileName);

      if (categoryIndex == null || itemIndex == null) {
        setState(() {
          _imageUrlController.text = publicUrl;
        });
      } else {
        // Atualizar imagem do item individual de notícia
        final categories = List<NewsCategory>.from(_content.categories);
        final category = categories[categoryIndex];
        final items = List<NewsItem>.from(category.items);
        final item = items[itemIndex];

        items[itemIndex] = NewsItem(
          headline: item.headline,
          story: item.story,
          link: item.link,
          imageUrl: publicUrl,
        );
        categories[categoryIndex] = NewsCategory(name: category.name, items: items);

        setState(() {
          _content = NewsletterContent(
            title: _content.title,
            intro: _content.intro,
            quickTakes: _content.quickTakes,
            categories: categories,
            imagePrompt: _content.imagePrompt,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no upload: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _handleGeneratePrompt() {
    final generatedPrompt = ImagePromptGenerator.generate(
      widget.draft.world,
      _titleController.text.isEmpty ? 'Fresh News Edition' : _titleController.text,
    );
    setState(() {
      _imagePromptController.text = generatedPrompt;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prompt de imagem gerado!')),
      );
    }
  }

  Future<void> _confirmAction(String title, String content, VoidCallback onConfirm) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FNColors.surface,
        title: Text(title, style: FNTypography.headingMedium.copyWith(color: Colors.white)),
        content: Text(content, style: FNTypography.bodyMedium.copyWith(color: FNColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('CANCELAR', style: FNTypography.techLabel.copyWith(color: FNColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('CONFIRMAR', style: FNTypography.techLabel.copyWith(color: FNColors.primaryViolet)),
          ),
        ],
      ),
    );

    if (result == true) {
      onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final worldMeta = WorldRegistry.get(widget.draft.world);

    return GlassCard(
      borderColor: FNColors.border,
      padding: const EdgeInsets.all(FNSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'EDIÇÃO #${widget.draft.editionNumber}',
                      style: FNTypography.headingMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: worldMeta.primaryColor.withValues(alpha: 0.15),
                      child: Text(
                        widget.draft.world.name.toUpperCase(),
                        style: FNTypography.techLabel.copyWith(color: worldMeta.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FNButton(
                label: 'SALVAR',
                isLoading: _isSaving,
                onPressed: _handleSave,
              ),
            ],
          ),
          const SizedBox(height: FNSpacing.lg),

          // Campos principais
          FNInput(
            controller: _titleController,
            label: 'TÍTULO DA EDIÇÃO',
            hint: 'Insira o título da newsletter',
          ),
          const SizedBox(height: FNSpacing.base),
          FNInput(
            controller: _summaryController,
            label: 'INTRODUÇÃO / RESUMO EDITORIAL',
            hint: 'Resumo que introduz a newsletter',
            maxLines: 3,
          ),
          const SizedBox(height: FNSpacing.lg),

          // Imagem de capa
          Text('IMAGEM DE CAPA', style: FNTypography.label),
          const SizedBox(height: FNSpacing.sm),
          FNInput(
            controller: _imageUrlController,
            hint: 'URL da imagem',
          ),
          const SizedBox(height: FNSpacing.sm),
          Row(
            children: [
              Expanded(
                child: FNButton(
                  label: _isUploading ? 'SUBINDO...' : 'UPLOAD CAPA',
                  variant: FNButtonVariant.outline,
                  leading: const Icon(LucideIcons.upload, size: 16, color: Colors.white),
                  onPressed: _isUploading ? null : () => _pickAndUploadImage(),
                ),
              ),
            ],
          ),
          const SizedBox(height: FNSpacing.lg),

          // Prompt de Imagem IA
          FNInput(
            controller: _imagePromptController,
            label: 'PROMPT DE IMAGEM DA IA',
            hint: 'Descreva o prompt para gerar a capa',
            maxLines: 2,
          ),
          const SizedBox(height: FNSpacing.sm),
          Row(
            children: [
              Expanded(
                child: FNButton(
                  label: _isGeneratingImage ? 'GERANDO...' : 'GERAR PROMPT IA',
                  variant: FNButtonVariant.ghost,
                  leading: const Icon(LucideIcons.sparkles, size: 16, color: Colors.white),
                  onPressed: _isGeneratingImage ? null : _handleGeneratePrompt,
                ),
              ),
              const SizedBox(width: FNSpacing.base),
              IconButton(
                icon: const Icon(LucideIcons.copy, color: Colors.white70),
                onPressed: () {
                  if (_imagePromptController.text.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: _imagePromptController.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Prompt copiado! Cole no Midjourney/DALL-E.')),
                    );
                  }
                },
                tooltip: 'Copiar Prompt',
              ),
            ],
          ),
          const SizedBox(height: FNSpacing.xl),

          // Toggle Curadoria Individual
          InkWell(
            onTap: () => setState(() => _showItems = !_showItems),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(color: FNColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'EDITAR CONTEÚDO (NOTÍCIAS E QUICK TAKES)',
                      style: FNTypography.techLabel.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(
                    _showItems ? LucideIcons.chevron_up : LucideIcons.chevron_down,
                    color: FNColors.textPrimary,
                  ),
                ],
              ),
            ),
          ),

          if (_showItems) ...[
            const SizedBox(height: FNSpacing.lg),
            _buildContentEditor(),
          ],
          const SizedBox(height: FNSpacing.lg),

          // Botões de Curadoria (Aprovar / Rejeitar)
          Row(
            children: [
              Expanded(
                child: FNButton(
                  label: 'APROVAR E PUBLICAR',
                  leading: const Icon(LucideIcons.check, size: 16, color: Colors.white),
                  onPressed: widget.onPublished != null 
                      ? () => _confirmAction(
                          'Aprovar e Publicar',
                          'Tem certeza que deseja publicar esta edição? Ela ficará disponível para todos os usuários imediatamente.',
                          widget.onPublished!)
                      : null,
                ),
              ),
              const SizedBox(width: FNSpacing.base),
              Expanded(
                child: FNButton(
                  label: 'EXCLUIR RASCUNHO',
                  leading: const Icon(LucideIcons.trash_2, size: 16, color: Colors.white),
                  variant: FNButtonVariant.outline,
                  primaryColor: FNColors.error,
                  onPressed: widget.onRejected != null 
                      ? () => _confirmAction(
                          'Excluir Rascunho',
                          'Tem certeza que deseja excluir esta edição? Esta ação não pode ser desfeita e os dados serão perdidos.',
                          widget.onRejected!)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_quickTakesControllers.isNotEmpty) ...[
          Text('QUICK TAKES', style: FNTypography.techLabel.copyWith(fontWeight: FontWeight.bold, color: FNColors.primaryViolet)),
          const SizedBox(height: FNSpacing.sm),
          ...List.generate(_quickTakesControllers.length, (idx) {
            return Padding(
              padding: const EdgeInsets.only(bottom: FNSpacing.base),
              child: TextFormField(
                controller: _quickTakesControllers[idx],
                style: FNTypography.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Take #${idx + 1}',
                  filled: true,
                  fillColor: FNColors.surfaceVariant.withValues(alpha: 0.3),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            );
          }),
          const SizedBox(height: FNSpacing.lg),
        ],
        if (_content.categories.isEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Nenhuma notícia encontrada nesta edição.', style: FNTypography.bodySmall),
          )
        else
          ...List.generate(_content.categories.length, (catIdx) {
            final category = _content.categories[catIdx];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.name.toUpperCase(),
              style: FNTypography.techLabel.copyWith(
                color: FNColors.primaryViolet,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: FNSpacing.sm),
            ...List.generate(category.items.length, (itemIdx) {
              final item = category.items[itemIdx];

              return Card(
                color: FNColors.surfaceVariant.withValues(alpha: 0.3),
                margin: const EdgeInsets.only(bottom: FNSpacing.base),
                shape: const RoundedRectangleBorder(
                  side: BorderSide(color: FNColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(FNSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        initialValue: item.headline,
                        style: FNTypography.bodyMedium,
                        decoration: const InputDecoration(labelText: 'MANCHETE'),
                        onChanged: (val) {
                          _updateNewsItem(catIdx, itemIdx, headline: val);
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: item.story,
                        style: FNTypography.bodySmall,
                        decoration: const InputDecoration(labelText: 'RESUMO / HISTÓRIA'),
                        maxLines: 2,
                        onChanged: (val) {
                          _updateNewsItem(catIdx, itemIdx, story: val);
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.imageUrl != null ? 'Com imagem' : 'Sem imagem',
                              style: FNTypography.bodySmall,
                            ),
                          ),
                          FNButton(
                            label: 'PICK IMAGEM',
                            variant: FNButtonVariant.ghost,
                            onPressed: () => _pickAndUploadImage(categoryIndex: catIdx, itemIndex: itemIdx),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Divider(),
            const SizedBox(height: FNSpacing.sm),
          ],
        );
      }),
      ],
    );
  }

  void _updateNewsItem(int catIdx, int itemIdx, {String? headline, String? story}) {
    final categories = List<NewsCategory>.from(_content.categories);
    final category = categories[catIdx];
    final items = List<NewsItem>.from(category.items);
    final item = items[itemIdx];

    items[itemIdx] = NewsItem(
      headline: headline ?? item.headline,
      story: story ?? item.story,
      link: item.link,
      imageUrl: item.imageUrl,
    );
    categories[catIdx] = NewsCategory(name: category.name, items: items);

    _content = NewsletterContent(
      title: _content.title,
      intro: _content.intro,
      quickTakes: _content.quickTakes,
      categories: categories,
      imagePrompt: _content.imagePrompt,
    );
  }
}
