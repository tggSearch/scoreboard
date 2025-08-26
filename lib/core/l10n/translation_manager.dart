import 'package:get/get.dart';
import '../translations/zh_cn.dart';
import '../translations/en_us.dart';
import '../translations/ja_jp.dart';
import '../translations/ko_kr.dart';
import '../translations/fr_fr.dart';
import '../translations/de_de.dart';
import '../translations/es_es.dart';
import '../translations/it_it.dart';
import '../translations/pt_pt.dart';
import '../translations/ru_ru.dart';

class TranslationManager {
  static TranslationManager? _instance;
  static TranslationManager get instance => _instance ??= TranslationManager._();

  TranslationManager._();

  static Map<String, String> get currentTranslations {
    final locale = Get.locale;
    if (locale != null) {
      final languageCode = '${locale.languageCode}_${locale.countryCode}';
      return _getTranslationsByLanguage(languageCode);
    }
    return EnUS.translations;
  }

  static Map<String, String> _getTranslationsByLanguage(String languageCode) {
    switch (languageCode) {
      case 'zh_CN':
        return ZhCN.translations;
      case 'en_US':
        return EnUS.translations;
      case 'ja_JP':
        return JaJP.translations;
      case 'ko_KR':
        return KoKR.translations;
      case 'fr_FR':
        return FrFR.translations;
      case 'de_DE':
        return DeDE.translations;
      case 'es_ES':
        return EsES.translations;
      case 'it_IT':
        return ItIT.translations;
      case 'pt_PT':
        return PtPT.translations;
      case 'ru_RU':
        return RuRU.translations;
      default:
        return EnUS.translations;
    }
  }

  static String getText(String key, {Map<String, dynamic>? args}) {
    final translations = currentTranslations;
    String text = translations[key] ?? key;
    
    if (args != null) {
      args.forEach((key, value) {
        text = text.replaceAll('{$key}', value.toString());
      });
    }
    
    return text;
  }

  static bool hasKey(String key) {
    return currentTranslations.containsKey(key);
  }

  static List<String> getAvailableKeys() {
    return currentTranslations.keys.toList();
  }

  static List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'zh_CN', 'nativeName': '简体中文'},
      {'code': 'en_US', 'nativeName': 'English'},
      {'code': 'ja_JP', 'nativeName': '日本語'},
      {'code': 'ko_KR', 'nativeName': '한국어'},
      {'code': 'fr_FR', 'nativeName': 'Français'},
      {'code': 'de_DE', 'nativeName': 'Deutsch'},
      {'code': 'es_ES', 'nativeName': 'Español'},
      {'code': 'it_IT', 'nativeName': 'Italiano'},
      {'code': 'pt_PT', 'nativeName': 'Português'},
      {'code': 'ru_RU', 'nativeName': 'Русский'},
    ];
  }

  static String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'zh_CN':
        return '简体中文';
      case 'en_US':
        return 'English';
      case 'ja_JP':
        return '日本語';
      case 'ko_KR':
        return '한국어';
      case 'fr_FR':
        return 'Français';
      case 'de_DE':
        return 'Deutsch';
      case 'es_ES':
        return 'Español';
      case 'it_IT':
        return 'Italiano';
      case 'pt_PT':
        return 'Português';
      case 'ru_RU':
        return 'Русский';
      default:
        return languageCode;
    }
  }

  static Map<String, List<String>> validateTranslations() {
    final zhKeys = ZhCN.translations.keys.toList();
    final enKeys = EnUS.translations.keys.toList();
    final jaKeys = JaJP.translations.keys.toList();
    final koKeys = KoKR.translations.keys.toList();
    final frKeys = FrFR.translations.keys.toList();
    final deKeys = DeDE.translations.keys.toList();
    final esKeys = EsES.translations.keys.toList();
    final itKeys = ItIT.translations.keys.toList();
    final ptKeys = PtPT.translations.keys.toList();
    final ruKeys = RuRU.translations.keys.toList();
    
    final missingInEn = zhKeys.where((key) => !enKeys.contains(key)).toList();
    final missingInZh = enKeys.where((key) => !zhKeys.contains(key)).toList();
    final missingInJa = zhKeys.where((key) => !jaKeys.contains(key)).toList();
    final missingInKo = zhKeys.where((key) => !koKeys.contains(key)).toList();
    final missingInFr = zhKeys.where((key) => !frKeys.contains(key)).toList();
    final missingInDe = zhKeys.where((key) => !deKeys.contains(key)).toList();
    final missingInEs = zhKeys.where((key) => !esKeys.contains(key)).toList();
    final missingInIt = zhKeys.where((key) => !itKeys.contains(key)).toList();
    final missingInPt = zhKeys.where((key) => !ptKeys.contains(key)).toList();
    final missingInRu = zhKeys.where((key) => !ruKeys.contains(key)).toList();
    
    return {
      'missing_in_en': missingInEn,
      'missing_in_zh': missingInZh,
      'missing_in_ja': missingInJa,
      'missing_in_ko': missingInKo,
      'missing_in_fr': missingInFr,
      'missing_in_de': missingInDe,
      'missing_in_es': missingInEs,
      'missing_in_it': missingInIt,
      'missing_in_pt': missingInPt,
      'missing_in_ru': missingInRu,
    };
  }

  static Map<String, int> getTranslationStats() {
    return {
      'zh_CN': ZhCN.translations.length,
      'en_US': EnUS.translations.length,
      'ja_JP': JaJP.translations.length,
      'ko_KR': KoKR.translations.length,
      'fr_FR': FrFR.translations.length,
      'de_DE': DeDE.translations.length,
      'es_ES': EsES.translations.length,
      'it_IT': ItIT.translations.length,
      'pt_PT': PtPT.translations.length,
      'ru_RU': RuRU.translations.length,
    };
  }
} 