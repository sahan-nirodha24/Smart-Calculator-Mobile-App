import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/providers/navigation_provider.dart';

enum AngleUnit { deg, rad, grad }

class ScientificState {
  final String expression;
  final String result;
  final List<String> history;
  final AngleUnit angleUnit;
  final bool isHyperbolic;
  final bool isScientificNotation;

  ScientificState({
    this.expression = '',
    this.result = '0',
    this.history = const [],
    this.angleUnit = AngleUnit.deg,
    this.isHyperbolic = false,
    this.isScientificNotation = false,
  });

  ScientificState copyWith({
    String? expression,
    String? result,
    List<String>? history,
    AngleUnit? angleUnit,
    bool? isHyperbolic,
    bool? isScientificNotation,
  }) {
    return ScientificState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      history: history ?? this.history,
      angleUnit: angleUnit ?? this.angleUnit,
      isHyperbolic: isHyperbolic ?? this.isHyperbolic,
      isScientificNotation: isScientificNotation ?? this.isScientificNotation,
    );
  }
}

class ScientificNotifier extends StateNotifier<ScientificState> {
  final Ref _ref;
  ScientificNotifier(this._ref) : super(ScientificState()) {
    _loadHistory();
  }

  static const _historyKey = 'scientific_history';

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

  void toggleAngleUnit() {
    final next = AngleUnit.values[(state.angleUnit.index + 1) % AngleUnit.values.length];
    state = state.copyWith(angleUnit: next);
  }

  void toggleHyperbolic() {
    state = state.copyWith(isHyperbolic: !state.isHyperbolic);
  }

  void toggleScientificNotation() {
    state = state.copyWith(isScientificNotation: !state.isScientificNotation);
    _evaluate(realtime: true);
  }

  void clearHistory() {
    state = state.copyWith(history: []);
    _saveHistory([]);
  }

  void onButtonPressed(String text) {
    if (text == 'C') {
      state = state.copyWith(expression: '', result: '0');
    } else if (text == 'CE') {
      state = state.copyWith(expression: '');
    } else if (text == '⌫') {
      if (state.expression.isNotEmpty) {
        state = state.copyWith(expression: state.expression.substring(0, state.expression.length - 1));
      }
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

      if (state.angleUnit == AngleUnit.deg) {
        finalExpression = finalExpression
            .replaceAll('sin(', 'sin(0.0174532925*')
            .replaceAll('cos(', 'cos(0.0174532925*')
            .replaceAll('tan(', 'tan(0.0174532925*');
      } else if (state.angleUnit == AngleUnit.grad) {
        finalExpression = finalExpression
            .replaceAll('sin(', 'sin(0.0157079633*')
            .replaceAll('cos(', 'cos(0.0157079633*')
            .replaceAll('tan(', 'tan(0.0157079633*');
      }

      Parser p = Parser();
      Expression exp = p.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      final decimalPlaces = _ref.read(appSettingsProvider).decimalPlaces;
      
      String resultStr;
      if (state.isScientificNotation) {
        resultStr = eval.toStringAsExponential(decimalPlaces);
      } else {
        if (eval == eval.toInt()) {
          resultStr = eval.toInt().toString();
        } else {
          resultStr = eval.toStringAsFixed(decimalPlaces);
          if (resultStr.contains('.')) {
            resultStr = resultStr.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
          }
        }
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

final scientificProvider = StateNotifierProvider<ScientificNotifier, ScientificState>((ref) {
  return ScientificNotifier(ref);
});
