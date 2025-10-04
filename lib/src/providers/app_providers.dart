import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/hive_service.dart';
import '../services/multi_ai_service.dart';
import '../services/notification_service.dart';
import '../services/speech_service.dart';
import 'settings_provider.dart';

final tabIndexProvider = StateProvider<int>((ref) => 0);

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final hiveServiceProvider = Provider<HiveService>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return HiveService(storage);
});

final multiAIServiceProvider = Provider<MultiAIService>((ref) {
  final settings = ref.watch(settingsProvider);
  return MultiAIService(
    geminiKey: settings.geminiKey,
    grokKey: settings.grokKey,
  );
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final speechServiceProvider = Provider<SpeechService>((ref) {
  return SpeechService();
});


