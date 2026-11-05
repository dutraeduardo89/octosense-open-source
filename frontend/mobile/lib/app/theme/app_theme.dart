import 'package:flutter/material.dart';

import 'app_tokens.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppTokens.brand,
          brightness: Brightness.light,
        ).copyWith(
          surface: const Color(0xFFF8FAF9),
          surfaceContainerLow: Colors.white,
          outlineVariant: const Color(0xFFDCE6E3),
        );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF5F8F7),
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.white.withValues(alpha: 0.96),
        indicatorColor: AppTokens.brand.withValues(alpha: 0.12),
        height: 68,
      ),
    );
  }

  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppTokens.brand,
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF0A1110),
          surfaceContainerLow: const Color(0xFF111A18),
          outlineVariant: const Color(0xFF263431),
        );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF08100E),
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: const Color(0xFF0D1614),
        indicatorColor: AppTokens.brand.withValues(alpha: 0.18),
        height: 68,
      ),
    );
  }
}
