/*
import 'package:alejandroloi/core/language/translation_services.dart';
import 'package:get/get.dart';


class LanguageController extends GetxController {
  final TranslationService _service = TranslationService();

  var selectedLang = 'en'.obs;
  var isTranslating = false.obs;

  Future<String> translate(String text) async {
    if (selectedLang.value == 'en') return text;
    isTranslating.value = true;
    final translated = await _service.translateText(text, selectedLang.value);
    isTranslating.value = false;
    return translated;
  }

  void changeLanguage(String langCode) {
    selectedLang.value = langCode;
    update();
  }
}
*/



import 'package:alejandroloi/core/language/translation_services.dart';
import 'package:get/get.dart';


class LanguageController extends GetxController {
  final TranslationService _service = TranslationService();
  var selectedLang = 'en'.obs;

  Future<String> translate(String text) async {
    if (selectedLang.value == 'en') return text;
    return await _service.translateText(text, selectedLang.value);
  }

  void changeLanguage(String langCode) {
    selectedLang.value = langCode;
    update(); // GetX update
  }
}

