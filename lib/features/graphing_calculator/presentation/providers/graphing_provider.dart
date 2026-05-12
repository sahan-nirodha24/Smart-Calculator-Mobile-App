import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphingState {
  final List<String> history;
  final String currentEquation;

  GraphingState({
    this.history = const [],
    this.currentEquation = 'x^2',
  });

  GraphingState copyWith({
    List<String>? history,
    String? currentEquation,
  }) {
    return GraphingState(
      history: history ?? this.history,
      currentEquation: currentEquation ?? this.currentEquation,
    );
  }
}

class GraphingNotifier extends StateNotifier<GraphingState> {
  GraphingNotifier() : super(GraphingState()) {
    _loadHistory();
  }

  static const _key = 'graphing_history';

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHistory = prefs.getStringList(_key);
    if (savedHistory != null) {
      state = state.copyWith(history: savedHistory);
    }
  }

  Future<void> addEquation(String equation) async {
    if (equation.isEmpty) return;
    
    final newHistory = [
      equation,
      ...state.history.where((e) => e != equation),
    ].take(10).toList(); // Keep last 10 equations

    state = state.copyWith(history: newHistory, currentEquation: equation);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newHistory);
  }

  void clearHistory() async {
    state = state.copyWith(history: []);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

final graphingProvider = StateNotifierProvider<GraphingNotifier, GraphingState>((ref) {
  return GraphingNotifier();
});
