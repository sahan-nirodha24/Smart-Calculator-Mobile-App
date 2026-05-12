import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/navigation_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to Smart Calculator",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Select a mode to get started",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 32),
            _buildSection(context, "Calculators"),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _MenuCard(
                  title: "Standard",
                  icon: Icons.calculate_outlined,
                  color: const Color(0xFF0078D4),
                  onTap: () => ref.read(navigationProvider.notifier).state = CalculatorMode.standard,
                ),
                _MenuCard(
                  title: "Scientific",
                  icon: Icons.science_outlined,
                  color: const Color(0xFF107C10),
                  onTap: () => ref.read(navigationProvider.notifier).state = CalculatorMode.scientific,
                ),
                _MenuCard(
                  title: "Graphing",
                  icon: Icons.show_chart_outlined,
                  color: const Color(0xFF8E44AD),
                  onTap: () => ref.read(navigationProvider.notifier).state = CalculatorMode.graphing,
                ),
                _MenuCard(
                  title: "Programmer",
                  icon: Icons.code_outlined,
                  color: const Color(0xFFD83B01),
                  onTap: () => ref.read(navigationProvider.notifier).state = CalculatorMode.programmer,
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSection(context, "Tools & Converters"),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _MenuCard(
                  title: "Currency",
                  icon: Icons.currency_exchange_outlined,
                  color: const Color(0xFFC239B3),
                  onTap: () => ref.read(navigationProvider.notifier).state = CalculatorMode.currency,
                ),
                _MenuCard(
                  title: "Unit Converter",
                  icon: Icons.straighten_outlined,
                  color: const Color(0xFF00B7C3),
                  onTap: () => ref.read(navigationProvider.notifier).state = CalculatorMode.unitConverter,
                ),
                _MenuCard(
                  title: "Date Calc",
                  icon: Icons.calendar_today_outlined,
                  color: const Color(0xFFE67E22),
                  onTap: () => ref.read(navigationProvider.notifier).state = CalculatorMode.dateCalculation,
                ),
                _MenuCard(
                  title: "Settings",
                  icon: Icons.settings_outlined,
                  color: Colors.blueGrey,
                  onTap: () => ref.read(navigationProvider.notifier).state = CalculatorMode.settings,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _MenuCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isDark 
                ? const Color(0xFF2B2B2B).withOpacity(isHovered ? 0.9 : 0.7) 
                : Colors.white.withOpacity(isHovered ? 1.0 : 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered 
                  ? widget.color.withOpacity(0.5) 
                  : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isHovered 
                    ? widget.color.withOpacity(0.2) 
                    : Colors.black.withOpacity(0.05),
                blurRadius: isHovered ? 15 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 32,
                  color: widget.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
