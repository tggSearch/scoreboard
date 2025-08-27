import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔍 开始检查翻译完整性...\n');
  
  // 读取所有翻译文件
  final zhTranslations = await readTranslationFile('lib/core/translations/zh_cn.dart');
  final enTranslations = await readTranslationFile('lib/core/translations/en_us.dart');
  final jaTranslations = await readTranslationFile('lib/core/translations/ja_jp.dart');
  final koTranslations = await readTranslationFile('lib/core/translations/ko_kr.dart');
  final frTranslations = await readTranslationFile('lib/core/translations/fr_fr.dart');
  final deTranslations = await readTranslationFile('lib/core/translations/de_de.dart');
  final esTranslations = await readTranslationFile('lib/core/translations/es_es.dart');
  final itTranslations = await readTranslationFile('lib/core/translations/it_it.dart');
  final ptTranslations = await readTranslationFile('lib/core/translations/pt_pt.dart');
  final ruTranslations = await readTranslationFile('lib/core/translations/ru_ru.dart');
  
  // 检查每种语言相对于中文的缺失键
  final missingInEn = findMissingKeys(zhTranslations, enTranslations);
  final missingInJa = findMissingKeys(zhTranslations, jaTranslations);
  final missingInKo = findMissingKeys(zhTranslations, koTranslations);
  final missingInFr = findMissingKeys(zhTranslations, frTranslations);
  final missingInDe = findMissingKeys(zhTranslations, deTranslations);
  final missingInEs = findMissingKeys(zhTranslations, esTranslations);
  final missingInIt = findMissingKeys(zhTranslations, itTranslations);
  final missingInPt = findMissingKeys(zhTranslations, ptTranslations);
  final missingInRu = findMissingKeys(zhTranslations, ruTranslations);
  
  // 显示检查结果
  print('📊 翻译完整性检查结果:');
  print('中文翻译键总数: ${zhTranslations.length}');
  print('英文翻译键总数: ${enTranslations.length}');
  print('日文翻译键总数: ${jaTranslations.length}');
  print('韩文翻译键总数: ${koTranslations.length}');
  print('法文翻译键总数: ${frTranslations.length}');
  print('德文翻译键总数: ${deTranslations.length}');
  print('西班牙文翻译键总数: ${esTranslations.length}');
  print('意大利文翻译键总数: ${itTranslations.length}');
  print('葡萄牙文翻译键总数: ${ptTranslations.length}');
  print('俄文翻译键总数: ${ruTranslations.length}');
  print('');
  
  if (missingInEn.isNotEmpty) {
    print('❌ 英文缺少 ${missingInEn.length} 个翻译键:');
    missingInEn.forEach((key) => print('  - $key'));
    print('');
  }
  
  if (missingInJa.isNotEmpty) {
    print('❌ 日文缺少 ${missingInJa.length} 个翻译键:');
    missingInJa.forEach((key) => print('  - $key'));
    print('');
  }
  
  if (missingInKo.isNotEmpty) {
    print('❌ 韩文缺少 ${missingInKo.length} 个翻译键:');
    missingInKo.forEach((key) => print('  - $key'));
    print('');
  }
  
  if (missingInFr.isNotEmpty) {
    print('❌ 法文缺少 ${missingInFr.length} 个翻译键:');
    missingInFr.forEach((key) => print('  - $key'));
    print('');
  }
  
  if (missingInDe.isNotEmpty) {
    print('❌ 德文缺少 ${missingInDe.length} 个翻译键:');
    missingInDe.forEach((key) => print('  - $key'));
    print('');
  }
  
  if (missingInEs.isNotEmpty) {
    print('❌ 西班牙文缺少 ${missingInEs.length} 个翻译键:');
    missingInEs.forEach((key) => print('  - $key'));
    print('');
  }
  
  if (missingInIt.isNotEmpty) {
    print('❌ 意大利文缺少 ${missingInIt.length} 个翻译键:');
    missingInIt.forEach((key) => print('  - $key'));
    print('');
  }
  
  if (missingInPt.isNotEmpty) {
    print('❌ 葡萄牙文缺少 ${missingInPt.length} 个翻译键:');
    missingInPt.forEach((key) => print('  - $key'));
    print('');
  }
  
  if (missingInRu.isNotEmpty) {
    print('❌ 俄文缺少 ${missingInRu.length} 个翻译键:');
    missingInRu.forEach((key) => print('  - $key'));
    print('');
  }
  
  // 自动补充缺失的翻译
  if (missingInEn.isNotEmpty || missingInJa.isNotEmpty || missingInKo.isNotEmpty || missingInFr.isNotEmpty || missingInDe.isNotEmpty || missingInEs.isNotEmpty || missingInIt.isNotEmpty || missingInPt.isNotEmpty || missingInRu.isNotEmpty) {
    print('🔧 开始自动补充缺失的翻译...\n');
    
    if (missingInEn.isNotEmpty) {
      await supplementTranslations('lib/core/translations/en_us.dart', missingInEn, zhTranslations, 'English');
    }
    
    if (missingInJa.isNotEmpty) {
      await supplementTranslations('lib/core/translations/ja_jp.dart', missingInJa, zhTranslations, 'Japanese');
    }
    
    if (missingInKo.isNotEmpty) {
      await supplementTranslations('lib/core/translations/ko_kr.dart', missingInKo, zhTranslations, 'Korean');
    }
    
    if (missingInFr.isNotEmpty) {
      await supplementTranslations('lib/core/translations/fr_fr.dart', missingInFr, zhTranslations, 'French');
    }
    
    if (missingInDe.isNotEmpty) {
      await supplementTranslations('lib/core/translations/de_de.dart', missingInDe, zhTranslations, 'German');
    }
    
    if (missingInEs.isNotEmpty) {
      await supplementTranslations('lib/core/translations/es_es.dart', missingInEs, zhTranslations, 'Spanish');
    }
    
    if (missingInIt.isNotEmpty) {
      await supplementTranslations('lib/core/translations/it_it.dart', missingInIt, zhTranslations, 'Italian');
    }
    
    if (missingInPt.isNotEmpty) {
      await supplementTranslations('lib/core/translations/pt_pt.dart', missingInPt, zhTranslations, 'Portuguese');
    }
    
    if (missingInRu.isNotEmpty) {
      await supplementTranslations('lib/core/translations/ru_ru.dart', missingInRu, zhTranslations, 'Russian');
    }
    
    print('✅ 翻译补充完成！');
  } else {
    print('✅ 所有语言的翻译都是完整的！');
  }
}

