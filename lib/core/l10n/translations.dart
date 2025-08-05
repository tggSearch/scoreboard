import 'package:get/get.dart';
import '../translations/zh_cn.dart';
import '../translations/en_us.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'zh_CN': ZhCN.translations,
    'en_US': EnUS.translations,
  };
} 