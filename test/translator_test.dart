import 'dart:async';

import 'package:intl_messages/intl_messages.dart';
import 'package:test/test.dart';

void main() {
  group('Translator', () {
    test('basic', () async {
      var log = [];

      var t = _MyTranslator(logger: (o) => log.add(o), maxBlockLength: 18);

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
      }, IntlLocale('en'));

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
  });
}

class _MyTranslator extends Translator {
  @override
  int maxBlockLength;

  _MyTranslator({super.logger, this.maxBlockLength = 5});

  final List<List<String>> blocksKeys = [];

  @override
  FutureOr<Map<String, String>?> translateBlock(Map<String, String> entries,
      IntlLocale locale, String language, confirm) {
    blocksKeys.add(entries.keys.toList());
    return entries
        .map((key, value) => MapEntry(key, value.toUpperCase().trim()));
  }
}
