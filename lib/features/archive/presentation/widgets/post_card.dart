import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/shared/domain/post.entity.dart';
import 'package:fresh_news_mobile/shared/widgets/fn_badge.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool isPreferred;

  const PostCard({
    super.key,
    required this.post,
    this.isPreferred = false,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = FNColors.forCategory(post.category, world: post.world);
    final borderColor = isPreferred
        ? const Color(0xFF34D399).withOpacity(0.6)
        : Colors.white.withOpacity(0.1);

    return InkWell(
      onTap: () => context.push('/post/${post.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: FNSpacing.base),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: isPreferred ? 2 : 1),
          color: FNColors.surface,
        ),
        child: Stack(
          children: [
            // Scanlines Overlay
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: const _ScanlinePainter(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(FNSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: FNSpacing.sm,
                          runSpacing: FNSpacing.sm,
                          children: [
                            FNBadge.category(
                              (post.subCategory.isNotEmpty && post.subCategory != 'GERAL') ? post.subCategory : post.category,
                              world: post.world,
                            ),
                            FNBadge(label: 'SCORE: ${post.score}'),
                          ],
                        ),
                      ),
                      if (isPreferred) ...[
                        const SizedBox(width: FNSpacing.sm),
                        _buildHighAffinityBadge(),
                      ]
                    ],
                  ),
                  const SizedBox(height: FNSpacing.md),
                  Text(
                    post.title,
                    style: FNTypography.headingSmall.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: FNSpacing.sm),
                  Text(
                    post.summary.isNotEmpty ? post.summary : post.content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: FNTypography.bodyMedium.copyWith(
                      color: FNColors.mutedForeground,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: FNSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'FONTE: ${post.source ?? 'WEB'}'.toUpperCase(),
                          style: FNTypography.techLabelSmall.copyWith(
                            color: FNColors.mutedForeground.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Text(
                            'LER_POST',
                            style: FNTypography.techLabelSmall.copyWith(
                              color: isPreferred ? const Color(0xFF34D399) : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 12,
                            color: isPreferred ? const Color(0xFF34D399) : Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighAffinityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.12),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
      ),
      child: Text(
        'AFINIDADE_ALTA',
        style: FNTypography.techLabelSmall.copyWith(
          color: const Color(0xFF10B981),
          fontWeight: FontWeight.bold,
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .custom(
       duration: 2.seconds,
       builder: (context, value, child) {
         return Container(
           decoration: BoxDecoration(
             boxShadow: [
               BoxShadow(
                 color: const Color(0xFF10B981).withOpacity(0.15 * value),
                 blurRadius: 8 * value,
                 spreadRadius: 1 * value,
               ),
             ],
           ),
           child: child,
         );
       },
     );
  }
}

class _ScanlinePainter extends CustomPainter {
  const _ScanlinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.015)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
