// lib/data/entry_repository.dart
import 'package:hive/hive.dart';
import 'emotions_data_hive_entry.dart';

class EntryRepository {
  final Box box;

  EntryRepository(this.box);

  Future<void> addEntry(EmotionEntry entry) async {
    try {
      await box.add(entry);
    } catch (e) {
      throw Exception('Failed to add entry: $e');
    }
  }

  Future<void> updateEntry(int index, EmotionEntry entry) async {
    try {
      await box.putAt(index, entry);
      await box.compact();
    } catch (e) {
      throw Exception('Failed to update entry: $e');
    }
  }

  Future<void> deleteEntry(int index) async {
    try {
      await box.deleteAt(index);
      await box.compact();
    } catch (e) {
      throw Exception('Failed to delete entry: $e');
    }
  }

  List<EmotionEntry> getAll() {
    try {
      return box.values.whereType<EmotionEntry>().toList();
    } catch (e) {
      throw Exception('Failed to read entries: $e');
    }
  }

  Future<void> clearAll() async {
    await box.clear();
  }
}
