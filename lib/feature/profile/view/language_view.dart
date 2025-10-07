import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Colors to match your app
const _bg = Color(0xFF0B0B0B);
const _card = Color(0xFF1E1F22);
const _stroke = Color(0x22FFFFFF);
const _text = Colors.white;
const _subtext = Colors.white70;
const _accent = Color(0xFFFF7A00);

class LanguageViewScreen extends StatefulWidget {
  const LanguageViewScreen({super.key, this.initialLocale});

  /// If you already have a saved locale (e.g., Locale('en','US')), pass it here.
  final Locale? initialLocale;

  @override
  State<LanguageViewScreen> createState() => _LanguageViewScreenState();
}

class _LanguageViewScreenState extends State<LanguageViewScreen> {
  final _controller = TextEditingController();
  late List<_Lang> _all;
  late List<_Lang> _filtered;
  _Lang? _selected;

  @override
  void initState() {
    super.initState();
    _all = _languages;
    _filtered = _all;

    if (widget.initialLocale != null) {
      _selected = _all.firstWhere(
            (l) =>
        l.locale.languageCode == widget.initialLocale!.languageCode &&
            (widget.initialLocale!.countryCode == null ||
                widget.initialLocale!.countryCode!.isEmpty ||
                l.locale.countryCode == widget.initialLocale!.countryCode),
        orElse: () => _all.first,
      );
    } else {
      _selected = _all.first; // default English
    }

    _controller.addListener(() {
      final q = _controller.text.trim().toLowerCase();
      setState(() {
        _filtered = q.isEmpty
            ? _all
            : _all.where((l) {
          final hay = '${l.nativeName} ${l.englishName} ${l.flag}'.toLowerCase();
          return hay.contains(q);
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_selected == null) return;
    Navigator.pop(context, _selected!.locale); // return the chosen Locale
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: _BackCircle(onTap: () => Navigator.pop(context)),
        title: const Text('Language',
            style: TextStyle(color: _text, fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Container(
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _stroke),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: _text),
                cursorColor: _subtext,
                decoration: const InputDecoration(
                  prefixIcon: Icon(CupertinoIcons.search, color: _subtext, size: 18),
                  hintText: 'Search language',
                  hintStyle: TextStyle(color: _subtext),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1, color: _stroke,
                indent: 56, endIndent: 12,
              ),
              itemBuilder: (context, i) {
                final lang = _filtered[i];
                final selected = _selected?.code == lang.code;

                return InkWell(
                  onTap: () => setState(() => _selected = lang),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        // flag
                        Text(lang.flag, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),

                        // names
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.nativeName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                lang.englishName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: _subtext, fontSize: 12.5),
                              ),
                            ],
                          ),
                        ),

                        // check
                        if (selected)
                          const Icon(CupertinoIcons.check_mark_circled_solid,
                              size: 20, color: _accent),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Save
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _save,
                  child: const Text('Save',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackCircle extends StatelessWidget {
  const _BackCircle({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(CupertinoIcons.back, color: _text, size: 20),
        ),
      ),
    );
  }
}

/// Simple language model
class _Lang {
  final String code;           // e.g., 'en_US', 'es_ES'
  final String nativeName;     // e.g., English / Español
  final String englishName;    // e.g., English (US) / Spanish (Spain)
  final String flag;           // emoji flag (no assets needed)
  final Locale locale;

  const _Lang({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.flag,
    required this.locale,
  });
}

/// NOTE: Emoji flags work without extra packages.
/// This list covers a wide set of popular languages and regions.
/// You can expand/modify as needed.
const List<_Lang> _languages = [
  _Lang(code: 'en_US', nativeName: 'English', englishName: 'English (United States)', flag: '🇺🇸', locale: Locale('en', 'US')),
  _Lang(code: 'en_GB', nativeName: 'English (UK)', englishName: 'English (United Kingdom)', flag: '🇬🇧', locale: Locale('en', 'GB')),
  _Lang(code: 'es_ES', nativeName: 'Español', englishName: 'Spanish (Spain)', flag: '🇪🇸', locale: Locale('es', 'ES')),
  _Lang(code: 'es_MX', nativeName: 'Español', englishName: 'Spanish (Mexico)', flag: '🇲🇽', locale: Locale('es', 'MX')),
  _Lang(code: 'fr_FR', nativeName: 'Français', englishName: 'French (France)', flag: '🇫🇷', locale: Locale('fr', 'FR')),
  _Lang(code: 'de_DE', nativeName: 'Deutsch', englishName: 'German (Germany)', flag: '🇩🇪', locale: Locale('de', 'DE')),
  _Lang(code: 'it_IT', nativeName: 'Italiano', englishName: 'Italian (Italy)', flag: '🇮🇹', locale: Locale('it', 'IT')),
  _Lang(code: 'pt_PT', nativeName: 'Português', englishName: 'Portuguese (Portugal)', flag: '🇵🇹', locale: Locale('pt', 'PT')),
  _Lang(code: 'pt_BR', nativeName: 'Português', englishName: 'Portuguese (Brazil)', flag: '🇧🇷', locale: Locale('pt', 'BR')),
  _Lang(code: 'ru_RU', nativeName: 'Русский', englishName: 'Russian (Russia)', flag: '🇷🇺', locale: Locale('ru', 'RU')),
  _Lang(code: 'ar_SA', nativeName: 'العربية', englishName: 'Arabic (Saudi Arabia)', flag: '🇸🇦', locale: Locale('ar', 'SA')),
  _Lang(code: 'bn_BD', nativeName: 'বাংলা', englishName: 'Bengali (Bangladesh)', flag: '🇧🇩', locale: Locale('bn', 'BD')),
  _Lang(code: 'hi_IN', nativeName: 'हिन्दी', englishName: 'Hindi (India)', flag: '🇮🇳', locale: Locale('hi', 'IN')),
  _Lang(code: 'zh_CN', nativeName: '中文', englishName: 'Chinese (Simplified, China)', flag: '🇨🇳', locale: Locale('zh', 'CN')),
  _Lang(code: 'zh_TW', nativeName: '中文', englishName: 'Chinese (Traditional, Taiwan)', flag: '🇹🇼', locale: Locale('zh', 'TW')),
  _Lang(code: 'ja_JP', nativeName: '日本語', englishName: 'Japanese (Japan)', flag: '🇯🇵', locale: Locale('ja', 'JP')),
  _Lang(code: 'ko_KR', nativeName: '한국어', englishName: 'Korean (Korea)', flag: '🇰🇷', locale: Locale('ko', 'KR')),
  _Lang(code: 'tr_TR', nativeName: 'Türkçe', englishName: 'Turkish (Turkey)', flag: '🇹🇷', locale: Locale('tr', 'TR')),
  _Lang(code: 'id_ID', nativeName: 'Indonesia', englishName: 'Indonesian (Indonesia)', flag: '🇮🇩', locale: Locale('id', 'ID')),
  _Lang(code: 'ms_MY', nativeName: 'Bahasa Melayu', englishName: 'Malay (Malaysia)', flag: '🇲🇾', locale: Locale('ms', 'MY')),
  _Lang(code: 'fil_PH', nativeName: 'Filipino', englishName: 'Filipino (Philippines)', flag: '🇵🇭', locale: Locale('fil', 'PH')),
  _Lang(code: 'vi_VN', nativeName: 'Tiếng Việt', englishName: 'Vietnamese (Vietnam)', flag: '🇻🇳', locale: Locale('vi', 'VN')),
  _Lang(code: 'th_TH', nativeName: 'ไทย', englishName: 'Thai (Thailand)', flag: '🇹🇭', locale: Locale('th', 'TH')),
  _Lang(code: 'he_IL', nativeName: 'עברית', englishName: 'Hebrew (Israel)', flag: '🇮🇱', locale: Locale('he', 'IL')),
  _Lang(code: 'fa_IR', nativeName: 'فارسی', englishName: 'Persian (Iran)', flag: '🇮🇷', locale: Locale('fa', 'IR')),
  _Lang(code: 'uk_UA', nativeName: 'Українська', englishName: 'Ukrainian (Ukraine)', flag: '🇺🇦', locale: Locale('uk', 'UA')),
  _Lang(code: 'pl_PL', nativeName: 'Polski', englishName: 'Polish (Poland)', flag: '🇵🇱', locale: Locale('pl', 'PL')),
  _Lang(code: 'nl_NL', nativeName: 'Nederlands', englishName: 'Dutch (Netherlands)', flag: '🇳🇱', locale: Locale('nl', 'NL')),
  _Lang(code: 'sv_SE', nativeName: 'Svenska', englishName: 'Swedish (Sweden)', flag: '🇸🇪', locale: Locale('sv', 'SE')),
  _Lang(code: 'no_NO', nativeName: 'Norsk', englishName: 'Norwegian (Norway)', flag: '🇳🇴', locale: Locale('no', 'NO')),
  _Lang(code: 'da_DK', nativeName: 'Dansk', englishName: 'Danish (Denmark)', flag: '🇩🇰', locale: Locale('da', 'DK')),
  _Lang(code: 'fi_FI', nativeName: 'Suomi', englishName: 'Finnish (Finland)', flag: '🇫🇮', locale: Locale('fi', 'FI')),
  _Lang(code: 'el_GR', nativeName: 'Ελληνικά', englishName: 'Greek (Greece)', flag: '🇬🇷', locale: Locale('el', 'GR')),
  _Lang(code: 'cs_CZ', nativeName: 'Čeština', englishName: 'Czech (Czechia)', flag: '🇨🇿', locale: Locale('cs', 'CZ')),
  _Lang(code: 'sk_SK', nativeName: 'Slovenčina', englishName: 'Slovak (Slovakia)', flag: '🇸🇰', locale: Locale('sk', 'SK')),
  _Lang(code: 'sl_SI', nativeName: 'Slovenščina', englishName: 'Slovenian (Slovenia)', flag: '🇸🇮', locale: Locale('sl', 'SI')),
  _Lang(code: 'hu_HU', nativeName: 'Magyar', englishName: 'Hungarian (Hungary)', flag: '🇭🇺', locale: Locale('hu', 'HU')),
  _Lang(code: 'ro_RO', nativeName: 'Română', englishName: 'Romanian (Romania)', flag: '🇷🇴', locale: Locale('ro', 'RO')),
  _Lang(code: 'bg_BG', nativeName: 'Български', englishName: 'Bulgarian (Bulgaria)', flag: '🇧🇬', locale: Locale('bg', 'BG')),
  _Lang(code: 'hr_HR', nativeName: 'Hrvatski', englishName: 'Croatian (Croatia)', flag: '🇭🇷', locale: Locale('hr', 'HR')),
  _Lang(code: 'sr_RS', nativeName: 'Српски', englishName: 'Serbian (Serbia)', flag: '🇷🇸', locale: Locale('sr', 'RS')),
  _Lang(code: 'lt_LT', nativeName: 'Lietuvių', englishName: 'Lithuanian (Lithuania)', flag: '🇱🇹', locale: Locale('lt', 'LT')),
  _Lang(code: 'lv_LV', nativeName: 'Latviešu', englishName: 'Latvian (Latvia)', flag: '🇱🇻', locale: Locale('lv', 'LV')),
  _Lang(code: 'et_EE', nativeName: 'Eesti', englishName: 'Estonian (Estonia)', flag: '🇪🇪', locale: Locale('et', 'EE')),
  _Lang(code: 'ka_GE', nativeName: 'ქართული', englishName: 'Georgian (Georgia)', flag: '🇬🇪', locale: Locale('ka', 'GE')),
  _Lang(code: 'az_AZ', nativeName: 'Azərbaycanca', englishName: 'Azerbaijani (Azerbaijan)', flag: '🇦🇿', locale: Locale('az', 'AZ')),
  _Lang(code: 'hy_AM', nativeName: 'Հայերեն', englishName: 'Armenian (Armenia)', flag: '🇦🇲', locale: Locale('hy', 'AM')),
  _Lang(code: 'af_ZA', nativeName: 'Afrikaans', englishName: 'Afrikaans (South Africa)', flag: '🇿🇦', locale: Locale('af', 'ZA')),
  _Lang(code: 'sw_KE', nativeName: 'Kiswahili', englishName: 'Swahili (Kenya)', flag: '🇰🇪', locale: Locale('sw', 'KE')),
  _Lang(code: 'am_ET', nativeName: 'አማርኛ', englishName: 'Amharic (Ethiopia)', flag: '🇪🇹', locale: Locale('am', 'ET')),
  _Lang(code: 'ur_PK', nativeName: 'اردو', englishName: 'Urdu (Pakistan)', flag: '🇵🇰', locale: Locale('ur', 'PK')),
  _Lang(code: 'ta_IN', nativeName: 'தமிழ்', englishName: 'Tamil (India)', flag: '🇮🇳', locale: Locale('ta', 'IN')),
  _Lang(code: 'te_IN', nativeName: 'తెలుగు', englishName: 'Telugu (India)', flag: '🇮🇳', locale: Locale('te', 'IN')),
  _Lang(code: 'ml_IN', nativeName: 'മലയാളം', englishName: 'Malayalam (India)', flag: '🇮🇳', locale: Locale('ml', 'IN')),
  _Lang(code: 'mr_IN', nativeName: 'मराठी', englishName: 'Marathi (India)', flag: '🇮🇳', locale: Locale('mr', 'IN')),
  _Lang(code: 'gu_IN', nativeName: 'ગુજરાતી', englishName: 'Gujarati (India)', flag: '🇮🇳', locale: Locale('gu', 'IN')),
  _Lang(code: 'kn_IN', nativeName: 'ಕನ್ನಡ', englishName: 'Kannada (India)', flag: '🇮🇳', locale: Locale('kn', 'IN')),
];


