import 'package:feelings/cubbit/entry_cubbit.dart';
import 'package:feelings/emotions_data_hive_entry.dart';
import 'package:feelings/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmotionHistoryPage extends StatelessWidget {
  const EmotionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<EntryCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text("Historia emocji")),
      body: BlocBuilder<EntryCubit, List<dynamic>>(
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
