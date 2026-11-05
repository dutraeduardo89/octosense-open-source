import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTextSize { standard, large, extraLarge }

enum AppColorVisionMode {
  standard,
  protanopia,
  deuteranopia,
  tritanopia,
  achromatopsia,
}

extension AppTextSizeX on AppTextSize {
  String get label => switch (this) {
    AppTextSize.standard => 'Padrão',
    AppTextSize.large => 'Grande',
    AppTextSize.extraLarge => 'Muito grande',
  };

  double get factor => switch (this) {
    AppTextSize.standard => 1.0,
    AppTextSize.large => 1.15,
    AppTextSize.extraLarge => 1.30,
  };
}

/// Modo de tema escolhido pelo usuário.
enum AppThemeMode { system, light, dark }

extension AppThemeModeX on AppThemeMode {
  String get label => switch (this) {
    AppThemeMode.system => 'Seguir sistema',
    AppThemeMode.light => 'Claro',
    AppThemeMode.dark => 'Escuro',
  };

  IconData get icon => switch (this) {
    AppThemeMode.system => Icons.brightness_auto_outlined,
    AppThemeMode.light => Icons.light_mode_outlined,
    AppThemeMode.dark => Icons.dark_mode_outlined,
  };

  ThemeMode get material => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}

class AppPreferences extends ChangeNotifier {
  static const _textSizeKey = 'accessibility.textSize';
  static const _highContrastKey = 'accessibility.highContrast';
  static const _reduceMotionKey = 'accessibility.reduceMotion';
  static const _themeModeKey = 'appearance.themeMode';
  static const _localeKey = 'appearance.locale';
  static const _colorVisionKey = 'accessibility.colorVision';

  AppTextSize textSize = AppTextSize.standard;
  bool highContrast = false;
  bool reduceMotion = false;
  AppThemeMode themeMode = AppThemeMode.system;
  Locale? locale = const Locale('pt');
  AppColorVisionMode colorVisionMode = AppColorVisionMode.standard;

  double get textScale => textSize.factor;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTextSize = prefs.getString(_textSizeKey);
    textSize = AppTextSize.values.firstWhere(
      (value) => value.name == savedTextSize,
      orElse: () => AppTextSize.standard,
    );

    highContrast = prefs.getBool(_highContrastKey) ?? false;
    reduceMotion = prefs.getBool(_reduceMotionKey) ?? false;

    final savedColorVision = prefs.getString(_colorVisionKey);
    colorVisionMode = AppColorVisionMode.values.firstWhere(
      (value) => value.name == savedColorVision,
      orElse: () => AppColorVisionMode.standard,
    );

    final savedLocale = prefs.getString(_localeKey);
    locale = switch (savedLocale) {
      'pt' => const Locale('pt'),
      'en' => const Locale('en'),
      'es' => const Locale('es'),
      'fr' => const Locale('fr'),
      'it' => const Locale('it'),
      'de' => const Locale('de'),
      _ => const Locale('pt'),
    };

    final savedTheme = prefs.getString(_themeModeKey);
    themeMode = AppThemeMode.values.firstWhere(
      (value) => value.name == savedTheme,
      orElse: () => AppThemeMode.system,
    );
  }

  Future<void> setTextSize(AppTextSize value) async {
    if (textSize == value) return;
    textSize = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_textSizeKey, value.name);
  }

  Future<void> setHighContrast(bool value) async {
    if (highContrast == value) return;
    highContrast = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastKey, value);
  }

  Future<void> setReduceMotion(bool value) async {
    if (reduceMotion == value) return;
    reduceMotion = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reduceMotionKey, value);
  }

  Future<void> setColorVisionMode(AppColorVisionMode value) async {
    if (colorVisionMode == value) return;
    colorVisionMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_colorVisionKey, value.name);
  }

  Future<void> setLocale(Locale? value) async {
    if (locale == value) return;
    locale = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, value.languageCode);
    }
  }

  Future<void> setThemeMode(AppThemeMode value) async {
    if (themeMode == value) return;
    themeMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, value.name);
  }
}

final appPreferences = AppPreferences();
