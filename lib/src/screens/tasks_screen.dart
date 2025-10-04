import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mindmate/src/providers/tasks_provider.dart';
import 'package:mindmate/src/providers/journal_provider.dart';
import 'package:mindmate/src/providers/settings_provider.dart';
import 'package:mindmate/src/providers/app_providers.dart';
import 'package:mindmate/src/models/task_item.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String _selectedFilter = 'all';
  bool _showBulkBar = false;

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);
    _showBulkBar = tasks.any((t) => t.done);
    final journals = ref.watch(journalProvider);
    
    // Filter tasks based on selection
    List<TaskItem> filteredTasks = tasks;
    switch (_selectedFilter) {
      case 'pending':
        filteredTasks = tasks.where((t) => !t.done).toList();
        break;
      case 'completed':
        filteredTasks = tasks.where((t) => t.done).toList();
        break;
      case 'today':
        final today = DateTime.now();
        filteredTasks = tasks.where((t) => 
          t.dueAt.year == today.year && 
          t.dueAt.month == today.month && 
          t.dueAt.day == today.day
        ).toList();
        break;
    }

    // Sort tasks by due date
    filteredTasks.sort((a, b) => a.dueAt.compareTo(b.dueAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _selectedFilter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Tasks')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
              const PopupMenuItem(value: 'today', child: Text('Today')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                Icons.filter_list,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showBulkBar)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.select_all, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tasks selected: ${tasks.where((t) => t.done).length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Selected Tasks'),
                          content: const Text('Delete all completed (checked) tasks?'),
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
                        await ref.read(tasksProvider.notifier).deleteCompletedTasks();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Selected tasks deleted')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete selected'),
                  ),
                ],
              ),
            ),
          // Quick Stats
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total',
                    tasks.length.toString(),
                    Icons.assignment,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Pending',
                    tasks.where((t) => !t.done).length.toString(),
                    Icons.pending,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Completed',
                    tasks.where((t) => t.done).length.toString(),
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
          ),

          // AI Suggestions Section
          if (journals.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Smart Suggestions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _showAISuggestions(context, ref),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Generate'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Based on your recent journal entries, I can suggest personalized tasks to help you stay on track.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Tasks List
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.checklist_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'all' ? 'No tasks yet' : 'No $_selectedFilter tasks',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first task',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return _buildTaskCard(context, ref, task);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTask(context, ref),
        icon: const Icon(Icons.add_task),
        label: const Text('Add Task'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, TaskItem task) {
    final isOverdue = task.dueAt.isBefore(DateTime.now()) && !task.done;
    final isToday = task.dueAt.day == DateTime.now().day &&
        task.dueAt.month == DateTime.now().month &&
        task.dueAt.year == DateTime.now().year;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isOverdue 
          ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3)
          : isToday 
              ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
      child: CheckboxListTile(
        value: task.done,
        onChanged: (value) => ref.read(tasksProvider.notifier).toggleDone(task.id),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.done ? TextDecoration.lineThrough : null,
            color: task.done 
                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: isOverdue 
                      ? Theme.of(context).colorScheme.error
                      : isToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy • HH:mm').format(task.dueAt),
                  style: TextStyle(
                    color: isOverdue 
                        ? Theme.of(context).colorScheme.error
                        : isToday
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: isOverdue || isToday ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
            if (task.remind) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Reminder set',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        secondary: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOverdue && !task.done)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'OVERDUE',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isToday && !task.done)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'TODAY',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDeleteTask(context, ref, task),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteTask(BuildContext context, WidgetRef ref, TaskItem task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
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
      ref.read(tasksProvider.notifier).deleteTask(task.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted')),
        );
      }
    }
  }

  Future<void> _showAISuggestions(BuildContext context, WidgetRef ref) async {
    final journals = ref.read(journalProvider);
    if (journals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write some journal entries first to get AI suggestions')),
      );
      return;
    }

    final settings = ref.read(settingsProvider);
    if (settings.geminiKey?.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add your Gemini API key in Settings to get AI suggestions')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Generating AI suggestions...'),
          ],
        ),
      ),
    );

    try {
      final ai = ref.read(multiAIServiceProvider);
      final recentJournal = journals.first.text;
      final suggestions = await ai.suggestTasks(recentJournal);
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('AI Task Suggestions'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: suggestions.map((suggestion) => ListTile(
                leading: const Icon(Icons.lightbulb_outline),
                title: Text(suggestion),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddTaskWithSuggestion(context, ref, suggestion);
                },
              )).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate suggestions: $e')),
        );
      }
    }
  }

  Future<void> _showAddTaskWithSuggestion(BuildContext context, WidgetRef ref, String suggestion) async {
    final titleCtrl = TextEditingController(text: suggestion);
    DateTime dueAt = DateTime.now().add(const Duration(hours: 1));
    bool remind = false;
    
    await _showAddTaskDialog(context, ref, titleCtrl, dueAt, remind);
  }

  Future<void> _showAddTask(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController();
    DateTime dueAt = DateTime.now().add(const Duration(hours: 1));
    bool remind = false;
    
    await _showAddTaskDialog(context, ref, titleCtrl, dueAt, remind);
  }

  Future<void> _showAddTaskDialog(BuildContext context, WidgetRef ref, TextEditingController titleCtrl, DateTime dueAt, bool remind) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add New Task',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                  hintText: 'What needs to be done?',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        DateFormat('MMM dd, yyyy • HH:mm').format(dueAt),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: ctx,
                          initialDate: dueAt,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date == null) return;
                        final time = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.fromDateTime(dueAt),
                        );
                        if (time == null) return;
                        setState(() {
                          dueAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Set Reminder'),
                subtitle: const Text('Get notified when task is due'),
                value: remind,
                onChanged: (value) => setState(() => remind = value),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    await ref.read(tasksProvider.notifier).addTask(
                      titleCtrl.text.trim(),
                      dueAt,
                      remind: remind,
                    );
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Save Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
