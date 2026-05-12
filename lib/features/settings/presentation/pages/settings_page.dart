import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text("Appearance", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ListTile(
          title: const Text("App Theme"),
          subtitle: const Text("Select which app theme to display"),
          trailing: DropdownButton<ThemeMode>(
            value: themeMode,
            items: const [
              DropdownMenuItem(value: ThemeMode.light, child: Text("Light")),
              DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
              DropdownMenuItem(value: ThemeMode.system, child: Text("Use system setting")),
            ],
            onChanged: (val) {
              if (val != null) {
                ref.read(themeProvider.notifier).setTheme(val);
              }
            },
          ),
        ),
        const Divider(),
        const Text("About", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        const ListTile(
          title: Text("Smart Calculator"),
          subtitle: Text("Version 1.0.0"),
        ),
      ],
    );
  }
}
