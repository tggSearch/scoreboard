import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

/// 通用语音播报模块 - 纯播报功能，不包含任何业务逻辑
/// 外部传入什么文本就播报什么文本，所有文本构建逻辑都在外部完成
class VoiceAnnouncer {
  final FlutterTts _flutterTts = FlutterTts();
  final RxBool isEnabled = true.obs;
  
  // 播报任务队列
  final List<String> _announcementQueue = [];
  bool _isProcessing = false;
  
  VoiceAnnouncer() {
    _initTts();
  }
  
  Future<void> _initTts() async {
    await _flutterTts.setLanguage("zh-CN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }
  
  /// 切换播报开关
  void toggle() {
    isEnabled.value = !isEnabled.value;
    if (!isEnabled.value) {
      // 如果禁用，清空队列
      _announcementQueue.clear();
      _isProcessing = false;
    }
  }
  
  /// 处理播报队列（异步执行，不阻塞主线程）
  Future<void> _processQueue() async {
    if (!isEnabled.value) return;
    
    // 如果正在处理，先停止当前播报
    if (_isProcessing) {
      try {
        await _flutterTts.stop();
      } catch (e) {
        debugPrint('停止当前播报失败: $e');
      }
    }
    
    _isProcessing = true;
    
    // 只处理队列中的最后一个（最新的）
    String? textToSpeak;
    while (_announcementQueue.isNotEmpty && isEnabled.value) {
      textToSpeak = _announcementQueue.removeAt(0);
    }
    
    if (textToSpeak != null && textToSpeak.isNotEmpty && isEnabled.value) {
      try {
        // 保存非空值，确保类型安全
        final String text = textToSpeak;
        // 使用Future确保不阻塞UI，但仍在主线程执行TTS
        await Future(() => _flutterTts.speak(text));
        // 等待当前播报完成
        await _flutterTts.awaitSpeakCompletion(true);
      } catch (e) {
        debugPrint('语音播报失败: $e');
      }
    }
    
    _isProcessing = false;
  }
  
  /// 添加播报任务到队列（非阻塞）
  /// 如果正在播报，会停止当前播报并播放最新的
  void _enqueueAnnouncement(String text) {
    if (!isEnabled.value || text.isEmpty) return;
    
    // 清空队列，只保留最新的播报
    _announcementQueue.clear();
    _announcementQueue.add(text);
    
    // 异步处理队列，不阻塞当前调用
    scheduleMicrotask(() => _processQueue());
  }
  
  /// 播报文本（非阻塞）
  /// 外部传入什么文本就播报什么文本，所有文本构建逻辑都在外部完成
  /// 如果正在播报，会停止当前播报并立即播放新的
  void announce(String text) {
    if (!isEnabled.value || text.isEmpty) return;
    _enqueueAnnouncement(text);
  }
  
  /// 清空播报队列
  void clearQueue() {
    _announcementQueue.clear();
  }
  
  /// 停止当前播报
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      clearQueue();
      _isProcessing = false;
    } catch (e) {
      debugPrint('停止播报失败: $e');
    }
  }
} 