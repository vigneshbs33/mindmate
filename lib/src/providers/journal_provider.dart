import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:mindmate/src/models/journal_entry.dart';
import 'package:mindmate/src/services/hive_service.dart';
import 'package:mindmate/src/providers/app_providers.dart';
import 'package:mindmate/src/providers/tasks_provider.dart';

final journalProvider = StateNotifierProvider<JournalController, List<JournalEntry>>((ref) {
  final hive = ref.watch(hiveServiceProvider);
  return JournalController(hive, ref);
});

class JournalController extends StateNotifier<List<JournalEntry>> {
  JournalController(this._hive, this._ref) : super([]) {
    _load();
  }

  final HiveService _hive;
  final Ref _ref;
  static const _uuid = Uuid();

  void _load() {
    final box = _hive.journalBox;
    state = box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addEntry(String text, String sentiment, {String? imagePath, String? audioPath}) async {
    final entry = JournalEntry(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      text: text,
      imagePath: imagePath,
      audioPath: audioPath,
      sentiment: sentiment,
    );
    await _hive.journalBox.put(entry.id, entry);
    _load();
    
    // Auto-create tasks based on journal content
    await _createAutoTasks(text, sentiment);
  }

  Future<void> _createAutoTasks(String text, String sentiment) async {
    try {
      final ai = _ref.read(multiAIServiceProvider);
      final suggestions = await ai.suggestTasks(text);
      
      // Create tasks for the first 2 suggestions
      final tasksController = _ref.read(tasksProvider.notifier);
      for (int i = 0; i < suggestions.length && i < 2; i++) {
        final suggestion = suggestions[i];
        final dueDate = DateTime.now().add(Duration(hours: (i + 1) * 6)); // Spread tasks over the day
        
        await tasksController.addTask(
          suggestion,
          dueDate,
          remind: true,
        );
      }
    } catch (e) {
      print('Auto task creation failed: $e');
      // Don't show error to user, just fail silently
    }
  }

  Future<void> deleteEntry(String id) async {
    await _hive.journalBox.delete(id);
    _load();
  }

  Future<void> updateEntry(String id, String text, String sentiment, {String? imagePath, String? audioPath}) async {
    final existing = _hive.journalBox.get(id);
    if (existing == null) return;
    final updated = existing.copyWith(
      text: text,
      sentiment: sentiment,
      imagePath: imagePath,
      audioPath: audioPath,
    );
    await _hive.journalBox.put(id, updated);
    _load();
  }
}


