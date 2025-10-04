class OfflineSentimentService {
  static const Map<String, double> _positiveWords = {
    'happy': 1.0, 'joy': 1.0, 'excited': 1.0, 'love': 1.0, 'amazing': 1.0,
    'wonderful': 1.0, 'fantastic': 1.0, 'great': 0.8, 'good': 0.7, 'awesome': 1.0,
    'beautiful': 0.9, 'perfect': 1.0, 'excellent': 0.9, 'brilliant': 0.9,
    'grateful': 0.8, 'blessed': 0.9, 'proud': 0.7, 'confident': 0.6,
    'peaceful': 0.7, 'calm': 0.6, 'relaxed': 0.6, 'content': 0.7,
    'hopeful': 0.8, 'optimistic': 0.8, 'motivated': 0.7, 'energetic': 0.6,
    'smile': 0.8, 'laugh': 0.9, 'fun': 0.8, 'enjoy': 0.7, 'celebrate': 0.9,
    'success': 0.8, 'achieve': 0.7, 'win': 0.8, 'victory': 0.9,
    'thankful': 0.8, 'appreciate': 0.7, 'cherish': 0.8, 'treasure': 0.8,
  };

  static const Map<String, double> _negativeWords = {
    'sad': -1.0, 'angry': -0.9, 'frustrated': -0.8, 'disappointed': -0.7,
    'worried': -0.8, 'anxious': -0.9, 'stressed': -0.8, 'tired': -0.6,
    'exhausted': -0.8, 'overwhelmed': -0.9, 'confused': -0.6, 'lost': -0.7,
    'pain': -0.9, 'suffering': -1.0, 'struggle': -0.7,
    'difficult': -0.6, 'hard': -0.6, 'terrible': -0.9, 'awful': -0.9,
    'horrible': -0.9, 'bad': -0.7, 'wrong': -0.6, 'fail': -0.8,
    'failure': -0.8, 'mistake': -0.6, 'error': -0.5, 'problem': -0.6,
    'crisis': -0.9, 'emergency': -0.8, 'urgent': -0.7, 'critical': -0.8,
    'depressed': -0.9, 'lonely': -0.8, 'isolated': -0.8, 'rejected': -0.8,
    'abandoned': -0.9, 'betrayed': -0.9, 'broken': -0.8,
    'hopeless': -0.9, 'helpless': -0.8, 'powerless': -0.7, 'defeated': -0.8,
  };

  static String analyzeSentiment(String text) {
    if (text.trim().isEmpty) return 'neutral';
    
    final words = text.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return 'neutral';

    double totalScore = 0.0;
    int wordCount = 0;

    for (final word in words) {
      if (_positiveWords.containsKey(word)) {
        totalScore += _positiveWords[word]!;
        wordCount++;
      } else if (_negativeWords.containsKey(word)) {
        totalScore += _negativeWords[word]!;
        wordCount++;
      }
    }

    if (wordCount == 0) return 'neutral';

    final averageScore = totalScore / wordCount;
    
    if (averageScore > 0.3) {
      return 'positive';
    } else if (averageScore < -0.3) {
      return 'negative';
    } else {
      return 'neutral';
    }
  }

  static List<String> getEmotionalResponses(String sentiment, String text) {
    switch (sentiment) {
      case 'positive':
        return [
          "That's wonderful to hear! 🌟",
          "I'm so happy for you! 😊",
          "Your positivity is inspiring! ✨",
          "Keep spreading that joy! 🎉",
        ];
      case 'negative':
        return [
          "I hear you, and I'm here for you. 💙",
          "It's okay to feel this way. You're not alone. 🤗",
          "Take your time. Healing isn't linear. 🌱",
          "Remember, this feeling is temporary. You're stronger than you know. 💪",
        ];
      default:
        return [
          "Thank you for sharing your thoughts. 📝",
          "Reflection is a powerful tool for growth. 🌱",
          "Every day brings new opportunities. 🌅",
          "You're doing great by taking time to reflect. ✨",
        ];
    }
  }

  static List<String> getSuggestedTasks(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return [
          "Share your joy with someone you care about",
          "Write down what made you feel this way",
          "Plan something fun for tomorrow",
          "Practice gratitude meditation",
        ];
      case 'negative':
        return [
          "Take a warm bath or shower",
          "Practice deep breathing for 5 minutes",
          "Call a trusted friend or family member",
          "Write down three things you're grateful for",
          "Go for a gentle walk outside",
        ];
      default:
        return [
          "Take a 10-minute break to relax",
          "Practice mindfulness meditation",
          "Do something creative",
          "Connect with nature",
        ];
    }
  }
}
