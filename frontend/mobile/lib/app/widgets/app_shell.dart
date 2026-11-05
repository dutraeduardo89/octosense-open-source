import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:octosense/l10n/app_localizations.dart';

import 'octosense_logo.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const _destinationPaths = [
    '/',
    '/trends',
    '/learn',
    '/settings',
  ];

  int get selectedIndex {
    if (location.startsWith('/settings')) return 3;
    if (location.startsWith('/learn')) return 2;
    if (location.startsWith('/trends')) return 1;
    return 0;
  }

  void navigate(BuildContext context, int index) {
    context.go(_destinationPaths[index]);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        final l10n = AppLocalizations.of(context)!;
        final destinations = [
          ('/', l10n.today, LucideIcons.home),
          ('/trends', l10n.trends, LucideIcons.activity),
          ('/learn', l10n.learn, LucideIcons.bookOpen),
          ('/settings', l10n.settingsTitle, LucideIcons.settings),
        ];

        if (desktop) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended: constraints.maxWidth >= 1180,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) => navigate(context, index),
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: _BrandMark(),
                  ),
                  destinations: [
                    for (final item in destinations)
                      NavigationRailDestination(
                        icon: Icon(item.$3),
                        label: Text(item.$2),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) => navigate(context, index),
            destinations: [
              for (final item in destinations)
                NavigationDestination(icon: Icon(item.$3), label: item.$2),
            ],
          ),
        );
      },
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1180;
    return Semantics(
      label: 'OctoSense',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const OctoSenseLogo(size: 42, animate: true),
          if (wide) ...[
            const SizedBox(width: 10),
            Text(
              'OctoSense',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ],
      ),
    );
  }
}
