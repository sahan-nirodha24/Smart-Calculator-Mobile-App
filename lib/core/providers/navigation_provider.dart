import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CalculatorMode {
  standard,
  scientific,
  graphing,
  programmer,
  dateCalculation,
  currency,
  unitConverter,
  settings
}

final navigationProvider = StateProvider<CalculatorMode>((ref) => CalculatorMode.standard);
