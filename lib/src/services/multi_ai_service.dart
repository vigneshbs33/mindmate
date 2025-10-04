import 'dart:convert';
import 'package:http/http.dart' as http;

enum AIProvider { gemini, grok, offline }

class MultiAIService {
  MultiAIService({
    this.geminiKey,
    this.grokKey,
  });

  final String? geminiKey;
  final String? grokKey;

  static const String _geminiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  static const String _grokEndpoint = 'https://api.x.ai/v1/chat/completions';

  Future<String> analyzeSentiment(String text) async {
    // Try Gemini first
    if (geminiKey?.isNotEmpty ?? false) {
      try {
        final result = await _callGemini('Analyze the emotional tone of this text and respond with ONLY one word: positive, negative, or neutral. Text: $text');
        if (result.isNotEmpty) {
          final sentiment = result.trim().toLowerCase();
          if (['positive', 'negative', 'neutral'].contains(sentiment)) {
            return sentiment;
          }
        }
      } catch (e) {
        print('Gemini sentiment analysis failed: $e');
      }
    }

    // Try Grok if Gemini fails
    if (grokKey?.isNotEmpty ?? false) {
      try {
        final result = await _callGrok('Analyze the emotional tone of this text and respond with ONLY one word: positive, negative, or neutral. Text: $text');
        if (result.isNotEmpty) {
          final sentiment = result.trim().toLowerCase();
          if (['positive', 'negative', 'neutral'].contains(sentiment)) {
            return sentiment;
          }
        }
      } catch (e) {
        print('Grok sentiment analysis failed: $e');
      }
    }

    // Fallback to offline analysis
    return _offlineSentimentAnalysis(text);
  }

  Future<String> generateInsights(String journalText) async {
    final prompt = 'Based on this journal entry, provide gentle, supportive insights and suggestions for mental wellbeing. Keep it under 100 words and be encouraging. Journal: $journalText';
    
    // Try Gemini first
    if (geminiKey?.isNotEmpty ?? false) {
      try {
        final result = await _callGemini(prompt);
        if (result.isNotEmpty) {
          return result.trim();
        }
      } catch (e) {
        print('Gemini insights failed: $e');
      }
    }

    // Try Grok if Gemini fails
    if (grokKey?.isNotEmpty ?? false) {
      try {
        final result = await _callGrok(prompt);
        if (result.isNotEmpty) {
          return result.trim();
        }
      } catch (e) {
        print('Grok insights failed: $e');
      }
    }

    // Fallback to offline insights
    return _offlineInsights(journalText);
  }

  Future<List<String>> suggestTasks(String journalText) async {
    final prompt = 'Based on this journal entry, suggest 2-3 helpful tasks or activities that could support mental wellbeing. Return as a simple list, one task per line. Journal: $journalText';
    
    // Try Gemini first
    if (geminiKey?.isNotEmpty ?? false) {
      try {
        final result = await _callGemini(prompt);
        if (result.isNotEmpty) {
          final tasks = result.split('\n').where((line) => line.trim().isNotEmpty).take(3).toList();
          if (tasks.isNotEmpty) {
            return tasks;
          }
        }
      } catch (e) {
        print('Gemini task suggestions failed: $e');
      }
    }

    // Try Grok if Gemini fails
    if (grokKey?.isNotEmpty ?? false) {
      try {
        final result = await _callGrok(prompt);
        if (result.isNotEmpty) {
          final tasks = result.split('\n').where((line) => line.trim().isNotEmpty).take(3).toList();
          if (tasks.isNotEmpty) {
            return tasks;
          }
        }
      } catch (e) {
        print('Grok task suggestions failed: $e');
      }
    }

    // Fallback to offline suggestions
    return _offlineTaskSuggestions(journalText);
  }

  Future<String> checkWellbeing(List<String> recentEntries) async {
    if (recentEntries.isEmpty) return 'Keep writing in your journal to get personalized insights.';
    
    final combinedText = recentEntries.take(5).join(' ');
    final prompt = 'Based on these recent journal entries, assess the person\'s mental wellbeing and provide a brief, supportive response. Be encouraging and suggest positive actions if needed. Entries: $combinedText';
    
    // Try Gemini first
    if (geminiKey?.isNotEmpty ?? false) {
      try {
        final result = await _callGemini(prompt);
        if (result.isNotEmpty) {
          return result.trim();
        }
      } catch (e) {
        print('Gemini wellbeing check failed: $e');
      }
    }

    // Try Grok if Gemini fails
    if (grokKey?.isNotEmpty ?? false) {
      try {
        final result = await _callGrok(prompt);
        if (result.isNotEmpty) {
          return result.trim();
        }
      } catch (e) {
        print('Grok wellbeing check failed: $e');
      }
    }

    // Fallback to offline wellbeing check
    return _offlineWellbeingCheck(recentEntries);
  }

