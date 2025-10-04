import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mindmate/src/providers/app_providers.dart';
import 'package:mindmate/src/providers/journal_provider.dart';
import 'package:mindmate/src/providers/tasks_provider.dart';

class AppSettings {
  final String? geminiKey;
  final String? grokKey;
  final bool biometricEnabled;
  const AppSettings({
    this.geminiKey, 
    this.grokKey,
    this.biometricEnabled = false,
  });

  AppSettings copyWith({
    String? geminiKey, 
    String? grokKey,
    bool? biometricEnabled,
  }) => AppSettings(
        geminiKey: geminiKey ?? this.geminiKey,
        grokKey: grokKey ?? this.grokKey,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      );
}

final settingsProvider = StateNotifierProvider<SettingsController, AppSettings>((ref) {
  const storage = FlutterSecureStorage();
  return SettingsController(storage, ref);
});

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._storage, this._ref) : super(const AppSettings()) {
    _load();
  }

  final FlutterSecureStorage _storage;
  final Ref _ref;
  static const _keyGemini = 'gemini_api_key';
  static const _keyGrok = 'grok_api_key';
  static const _keyBiometric = 'biometric_enabled';

  Future<void> _load() async {
    final geminiKey = await _storage.read(key: _keyGemini);
    final grokKey = await _storage.read(key: _keyGrok);
    final biometric = await _storage.read(key: _keyBiometric);
    state = AppSettings(
      geminiKey: geminiKey,
      grokKey: grokKey,
      biometricEnabled: biometric == 'true',
    );
  }

  Future<void> setGeminiKey(String key) async {
    await _storage.write(key: _keyGemini, value: key);
    state = state.copyWith(geminiKey: key);
    
    // Analyze previous journal entries with new API key
    await _analyzePreviousEntries();
  }

  Future<void> setGrokKey(String key) async {
    await _storage.write(key: _keyGrok, value: key);
    state = state.copyWith(grokKey: key);
    
    // Analyze previous journal entries with new API key
    await _analyzePreviousEntries();
  }

  Future<void> _analyzePreviousEntries() async {
    try {
      final journals = _ref.read(journalProvider);
      if (journals.isEmpty) return;
      
      final ai = _ref.read(multiAIServiceProvider);
      
      // Analyze the last 10 entries that don't have AI analysis
      final entriesToAnalyze = journals.take(10).where((entry) => 
        entry.text.isNotEmpty && 
        (entry.sentiment == 'neutral' || entry.text.length > 50)
      ).toList();
      
      for (final entry in entriesToAnalyze) {
        try {
          final newSentiment = await ai.analyzeSentiment(entry.text);
          final insights = await ai.generateInsights(entry.text);
          final tasks = await ai.suggestTasks(entry.text);
          
          // Update the entry with new analysis
          await _ref.read(journalProvider.notifier).updateEntry(
            entry.id,
            entry.text,
            newSentiment,
            imagePath: entry.imagePath,
            audioPath: entry.audioPath,
          );
          
          // Create tasks from suggestions
          final tasksController = _ref.read(tasksProvider.notifier);
          for (int i = 0; i < tasks.length && i < 2; i++) {
            final task = tasks[i];
            final dueDate = DateTime.now().add(Duration(hours: (i + 1) * 6));
            await tasksController.addTask(task, dueDate, remind: true);
          }
        } catch (e) {
          print('Failed to analyze entry ${entry.id}: $e');
          // Continue with other entries
        }
      }
    } catch (e) {
      print('Failed to analyze previous entries: $e');
    }
  }

  Future<void> setBiometric(bool enabled) async {
    await _storage.write(key: _keyBiometric, value: enabled.toString());
    state = state.copyWith(biometricEnabled: enabled);
  }
}


