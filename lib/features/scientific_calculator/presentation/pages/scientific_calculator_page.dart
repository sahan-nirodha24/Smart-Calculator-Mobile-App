import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/scientific_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class ScientificCalculatorPage extends ConsumerWidget {
  const ScientificCalculatorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scientificProvider);
    final notifier = ref.read(scientificProvider.notifier);

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: _buildDisplay(context, state),
        ),
        _buildScientificControls(context, state, notifier),
        Expanded(
          flex: 6,
          child: _buildKeypad(context, state, notifier),
        ),
      ],
    );
  }

  Widget _buildDisplay(BuildContext context, ScientificState state) {
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 18,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              state.result,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 52,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScientificControls(BuildContext context, ScientificState state, ScientificNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _controlButton(
            context,
            state.angleUnit.name.toUpperCase(),
            onPressed: () => notifier.toggleAngleUnit(),
            isActive: true,
          ),
          _controlButton(
            context,
            "HYP",
            onPressed: () => notifier.toggleHyperbolic(),
            isActive: state.isHyperbolic,
          ),
          _controlButton(
            context,
            "F-E",
            onPressed: () => notifier.toggleScientificNotation(),
            isActive: state.isScientificNotation,
          ),
        ],
      ),
    );
  }

  Widget _controlButton(BuildContext context, String text, {required VoidCallback onPressed, bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: isActive ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad(BuildContext context, ScientificState state, ScientificNotifier notifier) {
    final List<List<String>> keys = [
      ['2nd', 'π', 'e', 'C', '⌫'],
      ['sin', 'cos', 'tan', 'exp', 'mod'],
      ['x²', '1/x', '|x|', 'n!', '÷'],
      ['√x', '(', ')', 'log', '×'],
      ['xʸ', '7', '8', '9', '-'],
      ['10ˣ', '4', '5', '6', '+'],
      ['ln', '+/-', '0', '.', '='],
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
      child: Column(
        children: keys.map((row) {
          return Expanded(
            child: Row(
              children: row.map((key) {
                return Expanded(
                  child: _ScientificButton(
                    text: key,
                    onTap: () {
                      String action = key;
                      if (key == 'xʸ') action = '^';
                      if (key == '10ˣ') action = '10^';
                      if (key == 'π') action = '3.14159265';
                      if (key == 'e') action = '2.71828182';
                      
                      if (['sin', 'cos', 'tan'].contains(key)) {
                        action = state.isHyperbolic ? '${key}h(' : '$key(';
                      } else if (['log', 'ln'].contains(key)) {
                        action = '$key(';
                      }

                      notifier.onButtonPressed(action);
                    },
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

class _ScientificButton extends ConsumerStatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _ScientificButton({required this.text, required this.onTap});

  @override
  ConsumerState<_ScientificButton> createState() => _ScientificButtonState();
}

class _ScientificButtonState extends ConsumerState<_ScientificButton> {
  bool isHovered = false;

  void _handleTap() {
    final settings = ref.read(appSettingsProvider);
    if (settings.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNumber = RegExp(r'[0-9]').hasMatch(widget.text) || widget.text == '.';
    final isPrimary = widget.text == '=';

    Color bgColor;
    if (isPrimary) {
      bgColor = Theme.of(context).colorScheme.primary;
    } else if (isNumber) {
      bgColor = isDark ? const Color(0xFF3B3B3B) : Colors.white;
    } else {
      bgColor = isDark ? const Color(0xFF202020).withOpacity(0.5) : const Color(0xFFF3F3F3);
    }

    if (isHovered) {
      bgColor = isPrimary ? bgColor.withOpacity(0.9) : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05));
    }

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: isNumber ? 22 : 16,
                fontWeight: isNumber || isPrimary ? FontWeight.w600 : FontWeight.w500,
                color: isPrimary ? Theme.of(context).colorScheme.onPrimary : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
