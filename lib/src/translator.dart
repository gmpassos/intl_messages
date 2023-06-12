import 'package:async_extension/async_extension.dart';
import 'package:collection/collection.dart';

import 'intl_messages_base.dart';
import 'locales.dart';

/// [Translator] logger.
typedef TranslatorLogger = void Function(Object? o);

/// Translator base class.
abstract class Translator {
  /// Optional logger.
  final TranslatorLogger? logger;

  /// Optional [Translator] cache.
  final TranslatorCache? cache;

  final bool translateBlocksInParallel;
  final int maxParallelTranslations;

  Translator(
      {this.logger,
      this.cache,
      this.translateBlocksInParallel = false,
      this.maxParallelTranslations = 0});

  /// Logs [o] calling [logger].
  void log(Object o) {
    var logger = this.logger;
    if (logger != null) {
      logger(o);
    }
  }

  /// Resolves [locale] to the language name.
  String resolveLocaleName(IntlLocale locale) => getLocaleName(locale.code);

  /// Returns the cached translations for [entries] (if [cache] is provided).
  FutureOr<Map<String, String>?> getCachedEntries(
    Map<String, String> entries,
    IntlLocale fromLocale,
    IntlLocale toLocale,
  ) {
    var cache = this.cache;
    if (cache == null) return null;

    var results = Map.fromEntries(entries.entries.map((e) {
      var k = e.key;
      var t = cache.get(k, e.value, fromLocale, toLocale);
      return t != null ? MapEntry(k, t) : null;
    }).whereNotNull())
        .resolveAllValues();

    return results.resolveMapped((map) {
      var mapCached = Map<String, String>.fromEntries(map.entries.where((e) {
        var m = e.value;
        return m != null && m.trim().isNotEmpty;
      }).map((e) => MapEntry(e.key, e.value!)));

      return mapCached;
    });
  }

  /// Cache translated [entries] (if [cache] is provided).
  FutureOr<List<bool>?> cacheEntries(
    Map<String, String> entries,
    Map<String, String> translations,
    IntlLocale fromLocale,
    IntlLocale toLocale,
  ) {
    var cache = this.cache;
    if (cache == null) return null;

    var results = entries.entries.map((e) {
      var k = e.key;
      var m = entries[k];
      if (m == null || m.trim().isEmpty) return false;
      var t = translations[k];
      if (t == null || t.trim().isEmpty) return false;
      return cache.store(k, m, t, fromLocale, toLocale);
    }).resolveAll();

    return results;
  }

  /// Translates [entries] to [locale].
  FutureOr<Map<String, String>?> translate(
      Map<String, String> entries, IntlLocale fromLocale, IntlLocale toLocale,
      {bool confirm = true}) {
    if (fromLocale == toLocale) {
      return entries;
    }

    var fromLanguage = resolveLocaleName(fromLocale);
    var toLanguage = resolveLocaleName(toLocale);

    if (fromLanguage == toLanguage) {
      return entries;
    }

    var cachedTranslation = getCachedEntries(entries, fromLocale, toLocale);

    if (cachedTranslation != null) {
      return cachedTranslation.resolveMapped((cachedTranslation) =>
          _translateEntries(entries, cachedTranslation, fromLocale, toLocale,
              fromLanguage, toLanguage, confirm));
    } else {
      return _translateEntries(entries, null, fromLocale, toLocale,
          fromLanguage, toLanguage, confirm);
    }
  }

  FutureOr<Map<String, String>?> _translateEntries(
      Map<String, String> entries,
      Map<String, String>? cachedEntries,
      IntlLocale fromLocale,
      IntlLocale toLocale,
      String fromLanguage,
      String toLanguage,
      bool confirm) {
    var entriesToRequest = Map<String, String>.from(entries);

    Map<String, String>? cachedTranslation;
    if (cachedEntries != null && cachedEntries.isNotEmpty) {
      var cachedTranslationEntries = entries.entries
          .map((e) {
            var k = e.key;
            var m = cachedEntries[k];
            return m != null && m.trim().isNotEmpty ? MapEntry(k, m) : null;
          })
          .whereNotNull()
          .toList();

      cachedTranslation = Map.fromEntries(cachedTranslationEntries);

      if (cachedTranslation.length == entries.length) {
        return cachedTranslation;
      } else {
        entriesToRequest
            .removeWhere((k, _) => cachedTranslation!.containsKey(k));
      }
    }

    var allEntries = entriesToRequest.entries.toList();

    var blocks = splitBlocks(allEntries);

    if (blocks.isEmpty) return {};

    FutureOr<List<Map<String, String>?>> results;

    if (translateBlocksInParallel && maxParallelTranslations != 1) {
      if (maxParallelTranslations <= 0) {
        results = _translateBlocksParallel(
            blocks, fromLocale, toLocale, fromLanguage, toLanguage, confirm);
      } else {
        assert(maxParallelTranslations != 1);
        results = _translateBlocksParallelLimited(blocks, fromLocale, toLocale,
            fromLanguage, toLanguage, confirm, maxParallelTranslations);
      }
    } else if (blocks.length == 1) {
      return _translateBlockAndCache(blocks.first, fromLocale, toLocale,
          fromLanguage, toLanguage, confirm);
    } else {
      results = _translateBlocksInSequence(
          blocks, fromLocale, toLocale, fromLanguage, toLanguage, confirm);
    }

    return results.resolveMapped((results) {
      var resultsNotNull = results.whereNotNull().toList();

      var allResults = resultsNotNull.isNotEmpty
          ? resultsNotNull.reduce((map, e) => map..addAll(e))
          : <String, String>{};

      if (cachedTranslation != null) {
        allResults.addAll(cachedTranslation);
      }

      return allResults;
    });
  }

