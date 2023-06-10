import 'package:test/test.dart';
import 'package:intl_messages/intl_messages.dart';

void main() {
  group('Translator', () {
    test('TranslatorInMemory', () {
      final log = <String>[];

      void logger(m) {
        log.add('$m');
        print('[Translator] $m');
      }

      var translator = TranslatorInMemory(logger: logger);

      translator.addAllTranslations({
        IntlLocale.code('pt'): {
          IntlLocale.code('en'): {
            'hello': 'Hello!',
            'howAreYou': 'How are you?',
          },
        },
        IntlLocale.code('en'): {
          IntlLocale.code('pt'): {
            'hello': 'Oi!',
            'howAreYou': 'Como vai você?',
          },
        },
      });

      expect(
          translator.translate({
            'hello': 'hello',
            'howAreYou': 'how are you',
          }, IntlLocale.code('en'), IntlLocale.code('pt')),
          equals({
            'hello': 'Oi!',
            'howAreYou': 'Como vai você?',
          }));

      expect(
          translator.translate({
            'hello': 'oi',
            'howAreYou': 'como vai vc?',
          }, IntlLocale.code('pt'), IntlLocale.code('en')),
          equals({
            'hello': 'Hello!',
            'howAreYou': 'How are you?',
          }));
    });
  });
}
