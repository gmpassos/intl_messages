import 'dart:async';

import 'package:intl_messages/intl_messages.dart';
import 'package:test/test.dart';

void main() {
  group('Translator', () {
    test('basic', () async {
      var log = [];

      var t = _MyTranslator(logger: (o) => log.add(o), maxBlockLength: 18);

      var fromLocale = IntlLocale('en');
      var toLocale = IntlLocale('de');

      var results = await t.translate({
        'a': 'aaa',
        'b': 'bbb',
        'c': 'ccc',
        'd': 'ddd',
        'e': 'eee',
        'f': 'fff',
        'g': 'ggg',
        'h': 'hhh',
        'i': 'iii',
        'j': 'jjj',
      }, fromLocale, toLocale);

      expect(
          results,
          equals({
            'a': 'AAA',
            'b': 'BBB',
            'c': 'CCC',
            'd': 'DDD',
            'e': 'EEE',
            'f': 'FFF',
            'g': 'GGG',
            'h': 'HHH',
            'i': 'III',
            'j': 'JJJ',
          }));

      expect(
          t.blocksKeys,
          equals([
            ['a', 'b', 'c'],
            ['d', 'e', 'f'],
            ['g', 'h', 'i'],
            ['j']
          ]));
    });

    test('parallel(2)', () async {
      var log = [];

      var t = _MyTranslator(
          logger: (o) => log.add(o),
          maxBlockLength: 18,
          translateBlocksInParallel: true,
          maxParallelTranslations: 2);

      var fromLocale = IntlLocale('en');
      var toLocale = IntlLocale('de');

      var results = await t.translate({
        'a': 'aaa',
        'b': 'bbb',
        'c': 'ccc',
        'd': 'ddd',
        'e': 'eee',
        'f': 'fff',
        'g': 'ggg',
        'h': 'hhh',
        'i': 'iii',
        'j': 'jjj',
      }, fromLocale, toLocale);

      expect(
          results,
          equals({
            'a': 'AAA',
            'b': 'BBB',
            'c': 'CCC',
            'd': 'DDD',
            'e': 'EEE',
            'f': 'FFF',
            'g': 'GGG',
            'h': 'HHH',
            'i': 'III',
            'j': 'JJJ',
          }));

      expect(
          t.blocksKeys,
          equals([
            ['a', 'b', 'c'],
            ['d', 'e', 'f'],
            ['g', 'h', 'i'],
            ['j']
          ]));
    });

    test('cached', () async {
      var log = [];

      var cache = _MyTranslatorCache();

      var t = _MyTranslator(
          logger: (o) => log.add(o),
          maxBlockLength: 18,
          translateBlocksInParallel: true,
          maxParallelTranslations: 2,
          cache: cache);

      var fromLocale = IntlLocale('en');
      var toLocale = IntlLocale('de');

      expect(cache.get('a', 'aaa', fromLocale, toLocale), isNull);
      expect(cache.get('b', 'bbb', fromLocale, toLocale), isNull);
      expect(cache.get('x', 'xxx', fromLocale, toLocale), isNull);

      var results = await t.translate({
        'a': 'aaa',
        'b': 'bbb',
      }, fromLocale, toLocale);

      expect(
          results,
          equals({
            'a': 'AAA',
            'b': 'BBB',
          }));

      expect(cache.get('a', 'aaa', fromLocale, toLocale), equals('AAA'));
      expect(cache.get('b', 'bbb', fromLocale, toLocale), equals('BBB'));
      expect(cache.get('x', 'xxx', fromLocale, toLocale), isNull);

      expect(
          t.blocksKeys,
          equals([
            ['a', 'b'],
          ]));

      var results2 = await t.translate({
        'a': 'aaa',
        'b': 'bbb',
        'c': 'ccc',
        'd': 'ddd',
        'e': 'eee',
        'f': 'fff',
        'g': 'ggg',
        'h': 'hhh',
        'i': 'iii',
        'j': 'jjj',
      }, fromLocale, toLocale);

      expect(
          results2,
          equals({
            'a': 'AAA',
            'b': 'BBB',
            'c': 'CCC',
            'd': 'DDD',
            'e': 'EEE',
            'f': 'FFF',
            'g': 'GGG',
            'h': 'HHH',
            'i': 'III',
            'j': 'JJJ',
          }));

      expect(cache.get('i', 'iii', fromLocale, toLocale), equals('III'));
      expect(cache.get('j', 'jjj', fromLocale, toLocale), equals('JJJ'));
      expect(cache.get('x', 'xxx', fromLocale, toLocale), isNull);

      expect(
          t.blocksKeys,
          equals([
            ['a', 'b'],
            ['c', 'd', 'e'],
            ['f', 'g', 'h'],
            ['i', 'j']
          ]));
    });
  });
}

class _MyTranslator extends Translator {
  @override
  int maxBlockLength;

  _MyTranslator({
    super.logger,
    this.maxBlockLength = 5,
    super.translateBlocksInParallel,
    super.maxParallelTranslations,
    super.cache,
  });

  final List<List<String>> blocksKeys = [];

  @override
  FutureOr<Map<String, String>?> translateBlock(
      Map<String, String> entries,
      IntlLocale fromLocale,
      IntlLocale toLocale,
      String fromLanguage,
      String toLanguage,
      confirm) {
    blocksKeys.add(entries.keys.toList());
    return entries
        .map((key, value) => MapEntry(key, value.toUpperCase().trim()));
  }
}

class _MyTranslatorCache extends TranslatorCache {
  final Map<IntlLocale, Map<IntlLocale, Map<String, String>>> _cache = {};

  @override
  String? get(
      String key, String message, IntlLocale fromLocale, IntlLocale toLocale) {
    var mapFrom = _cache[fromLocale] ??= {};
    var mapTo = mapFrom[toLocale] ??= {};
    var translation = mapTo[key];
    return translation;
  }

  @override
  bool store(String key, String message, String translatedMessage,
      IntlLocale fromLocale, IntlLocale toLocale) {
    var mapFrom = _cache[fromLocale] ??= {};
    var mapTo = mapFrom[toLocale] ??= {};
    mapTo[key] = translatedMessage;
    return true;
  }
}
