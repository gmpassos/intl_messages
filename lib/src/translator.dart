import 'intl_messages_base.dart';
import 'locales.dart';
import 'package:async_extension/async_extension.dart';
import 'package:collection/collection.dart';

/// Translator base class.
abstract class Translator {
  /// Optional logger.
  final void Function(Object? o)? logger;

  final bool translateBlocksInParallel;
  final int maxParallelTranslations;

  Translator(
      {this.logger,
      this.translateBlocksInParallel = false,
      this.maxParallelTranslations = 0});

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

    FutureOr<List<Map<String, String>?>> results;

    if (translateBlocksInParallel && maxParallelTranslations != 1) {
      if (maxParallelTranslations <= 0) {
        results = _translateBlocksParallel(blocks, locale, language, confirm);
      } else {
        assert(maxParallelTranslations != 1);
        results = _translateBlocksParallelLimited(
            blocks, locale, language, confirm, maxParallelTranslations);
      }
    } else {
      results = _translateBlocksInSequence(blocks, locale, language, confirm);
    }

    return results.resolveMapped((results) {
      var allResults =
          results.whereNotNull().reduce((map, e) => map..addAll(e));
      return allResults;
    });
  }

  FutureOr<List<Map<String, String>?>> _translateBlocksParallel(
      List<List<MapEntry<String, String>>> blocks,
      IntlLocale locale,
      String language,
      bool confirm) {
    var results = blocks
        .map((blk) =>
            translateBlock(Map.fromEntries(blk), locale, language, confirm))
        .resolveAll();
    return results;
  }

  Future<List<Map<String, String>?>> _translateBlocksParallelLimited(
      List<List<MapEntry<String, String>>> blocks,
      IntlLocale locale,
      String language,
      bool confirm,
      int limit) async {
    var split =
        blocks.splitBeforeIndexed((i, e) => i > 0 && i % limit == 0).toList();

    final allResults = <Map<String, String>?>[];

    for (var blocks in split) {
      var results = await blocks
          .map((blk) =>
              translateBlock(Map.fromEntries(blk), locale, language, confirm))
          .resolveAll();

      allResults.addAll(results);
    }

    return allResults;
  }

  Future<List<Map<String, String>?>> _translateBlocksInSequence(
      List<List<MapEntry<String, String>>> blocks,
      IntlLocale locale,
      String language,
      bool confirm) async {
    final allResults = <Map<String, String>?>[];

    for (var blk in blocks) {
      var result =
          await translateBlock(Map.fromEntries(blk), locale, language, confirm);

      allResults.add(result);
    }

    return allResults;
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
