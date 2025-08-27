import 'dart:io';

void main() async {
  print('🔧 开始修复翻译文件中的重复键...\n');
  
  final translationFiles = [
    'lib/core/translations/zh_cn.dart',
    'lib/core/translations/en_us.dart',
    'lib/core/translations/ja_jp.dart',
    'lib/core/translations/ko_kr.dart',
    'lib/core/translations/fr_fr.dart',
    'lib/core/translations/de_de.dart',
    'lib/core/translations/es_es.dart',
    'lib/core/translations/it_it.dart',
    'lib/core/translations/pt_pt.dart',
    'lib/core/translations/ru_ru.dart',
  ];
  
  for (final filePath in translationFiles) {
    await fixDuplicateKeys(filePath);
  }
  
  print('✅ 重复键修复完成！');
}

Future<void> fixDuplicateKeys(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    print('⚠️ 文件不存在: $filePath');
    return;
  }
  
  print('🔧 修复文件: $filePath');
  
  final content = await file.readAsString();
  final lines = content.split('\n');
  final newLines = <String>[];
  final seenKeys = <String>{};
  final duplicateKeys = <String>[];
  
  for (final line in lines) {
    // 检查是否是翻译键值对
    final trimmedLine = line.trim();
    if (trimmedLine.startsWith("'") && trimmedLine.contains("':")) {
      final keyMatch = RegExp(r"'([^']+)':").firstMatch(trimmedLine);
      if (keyMatch != null) {
        final key = keyMatch.group(1)!;
        if (seenKeys.contains(key)) {
          duplicateKeys.add(key);
          print('  ❌ 发现重复键: $key');
          continue; // 跳过重复的键
        } else {
          seenKeys.add(key);
        }
      }
    }
    newLines.add(line);
  }
  
  if (duplicateKeys.isNotEmpty) {
    print('  📝 移除了 ${duplicateKeys.length} 个重复键');
    await file.writeAsString(newLines.join('\n'));
  } else {
    print('  ✅ 没有发现重复键');
  }
} 