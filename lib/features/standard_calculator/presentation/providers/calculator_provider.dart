import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculatorState {
  final String expression;
  final String result;
  final List<String> history;

  CalculatorState({
    this.expression = '',
    this.result = '0',
    this.history = const [],
  });

  CalculatorState copyWith({
    String? expression,
    String? result,
    List<String>? history,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      history: history ?? this.history,
    );
  }
}

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  CalculatorNotifier() : super(CalculatorState()) {
    _loadHistory();
  }

  static const _historyKey = 'calculator_history';

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

  void onButtonPressed(String text) {
    if (text == 'C') {
      state = state.copyWith(expression: '', result: '0');
    } else if (text == 'CE') {
      state = state.copyWith(expression: '');
    } else if (text == 'CLEAR_HISTORY') {
      state = state.copyWith(history: []);
      _saveHistory([]);
    } else if (text == '⌫') {
      if (state.expression.isNotEmpty) {
        state = state.copyWith(expression: state.expression.substring(0, state.expression.length - 1));
      }
    } else if (text == '1/x') {
      state = state.copyWith(expression: '1/(${state.expression})');
      _evaluate(realtime: true);
    } else if (text == 'x²') {
      state = state.copyWith(expression: '(${state.expression})^2');
      _evaluate(realtime: true);
    } else if (text == '√x') {
      state = state.copyWith(expression: 'sqrt(${state.expression})');
      _evaluate(realtime: true);
    } else if (text == '+/-') {
      if (state.expression.startsWith('-')) {
        state = state.copyWith(expression: state.expression.substring(1));
      } else {
        state = state.copyWith(expression: '-${state.expression}');
      }
      _evaluate(realtime: true);
    } else if (text == '=') {
      _evaluate();
    } else {
      String newExpression = state.expression + text;
      state = state.copyWith(expression: newExpression);
      _evaluate(realtime: true);
    }
  }

  void _evaluate({bool realtime = false}) {
    if (state.expression.isEmpty) {
      if (!realtime) state = state.copyWith(result: '0');
      return;
    }

    try {
      String finalExpression = state.expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('%', '/100');

      Parser p = Parser();
      Expression exp = p.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      String resultStr;
      if (eval == eval.toInt()) {
        resultStr = eval.toInt().toString();
      } else {
        resultStr = eval.toString();
      }

      if (realtime) {
        state = state.copyWith(result: resultStr);
      } else {
        final newHistory = [...state.history, "${state.expression} = $resultStr"];
        state = state.copyWith(
          history: newHistory,
          expression: resultStr,
          result: '',
        );
        _saveHistory(newHistory);
      }
    } catch (e) {
      if (!realtime) {
        state = state.copyWith(result: 'Error');
      }
    }
  }
}

final calculatorProvider = StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
  return CalculatorNotifier();
});
