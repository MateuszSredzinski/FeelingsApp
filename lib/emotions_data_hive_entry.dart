// lib/models/emotion_entry.dart
import 'package:hive/hive.dart';


//part 'emotion_entry.g.dart'; // nie generujemy - ale zostawimy tak, w razie chęci generowania; niekonieczne

class EmotionEntry {
  String title;
  DateTime dateTime;
  DateTime? editedAt;
  Map<String, int> emotions;
  String situationDescription;
  String personalNote;
  bool isDeleted;
  DateTime? deletedAt;

  EmotionEntry({
    required this.dateTime,
    this.editedAt,
    this.title = '',
    required this.emotions,
    this.situationDescription = '',
    this.personalNote = '',
    this.isDeleted = false,
    this.deletedAt,
  });
}

// Ręczny adapter (typeId = 0)
class EmotionEntryAdapter extends TypeAdapter<EmotionEntry> {
  @override
  final int typeId = 0;

  @override
  EmotionEntry read(BinaryReader reader) {
    final title = reader.read() as String;
    final dateTime = reader.read() as DateTime;
    final third = reader.read();

    DateTime? editedAt;
    late Map emotionsDynamic;
    if (third is DateTime) {
      editedAt = third;
      emotionsDynamic = reader.read() as Map;
    } else {
      emotionsDynamic = third as Map;
    }

    String situationDescription = '';
    String personalNote = '';
    bool isDeleted = false;
    DateTime? deletedAt;

    // Czytanie elastyczne: wspiera starszą kolejność pól.
    final remaining = <dynamic>[];
    while (reader.availableBytes > 0) {
      remaining.add(reader.read());
    }
    for (final v in remaining) {
      if (v is String && situationDescription.isEmpty) {
        situationDescription = v;
        continue;
      }
      if (v is String && personalNote.isEmpty) {
        personalNote = v;
        continue;
      }
      if (v is bool && !isDeleted) {
        isDeleted = v;
        continue;
      }
      if (v is DateTime && deletedAt == null) {
        deletedAt = v;
        continue;
      }
      if (v is DateTime && editedAt == null) {
        editedAt = v;
        continue;
      }
    }

    final emotions = Map<String, int>.from(emotionsDynamic.map((k, v) => MapEntry(k as String, v as int)));
    return EmotionEntry(
      title: title,
      dateTime: dateTime,
      editedAt: editedAt,
      emotions: emotions,
      situationDescription: situationDescription,
      personalNote: personalNote,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
    );
  }

  @override
  void write(BinaryWriter writer, EmotionEntry obj) {
    writer
      ..write(obj.title)
      ..write(obj.dateTime)
      ..write(obj.editedAt)
      ..write(obj.emotions)
      ..write(obj.situationDescription)
      ..write(obj.personalNote)
      ..write(obj.isDeleted)
      ..write(obj.deletedAt);
  }
}
