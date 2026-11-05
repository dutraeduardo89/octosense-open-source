import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:octosense/l10n/app_localizations.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../app/widgets/octosense_logo.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page >= 2) {
      context.go('/permissions');
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final items = [
      _OnboardingItem(
        title: l10n.onboarding1Title,
        text: l10n.onboarding1Text,
        icon: LucideIcons.heartPulse,
      ),
      _OnboardingItem(
        title: l10n.onboarding2Title,
        text: l10n.onboarding2Text,
        icon: LucideIcons.watch,
      ),
      _OnboardingItem(
        title: l10n.onboarding3Title,
        text: l10n.onboarding3Text,
        icon: LucideIcons.accessibility,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 15, 22, 0),
              child: Row(
                children: [
                  Semantics(
                    label: 'OctoSense',
                    child: const SizedBox(
                      width: 42,
                      height: 42,
                      child: OctoSenseLogo(size: 42, animate: true),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/permissions'),
                    child: Text(l10n.skip),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: items.length,
                onPageChanged: (value) => setState(() => _page = value),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      child: Column(
                        key: ValueKey(index),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (index == 0)
                            OctoSenseLogo(
                              size: 205,
                              animate: !MediaQuery.of(
                                context,
                              ).disableAnimations,
                            )
                          else
                            _OnboardingVisual(icon: item.icon, step: index + 1),
                          const SizedBox(height: 30),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Text(
                              item.text,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == _page ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == _page
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: Text(
                      _page == items.length - 1
                          ? l10n.start
                          : l10n.continueLabel,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingVisual extends StatelessWidget {
  const _OnboardingVisual({required this.icon, required this.step});

  final IconData icon;
  final int step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(54),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _OrbitPainter(
                color: theme.colorScheme.primary,
                secondary: theme.colorScheme.secondary,
                phase: step * 0.7,
              ),
            ),
          ),
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTokens.brandDeep, theme.colorScheme.primary],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.18),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Icon(icon, color: theme.colorScheme.onPrimary, size: 38),
          ),
        ],
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({
    required this.color,
    required this.secondary,
    required this.phase,
  });

  final Color color;
  final Color secondary;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 3; i++) {
      final rect = Rect.fromCenter(
        center: c,
        width: 138 - i * 23,
        height: 72 + i * 20,
      );
      canvas.drawOval(
        rect,
        Paint()
          ..color = i.isEven
              ? color.withValues(alpha: 0.20)
              : secondary.withValues(alpha: 0.20)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    final dotAngle = phase;
    final dot = Offset(
      c.dx + 62 * math.cos(dotAngle),
      c.dy + 34 * math.sin(dotAngle),
    );
    canvas.drawCircle(dot, 4, Paint()..color = secondary);
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return phase != oldDelegate.phase ||
        color != oldDelegate.color ||
        secondary != oldDelegate.secondary;
  }
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.title,
    required this.text,
    required this.icon,
  });

  final String title;
  final String text;
  final IconData icon;
}
