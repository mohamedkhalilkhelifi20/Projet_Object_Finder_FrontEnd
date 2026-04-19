import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/constants.dart';

class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _isSpeaking = false;

  // ─── Initialisation

  Future<void> init({String lang = AppConstants.langFr}) async {
    if (_initialized) return;

    await _tts.setLanguage(lang);
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() => _isSpeaking = true);
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((_) => _isSpeaking = false);

    _initialized = true;
  }

  // ─── Parler
  Future<void> speak(String message) async {
    if (!_initialized) await init();
    if (_isSpeaking) await _tts.stop();
    await _tts.speak(message);
  }

  // ─── Parler selon danger
  Future<void> speakDetection({
    required String voiceMessage,
    required String dangerLevel,
  }) async {
    if (!_initialized) await init();

    if (dangerLevel == 'Danger') {
      await _tts.stop();
      await _tts.speak(voiceMessage);
      return;
    }

    if (dangerLevel == 'ATTENTION' && !_isSpeaking) {
      await _tts.speak(voiceMessage);
      return;
    }

    if (!_isSpeaking) {
      await _tts.speak(voiceMessage);
    }
  }

  // ─── Changer la langue
  Future<void> setLanguage(String lang) async {
    await _setLanguage(lang);
  }

  Future<void> _setLanguage(String lang) async {
    if(lang == AppConstants.langTn){
        await _tts.setLanguage("ar-SA");
    }
    else {
      await _tts.setLanguage("fr-FR");
    }
  }

  // ─── Stop
  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  // ─── Dispose
  Future<void> dispose() async {
    await _tts.stop();
    _initialized = false;
  }
}
