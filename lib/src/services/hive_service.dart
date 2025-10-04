import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/journal_entry.dart';
import '../models/task_item.dart';

class HiveService {
  HiveService(this._secureStorage);
  final FlutterSecureStorage _secureStorage;

  static const String _encryptionKeyName = 'hive_key_mindmate';
  static const String journalBoxName = 'journal_entries';
  static const String tasksBoxName = 'tasks';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(JournalEntryAdapter());
    Hive.registerAdapter(TaskItemAdapter());

    final key = await _getOrCreateEncryptionKey();
    await Hive.openBox<JournalEntry>(journalBoxName,
        encryptionCipher: HiveAesCipher(key));
    await Hive.openBox<TaskItem>(tasksBoxName, encryptionCipher: HiveAesCipher(key));
  }

  Future<Uint8List> _getOrCreateEncryptionKey() async {
    final existing = await _secureStorage.read(key: _encryptionKeyName);
    if (existing != null) {
      return Uint8List.fromList(existing.split(',').map(int.parse).toList());
    }
    final key = Hive.generateSecureKey();
    await _secureStorage.write(key: _encryptionKeyName, value: key.join(','));
    return Uint8List.fromList(key);
  }

  Box<JournalEntry> get journalBox => Hive.box<JournalEntry>(journalBoxName);
  Box<TaskItem> get tasksBox => Hive.box<TaskItem>(tasksBoxName);
}


