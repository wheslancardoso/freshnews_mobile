import 'package:flutter/material.dart';

class ChameleonEffectsOverlay extends StatelessWidget {
  final List<String> effects;
  final Color accentColor;
  final Widget child;

  const ChameleonEffectsOverlay({
    super.key,
    required this.effects,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (effects.contains('scanlines'))
          const Positioned.fill(
            child: ScanlinesWidget(),
          ),
        if (effects.contains('cloud_compute_grid'))
          const Positioned.fill(
            child: BlueprintGridWidget(),
          ),
        if (effects.contains('terminal_glow'))
          Positioned.fill(
            child: TerminalGlowOverlay(color: accentColor),
          ),
      ],
    );
  }
}

class ScanlinesWidget extends StatelessWidget {
  const ScanlinesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: const ScanlinesPainter(),
      ),
    );
  }
}

class ScanlinesPainter extends CustomPainter {
  const ScanlinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    // Desenha linhas a cada 4 pixels de altura
    for (double y = 0; y < size.height; y += 4.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BlueprintGridWidget extends StatelessWidget {
  const BlueprintGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: const BlueprintGridPainter(),
      ),
    );
  }
}

class BlueprintGridPainter extends CustomPainter {
  const BlueprintGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1.0;

    // Linhas verticais a cada 24 pixels
    for (double x = 0; x < size.width; x += 24.0) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Linhas horizontais a cada 24 pixels
    for (double y = 0; y < size.height; y += 24.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TerminalGlowOverlay extends StatelessWidget {
  final Color color;

  const TerminalGlowOverlay({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: color.withValues(alpha: 0.08),
            width: 8.0,
          ),
          gradient: RadialGradient(
            colors: [
              Colors.transparent,
              color.withValues(alpha: 0.05),
            ],
            stops: const [0.65, 1.0],
            center: Alignment.center,
            radius: 1.0,
          ),
        ),
      ),
    );
  }
}

