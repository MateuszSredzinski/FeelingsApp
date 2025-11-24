// lib/cubit/entry_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:feelings/emotions_data_hive_entry.dart';
import 'package:feelings/entry_repo.dart';


class EntryCubit extends Cubit<List<EmotionEntry>> {
  final EntryRepository repository;
  EntryCubit(this.repository) : super([]);

  Future<void> load() async {
    final list = repository.getAll();
    emit(list);
  }

  Future<void> add(Map<String, int> emotions, {String title = ''}) async {
    final entry = EmotionEntry(dateTime: DateTime.now(), title: title, emotions: Map.from(emotions));
    await repository.addEntry(entry);
    await load();
  }

  Future<void> update(int index, Map<String, int> emotions, {String? title}) async {
    final current = state[index];
    final updated = EmotionEntry(
      dateTime: current.dateTime,
      title: title ?? current.title,
      emotions: Map.from(emotions),
    );
    await repository.updateEntry(index, updated);
    await load();
  }
}
