import 'package:flutter/material.dart';

/// Logo oficial do OctoSense.
///
/// Usa o asset PNG (variante light / dark conforme o brilho do tema).
/// O CustomPainter do polvo foi removido — nao faz parte da marca.
class OctoSenseLogo extends StatelessWidget {
  const OctoSenseLogo({
    super.key,
    this.size = 120,
    this.showWordmark = false,
    this.animate = true,
    this.compact = false,
  });

  final double size;
  final bool showWordmark;
  final bool animate;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = isDark
        ? 'assets/logos/octosense_dark.png'
        : 'assets/logos/octosense_light.png';

    final image = Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (!animate) return image;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.88, end: 1.0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
      ),
      child: image,
    );
  }
}

/// Utilitário compartilhado: respeita a preferência de "reduzir movimento"
/// do sistema. Exportado aqui porque era onde ficava antes da troca da marca.
bool appReducedMotion(BuildContext context) {
  return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}
