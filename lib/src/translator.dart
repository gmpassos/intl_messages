import 'intl_messages_base.dart';
import 'locales.dart';
import 'package:async_extension/async_extension.dart';
import 'package:collection/collection.dart';

/// Translator base class.
abstract class Translator {
  /// Optional logger.
  final void Function(Object? o)? logger;

  Translator({this.logger});

  /// Logs [o ] calling [logger].
  void log(Object o) {
    var logger = this.logger;
    if (logger != null) {
      logger(o);
    }
  }

  /// Resolves [locale] to the language name.
  String resolveLocaleName(IntlLocale locale) => getLocaleName(locale.code);

  /// Translates [entries] to [locale].
  FutureOr<Map<String, String>?> translate(
      Map<String, String> entries, IntlLocale locale,
      {bool confirm = true}) {
    String language = resolveLocaleName(locale);

    var allEntries = entries.entries.toList();

    var blocks = splitBlocks(allEntries);

    var results = blocks
        .map((blk) =>
            translateBlock(Map.fromEntries(blk), locale, language, confirm))
        .resolveAll();

    return results.resolveMapped((results) {
      var allResults =
          results.whereNotNull().reduce((map, e) => map..addAll(e));
      return allResults;
    });
  }

  /// Returns the maximum length of a block.
  /// See [splitBlocks].
  int get maxBlockLength;

  /// Split [entries] into blocks.
  List<List<MapEntry<String, String>>> splitBlocks(
      List<MapEntry<String, String>> entries) {
    var cursor = 0;

    var blocks = entries.splitBeforeIndexed((i, e) {
      var lng = (i - cursor) + 1;
      if (lng == 0) return false;

      var prevLength = entries
          .sublist(cursor, i + 1)
          .map((e) => e.key.length + e.value.length + 2)
          .sum;

      if (prevLength > maxBlockLength) {
        cursor = i;
        return true;
      } else {
        return false;
      }
    }).toList();

    return blocks;
  }

  /// Translates an entries block.
  /// Called by [translate].
  FutureOr<Map<String, String>?> translateBlock(
      Map<String, String> entries, IntlLocale locale, String language, confirm);
}
