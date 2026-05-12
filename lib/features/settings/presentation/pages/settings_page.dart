import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../../../standard_calculator/presentation/providers/calculator_provider.dart';
import '../../../programmer_calculator/presentation/providers/programmer_provider.dart';
import '../../../graphing_calculator/presentation/providers/graphing_provider.dart';
import '../../../date_calculator/presentation/providers/date_history_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final settings = ref.watch(appSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        children: [
          _buildSectionHeader(context, "Appearance"),
          _buildSettingCard(
            context,
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  title: "App Theme",
                  subtitle: "Switch between light and dark modes",
                  icon: Icons.palette_outlined,
                  trailing: DropdownButton<ThemeMode>(
                    value: themeMode,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(8),
                    items: const [
                      DropdownMenuItem(value: ThemeMode.light, child: Text("Light")),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
                      DropdownMenuItem(value: ThemeMode.system, child: Text("System")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(themeProvider.notifier).setTheme(val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, "Calculator Settings"),
          _buildSettingCard(
            context,
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  title: "Haptic Feedback",
                  subtitle: "Vibrate on button press",
                  icon: Icons.vibration,
                  trailing: Switch(
                    value: settings.hapticFeedback,
                    onChanged: (val) => ref.read(appSettingsProvider.notifier).setHapticFeedback(val),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingTile(
                  context,
                  title: "Decimal Places",
                  subtitle: "Number of digits after decimal",
                  icon: Icons.numbers,
                  trailing: DropdownButton<int>(
                    value: settings.decimalPlaces,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(8),
                    items: [2, 3, 4, 5].map((i) => DropdownMenuItem(value: i, child: Text(i.toString()))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(appSettingsProvider.notifier).setDecimalPlaces(val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, "Data & Privacy"),
          _buildSettingCard(
            context,
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  title: "Clear History",
                  subtitle: "Delete all calculation logs",
                  icon: Icons.delete_outline,
                  onTap: () => _showClearHistoryDialog(context, ref),
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingTile(
                  context,
                  title: "Reset to Defaults",
                  subtitle: "Restore all settings to original values",
                  icon: Icons.restore,
                  onTap: () => _showResetDefaultsDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, "About"),
          _buildSettingCard(
            context,
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  title: "Smart Calculator",
                  subtitle: "Version 1.0.0",
                  icon: Icons.info_outline,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showResetDefaultsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Settings?"),
        content: const Text("This will restore all settings (Theme, Haptic, Precision) to their original default values."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ref.read(appSettingsProvider.notifier).resetToDefaults();
              ref.read(themeProvider.notifier).reset();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Settings restored to defaults"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("Reset", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear History?"),
        content: const Text("This will permanently delete all your calculation history across all modes."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              // Clear history for all features
              ref.read(calculatorProvider.notifier).clearHistory();
              ref.read(programmerProvider.notifier).clearHistory();
              ref.read(graphingProvider.notifier).clearHistory();
              ref.read(dateHistoryProvider.notifier).clearHistory();
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("All history cleared successfully"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("Clear All", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
