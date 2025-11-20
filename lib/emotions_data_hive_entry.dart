// lib/models/emotion_entry.dart
import 'package:hive/hive.dart';


//part 'emotion_entry.g.dart'; // nie generujemy - ale zostawimy tak, w razie chęci generowania; niekonieczne

class EmotionEntry {
  String title;
  DateTime dateTime;
  Map<String, int> emotions;

  EmotionEntry({required this.dateTime, this.title = '', required this.emotions});
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
    final emotions = Map<String, int>.from(emotionsDynamic.map((k, v) => MapEntry(k as String, v as int)));
    return EmotionEntry(title: title as String, dateTime: dateTime, emotions: emotions);
  }

  @override
  void write(BinaryWriter writer, EmotionEntry obj) {
    writer.write(obj.title);
    writer.write(obj.dateTime);
    writer.write(obj.emotions);
  }
}
