// lib/models/emotion_entry.dart
import 'package:hive/hive.dart';
//part 'emotion_entry.g.dart'; // nie generujemy - ale zostawimy tak, w razie chęci generowania; niekonieczne

class EmotionEntry {
  String title;
  DateTime dateTime;
  DateTime? editedAt;
  Map<String, int> subEmotionIntensity;
  String situationDescription;
  String personalNote;
  bool isDeleted;
  DateTime? deletedAt;

  EmotionEntry({
    required this.dateTime,
    this.editedAt,
    this.title = '',
    required this.subEmotionIntensity,
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
    final rest = <dynamic>[];
    while (reader.availableBytes > 0) {
      rest.add(reader.read());
    }

    DateTime? editedAt;
    Map legacyEmotionsDynamic = {};
    String situationDescription = '';
    String personalNote = '';
    bool isDeleted = false;
    DateTime? deletedAt;
    Map subIntensityDynamic = {};

    // Format history:
    // v1: title, dateTime, editedAt, emotions(1-6), situation, note, isDeleted, deletedAt
    // v2: title, dateTime, editedAt, {}, situation, note, isDeleted, deletedAt, subEmotionIntensity(0-4)
    if (rest.length >= 6) {
      editedAt = rest[0] is DateTime ? rest[0] as DateTime : null;
      legacyEmotionsDynamic = rest[1] is Map ? rest[1] as Map : {};
      situationDescription = rest[2] is String ? rest[2] as String : '';
      personalNote = rest[3] is String ? rest[3] as String : '';
      isDeleted = rest[4] is bool ? rest[4] as bool : false;
      deletedAt = rest[5] is DateTime ? rest[5] as DateTime : null;
      if (rest.length >= 7 && rest[6] is Map) {
        subIntensityDynamic = rest[6] as Map;
      }
    } else {
      for (final v in rest) {
        if (v is DateTime && editedAt == null) {
          editedAt = v;
          continue;
        }
        if (v is Map && legacyEmotionsDynamic.isEmpty) {
          legacyEmotionsDynamic = v;
          continue;
        }
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
      }
    }

    Map<String, int> subEmotionIntensity = {};
    if (subIntensityDynamic.isNotEmpty) {
      subEmotionIntensity = Map<String, int>.from(
        subIntensityDynamic.map(
          (k, v) => MapEntry(k as String, _sanitizeIntensity(v)),
        ),
      );
    } else if (legacyEmotionsDynamic.isNotEmpty) {
      subEmotionIntensity = Map<String, int>.from(
        legacyEmotionsDynamic.map((k, v) => MapEntry(k as String, 0)),
      );
    }
    return EmotionEntry(
      title: title,
      dateTime: dateTime,
      editedAt: editedAt,
      subEmotionIntensity: subEmotionIntensity,
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
      ..write(<String, int>{})
      ..write(obj.situationDescription)
      ..write(obj.personalNote)
      ..write(obj.isDeleted)
      ..write(obj.deletedAt)
      ..write(obj.subEmotionIntensity);
  }

  int _sanitizeIntensity(dynamic value) {
    if (value is int && value >= 1 && value <= 4) {
      return value;
    }
    return 0;
  }
}
