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

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'zh_CN': ZhCN.translations,
    'en_US': EnUS.translations,
    'ja_JP': JaJP.translations,
    'ko_KR': KoKR.translations,
    'fr_FR': FrFR.translations,
    'de_DE': DeDE.translations,
    'es_ES': EsES.translations,
    'it_IT': ItIT.translations,
    'pt_PT': PtPT.translations,
    'ru_RU': RuRU.translations,
  };
} 