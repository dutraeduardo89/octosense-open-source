import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';

import 'accessibility/app_preferences.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class _ColorVisionFilter {
  static ColorFilter? forMode(AppColorVisionMode mode) {
    return switch (mode) {
      AppColorVisionMode.standard => null,
      AppColorVisionMode.protanopia => const ColorFilter.matrix(<double>[
        0.567,
        0.433,
        0,
        0,
        0,
        0.558,
        0.442,
        0,
        0,
        0,
        0,
        0.242,
        0.758,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      AppColorVisionMode.deuteranopia => const ColorFilter.matrix(<double>[
        0.625,
        0.375,
        0,
        0,
        0,
        0.700,
        0.300,
        0,
        0,
        0,
        0,
        0.300,
        0.700,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      AppColorVisionMode.tritanopia => const ColorFilter.matrix(<double>[
        0.950,
        0.050,
        0,
        0,
        0,
        0,
        0.433,
        0.567,
        0,
        0,
        0,
        0.475,
        0.525,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      AppColorVisionMode.achromatopsia => const ColorFilter.matrix(<double>[
        0.299,
        0.587,
        0.114,
        0,
        0,
        0.299,
        0.587,
        0.114,
        0,
        0,
        0.299,
        0.587,
        0.114,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
    };
  }
}

class OctoSenseApp extends StatelessWidget {
  const OctoSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder por fora: permite que mudanças de tema
    // (claro/escuro/sistema) reconstruam o MaterialApp inteiro.
    return ListenableBuilder(
      listenable: appPreferences,
      builder: (context, _) {
        return MaterialApp.router(
          builder: (context, child) {
            final baseTheme = Theme.of(context);
            final mediaQuery = MediaQuery.of(context);

            var accessibleTheme = baseTheme.copyWith(
              textTheme: baseTheme.textTheme.apply(
                fontSizeFactor: appPreferences.textScale,
              ),
              primaryTextTheme: baseTheme.primaryTextTheme.apply(
                fontSizeFactor: appPreferences.textScale,
              ),
            );

            if (appPreferences.highContrast) {
              accessibleTheme = accessibleTheme.copyWith(
                colorScheme: accessibleTheme.colorScheme.copyWith(
                  outline: accessibleTheme.colorScheme.onSurface,
                  outlineVariant: accessibleTheme.colorScheme.onSurface
                      .withValues(alpha: 0.55),
                ),
              );
            }

            final filteredChild = _ColorVisionFilter.forMode(
              appPreferences.colorVisionMode,
            );

            final content = MediaQuery(
              data: mediaQuery.copyWith(
                disableAnimations: appPreferences.reduceMotion,
                highContrast: appPreferences.highContrast,
              ),
              child: child!,
            );

            return Theme(
              data: accessibleTheme,
              child: filteredChild == null
                  ? content
                  : ColorFiltered(colorFilter: filteredChild, child: content),
            );
          },
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          locale: appPreferences.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          // Respeita escolha do usuário: sistema / claro / escuro.
          themeMode: appPreferences.themeMode.material,
          routerConfig: appRouter,
        );
      },
    );
  }
}
