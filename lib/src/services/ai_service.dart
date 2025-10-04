import 'dart:convert';

import 'package:http/http.dart' as http;

class AiService {
  AiService({required this.apiKey});
  final String apiKey;

  static const String _endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  Future<String> analyzeSentiment(String text) async {
    try {
      final prompt = 'Analyze the emotional tone of this text and respond with ONLY one word: positive, negative, or neutral. Text: $text';
      final body = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.1,
          'maxOutputTokens': 10,
        }
      };
      
      final resp = await http.post(
        Uri.parse('$_endpoint?key=\'AIzaSyA3Rfhg1B580NdeiH5VKw_WASrd9aY2YoQ\''),
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
            final textOut = (parts.first['text'] as String?)?.trim().toLowerCase();
            switch (textOut) {
              case 'positive':
              case 'negative':
              case 'neutral':
                return textOut!;
              default:
                return 'neutral';
            }
          }
        }
      }
      print('Gemini API error: ${resp.statusCode} ${resp.body}');
      return 'neutral';
    } catch (e) {
      print('AI Service error: $e');
      return 'neutral';
    }
  }

  Future<String> generateInsights(String journalText) async {
    try {
      final prompt = 'Based on this journal entry, provide gentle, supportive insights and suggestions for mental wellbeing. Keep it under 100 words and be encouraging. Journal: $journalText';
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
        Uri.parse('$_endpoint?key=\'AIzaSyA3Rfhg1B580NdeiH5VKw_WASrd9aY2YoQ\''),
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
            return (parts.first['text'] as String?)?.trim() ?? 'Keep reflecting and taking care of yourself.';
          }
        }
      }
      return 'Keep reflecting and taking care of yourself.';
    } catch (e) {
      print('AI Insights error: $e');
      return 'Keep reflecting and taking care of yourself.';
    }
  }

  Future<List<String>> suggestTasks(String journalText) async {
    try {
      final prompt = 'Based on this journal entry, suggest 2-3 helpful tasks or activities that could support mental wellbeing. Return as a simple list, one task per line. Journal: $journalText';
      final body = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.8,
          'maxOutputTokens': 150,
        }
      };
      
      final resp = await http.post(
        Uri.parse('$_endpoint?key=\'AIzaSyA3Rfhg1B580NdeiH5VKw_WASrd9aY2YoQ\''),
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
            final text = (parts.first['text'] as String?)?.trim() ?? '';
            return text.split('\n').where((line) => line.trim().isNotEmpty).take(3).toList();
          }
        }
      }
      return ['Take a 10-minute walk', 'Practice deep breathing', 'Write down three things you\'re grateful for'];
    } catch (e) {
      print('AI Task suggestions error: $e');
      return ['Take a 10-minute walk', 'Practice deep breathing', 'Write down three things you\'re grateful for'];
    }
  }
}


