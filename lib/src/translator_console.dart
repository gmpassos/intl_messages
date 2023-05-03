import 'dart:async';
import 'dart:io';

import 'intl_messages_base.dart';
import 'translator.dart';

/// Console translator.
class TranslatorConsole extends Translator {
  TranslatorConsole({super.logger});

  @override
  int get maxBlockLength => 999999;

  @override
  Future<Map<String, String>?> translateBlock(Map<String, String> entries,
      IntlLocale locale, String language, confirm) async {
    stdout.write(
        '-------------------------------------------------------------\n');

    var entriesTranslated = <String, String>{};

    for (var e in entries.entries) {
      var k = e.key;
      var m = await promptTranslation(k, e.value, locale,
          confirm: confirm, language: language);

      entriesTranslated[k] = m;
      log('Translated> $k: $m');
    }

    return entriesTranslated;
  }

  /// Console translation prompt.
  Future<String> promptTranslation(
      String key, String message, IntlLocale locale,
      {bool confirm = true, String? language}) async {
    language ??= resolveLocaleName(locale);

    message = message.replaceAll(RegExp(r'\s+'), ' ').trim();

    while (true) {
      stdout.write(
          'TRANSLATE THE MESSAGE[$key] TO `${locale.code}` ($language):\n\n');

      stdout.write('$message\n\n');

      stdout.write('> ');

      var line = stdin.readLineSync() ?? '';
      line = line.trim();

      if (!confirm) {
        return line;
      }

      var ok = confirmTranslation(key, line, locale, language: language);

      if (ok) {
        return line;
      }
    }
  }

  /// Console translation confirmation.
  bool confirmTranslation(String key, String message, IntlLocale locale,
      {String? language}) {
    language ??= resolveLocaleName(locale);

    stdout.write('\nCONFIRM TRANSLATION FOR `${locale.code}` ($language):\n\n');

    stdout.write('`$message`\n\n');

    stdout.write('(y/n)> ');

    var confirm = stdin.readLineSync() ?? '';
    confirm = confirm.trim().toLowerCase();

    var ok = confirm == 'y' ||
        confirm == 's' ||
        confirm == 'yes' ||
        confirm == 'sim' ||
        confirm == 'ok';
    return ok;
  }
}
