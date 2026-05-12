import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/calculator_provider.dart';
import '../widgets/history_panel.dart';

class StandardCalculatorPage extends ConsumerWidget {
  const StandardCalculatorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildDisplay(context, state),
                  ),
                  _buildMemoryButtons(context),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 6,
                    child: _buildKeypad(context, notifier),
                  ),
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
      },
    );
  }

  Widget _buildDisplay(BuildContext context, CalculatorState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Text(
              state.expression,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    letterSpacing: 1.2,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              state.result,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 56,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryButtons(BuildContext context) {
    final labels = ['MC', 'MR', 'M+', 'M-', 'MS', 'M⌄'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: labels.map((label) {
          return Expanded(
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeypad(BuildContext context, CalculatorNotifier notifier) {
    final List<List<String>> keys = [
      ['%', 'CE', 'C', '⌫'],
      ['1/x', 'x²', '√x', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['+/-', '0', '.', '='],
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
      child: Column(
        children: keys.map((row) {
          return Expanded(
            child: Row(
              children: row.map((key) {
                return Expanded(
                  child: _CalculatorButton(
                    text: key,
                    onTap: () => notifier.onButtonPressed(key),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CalculatorButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _CalculatorButton({required this.text, required this.onTap});

  @override
  State<_CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<_CalculatorButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOperator = ['÷', '×', '-', '+', '='].contains(widget.text);
    final isPrimary = widget.text == '=';
    final isNumber = RegExp(r'[0-9]').hasMatch(widget.text) || widget.text == '.';

    Color bgColor;
    if (isPrimary) {
      bgColor = Theme.of(context).colorScheme.primary;
    } else if (isNumber) {
      bgColor = isDark ? const Color(0xFF3B3B3B) : Colors.white;
    } else {
      bgColor = isDark ? const Color(0xFF323232) : const Color(0xFFF9F9F9);
    }

    // Adjust color on hover
    if (isHovered) {
      bgColor = isPrimary 
          ? bgColor.withOpacity(0.9) 
          : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05));
    }

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              width: 1,
            ),
            boxShadow: isNumber ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 1,
                offset: const Offset(0, 1),
              )
            ] : null,
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: isNumber ? 20 : 16,
                fontWeight: isPrimary || isNumber ? FontWeight.w500 : FontWeight.normal,
                color: isPrimary ? Theme.of(context).colorScheme.onPrimary : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
