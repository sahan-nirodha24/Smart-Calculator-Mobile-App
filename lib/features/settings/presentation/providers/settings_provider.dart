import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final bool hapticFeedback;
  final int decimalPlaces;
  final bool keepScreenOn;

  AppSettings({
    this.hapticFeedback = true,
    this.decimalPlaces = 2,
    this.keepScreenOn = false,
  });

  AppSettings copyWith({
    bool? hapticFeedback,
    int? decimalPlaces,
    bool? keepScreenOn,
  }) {
    return AppSettings(
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      hapticFeedback: prefs.getBool('haptic_feedback') ?? true,
      decimalPlaces: prefs.getInt('decimal_places') ?? 2,
      keepScreenOn: prefs.getBool('keep_screen_on') ?? false,
    );
  }

  Future<void> setHapticFeedback(bool value) async {
    state = state.copyWith(hapticFeedback: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic_feedback', value);
  }

  Future<void> setDecimalPlaces(int value) async {
    state = state.copyWith(decimalPlaces: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('decimal_places', value);
  }

  Future<void> setKeepScreenOn(bool value) async {
    state = state.copyWith(keepScreenOn: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keep_screen_on', value);
  }

  Future<void> resetToDefaults() async {
    state = AppSettings();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('haptic_feedback');
    await prefs.remove('decimal_places');
    await prefs.remove('keep_screen_on');
    // Note: Theme is handled by themeProvider, but we can clear it here too if needed
    await prefs.remove('theme_mode');
  }
}

final appSettingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
