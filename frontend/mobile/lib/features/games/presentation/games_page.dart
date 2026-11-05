import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../l10n/app_localizations.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  int _mode = 0;
  int _score = 0;
  int _streak = 0;
  int _round = 0;
  String? _feedback;
  bool _answered = false;

  void _answer(bool correct) {
    if (_answered) return;
    setState(() {
      _answered = true;
      if (correct) {
        _score++;
        _streak++;
        _feedback = AppLocalizations.of(context)!.gameCorrect;
      } else {
        _streak = 0;
        _feedback = AppLocalizations.of(context)!.gameTryAgain;
      }
    });
  }

  void _next() {
    setState(() {
      _round++;
      _answered = false;
      _feedback = null;
    });
  }

  void _reset() {
    setState(() {
      _score = 0;
      _streak = 0;
      _round = 0;
      _answered = false;
      _feedback = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final games = [
      (l10n.gameSignalTitle, l10n.gameSignalText, LucideIcons.route),
      (l10n.gameSensorTitle, l10n.gameSensorText, LucideIcons.scanLine),
      (l10n.gameBodyTitle, l10n.gameBodyText, LucideIcons.heartPulse),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 38),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.surfaceContainerLow,
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    LucideIcons.gamepad2,
                    color: theme.colorScheme.onPrimary,
                    size: 29,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.challenges,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.challengesSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.gamePlayAgain,
                  onPressed: _reset,
                  icon: const Icon(LucideIcons.rotateCcw),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ScorePill(
                  icon: LucideIcons.sparkles,
                  label: l10n.gameScore,
                  value: _score.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ScorePill(
                  icon: LucideIcons.flame,
                  label: l10n.gameStreak,
                  value: _streak.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SegmentedButton<int>(
            segments: [
              for (var i = 0; i < games.length; i++)
                ButtonSegment(
                  value: i,
                  icon: Icon(games[i].$3, size: 17),
                  label: Text(games[i].$1),
                ),
            ],
            selected: {_mode},
            onSelectionChanged: (value) {
              setState(() {
                _mode = value.first;
                _answered = false;
                _feedback = null;
              });
            },
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: switch (_mode) {
              0 => _SignalGame(
                key: ValueKey('signal-$_round'),
                round: _round,
                answered: _answered,
                onAnswer: _answer,
                onNext: _next,
              ),
              1 => _SensorGame(
                key: ValueKey('sensor-$_round'),
                round: _round,
                answered: _answered,
                onAnswer: _answer,
                onNext: _next,
              ),
              _ => _BodyGame(
                key: ValueKey('body-$_round'),
                round: _round,
                answered: _answered,
                onAnswer: _answer,
                onNext: _next,
              ),
            },
          ),
          if (_feedback != null) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.55,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      _feedback == l10n.gameCorrect
                          ? LucideIcons.checkCircle2
                          : LucideIcons.refreshCcw,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_feedback!)),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 180.ms),
          ],
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.title,
    required this.text,
    required this.icon,
    required this.child,
  });

  final String title;
  final String text;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 9),
              Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.onPressed,
    required this.enabled,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onNext,
      icon: const Icon(LucideIcons.arrowRight),
      label: Text(AppLocalizations.of(context)!.gameNext),
    );
  }
}

class _SignalGame extends StatelessWidget {
  const _SignalGame({
    super.key,
    required this.round,
    required this.answered,
    required this.onAnswer,
    required this.onNext,
  });

  final int round;
  final bool answered;
  final ValueChanged<bool> onAnswer;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = [
      (l10n.gameSignalBody, LucideIcons.heartPulse),
      (l10n.gameSignalSensor, LucideIcons.scan),
      (l10n.gameSignalAlgorithm, LucideIcons.cpu),
      (l10n.gameSignalMetric, LucideIcons.activity),
    ];
    final shuffled = List.of(steps)..add(steps.removeAt(round % steps.length));

    return _GameCard(
      title: l10n.gameSignalTitle,
      text: l10n.gameSignalText,
      icon: LucideIcons.route,
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < steps.length; i++)
                Chip(
                  avatar: Icon(steps[i].$2, size: 15),
                  label: Text('${i + 1}. ${steps[i].$1}'),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _AnswerButton(
            label: shuffled[0].$1,
            enabled: !answered,
            onPressed: () => onAnswer(round % 2 == 0),
          ),
          const SizedBox(height: 8),
          _AnswerButton(
            label: shuffled[1].$1,
            enabled: !answered,
            onPressed: () => onAnswer(false),
          ),
          const SizedBox(height: 8),
          _AnswerButton(
            label: shuffled[2].$1,
            enabled: !answered,
            onPressed: () => onAnswer(false),
          ),
          const SizedBox(height: 8),
          _AnswerButton(
            label: shuffled[3].$1,
            enabled: !answered,
            onPressed: () => onAnswer(round % 2 != 0),
          ),
          if (answered) ...[
            const SizedBox(height: 12),
            _NextButton(onNext: onNext),
          ],
        ],
      ),
    );
  }
}

class _SensorGame extends StatelessWidget {
  const _SensorGame({
    super.key,
    required this.round,
    required this.answered,
    required this.onAnswer,
    required this.onNext,
  });

  final int round;
  final bool answered;
  final ValueChanged<bool> onAnswer;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final questions = [
      (l10n.gameQSensorOptical, l10n.ppg, [l10n.ppg, l10n.motion, l10n.spo2]),
      (l10n.gameQSensorMotion, l10n.motion, [l10n.spo2, l10n.motion, l10n.ppg]),
      (l10n.gameQSensorOxygen, l10n.spo2, [l10n.motion, l10n.ppg, l10n.spo2]),
    ];
    final q = questions[round % questions.length];

    return _GameCard(
      title: l10n.gameSensorTitle,
      text: q.$1,
      icon: LucideIcons.scanLine,
      child: Column(
        children: [
          for (final option in q.$3) ...[
            _AnswerButton(
              label: option,
              enabled: !answered,
              onPressed: () => onAnswer(option == q.$2),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) _NextButton(onNext: onNext),
        ],
      ),
    );
  }
}

class _BodyGame extends StatelessWidget {
  const _BodyGame({
    super.key,
    required this.round,
    required this.answered,
    required this.onAnswer,
    required this.onNext,
  });

  final int round;
  final bool answered;
  final ValueChanged<bool> onAnswer;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final questions = [
      (
        l10n.gameQHeart,
        l10n.gameOptExercise,
        [l10n.gameOptSleep, l10n.gameOptExercise, l10n.gameOptColor],
      ),
      (
        l10n.gameQHeart,
        l10n.gameOptExercise,
        [l10n.gameOptColor, l10n.gameOptExercise, l10n.gameOptSleep],
      ),
      (
        l10n.topic12Title,
        l10n.gameSignalMetric,
        [l10n.gameSignalSensor, l10n.gameSignalMetric, l10n.gameSignalBody],
      ),
    ];
    final q = questions[round % questions.length];

    return _GameCard(
      title: l10n.gameBodyTitle,
      text: q.$1,
      icon: LucideIcons.heartPulse,
      child: Column(
        children: [
          Icon(LucideIcons.brain, size: 38, color: theme.colorScheme.primary),
          const SizedBox(height: 10),
          for (final option in q.$3) ...[
            _AnswerButton(
              label: option,
              enabled: !answered,
              onPressed: () => onAnswer(option == q.$2),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) _NextButton(onNext: onNext),
        ],
      ),
    );
  }
}
