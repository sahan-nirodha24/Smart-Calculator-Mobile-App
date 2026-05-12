import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/navigation_provider.dart';
import '../providers/calculator_provider.dart';
import '../../../programmer_calculator/presentation/providers/programmer_provider.dart';
import '../../../date_calculator/presentation/providers/date_history_provider.dart';

class HistoryPanel extends ConsumerWidget {
  const HistoryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(navigationProvider);

    switch (mode) {
      case CalculatorMode.standard:
      case CalculatorMode.scientific:
        return _buildStandardHistory(context, ref);
      case CalculatorMode.programmer:
        return _buildProgrammerHistory(context, ref);
      case CalculatorMode.dateCalculation:
        return _buildDateHistory(context, ref);
      default:
        return const Center(child: Text("History not available for this mode"));
    }
  }

  Widget _buildStandardHistory(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    return _buildHistoryList(
      context: context,
      title: "Standard History",
      history: state.history,
      onClear: () => ref.read(calculatorProvider.notifier).onButtonPressed('CLEAR_HISTORY'),
    );
  }

  Widget _buildProgrammerHistory(BuildContext context, WidgetRef ref) {
    final state = ref.watch(programmerProvider);
    return _buildHistoryList(
      context: context,
      title: "Programmer History",
      history: state.history,
      onClear: () => ref.read(programmerProvider.notifier).clearHistory(),
    );
  }

  Widget _buildDateHistory(BuildContext context, WidgetRef ref) {
    final history = ref.watch(dateHistoryProvider);
    return _buildHistoryList(
      context: context,
      title: "Date History",
      history: history,
      onClear: () => ref.read(dateHistoryProvider.notifier).clearHistory(),
    );
  }

  Widget _buildHistoryList({
    required BuildContext context,
    required String title,
    required List<String> history,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (history.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onClear,
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (history.isEmpty)
          const Expanded(
            child: Center(
              child: Text("There's no history yet", style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[history.length - 1 - index];
                final parts = item.split('=');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(parts[0].trim(), style: const TextStyle(color: Colors.grey, fontSize: 14), textAlign: TextAlign.right),
                      if (parts.length > 1)
                        Text(parts[1].trim(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
