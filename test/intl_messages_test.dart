import 'package:intl_messages/intl_messages.dart';
import 'package:swiss_knife/swiss_knife.dart';
import 'package:test/test.dart';

void main() {
  group('Message', () {
    LocalesManager? localesManager;

    setUpAll(() async {
      localesManager = _createLocalesManager();
      expect(localesManager, isNotNull);
    });

    test('Message.keyValue[simple]', () {
      var msg = Message.keyValue('foo', 'bar');

      expect(msg.key, equals('foo'));
      expect(msg.build(), equals('bar'));
    });

    test('Message.keyValue[var]', () {
      var msg = Message.keyValue('foo', 'The \$bar');

      expect(msg.key, equals('foo'));
      expect(msg.build({'bar': 'BAR', 'x': 123}), equals('The BAR'));
      expect(msg.build({'bar': 'BAZ', 'x': 123}), equals('The BAZ'));
    });

    test('Message.keyValue[plural]', () {
      var msg = Message.keyValue('foo',
          '{zero[n]:There are no emails for\\|to you \$user.|one[n]:You have 1 email.|two[n]:A pair of e-mails left.|many[n]:You have \$n emails left.|other[n]:Odd number of emails: \$n}');

      expect(msg.key, equals('foo'));

      expect(msg.build({'n': 0, 'user': 'John'}),
          equals('There are no emails for|to you John.'));
      expect(msg.build({'n': 1}), equals('You have 1 email.'));
      expect(msg.build({'n': 2}), equals('A pair of e-mails left.'));
      expect(msg.build({'n': 10}), equals('You have 10 emails left.'));
      expect(msg.build({'n': -1}), equals('Odd number of emails: -1'));
      expect(msg.build({'n': -2}), equals('Odd number of emails: -2'));
      expect(msg.build({'n': -5}), equals('Odd number of emails: -5'));
    });

    test('Message.line[simple]', () {
      var msg = Message.line('foo=bar');

      expect(msg.key, equals('foo'));
      expect(msg.build(), equals('bar'));
    });

    test('Message.line[var]:1', () {
      var msg = Message.line('foo=The \$bar!');

      expect(msg.key, equals('foo'));
      expect(msg.build({'bar': 'BAR', 'x': 123}), equals('The BAR!'));
      expect(msg.build({'bar': 'BAZ', 'x': 123}), equals('The BAZ!'));
    });

    test('Message.line[var]:2', () {
      var msg = Message.line('foo=The \\\$bar!');

      expect(msg.key, equals('foo'));
      expect(msg.build({'bar': 'BAZ'}), equals('The \$bar!'));
    });

    test('Message.line[var]:3', () {
      var msg = Message.line('foo=The\\n\$bar!');

      expect(msg.key, equals('foo'));
      expect(msg.build({'bar': 'BAR', 'x': 123}), equals('The\nBAR!'));
      expect(msg.build({'bar': 'BAZ', 'x': 123}), equals('The\nBAZ!'));
    });

    test('Message.entry[simple]', () {
      var msg = Message.entry({'key': 'foo', 'value': 'bar'});

      expect(msg.key, equals('foo'));
      expect(msg.build(), equals('bar'));
    });

    test('Message.entry[var]', () {
      var msg = Message.entry({
        'key': 'foo',
        'value': ['The ', '\$bar']
      });

      expect(msg.key, equals('foo'));
      expect(msg.build({'bar': 'BAR', 'x': 123}), equals('The BAR'));
      expect(msg.build({'bar': 'BAZ', 'x': 123}), equals('The BAZ'));
    });
  });

  group('IntlFallbackLanguage', () {
    setUp(() {});

    test('IntlFallbackLanguage', () {
      var fallbackLanguage = IntlFallbackLanguage('es');

      fallbackLanguage.set('de', 'en');

      expect(fallbackLanguage.get('de'), equals('en'));

      expect(fallbackLanguage.get('pt'), equals('es'));
    });
  });

  group('IntlResourceDiscover', () {
    LocalesManager? localesManager;
    String? testLocalesBaseUri;

    setUpAll(() async {
      localesManager = _createLocalesManager();
      expect(localesManager, isNotNull);
      testLocalesBaseUri = localesManager!.testLocalesBaseUri;
    });

    test('IntlResourceDiscover.findWithLocales', () async {
      var discover =
          IntlResourceDiscover('${testLocalesBaseUri}test-', '.intl');
      print(discover);

      var resources = await discover.findWithLocales(['fr']);
      print(resources.map((r) => r.uri).toList());

      expect(resources.length, equals(1));

      expect(resources.map((r) => r.locale).toList(), equals(['fr']));
    });
  });

  group('IntlResourceDiscover', () {
    LocalesManager? localesManager;
    String? testLocalesBaseUri;

    setUpAll(() async {
      localesManager = _createLocalesManager();
      expect(localesManager, isNotNull);
      testLocalesBaseUri = localesManager!.testLocalesBaseUri;
    });

    test('IntlResourceDiscover.findAll', () async {
      var discover =
          IntlResourceDiscover('${testLocalesBaseUri}test-', '.intl');
      var resources = await discover.findAll();
      print(resources.map((r) => r.uri).toList());

      expect(resources.length, equals(2));

      expect(resources.map((r) => r.locale).toList(), equals(['en', 'fr']));
    });

    test('IntlResourceDiscover.findWithLocales', () async {
      var discover =
          IntlResourceDiscover('${testLocalesBaseUri}test-', '.intl');
      var resources = await discover.findWithLocales(['fr']);
      print(resources.map((r) => r.uri).toList());

      expect(resources.length, equals(1));

      expect(resources.map((r) => r.locale).toList(), equals(['fr']));
    });
  });

  group('IntlMessages', () {
    LocalesManager? localesManager;
    String? testLocalesBaseUri;

    setUpAll(() async {
      localesManager = _createLocalesManager();
      expect(localesManager, isNotNull);
      testLocalesBaseUri = localesManager!.testLocalesBaseUri;
    });

    test('IntlMessages.registerMessagesResourcesContents', () async {
      IntlLocale.setDefaultLocale('EN');

      var package = IntlMessages.package('test-rsc1');
      expect(package.getRegisteredLocales(), equals([]));

      var discover =
          IntlResourceDiscover('${testLocalesBaseUri}test-', '.intl');

      var resources = await discover.findAll();
      expect(resources.length, equals(2));

      var reg = await package.registerMessagesResourcesContents(resources);
      expect(reg, equals(true));

      var registeredLocales = package.getRegisteredLocales();
      registeredLocales.sort();

      expect(registeredLocales, equals(['en', 'fr']));
    });

    test('IntlMessages.findAndRegisterMessagesResources', () async {
      IntlLocale.setDefaultLocale('EN');

      var package = IntlMessages.package('test-rsc2');
      expect(package.getRegisteredLocales(), equals([]));

      var discover =
          IntlResourceDiscover('${testLocalesBaseUri}test-', '.intl');

      var reg = await package.findAndRegisterMessagesResources(discover);
      expect(reg, equals(true));

      var registeredLocales = package.getRegisteredLocales();
      registeredLocales.sort();

      expect(registeredLocales, equals(['en', 'fr']));
    });

    test('IntlMessages.findAndRegisterMessagesResourcesWithLocales', () async {
      IntlLocale.setDefaultLocale('EN');

      var package = IntlMessages.package('test-rsc3');
      expect(package.getRegisteredLocales(), equals([]));

      var discover =
          IntlResourceDiscover('${testLocalesBaseUri}test-', '.intl');

      var reg = await (package
          .findAndRegisterMessagesResourcesWithLocales(discover, ['fr']));
      expect(reg, equals(true));

      var registeredLocales = package.getRegisteredLocales();
      registeredLocales.sort();

      expect(registeredLocales, equals(['fr']));
    });

    test('IntlMessages.discover', () async {
      IntlLocale.setDefaultLocale('EN');

      var package = IntlMessages.package('test-disc1');
      expect(package.getRegisteredLocales(), equals([]));

      var discover =
          IntlResourceDiscover('${testLocalesBaseUri}test-', '.intl');
      var reg = package.registerResourceDiscover(discover);

      var regComplete = reg.whenComplete(() {
        print('LOADED: $discover');
      });

      var msg = package.msg('foo');

      expect(msg.build(), isEmpty);
      expect(msg.message, equals(null));

      var onRegisterLocalizedMessages = <String>[];

      package.onRegisterLocalizedMessages
          .listen((l) => onRegisterLocalizedMessages.add(l));

      var found = await package.autoDiscover();

      print('discovered locales[1]: ${package.getRegisteredLocales()}');
      expect(found, equals(true));
      expect(discover.findCount, equals(28));

      print('onRegisterLocalizedMessages[1]: $onRegisterLocalizedMessages');
      expect(onRegisterLocalizedMessages, equals(['en']));

      expect(msg.build(), equals('x'));
      expect(msg.description, equals('Some description'));

      expect(await regComplete, isTrue);

      //////////

      var found2 = await package.setLocale(IntlLocale('fr'));

      print('discovered locales[2]: ${package.getRegisteredLocales()}');
      expect(found2, equals(true));
      expect(discover.findCount, equals(60));

      print('onRegisterLocalizedMessages[2]: $onRegisterLocalizedMessages');
      expect(onRegisterLocalizedMessages, equals(['en', 'fr']));

      expect(msg.build(), equals('a'));
    });

    test('IntlMessages.package[test]', () {
      IntlLocale.setDefaultLocale('EN');

      var packageTest1 = IntlMessages.package('test1');
      var packageTest2 = IntlMessages.package('test2');

      expect(packageTest1.getRegisteredLocales(), equals([]));
      expect(packageTest2.getRegisteredLocales(), equals([]));

      var localeEN = IntlLocale.code('en');
      var localeFR = IntlLocale('fr');

      packageTest1.registerMessages(localeEN, 'foo=x:\$n\nfuz=fx:\$n');
      packageTest2.registerMessages(localeEN.code, 'foo=y:\$n\nfuz=fy:\$n');

      packageTest1.registerMessages(localeFR.code, 'foo=a:\$n');
      packageTest2.registerMessages(localeFR, 'foo=b:\$n');

      var msgA1 = packageTest1.msg('foo');
      var msgA2 = packageTest2['foo'];

      var msgB1 = packageTest1.msg('fuz');
      var msgB2 = packageTest2['fuz'];

      expect(msgA1.key, equals('foo'));
      expect(msgA2.key, equals('foo'));

      expect(msgA1.build(), equals('x:'));
      expect(msgA2.build(), equals('y:'));

      expect(msgA1.build({'n': 10}), equals('x:10'));
      expect(msgA2.build({'n': 20}), equals('y:20'));

      expect(msgB1.build({'n': 100}), equals('fx:100'));
      expect(msgB2.build({'n': 200}), equals('fy:200'));

      IntlLocale.setDefaultLocale('FR');

      expect(msgA1.build(), equals('a:'));
      expect(msgA2.build(), equals('b:'));

      expect(msgA1.build({'n': 10}), equals('a:10'));
      expect(msgA2.build({'n': 20}), equals('b:20'));

      expect(msgB1.build({'n': 100}), equals('fx:100'));
      expect(msgB2.build({'n': 200}), equals('fy:200'));
    });

    test('IntlMessages.comments', () {
      IntlLocale.setDefaultLocale('EN');

      var packageTest1 = IntlMessages.package('comments1');

      expect(packageTest1.getRegisteredLocales(), equals([]));

      var localeEN = IntlLocale.code('en');
      var localeFR = IntlLocale('fr');

      packageTest1.registerMessages(
          localeEN, 'foo=x:\$n##Desc foo\nfuz=fx:\$n##Desc fuz!');

      packageTest1.registerMessages(
          localeFR.code, 'foo=a:\$n##Desc foo FR\nfuz=fa:\$n');

      var msgA1 = packageTest1.msg('foo');
      var msgB1 = packageTest1.msg('fuz');

      expect(msgA1.key, equals('foo'));

      expect(msgA1.build(), equals('x:'));

      expect(msgA1.description, equals('Desc foo'));
      expect(msgB1.description, equals('Desc fuz!'));

      expect(msgA1.build({'n': 10}), equals('x:10'));
      expect(msgB1.build({'n': 100}), equals('fx:100'));

      IntlLocale.setDefaultLocale('FR');

      expect(msgA1.build(), equals('a:'));

      expect(msgA1.description, equals('Desc foo FR'));
      expect(msgB1.description, equals('Desc fuz!'));

      expect(msgA1.build({'n': 10}), equals('a:10'));
      expect(msgB1.build({'n': 100}), equals('fa:100'));
    });

    test('IntlKey', () {
      IntlLocale.setDefaultLocale('EN');

      var packageTest1 = IntlMessages.package('intlkey');

      expect(packageTest1.getRegisteredLocales(), equals([]));

      var localeEN = IntlLocale.code('en');
      var localeFR = IntlLocale('fr');

      packageTest1.registerMessages(localeEN, 'foo=x:\$n\nfuz=fx:\$n');

      packageTest1.registerMessages(localeFR.code, 'foo=a:\$n\nfuz=fa:\$n');

      var keyA1 = packageTest1.key('foo');
      var keyB1 = packageTest1.key('fuz');

      expect(keyA1.key, equals('foo'));
      expect(keyA1.message, equals('x:'));

      expect(keyA1.withVariables({'n': 10}).message, equals('x:10'));
      expect(keyB1.withVariables({'n': 100}).message, equals('fx:100'));

      IntlLocale.setDefaultLocale('FR');

      expect(keyA1.message, equals('a:'));

      expect(keyA1.withVariables({'n': 10}).message, equals('a:10'));
      expect(keyB1.withVariables({'n': 100}).message, equals('fa:100'));
    });
  });

  group('Resource', () {
    setUp(() {});

    test('Message.keyValue[simple]', () {
      var pattern1 = RegExp(r'intl');
      var path1 = 'path/file-intl.txt';
      expect(replaceLocale(pattern1, path1, 'en'), equals('path/file-en.txt'));
      expect(replaceLocale(pattern1, path1, 'fr'), equals('path/file-fr.txt'));

      var pattern2 = RegExp(r'-(LOCALE)-intl');
      var path2 = 'path/file-LOCALE-intl.txt';
      expect(replaceLocale(pattern2, path2, 'en'),
          equals('path/file-en-intl.txt'));
      expect(replaceLocale(pattern2, path2, 'fr'),
          equals('path/file-fr-intl.txt'));
    });
  });

  group('IntlBasicDictionary', () {
    setUp(() {});

    test('msg', () {
      expect(IntlBasicDictionary.decimalDelimiter(IntlLocale.code('en')),
          equals('.'));
      expect(IntlBasicDictionary.decimalDelimiter(IntlLocale.code('es')),
          equals(','));

      expect(
          IntlBasicDictionary.decimalDelimiter(
              IntlLocale.code('xx'), IntlLocale.code('en')),
          equals('.'));
      expect(
          IntlBasicDictionary.decimalDelimiter(
              IntlLocale.code('xx'), IntlLocale.code('es')),
          equals(','));

      expect(IntlBasicDictionary.decimalDelimiter(IntlLocale.code('en_CA')),
          equals('.'));

      expect(IntlBasicDictionary.decimalDelimiter(IntlLocale.code('fr_CA')),
          equals(','));

      expect(IntlBasicDictionary.decimalDelimiter(IntlLocale.code('pt')),
          equals(','));

      expect(IntlBasicDictionary.decimalDelimiter(IntlLocale.code('fr')),
          equals(','));

      expect(IntlBasicDictionary.decimalDelimiter(IntlLocale.code('it')),
          equals(','));

      expect(IntlBasicDictionary.decimalDelimiter(IntlLocale.code('ru')),
          equals(','));

      expect(IntlBasicDictionary.decimalDelimiter(IntlLocale.code('en_UK')),
          equals('.'));

      expect(IntlBasicDictionary.decimalDelimiter(IntlLocale.code('en_GB')),
          equals('.'));

      expect(IntlBasicDictionary.decimalDelimiter(IntlLocale.code('en_AU')),
          equals('.'));

      expect(IntlBasicDictionary.decimalDelimiter(IntlLocale.code('en_XX')),
          equals('.'));

      expect(IntlBasicDictionary.decimalDelimiter(IntlLocale.code('fr_XX')),
          equals(','));

      expect(IntlBasicDictionary.decimalDelimiter(IntlLocale.code('zh')),
          equals('.'));

      // Arabic decimal separator (U+066B):
      expect(IntlBasicDictionary.decimalDelimiter(IntlLocale.code('ar')),
          equals('٫'));
    });

    test('msg', () {
      expect(IntlBasicDictionary.msg('help', IntlLocale.code('en')),
          equals('help'));
      expect(IntlBasicDictionary.msg('help', IntlLocale.code('pt')),
          equals('ajuda'));
      expect(
          IntlBasicDictionary.msg(
              'help', IntlLocale.code('en'), IntlLocale.code('pt')),
          equals('help'));
      expect(
          IntlBasicDictionary.msg(
              'help', IntlLocale.code('es'), IntlLocale.code('pt')),
          equals('ajuda'));
    });

    test('msgUpperCaseInitials', () {
      expect(
          IntlBasicDictionary.msgUpperCaseInitials(
              'help', IntlLocale.code('en')),
          equals('Help'));
      expect(
          IntlBasicDictionary.msgUpperCaseInitials(
              'help', IntlLocale.code('pt')),
          equals('Ajuda'));
      expect(
          IntlBasicDictionary.msgUpperCaseInitials(
              'help', IntlLocale.code('en'), IntlLocale.code('pt')),
          equals('Help'));
      expect(
          IntlBasicDictionary.msgUpperCaseInitials(
              'help', IntlLocale.code('es'), IntlLocale.code('pt')),
          equals('Ajuda'));
    });
  });

  group('IntlBasicDictionary', () {
    setUp(() {});

    test('getDateRangeTypeTitle', () {
      expect(getDateRangeTypeTitle(DateRangeType.today, IntlLocale.code('en')),
          equals('today'));
      expect(getDateRangeTypeTitle(DateRangeType.today, IntlLocale.code('pt')),
          equals('hoje'));

      expect(
          getDateRangeTypeTitle(DateRangeType.yesterday, IntlLocale.code('en')),
          equals('yesterday'));
      expect(
          getDateRangeTypeTitle(DateRangeType.yesterday, IntlLocale.code('pt')),
          equals('ontem'));

      expect(
          getDateRangeTypeTitle(DateRangeType.last7Days, IntlLocale.code('en')),
          equals('last 7 days'));
      expect(
          getDateRangeTypeTitle(DateRangeType.last7Days, IntlLocale.code('pt')),
          equals('últimos 7 dias'));

      expect(
          getDateRangeTypeTitle(
              DateRangeType.last30Days, IntlLocale.code('en')),
          equals('last 30 days'));
      expect(
          getDateRangeTypeTitle(
              DateRangeType.last30Days, IntlLocale.code('pt')),
          equals('últimos 30 dias'));

      expect(
          getDateRangeTypeTitle(
              DateRangeType.last60Days, IntlLocale.code('en')),
          equals('last 60 days'));
      expect(
          getDateRangeTypeTitle(
              DateRangeType.last60Days, IntlLocale.code('pt')),
          equals('últimos 60 dias'));

      expect(
          getDateRangeTypeTitle(
              DateRangeType.last90Days, IntlLocale.code('en')),
          equals('last 90 days'));
      expect(
          getDateRangeTypeTitle(
              DateRangeType.last90Days, IntlLocale.code('pt')),
          equals('últimos 90 dias'));

      expect(
          getDateRangeTypeTitle(DateRangeType.lastWeek, IntlLocale.code('en')),
          equals('last week'));
      expect(
          getDateRangeTypeTitle(DateRangeType.lastWeek, IntlLocale.code('pt')),
          equals('última semana'));

      expect(
          getDateRangeTypeTitle(DateRangeType.thisWeek, IntlLocale.code('en')),
          equals('this week'));
      expect(
          getDateRangeTypeTitle(DateRangeType.thisWeek, IntlLocale.code('pt')),
          equals('esta semana'));

      expect(
          getDateRangeTypeTitle(DateRangeType.lastMonth, IntlLocale.code('en')),
          equals('last month'));
      expect(
          getDateRangeTypeTitle(DateRangeType.lastMonth, IntlLocale.code('pt')),
          equals('último mês'));

      expect(
          getDateRangeTypeTitle(DateRangeType.thisMonth, IntlLocale.code('en')),
          equals('this month'));
      expect(
          getDateRangeTypeTitle(DateRangeType.thisMonth, IntlLocale.code('pt')),
          equals('este mês'));
    });
  });
}

LocalesManager _createLocalesManager() =>
    createLocalesManager((locale) async => ['en', 'fr'].contains(locale));

extension _LocalesManagerExtension on LocalesManager {
  String get testLocalesBaseUri => isBrowserURI ? '' : 'test/';
}
