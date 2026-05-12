import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:math_expressions/math_expressions.dart';
import '../providers/graphing_provider.dart';

class GraphingCalculatorPage extends ConsumerStatefulWidget {
  const GraphingCalculatorPage({super.key});

  @override
  ConsumerState<GraphingCalculatorPage> createState() => _GraphingCalculatorPageState();
}

class _GraphingCalculatorPageState extends ConsumerState<GraphingCalculatorPage> {
  late TextEditingController _controller;
  String? _errorMessage;
  
  // Graph range
  double minX = -10;
  double maxX = 10;
  double minY = -10;
  double maxY = 10;

  @override
  void initState() {
    super.initState();
    final currentState = ref.read(graphingProvider);
    _controller = TextEditingController(text: currentState.currentEquation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<FlSpot> _generateSpots(String equation) {
    List<FlSpot> spots = [];
    try {
      String sanitized = equation.toLowerCase()
          .replaceAll(' ', '')
          .replaceAllMapped(RegExp(r'(\d)([a-z\(])'), (match) => '${match.group(1)}*${match.group(2)}')
          .replaceAllMapped(RegExp(r'(\))([0-9a-z\(])'), (match) => '${match.group(1)}*${match.group(2)}');

      Parser p = Parser();
      Expression exp = p.parse(sanitized);
      ContextModel cm = ContextModel();

      double step = (maxX - minX) / 250; // Resolution
      for (double x = minX; x <= maxX; x += step) {
        cm.bindVariable(Variable('x'), Number(x));
        double y = exp.evaluate(EvaluationType.REAL, cm);
        
        if (!y.isNaN && !y.isInfinite && y.abs() < 1000) {
          spots.add(FlSpot(x, y));
        }
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _errorMessage != null) {
          setState(() => _errorMessage = null);
        }
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _errorMessage == null) {
          setState(() => _errorMessage = "Invalid Equation");
        }
      });
    }
    return spots;
  }

  void _updateGraph() {
    ref.read(graphingProvider.notifier).addEquation(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(graphingProvider);
    final spots = _generateSpots(state.currentEquation);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "f(x) =",
                  errorText: _errorMessage,
                  hintText: "e.g., sin(x), x^2 + 2x + 1",
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.history, size: 20),
                        onPressed: _showHistoryMenu,
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: _updateGraph,
                      ),
                    ],
                  ),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                onSubmitted: (_) => _updateGraph(),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _quickButton("sin(x)"),
                    _quickButton("cos(x)"),
                    _quickButton("tan(x)"),
                    _quickButton("x^2"),
                    _quickButton("sqrt(x)"),
                    _quickButton("log(10, x)"),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 32, 32),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LineChart(
                  LineChartData(
                    minX: minX, maxX: maxX,
                    minY: minY, maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: false,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                        ),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 22, interval: (maxX - minX) / 4),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: (maxY - minY) / 4),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: (maxY - minY) / 10,
                      verticalInterval: (maxX - minX) / 10,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Theme.of(context).dividerColor.withOpacity(value == 0 ? 0.5 : 0.05),
                        strokeWidth: value == 0 ? 2 : 0.5,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: Theme.of(context).dividerColor.withOpacity(value == 0 ? 0.5 : 0.05),
                        strokeWidth: value == 0 ? 2 : 0.5,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              'x: ${spot.x.toStringAsFixed(2)}\ny: ${spot.y.toStringAsFixed(2)}',
                              const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        _buildZoomControls(),
      ],
    );
  }

  void _showHistoryMenu() {
    final history = ref.read(graphingProvider).history;
    if (history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No graphing history yet")));
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Recent Equations", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      ref.read(graphingProvider.notifier).clearHistory();
                      Navigator.pop(context);
                    },
                    child: const Text("Clear All"),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: history.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.show_chart, size: 20),
                    title: Text(history[index]),
                    onTap: () {
                      _controller.text = history[index];
                      _updateGraph();
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _quickButton(String eq) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(eq),
        onPressed: () {
          _controller.text = eq;
          _updateGraph();
        },
      ),
    );
  }

  Widget _buildZoomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _zoomBtn(Icons.zoom_in, "Zoom In", () {
            setState(() {
              minX /= 1.5; maxX /= 1.5; minY /= 1.5; maxY /= 1.5;
            });
          }),
          const SizedBox(width: 16),
          _zoomBtn(Icons.zoom_out, "Zoom Out", () {
            setState(() {
              minX *= 1.5; maxX *= 1.5; minY *= 1.5; maxY *= 1.5;
            });
          }),
          const SizedBox(width: 16),
          _zoomBtn(Icons.center_focus_strong, "Reset View", () {
            setState(() {
              minX = -10;
              maxX = 10;
              minY = -10;
              maxY = 10;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Graph Reset to Default View"), duration: Duration(seconds: 1)),
            );
          }),
        ],
      ),
    );
  }

  Widget _zoomBtn(IconData icon, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
