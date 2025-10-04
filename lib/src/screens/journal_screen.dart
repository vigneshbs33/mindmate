import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindmate/src/providers/journal_provider.dart';
import 'package:mindmate/src/providers/app_providers.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isRecording = false;
  String _currentSentiment = 'neutral';
  String _emotionalResponse = '';
  List<String> _suggestedTasks = [];
  bool _isAnalyzing = false;
  String? _imagePath;
  String? _editingEntryId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyzeText() async {
    if (_controller.text.trim().isEmpty) return;
    
    setState(() => _isAnalyzing = true);
    
    try {
      final ai = ref.read(multiAIServiceProvider);
      _currentSentiment = await ai.analyzeSentiment(_controller.text);
      _emotionalResponse = await ai.generateInsights(_controller.text);
      _suggestedTasks = await ai.suggestTasks(_controller.text);
    } catch (e) {
      print('Analysis error: $e');
      _currentSentiment = 'neutral';
      _emotionalResponse = 'Keep reflecting and taking care of yourself.';
      _suggestedTasks = ['Take a 10-minute walk', 'Practice deep breathing', 'Write down three things you\'re grateful for'];
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _toggleRecord() async {
    if (_isRecording) {
      await ref.read(speechServiceProvider).stop();
      setState(() => _isRecording = false);
    } else {
      final speech = ref.read(speechServiceProvider);
      final success = await speech.start((text) {
        if (mounted) {
          setState(() {
            _controller.text = text;
            _isRecording = false;
          });
          _analyzeText();
        }
      });
      if (success) {
        setState(() => _isRecording = true);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _imagePath = image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _saveEntry() async {
    if (_controller.text.trim().isEmpty) return;

    // Analyze sentiment only when saving
    setState(() => _isAnalyzing = true);
    
    try {
      final ai = ref.read(multiAIServiceProvider);
      _currentSentiment = await ai.analyzeSentiment(_controller.text);
      _emotionalResponse = await ai.generateInsights(_controller.text);
      _suggestedTasks = await ai.suggestTasks(_controller.text);
    } catch (e) {
      print('Analysis error: $e');
      _currentSentiment = 'neutral';
      _emotionalResponse = 'Keep reflecting and taking care of yourself.';
      _suggestedTasks = ['Take a 10-minute walk', 'Practice deep breathing', 'Write down three things you\'re grateful for'];
    }

    if (_editingEntryId == null) {
      await ref.read(journalProvider.notifier).addEntry(
        _controller.text.trim(),
        _currentSentiment,
        imagePath: _imagePath,
      );
    } else {
      await ref.read(journalProvider.notifier).updateEntry(
        _editingEntryId!,
        _controller.text.trim(),
        _currentSentiment,
        imagePath: _imagePath,
      );
    }

    _controller.clear();
    setState(() {
      _currentSentiment = 'neutral';
      _emotionalResponse = '';
      _suggestedTasks = [];
      _imagePath = null;
      _editingEntryId = null;
      _isAnalyzing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editingEntryId == null ? 'Journal entry saved! 📝' : 'Journal entry updated')),
      );
    }
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getSentimentIcon(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Icons.sentiment_very_satisfied;
      case 'negative':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(journalProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              // Writing Section
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.edit_note,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How are you feeling today?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Image Preview
                    if (_imagePath != null) ...[
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          minHeight: 200,
                          maxHeight: 400,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb 
                            ? Image.network( // Use Image.network for web
                                _imagePath!,
                                fit: BoxFit.contain, // Changed to contain to show full image
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 200,
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.image,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    size: 48,
                                  ),
                                ),
                              )
                            : Image.file( // Use Image.file for mobile
                                File(_imagePath!),
                                fit: BoxFit.contain, // Changed to contain to show full image
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 200,
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.image,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    size: 48,
                                  ),
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Text Input with stable min height (prevents collapse on web)
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 200),
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        expands: false,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: 'Write about your day, thoughts, or feelings...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        onChanged: (text) {
                          setState(() {});
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action Buttons
                    Row(
                      children: [
                        // Voice Recording Button
                        Container(
                          decoration: BoxDecoration(
                            color: _isRecording ? Colors.red : Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: _toggleRecord,
                            icon: Icon(
                              _isRecording ? Icons.stop : Icons.mic,
                              color: _isRecording ? Colors.white : Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Image Button
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: _pickImage,
                            icon: Icon(
                              Icons.image,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Save/Update Button
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _controller.text.trim().isNotEmpty ? _saveEntry : null,
                            icon: Icon(_editingEntryId == null ? Icons.save : Icons.check),
                            label: Text(_editingEntryId == null ? 'Save Entry' : 'Update Entry'),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Analysis Section
              if (_controller.text.trim().isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (_isAnalyzing)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(
                              _getSentimentIcon(_currentSentiment),
                              color: _getSentimentColor(_currentSentiment),
                              size: 20,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            'Sentiment: ${_currentSentiment.toUpperCase()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getSentimentColor(_currentSentiment),
                            ),
                          ),
                        ],
                      ),
                      
                      if (_emotionalResponse.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _emotionalResponse,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      
                      if (_suggestedTasks.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Suggested Activities:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...(_suggestedTasks.take(3).map((task) => Padding(
                          padding: const EdgeInsets.only(left: 8, top: 2),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  task,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ))),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Recent Entries
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Entries',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    entries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.menu_book_outlined,
                                size: 48,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No entries yet',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Start writing to see your entries here',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _editingEntryId = entry.id;
                                    _controller.text = entry.text;
                                    _currentSentiment = entry.sentiment;
                                    _imagePath = entry.imagePath;
                                  });
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: _getSentimentColor(entry.sentiment).withValues(alpha: 0.2),
                                            child: Icon(
                                              _getSentimentIcon(entry.sentiment),
                                              color: _getSentimentColor(entry.sentiment),
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  entry.text.length > 80 
                                                      ? '${entry.text.substring(0, 80)}...'
                                                      : entry.text,
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: Theme.of(context).textTheme.bodyLarge,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${entry.sentiment.toUpperCase()} • ${_formatDate(entry.createdAt)}',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuButton(
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit_outlined, size: 16),
                                                    const SizedBox(width: 8),
                                                    const Text('Edit'),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                                    const SizedBox(width: 8),
                                                    const Text('Delete', style: TextStyle(color: Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            onSelected: (value) async {
                                              if (value == 'edit') {
                                                setState(() {
                                                  _editingEntryId = entry.id;
                                                  _controller.text = entry.text;
                                                  _currentSentiment = entry.sentiment;
                                                  _imagePath = entry.imagePath;
                                                });
                                              } else if (value == 'delete') {
                                                final confirmed = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Delete Entry'),
                                                    content: const Text('Are you sure you want to delete this entry?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.of(context).pop(false),
                                                        child: const Text('Cancel'),
                                                      ),
                                                      FilledButton(
                                                        onPressed: () => Navigator.of(context).pop(true),
                                                        child: const Text('Delete'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirmed == true) {
                                                  await ref.read(journalProvider.notifier).deleteEntry(entry.id);
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Entry deleted')),
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      if (entry.imagePath != null) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          width: double.infinity,
                                          constraints: const BoxConstraints(
                                            minHeight: 150,
                                            maxHeight: 300,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: kIsWeb 
                                              ? Image.network( // Use Image.network for web
                                                  entry.imagePath!,
                                                  fit: BoxFit.contain, // Changed to contain to show full image
                                                  width: double.infinity,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    height: 150,
                                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                                    child: Icon(
                                                      Icons.image,
                                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                      size: 32,
                                                    ),
                                                  ),
                                                )
                                              : Image.file( // Use Image.file for mobile
                                                  File(entry.imagePath!),
                                                  fit: BoxFit.contain, // Changed to contain to show full image
                                                  width: double.infinity,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    height: 150,
                                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                                    child: Icon(
                                                      Icons.image,
                                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                      size: 32,
                                                    ),
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
