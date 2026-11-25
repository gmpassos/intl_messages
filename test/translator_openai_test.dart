import 'package:intl_messages/intl_messages.dart';
import 'package:intl_messages/src/translator_openai.dart';
import 'package:test/test.dart';

void main() {
  group('TranslatorOpenAI', () {
    test('defaults', () {
      expect(TranslatorOpenAI.defaultModel, equals('gpt-6-luna'));

      var t = TranslatorOpenAI(apiKey: 'test-key');
      expect(t.apiKey, equals('test-key'));
      expect(t.model, equals('gpt-6-luna'));
      expect(t.maxBlockLength, equals(500));
      expect(t.maxRetries, equals(3));
      expect(t.translateBlocksInParallel, isTrue);
      expect(t.maxParallelTranslations, equals(2));
    });

    test('custom model and clamped parallelism', () {
      var t = TranslatorOpenAI(
        apiKey: 'k',
        model: 'custom-model',
        maxBlockLength: 100,
        maxParallelTranslations: 50,
      );
      expect(t.model, equals('custom-model'));
      expect(t.maxBlockLength, equals(100));
      expect(t.maxParallelTranslations, equals(10));

      expect(
        TranslatorOpenAI(
          apiKey: 'k',
          maxParallelTranslations: 0,
        ).maxParallelTranslations,
        equals(1),
      );
    });

    group('parseResult', () {
      final t = TranslatorOpenAI(apiKey: 'k');

      test('`key=message` lines', () {
        expect(
          t.parseResult({
            'hello': 'Hello',
            'bye': 'Bye',
          }, 'hello=Bonjour\n\n  bye=Au revoir  \n'),
          equals({'hello': 'Bonjour', 'bye': 'Au revoir'}),
        );
      });

      test('`key: message` fallback and lines without separator', () {
        expect(
          t.parseResult({
            'hello': 'Hello',
            'bye': 'Bye',
          }, 'Here is the translation\nhello: Bonjour\nbye=Au revoir'),
          equals({'hello': ' Bonjour', 'bye': 'Au revoir'}),
        );
      });

      test('case-insensitive keys', () {
        expect(
          t.parseResult({'helloWorld': 'Hello world'}, 'HELLOWORLD=Bonjour'),
          equals({'helloWorld': 'Bonjour'}),
        );
      });

      test('ignores unknown keys', () {
        expect(t.parseResult({'a': 'A'}, 'a=x\nzzz=y'), equals({'a': 'x'}));
      });

      test('positional fallback when keys were altered', () {
        expect(
          t.parseResult({'a': 'One', 'b': 'Two'}, 'x=Un\ny=Deux'),
          equals({'a': 'Un', 'b': 'Deux'}),
        );
      });

      test('`key=`/`translation=` pairs (both orders)', () {
        expect(
          t.parseResult({
            'a': 'One',
            'b': 'Two',
          }, 'key=a\ntranslation=Un\ntranslation=Deux\nkey=b'),
          equals({'a': 'Un', 'b': 'Deux'}),
        );
      });

      test('odd `key=`/`translation=` lines do not throw', () {
        // A truncated pair list: the unpaired last line is dropped.
        expect(
          t.parseResult({
            'a': 'One',
            'b': 'Two',
          }, 'key=a\ntranslation=Un\nkey=b'),
          equals({'a': 'Un'}),
        );

        // Only echoed `key=` lines: nothing pairs, and the key names must not
        // come back (positionally) as translations.
        expect(
          t.parseResult({'a': 'One', 'b': 'Two'}, 'key=a\nkey=b'),
          isEmpty,
        );
      });

      test('message keys `key`/`translation` are not re-paired', () {
        expect(
          t.parseResult({'key': 'Key'}, 'key=Clé'),
          equals({'key': 'Clé'}),
        );
        expect(
          t.parseResult({
            'key': 'Key',
            'translation': 'Translation',
          }, 'key=Clé\ntranslation=Traduction'),
          equals({'key': 'Clé', 'translation': 'Traduction'}),
        );
        // The second prompt's `key=message` header echoed back:
        expect(
          t.parseResult({
            'translation': 'Translation',
          }, 'key=message\ntranslation=Traduction'),
          equals({'translation': 'Traduction'}),
        );
      });

      test('normalizes `original -> translation`', () {
        expect(
          t.parseResult({'a': 'Good  morning'}, 'a=good morning -> Bonjour'),
          equals({'a': 'Bonjour'}),
        );
        // Not prefixed by the original message: kept as-is.
        expect(t.parseResult({'a': 'Hi'}, 'a=x -> y'), equals({'a': 'x -> y'}));
      });

      test('normalizes a repeated `key=` prefix', () {
        expect(t.parseResult({'a': 'Hi'}, 'a=a=Salut'), equals({'a': 'Salut'}));
      });
    });

    group('validateTranslation', () {
      final logs = <String>[];
      final t = TranslatorOpenAI(apiKey: 'k', logger: (o) => logs.add('$o'));

      test('all translated', () {
        expect(t.validateTranslation({'a': 'One'}, {'a': 'Un'}, 1), isNull);
      });

      test('untranslated keys (case/space-insensitive)', () {
        logs.clear();
        expect(
          t.validateTranslation(
            {'a': 'One', 'b': 'Two', 'c': 'Three'},
            {'a': 'Un', 'b': ' TWO ', 'c': 'three'},
            7,
          ),
          equals(['b', 'c']),
        );
        expect(logs.single, startsWith('NOT TRANSLATED[7] KEYS>'));
      });

      test('missing or empty translation is reported', () {
        expect(
          t.validateTranslation(
            {'a': 'One', 'b': 'Two', 'c': 'Three'},
            {'a': 'Un', 'c': ' '},
            1,
          ),
          equals(['b', 'c']),
        );
      });

      test('empty message needs no translation', () {
        expect(t.validateTranslation({'a': ' '}, {}, 1), isNull);
        expect(t.validateTranslation({'a': ''}, {'a': ''}, 1), isNull);
      });
    });

    group('translateBlock', () {
      final en = IntlLocale('en');
      final fr = IntlLocale('fr');

      test('first response valid: single prompt', () async {
        var t = _FakeTranslatorOpenAI(['a=Un\nb=Deux']);

        var r = await t.translateBlock(
          {'a': ' One ', 'b': 'Two\n  lines'},
          en,
          fr,
          'English',
          'French',
          false,
        );

        expect(r, equals({'a': 'Un', 'b': 'Deux'}));
        expect(t.prompts, hasLength(1));
        // Messages are trimmed and whitespace is collapsed into one line each:
        expect(t.prompts.single.prompt, equals('a=One\nb=Two lines'));
        expect(t.prompts.single.instruction, contains('into French'));
      });

      test('first response invalid: second prompt used', () async {
        var t = _FakeTranslatorOpenAI(['a=One\nb=Deux', 'a=Un\nb=Deux']);

        var r = await t.translateBlock(
          {'a': 'One', 'b': 'Two'},
          en,
          fr,
          'English',
          'French',
          false,
        );

        expect(r, equals({'a': 'Un', 'b': 'Deux'}));
        expect(t.prompts, hasLength(2));
        expect(t.prompts[1].prompt, equals('key=message\na=One\nb=Two\n'));
        expect(t.prompts[1].instruction, contains('to French'));
      });

      test('both partially invalid: valid entries merged', () async {
        var logs = <String>[];
        var t = _FakeTranslatorOpenAI([
          'a=Un\nb=Two\nc=Three',
          'a=One\nb=Deux\nc=Three',
        ], logger: (o) => logs.add('$o'));

        var r = await t.translateBlock(
          {'a': 'One', 'b': 'Two', 'c': 'Three'},
          en,
          fr,
          'English',
          'French',
          false,
        );

        // `c` was never translated: returned as the model gave it.
        expect(r, equals({'a': 'Un', 'b': 'Deux', 'c': 'Three'}));
        expect(logs, contains('FIXED TRANSLATION[3]>'));
        expect(logs, contains('** NOT TRANSLATED KEY> c: Three'));
      });

      test('truncated first response: retried', () async {
        var t = _FakeTranslatorOpenAI(['a=Un', 'a=Un\nb=Deux']);

        var r = await t.translateBlock(
          {'a': 'One', 'b': 'Two'},
          en,
          fr,
          'English',
          'French',
          false,
        );

        expect(r, equals({'a': 'Un', 'b': 'Deux'}));
        expect(t.prompts, hasLength(2));
      });

      test('second prompt header avoids an entry named `key`', () async {
        var t = _FakeTranslatorOpenAI(['key=Key', 'key=Clé']);

        var r = await t.translateBlock(
          {'key': 'Key'},
          en,
          fr,
          'English',
          'French',
          false,
        );

        expect(r, equals({'key': 'Clé'}));
        expect(t.prompts[1].prompt, equals('key__0=message\nkey=Key\n'));
      });

      test('empty or null responses', () async {
        var entries = {'a': 'One'};

        expect(
          await _FakeTranslatorOpenAI([null])
              .translateBlock(entries, en, fr, 'English', 'French', false),
          isNull,
        );

        expect(
          await _FakeTranslatorOpenAI(['a=One', ''])
              .translateBlock(entries, en, fr, 'English', 'French', false),
          isNull,
        );
      });

      test('through `Translator.translate`', () async {
        var t = _FakeTranslatorOpenAI(['hello=Bonjour']);

        var r = await t.translate({'hello': 'Hello'}, en, fr, confirm: false);

        expect(r, equals({'hello': 'Bonjour'}));
        expect(t.prompts.single.instruction, contains('French'));
      });
    });
  });
}

/// A [TranslatorOpenAI] that answers [prompt] from scripted [responses]
/// instead of calling the OpenAI API, so the block translation and response
/// parsing logic can be tested offline.
class _FakeTranslatorOpenAI extends TranslatorOpenAI {
  final List<String?> responses;

  /// The prompts received, in order.
  final List<({String prompt, String? instruction})> prompts = [];

  _FakeTranslatorOpenAI(this.responses, {super.logger}) : super(apiKey: 'fake');

  @override
  Future<String?> prompt(String prompt, {String? instruction, int? n}) async {
    prompts.add((prompt: prompt, instruction: instruction));
    return responses[prompts.length - 1];
  }
}
