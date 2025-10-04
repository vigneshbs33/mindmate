import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  Future<bool> init() async {
    return await _speech.initialize();
  }

  Future<bool> start(void Function(String) onResult) async {
    if (_isListening) {
      await stop();
    }
    
    try {
      final result = await _speech.listen(
        onResult: (result) => onResult(result.recognizedWords),
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        onSoundLevelChange: (level) {
          // Optional: handle sound level changes
        },
      );
      _isListening = result;
      return result;
    } catch (e) {
      print('Speech recognition error: $e');
      _isListening = false;
      return false;
    }
  }

  Future<void> stop() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  bool get isListening => _isListening;
}


