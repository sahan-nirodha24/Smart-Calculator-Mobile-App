import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import '../../../../core/providers/navigation_provider.dart';
import '../../../standard_calculator/presentation/pages/standard_calculator_page.dart';
import '../../../scientific_calculator/presentation/pages/scientific_calculator_page.dart';
import '../../../unit_converter/presentation/pages/unit_converter_page.dart';
import '../../../date_calculator/presentation/pages/date_calculator_page.dart';
import '../../../currency_converter/presentation/pages/currency_converter_page.dart';
import '../../../programmer_calculator/presentation/pages/programmer_calculator_page.dart';
import '../../../graphing_calculator/presentation/pages/graphing_calculator_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../standard_calculator/presentation/widgets/history_panel.dart';
import 'dashboard_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool isSidebarExpanded = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(navigationProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 700;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Platform.isWindows ? Colors.transparent : null,
      drawer: isCompact ? _buildSidebar(mode, asDrawer: true) : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isCompact) _buildSidebar(mode),
            Expanded(
              child: Container(
                color: isDark ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.2),
                child: Column(
                  children: [
                    _buildTitleBar(mode, isCompact),
                    Expanded(
                      child: _buildContent(mode),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(CalculatorMode currentMode, {bool asDrawer = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sidebarContent = Container(
      width: (isSidebarExpanded || asDrawer) ? 280 : 50,
      color: asDrawer 
          ? Theme.of(context).colorScheme.surface 
          : (isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.2)),
      child: Column(
        children: [
          if (asDrawer) const SizedBox(height: 50) else const SizedBox(height: 40),
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: "Dashboard",
            isSelected: currentMode == CalculatorMode.dashboard,
            isExpanded: isSidebarExpanded || asDrawer,
            onTap: () => _handleNavigation(CalculatorMode.dashboard, asDrawer),
          ),
          if (!asDrawer)
            _SidebarItem(
              icon: Icons.menu,
              label: "Menu",
              isExpanded: isSidebarExpanded,
              onTap: () => setState(() => isSidebarExpanded = !isSidebarExpanded),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _SidebarGroup(title: "Calculator", isExpanded: isSidebarExpanded || asDrawer),
                _SidebarItem(
                  icon: Icons.calculate_outlined,
                  activeIcon: Icons.calculate,
                  label: "Standard",
                  isSelected: currentMode == CalculatorMode.standard,
                  isExpanded: isSidebarExpanded || asDrawer,
                  onTap: () => _handleNavigation(CalculatorMode.standard, asDrawer),
                ),
                _SidebarItem(
                  icon: Icons.science_outlined,
                  activeIcon: Icons.science,
                  label: "Scientific",
                  isSelected: currentMode == CalculatorMode.scientific,
                  isExpanded: isSidebarExpanded || asDrawer,
                  onTap: () => _handleNavigation(CalculatorMode.scientific, asDrawer),
                ),
                _SidebarItem(
                  icon: Icons.show_chart_outlined,
                  activeIcon: Icons.show_chart,
                  label: "Graphing",
                  isSelected: currentMode == CalculatorMode.graphing,
                  isExpanded: isSidebarExpanded || asDrawer,
                  onTap: () => _handleNavigation(CalculatorMode.graphing, asDrawer),
                ),
                _SidebarItem(
                  icon: Icons.code_outlined,
                  activeIcon: Icons.code,
                  label: "Programmer",
                  isSelected: currentMode == CalculatorMode.programmer,
                  isExpanded: isSidebarExpanded || asDrawer,
                  onTap: () => _handleNavigation(CalculatorMode.programmer, asDrawer),
                ),
                _SidebarItem(
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  label: "Date Calculation",
                  isSelected: currentMode == CalculatorMode.dateCalculation,
                  isExpanded: isSidebarExpanded || asDrawer,
                  onTap: () => _handleNavigation(CalculatorMode.dateCalculation, asDrawer),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Divider(height: 1),
                ),
                _SidebarGroup(title: "Converter", isExpanded: isSidebarExpanded || asDrawer),
                _SidebarItem(
                  icon: Icons.currency_exchange_outlined,
                  activeIcon: Icons.currency_exchange,
                  label: "Currency",
                  isSelected: currentMode == CalculatorMode.currency,
                  isExpanded: isSidebarExpanded || asDrawer,
                  onTap: () => _handleNavigation(CalculatorMode.currency, asDrawer),
                ),
                _SidebarItem(
                  icon: Icons.straighten_outlined,
                  activeIcon: Icons.straighten,
                  label: "Unit Converter",
                  isSelected: currentMode == CalculatorMode.unitConverter,
                  isExpanded: isSidebarExpanded || asDrawer,
                  onTap: () => _handleNavigation(CalculatorMode.unitConverter, asDrawer),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _SidebarItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: "Settings",
            isSelected: currentMode == CalculatorMode.settings,
            isExpanded: isSidebarExpanded || asDrawer,
            onTap: () => _handleNavigation(CalculatorMode.settings, asDrawer),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );

    if (asDrawer) {
      return Drawer(
        child: sidebarContent,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isSidebarExpanded ? 280 : 50,
      child: sidebarContent,
    );
  }

  void _handleNavigation(CalculatorMode mode, bool isDrawer) {
    ref.read(navigationProvider.notifier).state = mode;
    if (isDrawer) {
      Navigator.pop(context);
    }
  }

  Widget _buildTitleBar(CalculatorMode mode, bool isCompact) {
    String title = "";
    switch (mode) {
      case CalculatorMode.dashboard: title = "Dashboard"; break;
      case CalculatorMode.standard: title = "Standard"; break;
      case CalculatorMode.scientific: title = "Scientific"; break;
      case CalculatorMode.graphing: title = "Graphing"; break;
      case CalculatorMode.programmer: title = "Programmer"; break;
      case CalculatorMode.dateCalculation: title = "Date Calculation"; break;
      case CalculatorMode.currency: title = "Currency"; break;
      case CalculatorMode.unitConverter: title = "Unit Converter"; break;
      case CalculatorMode.settings: title = "Settings"; break;
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          if (isCompact)
            IconButton(
              icon: const Icon(Icons.menu, size: 20),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            )
          else if (!isSidebarExpanded)
            const SizedBox(width: 50),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600, 
              fontSize: 14,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          if (mode != CalculatorMode.dashboard && mode != CalculatorMode.settings) ...[
            _TitleBarButton(
              icon: Icons.history,
              tooltip: "History",
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: const HistoryPanel(),
                  ),
                );
              },
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildContent(CalculatorMode mode) {
    Widget child;
    switch (mode) {
      case CalculatorMode.dashboard:
        child = const DashboardPage(key: ValueKey("dashboard"));
        break;
      case CalculatorMode.standard:
        child = StandardCalculatorPage(key: const ValueKey("standard"));
        break;
      case CalculatorMode.scientific:
        child = ScientificCalculatorPage(key: const ValueKey("scientific"));
        break;
      case CalculatorMode.graphing:
        child = GraphingCalculatorPage(key: const ValueKey("graphing"));
        break;
      case CalculatorMode.programmer:
        child = ProgrammerCalculatorPage(key: const ValueKey("programmer"));
        break;
      case CalculatorMode.unitConverter:
        child = UnitConverterPage(key: const ValueKey("unit"));
        break;
      case CalculatorMode.dateCalculation:
        child = DateCalculatorPage(key: const ValueKey("date"));
        break;
      case CalculatorMode.currency:
        child = CurrencyConverterPage(key: const ValueKey("currency"));
        break;
      case CalculatorMode.settings:
        child = SettingsPage(key: const ValueKey("settings"));
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _TitleBarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isActive;

  const _TitleBarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isActive ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon, 
              size: 18, 
              color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarGroup extends StatelessWidget {
  final String title;
  final bool isExpanded;

  const _SidebarGroup({required this.title, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    if (!isExpanded) return const SizedBox(height: 10);
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.isSelected = false,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        height: 36,
        margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
        child: Material(
          color: widget.isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1) 
              : (isHovered ? Theme.of(context).colorScheme.onSurface.withOpacity(0.05) : Colors.transparent),
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                const SizedBox(width: 4),
                if (widget.isSelected)
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                else
                  const SizedBox(width: 3),
                const SizedBox(width: 8),
                Icon(
                  widget.isSelected ? (widget.activeIcon ?? widget.icon) : widget.icon, 
                  size: 18, 
                  color: widget.isSelected ? Theme.of(context).colorScheme.primary : null
                ),
                if (widget.isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
