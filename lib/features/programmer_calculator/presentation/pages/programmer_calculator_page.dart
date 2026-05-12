import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/programmer_provider.dart';
import '../../../standard_calculator/presentation/widgets/history_panel.dart';

class ProgrammerCalculatorPage extends ConsumerStatefulWidget {
  const ProgrammerCalculatorPage({super.key});

  @override
  ConsumerState<ProgrammerCalculatorPage> createState() => _ProgrammerCalculatorPageState();
}

class _ProgrammerCalculatorPageState extends ConsumerState<ProgrammerCalculatorPage> {
  String _expression = "";
  String? _lastOp;
  BigInt? _buffer;

  void _onKeyPress(String key, ProgrammerState state, ProgrammerNotifier notifier) {
    setState(() {
      BigInt currentValue = state.currentValue;
      NumberBase activeBase = state.activeBase;

      if (key == "C") {
        notifier.updateValue(BigInt.zero);
        _buffer = null;
        _lastOp = null;
        _expression = "";
      } else if (key == "⌫") {
        String s = currentValue.toRadixString(_getRadix(activeBase));
        if (s.length > 1) {
          s = s.substring(0, s.length - 1);
          notifier.updateValue(BigInt.parse(s, radix: _getRadix(activeBase)));
        } else {
          notifier.updateValue(BigInt.zero);
        }
      } else if (RegExp(r'^[0-9A-F]$').hasMatch(key)) {
        int radix = _getRadix(activeBase);
        String s = currentValue == BigInt.zero ? "" : currentValue.toRadixString(radix);
        s += key;
        try {
          notifier.updateValue(BigInt.parse(s, radix: radix));
        } catch (e) {}
      } else if (["AND", "OR", "XOR", "Lsh", "Rsh", "+", "-", "×", "÷", "mod"].contains(key)) {
        _buffer = currentValue;
        _lastOp = key;
        _expression = "${currentValue.toRadixString(_getRadix(activeBase)).toUpperCase()} $key";
        notifier.updateValue(BigInt.zero);
      } else if (key == "=") {
        if (_buffer != null && _lastOp != null) {
          BigInt result = _calculate(currentValue);
          String historyEntry = "$_expression ${currentValue.toRadixString(_getRadix(activeBase)).toUpperCase()} = ${result.toRadixString(_getRadix(activeBase)).toUpperCase()}";
          notifier.addToHistory(historyEntry);
          notifier.updateValue(result);
          _lastOp = null;
          _buffer = null;
          _expression = "";
        }
      } else if (key == "NOT") {
        notifier.updateValue(~currentValue);
      }
    });
  }

  BigInt _calculate(BigInt currentValue) {
    if (_buffer == null || _lastOp == null) return currentValue;
    switch (_lastOp) {
      case "AND": return _buffer! & currentValue;
      case "OR": return _buffer! | currentValue;
      case "XOR": return _buffer! ^ currentValue;
      case "Lsh": return _buffer! << currentValue.toInt();
      case "Rsh": return _buffer! >> currentValue.toInt();
      case "+": return _buffer! + currentValue;
      case "-": return _buffer! - currentValue;
      case "×": return _buffer! * currentValue;
      case "÷": return currentValue != BigInt.zero ? _buffer! ~/ currentValue : BigInt.zero;
      case "mod": return currentValue != BigInt.zero ? _buffer! % currentValue : BigInt.zero;
      default: return currentValue;
    }
  }

  int _getRadix(NumberBase base) {
    switch (base) {
      case NumberBase.hex: return 16;
      case NumberBase.oct: return 8;
      case NumberBase.bin: return 2;
      default: return 10;
    }
  }

  bool _isKeyEnabled(String key, NumberBase activeBase) {
    if (RegExp(r'^[0-9]$').hasMatch(key)) {
      int val = int.parse(key);
      if (activeBase == NumberBase.bin) return val < 2;
      if (activeBase == NumberBase.oct) return val < 8;
      return true;
    }
    if (RegExp(r'^[A-F]$').hasMatch(key)) {
      return activeBase == NumberBase.hex;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(programmerProvider);
    final notifier = ref.read(programmerProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildDisplay(state),
                  _buildBaseSelector(state, notifier),
                  const Divider(height: 1),
                  Expanded(child: _buildKeypad(state, notifier)),
                ],
              ),
            ),
            if (constraints.maxWidth > 900)
              Container(
                width: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
                ),
                child: const HistoryPanel(),
              ),
          ],
        );
      }
    );
  }

  Widget _buildDisplay(ProgrammerState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      alignment: Alignment.bottomRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(_expression, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              state.currentValue.toRadixString(_getRadix(state.activeBase)).toUpperCase(),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseSelector(ProgrammerState state, ProgrammerNotifier notifier) {
    return Column(
      children: [
        _baseTile(NumberBase.hex, "HEX", state, notifier),
        _baseTile(NumberBase.dec, "DEC", state, notifier),
        _baseTile(NumberBase.oct, "OCT", state, notifier),
        _baseTile(NumberBase.bin, "BIN", state, notifier),
      ],
    );
  }

  Widget _baseTile(NumberBase base, String label, ProgrammerState state, ProgrammerNotifier notifier) {
    bool isSelected = state.activeBase == base;
    String val = state.currentValue.toRadixString(_getRadix(base)).toUpperCase();
    if (base == NumberBase.bin) {
      val = val.padLeft((val.length / 4).ceil() * 4, '0').replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ");
    }

    return InkWell(
      onTap: () => notifier.setBase(base),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : null,
        child: Row(
          children: [
            Container(
              width: 4, height: 16,
              margin: const EdgeInsets.only(right: 12),
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            ),
            SizedBox(width: 40, child: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12))),
            Expanded(
              child: Text(
                val,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad(ProgrammerState state, ProgrammerNotifier notifier) {
    final keys = [
      ['Lsh', 'Rsh', 'OR', 'XOR', 'NOT', 'AND'],
      ['A', 'B', 'C', 'D', 'E', 'F'],
      ['7', '8', '9', '(', ')', '⌫'],
      ['4', '5', '6', '×', '÷', 'C'],
      ['1', '2', '3', '-', '+', '='],
      ['mod', '0', '.', ' ', ' ', ' '],
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: keys.map((row) => Expanded(
          child: Row(
            children: row.map((key) => Expanded(
              child: _buildButton(key, state, notifier),
            )).toList(),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildButton(String text, ProgrammerState state, ProgrammerNotifier notifier) {
    if (text.trim().isEmpty) return const SizedBox();
    
    bool enabled = _isKeyEnabled(text, state.activeBase);
    bool isOp = ["AND", "OR", "XOR", "NOT", "Lsh", "Rsh", "+", "-", "×", "÷", "="].contains(text);
    
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Material(
        color: isOp 
          ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5)
          : (enabled ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surface.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(2),
        child: InkWell(
          onTap: enabled ? () => _onKeyPress(text, state, notifier) : null,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: enabled ? null : Colors.grey.withOpacity(0.5),
                fontWeight: isOp ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
