import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NumberBase { hex, dec, oct, bin }

class ProgrammerState {
  final BigInt currentValue;
  final NumberBase activeBase;
  final List<String> history;

  ProgrammerState({
    required this.currentValue,
    this.activeBase = NumberBase.dec,
    this.history = const [],
  });

  factory ProgrammerState.initial() {
    return ProgrammerState(
      currentValue: BigInt.zero,
      activeBase: NumberBase.dec,
      history: const [],
    );
  }

  ProgrammerState copyWith({
    BigInt? currentValue,
    NumberBase? activeBase,
    List<String>? history,
  }) {
    return ProgrammerState(
      currentValue: currentValue ?? this.currentValue,
      activeBase: activeBase ?? this.activeBase,
      history: history ?? this.history,
    );
  }
}

class ProgrammerNotifier extends StateNotifier<ProgrammerState> {
  ProgrammerNotifier() : super(ProgrammerState.initial()) {
    _loadHistory();
  }

  static const _historyKey = 'programmer_history';

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHistory = prefs.getStringList(_historyKey);
    if (savedHistory != null) {
      state = state.copyWith(history: savedHistory);
    }
  }

  Future<void> _saveHistory(List<String> newHistory) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, newHistory);
  }

  void addToHistory(String entry) {
    final newHistory = [...state.history, entry];
    state = state.copyWith(history: newHistory);
    _saveHistory(newHistory);
  }

  void clearHistory() {
    state = state.copyWith(history: []);
    _saveHistory([]);
  }

  void updateValue(BigInt val) {
    state = state.copyWith(currentValue: val);
  }

  void setBase(NumberBase base) {
    state = state.copyWith(activeBase: base);
  }
}

final programmerProvider = StateNotifierProvider<ProgrammerNotifier, ProgrammerState>((ref) {
  return ProgrammerNotifier();
});