  FutureOr<List<Map<String, String>?>> _translateBlocksParallel(
      List<List<MapEntry<String, String>>> blocks,
      IntlLocale fromLocale,
      IntlLocale toLocale,
      String fromLanguage,
      String toLanguage,
      bool confirm) {
    var results = blocks
        .map((blk) => _translateBlockAndCache(
            blk, fromLocale, toLocale, fromLanguage, toLanguage, confirm))
        .resolveAll();
    return results;
  }

  Future<List<Map<String, String>?>> _translateBlocksParallelLimited(
      List<List<MapEntry<String, String>>> blocks,
      IntlLocale fromLocale,
      IntlLocale toLocale,
      String fromLanguage,
      String toLanguage,
      bool confirm,
      int limit) async {
    var split =
        blocks.splitBeforeIndexed((i, e) => i > 0 && i % limit == 0).toList();

    final allResults = <Map<String, String>?>[];

    for (var blocks in split) {
      var results = await blocks
          .map((blk) => _translateBlockAndCache(
              blk, fromLocale, toLocale, fromLanguage, toLanguage, confirm))
          .resolveAll();

      allResults.addAll(results);
    }

    return allResults;
  }

  Future<List<Map<String, String>?>> _translateBlocksInSequence(
      List<List<MapEntry<String, String>>> blocks,
      IntlLocale fromLocale,
      IntlLocale toLocale,
      String fromLanguage,
      String toLanguage,
      bool confirm) async {
    final allResults = <Map<String, String>?>[];

    for (var blk in blocks) {
      var result = await _translateBlockAndCache(
          blk, fromLocale, toLocale, fromLanguage, toLanguage, confirm);

      allResults.add(result);
    }

    return allResults;
  }

  FutureOr<Map<String, String>?> _translateBlockAndCache(
      List<MapEntry<String, String>> block,
      IntlLocale fromLocale,
      IntlLocale toLocale,
      String fromLanguage,
      String toLanguage,
      bool confirm) {
    final blockEntries = Map.fromEntries(block);

    return translateBlock(blockEntries, fromLocale, toLocale, fromLanguage,
            toLanguage, confirm)
        .then((translations) {
      if (translations != null && translations.isNotEmpty) {
        cacheEntries(blockEntries, translations, fromLocale, toLocale);
      }
      return translations;
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
      Map<String, String> entries,
      IntlLocale fromLocale,
      IntlLocale toLocale,
      String fromLanguage,
      String toLanguage,
      bool confirm);
}

/// Base class for a [Translator] cache.
abstract class TranslatorCache {
  final TranslatorLogger? logger;

  TranslatorCache({this.logger});

  /// Logs [o] calling [logger].
  void log(Object o) {
    var logger = this.logger;
    if (logger != null) {
      logger(o);
    }
  }

  FutureOr<String?> get(
      String key, String message, IntlLocale fromLocale, IntlLocale toLocale);

  FutureOr<bool> store(String key, String message, String translatedMessage,
      IntlLocale fromLocale, IntlLocale toLocale);
}

/// A Translator with a inn-memory set of translations.
/// - Useful for unit tests.
class TranslatorInMemory extends Translator {
  TranslatorInMemory({super.logger});

  @override
  int get maxBlockLength => 999999;

  @override
  FutureOr<Map<String, String>?> translateBlock(
      Map<String, String> entries,
      IntlLocale fromLocale,
      IntlLocale toLocale,
      String fromLanguage,
      String toLanguage,
      bool confirm) {
    var translation = entries.map((key, msg) =>
        MapEntry(key, translateEntry(fromLocale, toLocale, key, msg)));
    return translation;
  }

  final Map<String, Map<String, Map<String, Map<String, String>>>>
      _translations = {};

  /// Clears the in-memory set of translations.
  void clearTranslations() => _translations.clear();

  /// Adds a translation to the in-memory set.
  void addTranslation(IntlLocale fromLocale, IntlLocale toLocale, String key,
      String message, String translation) {
    var from = _translations[fromLocale.code] ??= {};
    var to = from[toLocale.code] ??= {};
    var entries = to[key] ??= {};

    entries[_simplifyMessage(message)] = translation;
  }

  static String _simplifyMessage(String m) => m.toLowerCase().trim();

  /// Add all entries in [translations] to the in-memory set.
  /// See [addTranslation].
  void addTranslations(IntlLocale fromLocale, IntlLocale toLocale,
      Map<String, Map<String, String>> translations) {
    for (var e in translations.entries) {
      for (var t in e.value.entries) {
        addTranslation(fromLocale, toLocale, e.key, t.key, t.value);
      }
    }
  }

  /// Adds all translations in [translations] [Map].
  /// See [addTranslations];
  void addAllTranslations(
      Map<IntlLocale, Map<IntlLocale, Map<String, Map<String, String>>>>
          translations) {
    for (var fromEntry in translations.entries) {
      final fromLocale = fromEntry.key;

      for (var toEntry in fromEntry.value.entries) {
        final toLocale = toEntry.key;

        addTranslations(fromLocale, toLocale, toEntry.value);
      }
    }
  }

  String translateEntry(
      IntlLocale fromLocale, IntlLocale toLocale, String key, String message) {
    var from = _translations[fromLocale.code] ??= {};
    var to = from[toLocale.code] ??= {};

    var entries = to[key] ??= {};

    var m = _simplifyMessage(message);

    var t = entries[m];

    return t ??= message;
  }
}
