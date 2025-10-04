import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mindmate/src/providers/settings_provider.dart';
import 'package:mindmate/src/providers/journal_provider.dart';
import 'package:mindmate/src/providers/tasks_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Configuration Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'AI Configuration',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure AI services for enhanced features. The app works offline by default.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // API Keys
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.vpn_key_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: const Text('Gemini API Key'),
                    subtitle: Text(settings.geminiKey?.isEmpty ?? true ? 'Not configured' : 'Configured'),
                    trailing: Icon(
                      settings.geminiKey?.isNotEmpty ?? false 
                          ? Icons.check_circle 
                          : Icons.radio_button_unchecked,
                      color: settings.geminiKey?.isNotEmpty ?? false 
                          ? Colors.green 
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    onTap: () => _showApiKeyDialog(context, ref, 'Gemini', settings.geminiKey, (key) => 
                        ref.read(settingsProvider.notifier).setGeminiKey(key)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.vpn_key_outlined,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    title: const Text('Grok API Key'),
                    subtitle: Text(settings.grokKey?.isEmpty ?? true ? 'Not configured' : 'Configured'),
                    trailing: Icon(
                      settings.grokKey?.isNotEmpty ?? false 
                          ? Icons.check_circle 
                          : Icons.radio_button_unchecked,
                      color: settings.grokKey?.isNotEmpty ?? false 
                          ? Colors.green 
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    onTap: () => _showApiKeyDialog(context, ref, 'Grok', settings.grokKey, (key) => 
                        ref.read(settingsProvider.notifier).setGrokKey(key)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Security Section
            Text(
              'Security & Privacy',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: SwitchListTile(
                value: settings.biometricEnabled,
                onChanged: (v) => ref.read(settingsProvider.notifier).setBiometric(v),
                title: const Text('Biometric Lock'),
                subtitle: const Text('Use fingerprint or face recognition to secure the app'),
                secondary: Icon(
                  Icons.fingerprint,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Data Management Section
            Text(
              'Data Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.file_download_outlined,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    title: const Text('Export Data'),
                    subtitle: const Text('Export your journal entries and tasks as JSON'),
                    onTap: () => _exportData(context, ref),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_forever_outlined,
                        color: Colors.red,
                      ),
                    ),
                    title: const Text('Clear All Data'),
                    subtitle: const Text('Permanently delete all journal entries and tasks'),
                    onTap: () => _showClearDataDialog(context, ref),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // App Info Section
            Text(
              'About',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
                    Card(
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: const Text('MindMate'),
                        subtitle: const Text('Version 1.0.0\nYour AI-powered mental health companion\n\nCreated by Vignesh B S'),
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  Future<void> _showApiKeyDialog(
    BuildContext context, 
    WidgetRef ref, 
    String serviceName, 
    String? currentKey,
    Function(String) onSave,
  ) async {
    final ctrl = TextEditingController(text: currentKey ?? '');
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configure $serviceName API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Get your free API key from:\n${serviceName == 'Gemini' ? 'https://makersuite.google.com/app/apikey' : 'https://console.x.ai/'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
                hintText: 'Enter your API key...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onSave(ctrl.text.trim());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$serviceName API key saved')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final journals = ref.read(journalProvider);
      final tasks = ref.read(tasksProvider);
      
      final data = {
        'exported_at': DateTime.now().toIso8601String(),
        'journals': journals.map((e) => e.toJson()).toList(),
        'tasks': tasks.map((e) => e.toJson()).toList(),
      };
      
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      await Share.share(jsonString, subject: 'MindMate Data Export');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _showClearDataDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your journal entries and tasks. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      // Clear all data
      final journals = ref.read(journalProvider);
      final tasks = ref.read(tasksProvider);
      
      for (final journal in journals) {
        await ref.read(journalProvider.notifier).deleteEntry(journal.id);
      }
      
      for (final task in tasks) {
        await ref.read(tasksProvider.notifier).deleteTask(task.id);
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared')),
        );
      }
    }
  }
}


