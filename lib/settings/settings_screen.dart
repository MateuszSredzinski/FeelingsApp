import 'package:flutter/material.dart';
import 'package:feelings/settings/emotions_definitions_screen.dart';
import 'package:feelings/settings/trash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:feelings/settings/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia')),
      body: ListView(
        children: [
          BlocBuilder<SettingsCubit, bool>(
            builder: (context, enabled) {
              return SwitchListTile(
                title: const Text('Intensywność emocji (1–4)'),
                subtitle: Text(enabled ? 'Włączona' : 'Wyłączona'),
                value: enabled,
                onChanged: (value) =>
                    context.read<SettingsCubit>().setIntensityEnabled(value),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Definicje emocji'),
            subtitle: const Text('Poznaj opisy głównych emocji'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EmotionsDefinitionsScreen()),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Kosz'),
            subtitle: const Text('Przywracaj lub usuń trwale wpisy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TrashScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
