import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:feelings/cubbit/entry_cubbit.dart';
import 'package:feelings/emotions_data_hive_entry.dart';
import 'package:feelings/main.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<EntryCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Kosz')),
      body: BlocBuilder<EntryCubit, List<EmotionEntry>>(
        bloc: cubit,
        builder: (context, state) {
          final trashed = <MapEntry<int, EmotionEntry>>[];
          for (var i = 0; i < state.length; i++) {
            final entry = state[i];
            if (entry.isDeleted) {
              trashed.add(MapEntry(i, entry));
            }
          }

          trashed.sort((a, b) => b.value.dateTime.compareTo(a.value.dateTime));

          if (trashed.isEmpty) {
            return const Center(child: Text('Kosz jest pusty'));
          }
          return ListView.builder(
            itemCount: trashed.length,
            itemBuilder: (context, index) {
              final item = trashed[index];
              final entry = item.value;
              final originalIndex = item.key;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(entry.title.isEmpty ? 'Bez tytułu' : entry.title),
                  subtitle: Text(
                    '${entry.emotions.keys.join(', ')}\n${_formatDate(entry.dateTime)} ${_formatTime(entry.dateTime)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.restore),
                        onPressed: () async {
                          await cubit.restore(originalIndex);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever),
                        onPressed: () async {
                          await cubit.deleteForever(originalIndex);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

String _formatTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

String _formatDate(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
