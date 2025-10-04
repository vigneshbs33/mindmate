import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindmate/src/models/journal_entry.dart';
import 'package:mindmate/src/providers/journal_provider.dart';
import 'package:mindmate/src/providers/settings_provider.dart';
import 'package:mindmate/src/providers/app_providers.dart';

class WeeklyInsight {
  final Map<DateTime, int> moodScorePerDay; // -1 neg, 0 neutral, +1 pos
  final String suggestions;
  const WeeklyInsight({required this.moodScorePerDay, required this.suggestions});
}

final insightsProvider = FutureProvider<WeeklyInsight>((ref) async {
  final entries = ref.watch(journalProvider);
  final ai = ref.read(multiAIServiceProvider);
  final week = _entriesForLast7Days(entries);
  final moodMap = <DateTime, int>{};
  for (final e in week) {
    moodMap[DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day)] = _score(e.sentiment);
  }
  String suggestions = 'Add more entries to get insights.';
  if (week.isNotEmpty) {
    try {
      suggestions = await ai.checkWellbeing(week.map((e) => e.text).toList());
    } catch (e) {
      suggestions = 'Keep writing in your journal to track your wellbeing journey.';
    }
  }
  return WeeklyInsight(moodScorePerDay: moodMap, suggestions: suggestions);
});

List<JournalEntry> _entriesForLast7Days(List<JournalEntry> entries) {
  final now = DateTime.now();
  final sevenDaysAgo = now.subtract(const Duration(days: 6));
  return entries.where((e) => e.createdAt.isAfter(DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day))).toList();
}

int _score(String s) {
  switch (s) {
    case 'positive':
      return 1;
    case 'negative':
      return -1;
    default:
      return 0;
  }
}


