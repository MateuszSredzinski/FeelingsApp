// lib/models/emotion_entry.dart
import 'package:hive/hive.dart';


//part 'emotion_entry.g.dart'; // nie generujemy - ale zostawimy tak, w razie chęci generowania; niekonieczne

class EmotionEntry {
  String title;
  String situationDescription;
  String personalNote;
  DateTime dateTime;
  Map<String, int> emotions;
  bool isDeleted;
  DateTime? deletedAt;

  EmotionEntry({
    required this.dateTime,
    this.title = '',
    this.situationDescription = '',
    this.personalNote = '',
    this.isDeleted = false,
    this.deletedAt,
    required this.emotions,
  });
}

// Ręczny adapter (typeId = 0)
class EmotionEntryAdapter extends TypeAdapter<EmotionEntry> {
  @override
  final int typeId = 0;

  @override
  EmotionEntry read(BinaryReader reader) {
    final title = reader.read();
    final dateTime = reader.read() as DateTime;
    final emotionsDynamic = reader.read() as Map;

    // wartości domyślne dla kompatybilności ze starymi zapisami
    bool isDeleted = false;
    DateTime? deletedAt;
    String situationDescription = '';
    String personalNote = '';

    if (reader.availableBytes > 0) {
      try {
        isDeleted = reader.read() as bool;
        deletedAt = reader.read() as DateTime?;
        situationDescription = reader.read() as String? ?? '';
        personalNote = reader.read() as String? ?? '';
      } catch (_) {
        // zachowaj wartości domyślne, jeśli stary format nie zawiera pól
      }
    }

    final emotions = Map<String, int>.from(emotionsDynamic.map((k, v) => MapEntry(k as String, v as int)));
    return EmotionEntry(
      title: title as String,
      dateTime: dateTime,
      emotions: emotions,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      situationDescription: situationDescription,
      personalNote: personalNote,
    );
  }

  @override
  void write(BinaryWriter writer, EmotionEntry obj) {
    writer.write(obj.title);
    writer.write(obj.dateTime);
    writer.write(obj.emotions);
    writer.write(obj.isDeleted);
    writer.write(obj.deletedAt);
    writer.write(obj.situationDescription);
    writer.write(obj.personalNote);
  }
}