Future<Map<String, String>> readTranslationFile(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    print('⚠️ 文件不存在: $filePath');
    return {};
  }
  
  final content = await file.readAsString();
  final translations = <String, String>{};
  
  // 简单的正则表达式来提取翻译键值对
  final regex = RegExp(r"'([^']+)':\s*'([^']*)'");
  final matches = regex.allMatches(content);
  
  for (final match in matches) {
    final key = match.group(1);
    final value = match.group(2);
    if (key != null && value != null) {
      translations[key] = value;
    }
  }
  
  return translations;
}

List<String> findMissingKeys(Map<String, String> source, Map<String, String> target) {
  return source.keys.where((key) => !target.containsKey(key)).toList();
}

Future<void> supplementTranslations(
  String filePath, 
  List<String> missingKeys, 
  Map<String, String> zhTranslations,
  String languageName
) async {
  print('🔧 补充 $languageName 翻译...');
  
  final file = File(filePath);
  final content = await file.readAsString();
  
  // 生成缺失翻译的占位符
  final supplementTranslations = <String, String>{};
  for (final key in missingKeys) {
    final zhValue = zhTranslations[key] ?? key;
    supplementTranslations[key] = generatePlaceholderTranslation(zhValue, languageName);
  }
  
  // 在文件末尾的注释前插入缺失的翻译
  final lines = content.split('\n');
  final newLines = <String>[];
  bool foundEnd = false;
  int insertIndex = -1;
  
  for (int i = lines.length - 1; i >= 0; i--) {
    final line = lines[i];
    newLines.insert(0, line);
    
    // 找到最后一个翻译键值对的位置
    if (!foundEnd && line.trim().startsWith("'") && line.contains("':")) {
      foundEnd = true;
      insertIndex = i;
    }
  }
  
  // 在找到的位置插入缺失的翻译
  if (insertIndex >= 0 && supplementTranslations.isNotEmpty) {
    // 插入注释
    newLines.insert(insertIndex + 1, '');
    newLines.insert(insertIndex + 1, '    // Auto-supplemented translations');
    
    // 插入缺失的翻译
    supplementTranslations.forEach((key, value) {
      newLines.insert(insertIndex + 2, "    '$key': '$value',");
    });
  }
  
  // 写回文件
  await file.writeAsString(newLines.join('\n'));
  
  print('✅ $languageName 翻译补充完成，添加了 ${supplementTranslations.length} 个翻译键');
}

String generatePlaceholderTranslation(String zhValue, String languageName) {
  // 根据语言生成占位符翻译
  switch (languageName) {
    case 'English':
      // 简单的英文占位符，保持原中文作为注释
      return '[$zhValue]';
    case 'Japanese':
      // 日文占位符
      return '[$zhValue]';
    case 'Korean':
      // 韩文占位符
      return '[$zhValue]';
    case 'French':
      // 法文占位符
      return '[$zhValue]';
    case 'German':
      // 德文占位符
      return '[$zhValue]';
    case 'Spanish':
      // 西班牙文占位符
      return '[$zhValue]';
    case 'Italian':
      // 意大利文占位符
      return '[$zhValue]';
    case 'Portuguese':
      // 葡萄牙文占位符
      return '[$zhValue]';
    case 'Russian':
      // 俄文占位符
      return '[$zhValue]';
    default:
      return '[$zhValue]';
  }
}

// 辅助函数：生成更智能的翻译建议
String generateSmartTranslation(String zhValue, String languageName) {
  // 这里可以集成翻译API或使用预定义的翻译映射
  // 目前返回占位符，后续可以扩展
  return generatePlaceholderTranslation(zhValue, languageName);
} 