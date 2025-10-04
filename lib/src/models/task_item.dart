import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_item.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class TaskItem {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? note;
  @HiveField(3)
  final DateTime dueAt;
  @HiveField(4)
  final bool done;
  @HiveField(5)
  final bool remind;

  const TaskItem({
    required this.id,
    required this.title,
    this.note,
    required this.dueAt,
    this.done = false,
    this.remind = false,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) => _$TaskItemFromJson(json);
  Map<String, dynamic> toJson() => _$TaskItemToJson(this);

  TaskItem copyWith({
    String? id,
    String? title,
    String? note,
    DateTime? dueAt,
    bool? done,
    bool? remind,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      dueAt: dueAt ?? this.dueAt,
      done: done ?? this.done,
      remind: remind ?? this.remind,
    );
  }
}


