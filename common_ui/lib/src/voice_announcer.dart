import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceAnnouncer {
  final FlutterTts _flutterTts = FlutterTts();
  final RxBool isEnabled = true.obs;
  
  VoiceAnnouncer() {
    _initTts();
  }
  
  Future<void> _initTts() async {
    await _flutterTts.setLanguage("zh-CN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }
  
  void toggle() {
    isEnabled.value = !isEnabled.value;
  }
  
  Future<void> announce(String text) async {
    if (isEnabled.value && text.isNotEmpty) {
      try {
        await _flutterTts.speak(text);
      } catch (e) {
        print('voice_announcement_failed'.tr + ': $e');
      }
    }
  }
  
  Future<void> announceWin(String playerName, String winType, int fans, bool isSelfDraw) async {
    if (!isEnabled.value) return;
    
    String announcement = '$playerName $winType';
    if (fans > 1) {
      announcement += ' $fans${'fans'.tr}';
    }
    if (isSelfDraw) {
      announcement += ' ${'self_draw'.tr}';
    }
    
    await announce(announcement);
  }
  
  Future<void> announceGang(String playerName, String gangType, int fans) async {
    if (!isEnabled.value) return;
    
    String announcement = '$playerName $gangType';
    if (fans > 0) {
      announcement += ' $fans${'fans'.tr}';
    }
    
    await announce(announcement);
  }
  
  Future<void> announceTime(String timeText) async {
    if (!isEnabled.value) return;
    await announce('${'countdown'.tr} $timeText');
  }
  
  Future<void> announceCountdown(String timeText) async {
    if (!isEnabled.value) return;
    await announce('${'countdown'.tr} $timeText');
  }
} 