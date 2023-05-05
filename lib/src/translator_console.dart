import 'dart:async';
import 'dart:io';

import 'intl_messages_base.dart';
import 'translator.dart';

/// Console translator.
class TranslatorConsole extends Translator {
  TranslatorConsole({super.logger, super.cache})
      : super(translateBlocksInParallel: false);

  @override
  int get maxBlockLength => 999999;

  @override
  Future<Map<String, String>?> translateBlock(
      Map<String, String> entries,
      IntlLocale fromLocale,
      IntlLocale toLocale,
      String fromLanguage,
      String toLanguage,
      confirm) async {
    stdout.write(
        '-------------------------------------------------------------\n');

    var entriesTranslated = <String, String>{};

    for (var e in entries.entries) {
      var k = e.key;
      var m = await promptTranslation(k, e.value, fromLocale, toLocale,
          fromLanguage: fromLanguage, toLanguage: toLanguage, confirm: confirm);

      entriesTranslated[k] = m;
      log('Translated> $k: $m');
    }

    return entriesTranslated;
  }

  /// Console translation prompt.
  Future<String> promptTranslation(
    String key,
    String message,
    IntlLocale fromLocale,
    IntlLocale toLocale, {
    String? fromLanguage,
    String? toLanguage,
    bool confirm = true,
  }) async {
    fromLanguage ??= resolveLocaleName(fromLocale);
    toLanguage ??= resolveLocaleName(toLocale);

    message = message.replaceAll(RegExp(r'\s+'), ' ').trim();

    while (true) {
      stdout.write(
          'TRANSLATE THE MESSAGE[$key] FROM `${fromLocale.code}` ($fromLanguage) TO `${toLocale.code}` ($toLanguage):\n\n');

      stdout.write('$message\n\n');

      stdout.write('> ');

      var line = stdin.readLineSync() ?? '';
      line = line.trim();

      if (!confirm) {
        return line;
      }

      var ok = confirmTranslation(key, line, fromLocale, toLocale,
          fromLanguage: fromLanguage, toLanguage: toLanguage);

      if (ok) {
        return line;
      }
    }
  }

  /// Console translation confirmation.
  bool confirmTranslation(
      String key, String message, IntlLocale fromLocale, IntlLocale toLocale,
      {String? fromLanguage, String? toLanguage}) {
    fromLanguage ??= resolveLocaleName(fromLocale);
    toLanguage ??= resolveLocaleName(toLocale);

    stdout.write(
        '\nCONFIRM TRANSLATION FROM `${fromLocale.code}` ($fromLanguage) TO `${toLocale.code}` ($toLanguage):\n\n');

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
