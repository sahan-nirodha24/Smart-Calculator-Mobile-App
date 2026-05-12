import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DateHistoryNotifier extends StateNotifier<List<String>> {
  DateHistoryNotifier() : super([]) {
    _loadHistory();
  }

  static const _key = 'date_calculation_history';

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key);
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> addEntry(String entry) async {
    final newHistory = [entry, ...state].take(20).toList();
    state = newHistory;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newHistory);
  }

  Future<void> clearHistory() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

final dateHistoryProvider = StateNotifierProvider<DateHistoryNotifier, List<String>>((ref) {
  return DateHistoryNotifier();
});
