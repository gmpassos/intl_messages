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
            'hello': {'Oi!': 'Hello!'},
            'howAreYou': {'Como vai você?': 'How are you?'},
          },
        },
        IntlLocale.code('en'): {
          IntlLocale.code('pt'): {
            'hello': {'Hello!': 'Oi!'},
            'howAreYou': {'How are you?': 'Como vai você?'},
          },
        },
      });

      expect(
          translator.translate({
            'hello': 'Hello!',
            'howAreYou': 'HOW are you?',
          }, IntlLocale.code('en'), IntlLocale.code('pt')),
          equals({
            'hello': 'Oi!',
            'howAreYou': 'Como vai você?',
          }));

      expect(
          translator.translate({
            'hello': 'OI!',
            'howAreYou': 'Como vai você?',
          }, IntlLocale.code('pt'), IntlLocale.code('en')),
          equals({
            'hello': 'Hello!',
            'howAreYou': 'How are you?',
          }));
    });
  });
}
