import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/widgets/octosense_logo.dart';
import '../../../l10n/app_localizations.dart';

enum LearnSection { overview, sensors, science }

enum _TopicCategory { overview, sensors, science }

class _LearnTopic {
  const _LearnTopic({
    required this.id,
    required this.category,
    required this.icon,
    required this.title,
    required this.paragraphs,
  });

  final String id;
  final _TopicCategory category;
  final IconData icon;
  final String title;
  final List<String> paragraphs;

  String get summary => paragraphs.first;
}

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final FlutterTts _tts = FlutterTts();
  String? _speakingId;

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _toggleSpeech(_LearnTopic topic) async {
    if (_speakingId == topic.id) {
      if (mounted) setState(() => _speakingId = null);
      await _tts.stop();
      return;
    }

    if (mounted) setState(() => _speakingId = topic.id);
    await _tts.stop();
    if (!mounted) return;

    final language = Localizations.localeOf(context).languageCode == 'en'
        ? 'en-US'
        : Localizations.localeOf(context).languageCode == 'es'
        ? 'es-ES'
        : Localizations.localeOf(context).languageCode == 'fr'
        ? 'fr-FR'
        : Localizations.localeOf(context).languageCode == 'it'
        ? 'it-IT'
        : Localizations.localeOf(context).languageCode == 'de'
        ? 'de-DE'
        : 'pt-BR';

    try {
      await _tts.setLanguage(language);
      await _tts.setSpeechRate(0.46);
      await _tts.awaitSpeakCompletion(true);
      await _tts.speak('${topic.title}. ${topic.paragraphs.join(' ')}');
    } finally {
      if (mounted && _speakingId == topic.id) {
        setState(() => _speakingId = null);
      }
    }
  }


  void _openTopic(_LearnTopic topic) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final l10n = AppLocalizations.of(sheetContext)!;

        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final speaking = _speakingId == topic.id;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              topic.icon,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Semantics(
                              header: true,
                              child: Text(
                                topic.title,
                                style: theme.textTheme.headlineSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _StoryStepCard(icon: topic.icon, text: topic.summary),
                      const SizedBox(height: 10),
                      for (final paragraph in topic.paragraphs.skip(1))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _FactCard(icon: topic.icon, text: paragraph),
                        ),
                      const SizedBox(height: 3),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          setSheetState(() {});
                          _toggleSpeech(topic).then((_) {
                            if (sheetContext.mounted) {
                              setSheetState(() {});
                            }
                          });
                        },
                        icon: Icon(
                          speaking ? LucideIcons.square : LucideIcons.volume2,
                        ),
                        label: Text(
                          speaking ? l10n.stopListening : l10n.listen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final topics = _topics(l10n);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 38),
        children: [
          _LearnHero(
            l10n: l10n,
          ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.03, end: 0),
          const SizedBox(height: 18),
          _WatchExplorer(l10n: l10n),
          const SizedBox(height: 20),
          _WearableStory(l10n: l10n),
          const SizedBox(height: 20),
          _SectionHeader(
            icon: LucideIcons.scanLine,
            title: l10n.sensorTitle,
            subtitle: l10n.sensorSubtitle,
          ),
          const SizedBox(height: 10),
          _SensorExplorer(l10n: l10n),
          const SizedBox(height: 20),
          _SectionHeader(
            icon: LucideIcons.flaskConical,
            title: l10n.scienceLab,
            subtitle: l10n.scienceLabSubtitle,
          ),
          const SizedBox(height: 10),
          _ScienceExplorer(l10n: l10n),
          const SizedBox(height: 20),
          _SectionHeader(
            icon: LucideIcons.route,
            title: l10n.signalPath,
            subtitle: l10n.signalPathSubtitle,
          ),
          const SizedBox(height: 10),
          _SignalFlow(l10n: l10n),
          const SizedBox(height: 18),
          const SizedBox(height: 20),
          _SectionHeader(
            icon: LucideIcons.sparkles,
            title: l10n.topicsTitle,
            subtitle: l10n.topicsSubtitle,
          ),
          const SizedBox(height: 10),
          for (final topic in topics)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TopicCard(
                topic: topic,
                onOpen: () => _openTopic(topic),
              ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.02, end: 0),
            ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  LucideIcons.info,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.healthEstimateNote,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LearnHero extends StatelessWidget {
  const _LearnHero({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.surfaceContainerLow,
          ],
        ),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        children: [
          const OctoSenseLogo(size: 84, animate: true),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.learn.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.learnIntro,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.learnIntroSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 21, color: theme.colorScheme.primary),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WatchExplorer extends StatefulWidget {
  const _WatchExplorer({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_WatchExplorer> createState() => _WatchExplorerState();
}

class _WatchExplorerState extends State<_WatchExplorer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idle;
  double _rx = -0.08;
  double _ry = 0.14;
  String _selected = 'screen';

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
    if (!appReducedMotion(context)) _idle.repeat(reverse: true);
  }

  @override
  void dispose() {
    _idle.dispose();
    super.dispose();
  }

  List<_WatchPart> _parts(AppLocalizations l10n) => [
    _WatchPart(
      id: 'screen',
      label: l10n.watchPartScreen,
      icon: LucideIcons.scan,
      description: l10n.watchPartScreenText,
    ),
    _WatchPart(
      id: 'ppg',
      label: l10n.watchPartPpg,
      icon: LucideIcons.scanHeart,
      description: l10n.watchPartPpgText,
    ),
    _WatchPart(
      id: 'motion',
      label: l10n.watchPartMotion,
      icon: LucideIcons.move3d,
      description: l10n.watchPartMotionText,
    ),
    _WatchPart(
      id: 'oxygen',
      label: l10n.watchPartOxygen,
      icon: LucideIcons.droplets,
      description: l10n.watchPartOxygenText,
    ),
    _WatchPart(
      id: 'crown',
      label: l10n.watchPartCrown,
      icon: LucideIcons.circleDot,
      description: l10n.watchPartCrownText,
    ),
    _WatchPart(
      id: 'strap',
      label: l10n.watchPartStrap,
      icon: LucideIcons.ruler,
      description: l10n.watchPartStrapText,
    ),
    _WatchPart(
      id: 'back',
      label: l10n.watchPartBack,
      icon: LucideIcons.radioTower,
      description: l10n.watchPartBackText,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = _parts(widget.l10n);
    final current = parts.firstWhere((part) => part.id == _selected);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.box, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.l10n.exploreWatch,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              Icon(
                LucideIcons.rotate3d,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.l10n.exploreWatchHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 5),
          AnimatedBuilder(
            animation: _idle,
            builder: (context, child) {
              final idleY = appReducedMotion(context)
                  ? 0.0
                  : math.sin(_idle.value * math.pi) * 0.045;
              return GestureDetector(
                onPanUpdate: (details) {
                  if (appReducedMotion(context)) return;
                  setState(() {
                    _ry = (_ry + details.delta.dx * 0.008).clamp(-0.76, 0.76);
                    _rx = (_rx - details.delta.dy * 0.008).clamp(-0.56, 0.56);
                  });
                },
                child: SizedBox(
                  height: 315,
                  child: Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0018)
                        ..rotateX(_rx + idleY)
                        ..rotateY(_ry),
                      child: _ExplodedWatch(
                        selected: _selected,
                        onSelect: (id) => setState(() => _selected = id),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final part in parts)
                Semantics(
                  button: true,
                  selected: part.id == _selected,
                  label: part.label,
                  child: ChoiceChip(
                    avatar: Icon(part.icon, size: 15),
                    label: Text(part.label),
                    selected: part.id == _selected,
                    onSelected: (_) => setState(() => _selected = part.id),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 11),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: _WatchInfo(key: ValueKey(_selected), part: current),
          ),
        ],
      ),
    );
  }
}

class _WatchPart {
  const _WatchPart({
    required this.id,
    required this.label,
    required this.icon,
    required this.description,
  });

  final String id;
  final String label;
  final IconData icon;
  final String description;
}

class _WatchInfo extends StatelessWidget {
  const _WatchInfo({super.key, required this.part});

  final _WatchPart part;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(part.icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              part.description,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.42),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplodedWatch extends StatelessWidget {
  const _ExplodedWatch({required this.selected, required this.onSelect});

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;

    return SizedBox(
      width: 220,
      height: 275,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(0, 92),
            child: _WatchLayer(
              width: 75,
              height: 76,
              radius: 24,
              color: theme.colorScheme.outlineVariant,
              accent: selected == 'strap' ? theme.colorScheme.primary : null,
              onTap: () => onSelect('strap'),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, 44),
            child: _WatchLayer(
              width: 162,
              height: 168,
              radius: 40,
              color: theme.colorScheme.outline,
              accent: selected == 'back' ? theme.colorScheme.tertiary : null,
              onTap: () => onSelect('back'),
              child: _BackSensorVisual(
                color: selected == 'back'
                    ? theme.colorScheme.tertiary
                    : theme.colorScheme.secondary,
                surface: surface,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -5),
            child: _WatchLayer(
              width: 174,
              height: 180,
              radius: 42,
              color: theme.colorScheme.surfaceContainerHighest,
              accent: selected == 'screen' ? theme.colorScheme.primary : null,
              onTap: () => onSelect('screen'),
              child: _WatchDisplay(
                primary: theme.colorScheme.primary,
                secondary: theme.colorScheme.secondary,
                surface: surface,
              ),
            ),
          ),
          Positioned(
            right: 5,
            top: 108,
            child: _Hotspot(
              active: selected == 'crown',
              color: theme.colorScheme.primary,
              onTap: () => onSelect('crown'),
            ),
          ),
          Positioned(
            left: 43,
            top: 58,
            child: _Hotspot(
              active: selected == 'ppg',
              color: theme.colorScheme.secondary,
              onTap: () => onSelect('ppg'),
            ),
          ),
          Positioned(
            right: 43,
            top: 58,
            child: _Hotspot(
              active: selected == 'motion',
              color: theme.colorScheme.primary,
              onTap: () => onSelect('motion'),
            ),
          ),
          Positioned(
            right: 46,
            bottom: 32,
            child: _Hotspot(
              active: selected == 'oxygen',
              color: theme.colorScheme.tertiary,
              onTap: () => onSelect('oxygen'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchLayer extends StatelessWidget {
  const _WatchLayer({
    required this.width,
    required this.height,
    required this.radius,
    required this.color,
    required this.onTap,
    this.accent,
    this.child,
  });

  final double width;
  final double height;
  final double radius;
  final Color color;
  final Color? accent;
  final VoidCallback onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, theme.colorScheme.surfaceContainerLow],
          ),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: accent ?? theme.colorScheme.outlineVariant,
            width: accent == null ? 1.2 : 3,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _WatchDisplay extends StatelessWidget {
  const _WatchDisplay({
    required this.primary,
    required this.secondary,
    required this.surface,
  });

  final Color primary;
  final Color secondary;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(31),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.heartPulse, color: secondary, size: 27),
          const SizedBox(height: 4),
          Text(
            '72',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'BPM',
            style: theme.textTheme.labelSmall?.copyWith(
              color: primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 90,
            height: 28,
            child: CustomPaint(painter: _PulsePainter(color: secondary)),
          ),
        ],
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  const _PulsePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(2, size.height / 2);
    for (var i = 0; i < size.width.toInt() - 4; i++) {
      final y =
          size.height / 2 +
          (i > 32 && i < 48
              ? math.sin((i - 32) * 0.48) * 9
              : math.sin(i * 0.11) * 2);
      path.lineTo(2 + i.toDouble(), y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) {
    return color != oldDelegate.color;
  }
}

class _Hotspot extends StatelessWidget {
  const _Hotspot({
    required this.active,
    required this.color,
    required this.onTap,
  });

  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: active ? 25 : 18,
          height: active ? 25 : 18,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 13,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            active ? LucideIcons.plus : LucideIcons.dot,
            size: active ? 14 : 10,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

class _BackSensorVisual extends StatelessWidget {
  const _BackSensorVisual({required this.color, required this.surface});

  final Color color;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: surface.withValues(alpha: 0.82),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: List.generate(
            7,
            (index) => Container(
              width: index == 3 ? 11 : 7,
              height: index == 3 ? 11 : 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}

class _WearableStory extends StatefulWidget {
  const _WearableStory({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_WearableStory> createState() => _WearableStoryState();
}

class _WearableStoryState extends State<_WearableStory> {
  int _step = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!appReducedMotion(context)) {
      _timer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
        if (mounted) setState(() => _step = (_step + 1) % 3);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = widget.l10n;
    final items = [
      (l10n.wearableStory1Title, l10n.wearableStory1Text, LucideIcons.watch),
      (l10n.wearableStory2Title, l10n.wearableStory2Text, LucideIcons.scanLine),
      (
        l10n.wearableStory3Title,
        l10n.wearableStory3Text,
        LucideIcons.heartPulse,
      ),
    ];
    final item = items[_step];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            height: 78,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size.square(74),
                  painter: _StoryOrbitPainter(
                    primary: theme.colorScheme.primary,
                    secondary: theme.colorScheme.secondary,
                    step: _step,
                  ),
                ),
                const OctoSenseLogo(size: 54, animate: true),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              child: Column(
                key: ValueKey(_step),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.wearableStoryTitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        item.$3,
                        size: 18,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          item.$1,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$2,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryOrbitPainter extends CustomPainter {
  const _StoryOrbitPainter({
    required this.primary,
    required this.secondary,
    required this.step,
  });

  final Color primary;
  final Color secondary;
  final int step;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 3; i++) {
      canvas.drawOval(
        Rect.fromCenter(center: center, width: 66 - i * 15, height: 42 + i * 7),
        Paint()
          ..color = i == step
              ? primary.withValues(alpha: 0.5)
              : secondary.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StoryOrbitPainter oldDelegate) {
    return step != oldDelegate.step;
  }
}

class _SensorExplorer extends StatefulWidget {
  const _SensorExplorer({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_SensorExplorer> createState() => _SensorExplorerState();
}

class _SensorExplorerState extends State<_SensorExplorer> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      (
        widget.l10n.ppg,
        widget.l10n.ppgSimple,
        widget.l10n.ppgExplain,
        LucideIcons.scanHeart,
      ),
      (
        widget.l10n.motion,
        widget.l10n.motionSimple,
        widget.l10n.motionExplain,
        LucideIcons.move3d,
      ),
      (
        widget.l10n.spo2,
        widget.l10n.spo2Simple,
        widget.l10n.spo2Explain,
        LucideIcons.droplets,
      ),
    ];
    final item = items[_selected];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        children: [
          SegmentedButton<int>(
            segments: [
              for (var i = 0; i < items.length; i++)
                ButtonSegment(
                  value: i,
                  icon: Icon(items[i].$4, size: 17),
                  label: Text(items[i].$1),
                ),
            ],
            selected: {_selected},
            onSelectionChanged: (selection) {
              setState(() => _selected = selection.first);
            },
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 230),
            child: Container(
              key: ValueKey(_selected),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.42,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CustomPaint(
                      painter: _SensorVisualPainter(
                        kind: _selected,
                        primary: theme.colorScheme.primary,
                        secondary: theme.colorScheme.secondary,
                        tertiary: theme.colorScheme.tertiary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.$1, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 3),
                        Text(
                          item.$2,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.$3,
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.4,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SensorVisualPainter extends CustomPainter {
  const _SensorVisualPainter({
    required this.kind,
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  final int kind;
  final Color primary;
  final Color secondary;
  final Color tertiary;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    if (kind == 0) {
      p.color = primary;
      canvas.drawCircle(center, 22, p);
      p.color = secondary;
      final path = Path()..moveTo(4, center.dy);
      for (var i = 0; i < 62; i++) {
        path.lineTo(
          4 + i.toDouble(),
          center.dy + math.sin(i * 0.39) * (i % 12 == 0 ? 12 : 4),
        );
      }
      canvas.drawPath(path, p);
    } else if (kind == 1) {
      p.color = secondary;
      canvas.drawLine(center.translate(-23, 0), center.translate(23, 0), p);
      canvas.drawLine(center.translate(0, -23), center.translate(0, 23), p);
      p.color = primary;
      canvas.drawCircle(center, 8, p);
    } else {
      p.color = tertiary;
      for (var i = 0; i < 3; i++) {
        canvas.drawCircle(center.translate((i - 1) * 18, 0), 11, p);
      }
      canvas.drawCircle(center, 4, Paint()..color = primary);
    }
  }

  @override
  bool shouldRepaint(covariant _SensorVisualPainter oldDelegate) {
    return oldDelegate.kind != kind;
  }
}

class _ScienceExplorer extends StatefulWidget {
  const _ScienceExplorer({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_ScienceExplorer> createState() => _ScienceExplorerState();
}

class _ScienceExplorerState extends State<_ScienceExplorer> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      (widget.l10n.biology, widget.l10n.biologyExplain, LucideIcons.dna),
      (widget.l10n.chemistry, widget.l10n.chemistryExplain, LucideIcons.atom),
      (widget.l10n.physics, widget.l10n.physicsExplain, LucideIcons.waves),
    ];
    final item = items[_selected];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainerLow,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.28),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        children: [
          SegmentedButton<int>(
            segments: [
              for (var i = 0; i < items.length; i++)
                ButtonSegment(
                  value: i,
                  icon: Icon(items[i].$3, size: 17),
                  label: Text(items[i].$1),
                ),
            ],
            selected: {_selected},
            onSelectionChanged: (selection) {
              setState(() => _selected = selection.first);
            },
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 230),
            child: Column(
              key: ValueKey(_selected),
              children: [
                SizedBox(
                  height: 125,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _SciencePainter(
                      kind: _selected,
                      primary: theme.colorScheme.primary,
                      secondary: theme.colorScheme.secondary,
                      tertiary: theme.colorScheme.tertiary,
                      surface: theme.colorScheme.surface,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(item.$1, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  item.$2,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.42,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SciencePainter extends CustomPainter {
  const _SciencePainter({
    required this.kind,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.surface,
  });

  final int kind;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (kind == 0) {
      final p = Paint()
        ..color = primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;
      canvas.drawCircle(center.translate(-34, -7), 25, p);
      canvas.drawCircle(center.translate(34, -7), 25, p);
      canvas.drawLine(center.translate(-7, -7), center.translate(7, -7), p);
      canvas.drawArc(
        Rect.fromCenter(
          center: center.translate(0, 29),
          width: 112,
          height: 55,
        ),
        math.pi,
        math.pi,
        false,
        p,
      );
    } else if (kind == 1) {
      final positions = [
        center.translate(0, -30),
        center.translate(36, 14),
        center.translate(-36, 14),
      ];
      final colors = [primary, secondary, tertiary];
      for (var i = 0; i < positions.length; i++) {
        canvas.drawCircle(
          positions[i],
          18,
          Paint()..color = colors[i].withValues(alpha: 0.88),
        );
      }
      final line = Paint()
        ..color = surface
        ..strokeWidth = 3;
      canvas.drawLine(positions[0], positions[1], line);
      canvas.drawLine(positions[1], positions[2], line);
      canvas.drawLine(positions[2], positions[0], line);
    } else {
      final p = Paint()
        ..color = secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round;
      final path = Path()..moveTo(10, center.dy);
      for (var i = 0; i < size.width.toInt() - 20; i++) {
        path.lineTo(10 + i.toDouble(), center.dy + math.sin(i * 0.2) * 26);
      }
      canvas.drawPath(path, p);
      canvas.drawCircle(
        center.translate(56, 0),
        16,
        Paint()
          ..color = primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SciencePainter oldDelegate) {
    return oldDelegate.kind != kind;
  }
}

class _SignalFlow extends StatelessWidget {
  const _SignalFlow({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      (l10n.stepBody, l10n.stepBodyText, LucideIcons.heartPulse),
      (l10n.stepSensor, l10n.stepSensorText, LucideIcons.scan),
      (l10n.stepAlgorithm, l10n.stepAlgorithmText, LucideIcons.cpu),
      (l10n.stepApp, l10n.stepAppText, LucideIcons.sparkles),
    ];

    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      items[i].$3,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (i < items.length - 1)
                    Container(
                      height: 30,
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(items[i].$1, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        items[i].$2,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic, required this.onOpen});

  final _LearnTopic topic;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: topic.title,
      hint: l10n.explore,
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    topic.icon,
                    size: 21,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(topic.title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        topic.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  LucideIcons.arrowUpRight,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: theme.colorScheme.secondary),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.42),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryStepCard extends StatelessWidget {
  const _StoryStepCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.43),
            ),
          ),
        ],
      ),
    );
  }
}

class LearnDetailPage extends StatelessWidget {
  const LearnDetailPage({required this.section, super.key});

  final LearnSection section;

  @override
  Widget build(BuildContext context) => const LearnPage();
}

List<_LearnTopic> _topics(AppLocalizations l10n) {
  return [
    _LearnTopic(
      id: '01',
      category: _TopicCategory.overview,
      icon: LucideIcons.activity,
      title: l10n.topic1Title,
      paragraphs: [l10n.topic1P1, l10n.topic1P2, l10n.topic1P3, l10n.topic1P4],
    ),
    _LearnTopic(
      id: '02',
      category: _TopicCategory.overview,
      icon: LucideIcons.heartPulse,
      title: l10n.topic2Title,
      paragraphs: [l10n.topic2P1, l10n.topic2P2, l10n.topic2P3, l10n.topic2P4],
    ),
    _LearnTopic(
      id: '03',
      category: _TopicCategory.overview,
      icon: LucideIcons.moon,
      title: l10n.topic3Title,
      paragraphs: [l10n.topic3P1, l10n.topic3P2, l10n.topic3P3, l10n.topic3P4],
    ),
    _LearnTopic(
      id: '04',
      category: _TopicCategory.overview,
      icon: LucideIcons.footprints,
      title: l10n.topic4Title,
      paragraphs: [l10n.topic4P1, l10n.topic4P2, l10n.topic4P3, l10n.topic4P4],
    ),
    _LearnTopic(
      id: '05',
      category: _TopicCategory.sensors,
      icon: LucideIcons.sunMedium,
      title: l10n.topic5Title,
      paragraphs: [l10n.topic5P1, l10n.topic5P2, l10n.topic5P3, l10n.topic5P4],
    ),
    _LearnTopic(
      id: '06',
      category: _TopicCategory.sensors,
      icon: LucideIcons.move3d,
      title: l10n.topic6Title,
      paragraphs: [l10n.topic6P1, l10n.topic6P2, l10n.topic6P3, l10n.topic6P4],
    ),
    _LearnTopic(
      id: '07',
      category: _TopicCategory.sensors,
      icon: LucideIcons.droplets,
      title: l10n.topic7Title,
      paragraphs: [l10n.topic7P1, l10n.topic7P2, l10n.topic7P3, l10n.topic7P4],
    ),
    _LearnTopic(
      id: '08',
      category: _TopicCategory.science,
      icon: LucideIcons.flaskConical,
      title: l10n.topic8Title,
      paragraphs: [l10n.topic8P1, l10n.topic8P2, l10n.topic8P3, l10n.topic8P4],
    ),
    _LearnTopic(
      id: '09',
      category: _TopicCategory.science,
      icon: LucideIcons.zap,
      title: l10n.topic9Title,
      paragraphs: [l10n.topic9P1, l10n.topic9P2, l10n.topic9P3, l10n.topic9P4],
    ),
    _LearnTopic(
      id: '10',
      category: _TopicCategory.science,
      icon: LucideIcons.heartPulse,
      title: l10n.topic10Title,
      paragraphs: [
        l10n.topic10P1,
        l10n.topic10P2,
        l10n.topic10P3,
        l10n.topic10P4,
      ],
    ),
    _LearnTopic(
      id: '11',
      category: _TopicCategory.science,
      icon: LucideIcons.route,
      title: l10n.topic11Title,
      paragraphs: [
        l10n.topic11P1,
        l10n.topic11P2,
        l10n.topic11P3,
        l10n.topic11P4,
      ],
    ),
    _LearnTopic(
      id: '12',
      category: _TopicCategory.science,
      icon: LucideIcons.chartNoAxesCombined,
      title: l10n.topic12Title,
      paragraphs: [
        l10n.topic12P1,
        l10n.topic12P2,
        l10n.topic12P3,
        l10n.topic12P4,
      ],
    ),
  ];
}
