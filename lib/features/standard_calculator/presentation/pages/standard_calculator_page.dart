import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/calculator_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    letterSpacing: 1.2,
                    fontSize: 18,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              state.result,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 68,
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
              child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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

class _CalculatorButton extends ConsumerStatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _CalculatorButton({required this.text, required this.onTap});

  @override
  ConsumerState<_CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends ConsumerState<_CalculatorButton> with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    final isOperator = ['÷', '×', '-', '+', '='].contains(widget.text);
    final isPrimary = widget.text == '=';
    final isNumber = RegExp(r'[0-9]').hasMatch(widget.text) || widget.text == '.';

    Color bgColor;
    List<Color>? gradientColors;
    
    if (isPrimary) {
      gradientColors = [const Color(0xFF0078D4), const Color(0xFF2B88D8)];
      bgColor = const Color(0xFF0078D4);
    } else if (isNumber) {
      bgColor = isDark ? const Color(0xFF3B3B3B) : Colors.white;
    } else {
      bgColor = isDark ? const Color(0xFF323232) : const Color(0xFFF3F3F3);
    }

    if (isHovered) {
      bgColor = isPrimary 
          ? bgColor.withOpacity(0.9) 
          : (isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.06));
    }

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: _handleTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: gradientColors == null ? bgColor : null,
              gradient: gradientColors != null ? LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ) : null,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isPrimary 
                    ? Colors.white.withOpacity(0.2) 
                    : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
                if (isPrimary)
                  BoxShadow(
                    color: const Color(0xFF0078D4).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Center(
              child: Text(
                widget.text,
                style: TextStyle(
                  fontSize: isNumber ? 26 : 22,
                  fontWeight: isPrimary || isNumber ? FontWeight.w600 : FontWeight.w500,
                  color: isPrimary ? Colors.white : (isDark ? Colors.white.withOpacity(0.9) : Colors.black87),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