  Future<String> _callGemini(String prompt) async {
    final body = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 200,
      }
    };
    
    final resp = await http.post(
      Uri.parse('$_geminiEndpoint?key=$geminiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates.first['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;
        if (parts != null && parts.isNotEmpty) {
          return (parts.first['text'] as String?)?.trim() ?? '';
        }
      }
    }
    throw Exception('Gemini API error: ${resp.statusCode}');
  }

  Future<String> _callGrok(String prompt) async {
    final body = {
      'model': 'grok-beta',
      'messages': [
        {
          'role': 'user',
          'content': prompt,
        }
      ],
      'max_tokens': 200,
      'temperature': 0.7,
    };
    
    final resp = await http.post(
      Uri.parse(_grokEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $grokKey',
      },
      body: jsonEncode(body),
    );
    
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      if (choices != null && choices.isNotEmpty) {
        final message = choices.first['message'] as Map<String, dynamic>?;
        return (message?['content'] as String?)?.trim() ?? '';
      }
    }
    throw Exception('Grok API error: ${resp.statusCode}');
  }

  String _offlineSentimentAnalysis(String text) {
    if (text.trim().isEmpty) return 'neutral';
    
    final words = text.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return 'neutral';

    const positiveWords = {
      'happy', 'joy', 'excited', 'love', 'amazing', 'wonderful', 'fantastic',
      'great', 'good', 'awesome', 'beautiful', 'perfect', 'excellent',
      'grateful', 'blessed', 'proud', 'confident', 'peaceful', 'calm',
      'hopeful', 'optimistic', 'motivated', 'energetic', 'smile', 'laugh'
    };

    const negativeWords = {
      'sad', 'angry', 'frustrated', 'disappointed', 'worried', 'anxious',
      'stressed', 'tired', 'exhausted', 'overwhelmed', 'confused', 'lost',
      'hurt', 'pain', 'suffering', 'struggle', 'difficult', 'hard',
      'terrible', 'awful', 'horrible', 'bad', 'wrong', 'fail', 'failure',
      'depressed', 'lonely', 'isolated', 'rejected', 'hopeless', 'helpless'
    };

    int positiveCount = 0;
    int negativeCount = 0;

    for (final word in words) {
      if (positiveWords.contains(word)) positiveCount++;
      if (negativeWords.contains(word)) negativeCount++;
    }

    if (positiveCount > negativeCount) return 'positive';
    if (negativeCount > positiveCount) return 'negative';
    return 'neutral';
  }

  String _offlineInsights(String journalText) {
    final sentiment = _offlineSentimentAnalysis(journalText);
    
    switch (sentiment) {
      case 'positive':
        return 'It\'s wonderful to see your positive outlook! Keep nurturing these good feelings and remember to celebrate your achievements, no matter how small.';
      case 'negative':
        return 'I hear you, and I want you to know that it\'s okay to feel this way. Consider reaching out to someone you trust, or try some gentle self-care activities. You\'re stronger than you know.';
      default:
        return 'Thank you for taking the time to reflect. Every day brings new opportunities for growth and learning. Keep writing and stay curious about your journey.';
    }
  }

  List<String> _offlineTaskSuggestions(String journalText) {
    final sentiment = _offlineSentimentAnalysis(journalText);
    
    switch (sentiment) {
      case 'positive':
        return [
          'Share your joy with someone you care about',
          'Write down what made you feel this way',
          'Plan something fun for tomorrow'
        ];
      case 'negative':
        return [
          'Take a warm bath or shower',
          'Practice deep breathing for 5 minutes',
          'Call a trusted friend or family member'
        ];
      default:
        return [
          'Take a 10-minute break to relax',
          'Practice mindfulness meditation',
          'Do something creative'
        ];
    }
  }

  String _offlineWellbeingCheck(List<String> recentEntries) {
    if (recentEntries.isEmpty) return 'Keep writing in your journal to get personalized insights.';
    
    int positiveCount = 0;
    int negativeCount = 0;
    
    for (final entry in recentEntries) {
      final sentiment = _offlineSentimentAnalysis(entry);
      if (sentiment == 'positive') positiveCount++;
      if (sentiment == 'negative') negativeCount++;
    }
    
    if (positiveCount > negativeCount) {
      return 'Your recent entries show a positive trend! Keep up the great work and continue focusing on the good things in your life.';
    } else if (negativeCount > positiveCount) {
      return 'I notice you\'ve been going through some challenges lately. Remember that it\'s okay to ask for help and that difficult times don\'t last forever.';
    } else {
      return 'Your journal shows a balanced perspective. Continue reflecting and taking care of yourself. Every day is a new opportunity.';
    }
  }
}
