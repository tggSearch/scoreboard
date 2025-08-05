#!/usr/bin/env dart

import 'dart:io';

void main() {
  print('🔧 开始清理翻译文件中的重复key...');
  
  // 清理英文翻译文件
  cleanTranslationFile('lib/core/translations/en_us.dart', 'EnUS');
  
  // 清理中文翻译文件
  cleanTranslationFile('lib/core/translations/zh_cn.dart', 'ZhCN');
  
  print('✅ 翻译文件清理完成！');
}

void cleanTranslationFile(String filePath, String className) {
  print('📝 正在处理 $filePath...');
  
  try {
    final file = File(filePath);
    if (!file.existsSync()) {
      print('❌ 文件不存在: $filePath');
      return;
    }
    
    final content = file.readAsStringSync();
    final lines = content.split('\n');
    
    // 找到translations map的开始和结束位置
    int startIndex = -1;
    int endIndex = -1;
    
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('static const Map<String, String> translations = {')) {
        startIndex = i;
      }
      if (startIndex != -1 && lines[i].trim() == '};') {
        endIndex = i;
        break;
      }
    }
    
    if (startIndex == -1 || endIndex == -1) {
      print('❌ 无法找到translations map的边界');
      return;
    }
    
    // 提取translations map的内容
    final mapLines = lines.sublist(startIndex + 1, endIndex);
    
    // 解析key-value对
    final Map<String, String> keyValuePairs = {};
    final List<String> cleanedLines = [];
    
    for (String line in mapLines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty || trimmedLine.startsWith('//')) {
        cleanedLines.add(line);
        continue;
      }
      
      // 解析key-value对
      final colonIndex = trimmedLine.indexOf(':');
      if (colonIndex != -1) {
        final key = trimmedLine.substring(0, colonIndex).trim();
        final value = trimmedLine.substring(colonIndex + 1).trim();
        
        // 移除key的引号
        final cleanKey = key.replaceAll("'", "").replaceAll('"', '');
        
        // 如果key已经存在，跳过这一行
        if (keyValuePairs.containsKey(cleanKey)) {
          print('🔄 跳过重复key: $cleanKey');
          continue;
        }
        
        keyValuePairs[cleanKey] = value;
        cleanedLines.add(line);
      } else {
        cleanedLines.add(line);
      }
    }
    
    // 重建文件内容
    final newContent = [
      ...lines.sublist(0, startIndex + 1),
      ...cleanedLines,
      ...lines.sublist(endIndex),
    ].join('\n');
    
    // 写回文件
    file.writeAsStringSync(newContent);
    
    print('✅ $filePath 处理完成，移除了 ${mapLines.length - cleanedLines.length} 个重复key');
    
  } catch (e) {
    print('❌ 处理 $filePath 时出错: $e');
  }
} 