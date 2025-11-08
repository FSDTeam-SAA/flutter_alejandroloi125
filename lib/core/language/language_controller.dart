import 'package:alejandroloi/core/language/static_text.dart';
import 'package:get/get.dart';

import 'translation_services.dart';

class LanguageController extends GetxController {
  final TranslationService _service = TranslationService();
  var selectedLang = 'en'.obs;
  final Map<String, String> _cache = {};

  //  Dynamic translation (Google API)
  Future<String> translate(String text) async {
    if (selectedLang.value == 'en') return text;

    final cacheKey = '$text-${selectedLang.value}';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    final translated = await _service.translateText(text, selectedLang.value);
    _cache[cacheKey] = translated;
    return translated;
  }

  //  Static translation getter
  String t(String key) {
    final lang = selectedLang.value;
    return staticTexts[lang]?[key] ?? staticTexts['en']?[key] ?? key;
  }


  // Auto translate all static texts
  Future<void> autoTranslateStaticTexts() async {
    final lang = selectedLang.value;
    if (lang == 'en') return;

    staticTexts.putIfAbsent(lang, () => {});

    for (var entry in staticTexts['en']!.entries) {
      final key = entry.key;
      final text = entry.value;

      if (!staticTexts[lang]!.containsKey(key)) {
        final translated = await _service.translateText(text, lang);
        staticTexts[lang]![key] = translated;
      }
    }
  }



  // Change language and refresh
  Future<void> changeLanguageAndRefreshUI(String lang) async {
    selectedLang.value = lang;
    _cache.clear();
    await autoTranslateStaticTexts();
    update();
  }

/*  Future<void> autoTranslateStaticTexts() async {
    final lang = selectedLang.value;
    if (lang == 'en') return;

    for (var entry in staticTexts['en']!.entries) {
      final key = entry.key;
      final text = entry.value;

      final translated = await _service.translateText(text, lang);
      staticTexts.putIfAbsent(lang, () => {})[key] = translated;
    }
  }*/


/*
  Future<void> autoTranslateStaticTexts() async {
    final lang = selectedLang.value;

    // যদি ইংরেজি হয়, কিছু না করেই ফিরে যাও
    if (lang == 'en') return;

    // যদি ওই ভাষার cache না থাকে, তাহলে তৈরি করো
    staticTexts.putIfAbsent(lang, () => {});

    for (var entry in staticTexts['en']!.entries) {
      final key = entry.key;
      final englishText = entry.value;

      // যদি আগেই ওই ভাষায় ওই key translate করা না থাকে, তাহলে translate করো
      if (!staticTexts[lang]!.containsKey(key)) {
        final translated = await _service.translateText(englishText, lang);
        staticTexts[lang]![key] = translated;
      }
    }
  }
*/


}
