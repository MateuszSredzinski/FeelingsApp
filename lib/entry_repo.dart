// lib/data/entry_repository.dart
import 'package:hive/hive.dart';
import 'emotions_data_hive_entry.dart';

class EntryRepository {
  final Box box;

  EntryRepository(this.box);

  Future<void> addEntry(EmotionEntry entry) async {
    await box.add(entry);
  }

  List<EmotionEntry> getAll() {
    return box.values.map((e) => e as EmotionEntry).toList();
  }

  Future<void> clearAll() async {
    await box.clear();
  }
}
