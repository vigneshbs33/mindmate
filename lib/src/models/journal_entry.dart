import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class JournalEntry {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime createdAt;
  @HiveField(2)
  final String text;
  @HiveField(3)
  final String? imagePath;
  @HiveField(4)
  final String? audioPath;
  @HiveField(5)
  final String sentiment; // positive, negative, neutral

  const JournalEntry({
    required this.id,
    required this.createdAt,
    required this.text,
    this.imagePath,
    this.audioPath,
    this.sentiment = 'neutral',
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) => _$JournalEntryFromJson(json);
  Map<String, dynamic> toJson() => _$JournalEntryToJson(this);

  JournalEntry copyWith({
    String? id,
    DateTime? createdAt,
    String? text,
    String? imagePath,
    String? audioPath,
    String? sentiment,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
      sentiment: sentiment ?? this.sentiment,
    );
  }
}


