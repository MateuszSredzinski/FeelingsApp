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

  Future<void> addEntry(EmotionEntry entry) async {
    await repository.addEntry(entry);
    await load();
  }

  Future<void> update(
    int index,
    Map<String, int> emotions, {
    String? title,
    String? situationDescription,
    String? personalNote,
  }) async {
    final current = state[index];
    final updated = EmotionEntry(
      dateTime: current.dateTime,
      editedAt: DateTime.now(),
      title: title ?? current.title,
      situationDescription: situationDescription ?? current.situationDescription,
      personalNote: personalNote ?? current.personalNote,
      emotions: Map.from(emotions),
      isDeleted: current.isDeleted,
      deletedAt: current.deletedAt,
    );
    await repository.updateEntry(index, updated);
    await load();
  }

  Future<void> deleteToTrash(int index) async {
    final current = state[index];
    final updated = EmotionEntry(
      dateTime: current.dateTime,
      editedAt: current.editedAt,
      title: current.title,
      situationDescription: current.situationDescription,
      personalNote: current.personalNote,
      emotions: Map.from(current.emotions),
      isDeleted: true,
      deletedAt: DateTime.now(),
    );
    await repository.updateEntry(index, updated);
    await load();
  }

  Future<void> restore(int index) async {
    final current = state[index];
    final updated = EmotionEntry(
      dateTime: current.dateTime,
      editedAt: current.editedAt,
      title: current.title,
      situationDescription: current.situationDescription,
      personalNote: current.personalNote,
      emotions: Map.from(current.emotions),
      isDeleted: false,
      deletedAt: null,
    );
    await repository.updateEntry(index, updated);
    await load();
  }

  Future<void> deleteForever(int index) async {
    await repository.deleteEntry(index);
    await load();
  }
}
