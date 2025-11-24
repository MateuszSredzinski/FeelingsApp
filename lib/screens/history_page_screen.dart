import 'package:feelings/cubbit/entry_cubbit.dart';
import 'package:feelings/emotions_data_hive_entry.dart';
import 'package:feelings/main.dart';
import 'package:feelings/screens/choose_emotions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmotionHistoryPage extends StatelessWidget {
  const EmotionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<EntryCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text("Historia emocji")),
      body: BlocBuilder<EntryCubit, List<EmotionEntry>>(
        bloc: cubit,
        builder: (context, state) {
          if (state.isEmpty) {
            return const Center(child: Text('Brak zapisanych wpisów'));
          }
          return ListView.builder(
            itemCount: state.length,
            itemBuilder: (context, index) {
              final entry = state[index] as EmotionEntry;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(entry.title.isEmpty ? "Bez tytułu" : entry.title),
                  subtitle:
                      Text(entry.emotions.entries.map((e) => '${e.key}: ${e.value}/6').join(', ')),
                  trailing: Text(
                    '${entry.dateTime.hour.toString().padLeft(2, '0')}:${entry.dateTime.minute.toString().padLeft(2, '0')}',
                  ),
                  onTap: () => _showEntryDialog(context, entry, index),
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
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Wybrane emocje',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.emotions.entries.map((emotion) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Zamknij'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EmotionSelectPage(
                                initialSelection: Map<String, int>.from(entry.emotions),
                                entryIndex: index,
                              ),
                            ),
                          );
                        },
                        child: const Text('Edytuj'),
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
}
