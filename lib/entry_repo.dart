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

  Future<void> markDeleted(int index) async {
    try {
      final entry = box.getAt(index) as EmotionEntry?;
      if (entry == null) return;
      final updated = EmotionEntry(
        dateTime: entry.dateTime,
        title: entry.title,
        situationDescription: entry.situationDescription,
        personalNote: entry.personalNote,
        emotions: Map<String, int>.from(entry.emotions),
        isDeleted: true,
        deletedAt: DateTime.now(),
      );
      await updateEntry(index, updated);
    } catch (e) {
      throw Exception('Failed to delete entry: $e');
    }
  }

  Future<void> restoreEntry(int index) async {
    try {
      final entry = box.getAt(index) as EmotionEntry?;
      if (entry == null) return;
      final updated = EmotionEntry(
        dateTime: entry.dateTime,
        title: entry.title,
        situationDescription: entry.situationDescription,
        personalNote: entry.personalNote,
        emotions: Map<String, int>.from(entry.emotions),
        isDeleted: false,
        deletedAt: null,
      );
      await updateEntry(index, updated);
    } catch (e) {
      throw Exception('Failed to restore entry: $e');
    }
  }

  Future<void> deleteForever(int index) async {
    try {
      await box.deleteAt(index);
      await box.compact();
    } catch (e) {
      throw Exception('Failed to delete permanently: $e');
    }
  }

  List<EmotionEntry> getAll() {
    try {
      return box.values.whereType<EmotionEntry>().toList();
    } catch (e) {
      throw Exception('Failed to read entries: $e');
    }
  }

  Future<void> cleanupTrash() async {
    final threshold = DateTime.now().subtract(const Duration(days: 30));
    final toDelete = <int>[];
    for (var i = 0; i < box.length; i++) {
      final entry = box.getAt(i);
      if (entry is EmotionEntry &&
          entry.isDeleted &&
          entry.deletedAt != null &&
          entry.deletedAt!.isBefore(threshold)) {
        toDelete.add(i);
      }
    }
    // delete from end to keep indices valid
    for (final idx in toDelete.reversed) {
      await deleteForever(idx);
    }
  }

  Future<void> clearAll() async {
    await box.clear();
  }
}
