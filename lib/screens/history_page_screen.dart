import 'package:feelings/cubbit/entry_cubbit.dart';
import 'package:feelings/emotions_data.dart';
import 'package:feelings/emotions_data_hive_entry.dart';
import 'package:feelings/main.dart';
import 'package:feelings/screens/choose_emotions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:feelings/widgets/feelings_dialog.dart';
import 'package:feelings/settings/settings_screen.dart';

class EmotionHistoryPage extends StatelessWidget {
  const EmotionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<EntryCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historia emocji"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<EntryCubit, List<EmotionEntry>>(
        bloc: cubit,
        builder: (context, state) {
          final visibleEntries = <MapEntry<int, EmotionEntry>>[];
          for (var i = 0; i < state.length; i++) {
            final entry = state[i];
            if (!entry.isDeleted) {
              visibleEntries.add(MapEntry(i, entry));
            }
          }

          visibleEntries.sort(
            (a, b) => b.value.dateTime.compareTo(a.value.dateTime),
          );

          if (visibleEntries.isEmpty) {
            return const Center(child: Text('Brak zapisanych wpisów'));
          }
          return ListView.builder(
            itemCount: visibleEntries.length,
            itemBuilder: (context, index) {
              final item = visibleEntries[index];
              final entry = item.value;
              final originalIndex = item.key;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  // title: Text(
                  //   entry.personalNote.isNotEmpty
                  //       ? entry.personalNote.split('\n').first
                  //       : (entry.title.isNotEmpty ? entry.title : 'Brak wpisuX'),
                  // ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.emotions.isNotEmpty
                            ? entry.emotions.entries.map((e) => '${e.key}: ${e.value}/6').join(', ')
                            : 'Brak wybranych emocji',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.personalNote.isNotEmpty ? entry.personalNote : 'Brak wpisuY',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_formatTime(entry.dateTime)),
                      const SizedBox(height: 4),
                      Text('${_formatDate(entry.dateTime)}, ${_weekdayName(entry.dateTime)}'),
                    ],
                  ),
                  onTap: () => _showEntryDialog(context, entry, originalIndex),
                  onLongPress: () => _confirmDelete(context, originalIndex),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEntryDialog(BuildContext context, EmotionEntry entry, int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (dialogContext) {
        return FeelingsDialog(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Wybrane emocje', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ],
                  ),
                  if (_groupEntryByMain(entry).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _groupEntryByMain(entry).entries.map((group) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(group.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: group.value.map((emotion) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        style:
                                            ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                        onPressed: null,
                                        child: Text(
                                          emotion.key,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      _buildIntensityDots(emotion.value),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text('Brak wybranych emocji'),
                    ),
                  const SizedBox(height: 12),
                  const Text(
                    'Notatka dla siebie',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.personalNote.isNotEmpty ? entry.personalNote : 'Brak wpisu',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _confirmDelete(context, index);
                        },
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EmotionSelectPage(
                                initialSelection: Map<String, int>.from(entry.emotions),
                                entryIndex: index,
                                initialNote: entry.situationDescription,
                                initialPersonalNote: entry.personalNote,
                              ),
                            ),
                          );
                        },
                        child: const Text('Edytuj'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Zamknij'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (dialogContext) {
        return FeelingsDialog(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Przenieść wpis do kosza?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text('Wpis zostanie oznaczony jako usunięty i trafi do kosza.'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Anuluj'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        await getIt<EntryCubit>().deleteToTrash(index);
                        if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                      },
                      child: const Text('Przenieś do kosza'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIntensityDots(int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(6, (i) {
        final dotValue = i + 1;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: value >= dotValue ? Colors.blue : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';

  String _weekdayName(DateTime dt) {
    const names = [
      'poniedziałek',
      'wtorek',
      'środa',
      'czwartek',
      'piątek',
      'sobota',
      'niedziela',
    ];
    return names[(dt.weekday - 1) % 7];
  }

  Map<String, List<MapEntry<String, int>>> _groupEntryByMain(EmotionEntry entry) {
    final Map<String, String> subToMain = {};
    for (final main in mainEmotions) {
      for (final sub in main.subEmotions) {
        subToMain[sub] = main.name;
      }
    }

    final Map<String, List<MapEntry<String, int>>> grouped = {};
    entry.emotions.forEach((sub, value) {
      final main = subToMain[sub] ?? 'Inne';
      grouped.putIfAbsent(main, () => []);
      grouped[main]!.add(MapEntry(sub, value));
    });
    return grouped;
  }
}
