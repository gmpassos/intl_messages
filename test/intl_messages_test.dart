import 'package:intl_messages/intl_messages.dart';
import 'package:test/test.dart';

void main() {
  group('Message', () {
    setUp(() {});

    test('Message.keyValue[simple]', () {
      var msg = Message.keyValue("foo", "bar");

      expect(msg.key, equals("foo"));
      expect(msg.build(), equals("bar"));
    });

    test('Message.keyValue[var]', () {
      var msg = Message.keyValue("foo", 'The \$bar');

      expect(msg.key, equals("foo"));
      expect(msg.build({'bar': 'BAR', 'x': 123}), equals("The BAR"));
      expect(msg.build({'bar': 'BAZ', 'x': 123}), equals("The BAZ"));
    });

    test('Message.keyValue[plural]', () {
      var msg = Message.keyValue("foo",
          '{zero[n]:There are no emails for\\|to you \$user.|one[n]:You have 1 email.|two[n]:A pair of e-mails left.|many[n]:You have \$n emails left.|other[n]:Odd number of emails: \$n}');

      expect(msg.key, equals("foo"));

      expect(msg.build({'n': 0, 'user': 'John'}),
          equals("There are no emails for|to you John."));
      expect(msg.build({'n': 1}), equals("You have 1 email."));
      expect(msg.build({'n': 2}), equals("A pair of e-mails left."));
      expect(msg.build({'n': 10}), equals("You have 10 emails left."));
      expect(msg.build({'n': -1}), equals("Odd number of emails: -1"));
      expect(msg.build({'n': -2}), equals("Odd number of emails: -2"));
      expect(msg.build({'n': -5}), equals("Odd number of emails: -5"));
    });

    test('Message.line[simple]', () {
      var msg = Message.line("foo=bar");

      expect(msg.key, equals("foo"));
      expect(msg.build(), equals("bar"));
    });

    test('Message.line[var]:1', () {
      var msg = Message.line("foo=The \$bar!");

      expect(msg.key, equals("foo"));
      expect(msg.build({'bar': 'BAR', 'x': 123}), equals("The BAR!"));
      expect(msg.build({'bar': 'BAZ', 'x': 123}), equals("The BAZ!"));
    });

    test('Message.line[var]:2', () {
      var msg = Message.line("foo=The \\\$bar!");

      expect(msg.key, equals("foo"));
      expect(msg.build({'bar': 'BAZ'}), equals("The \$bar!"));
    });

    test('Message.line[var]:3', () {
      var msg = Message.line("foo=The\\n\$bar!");

      expect(msg.key, equals("foo"));
      expect(msg.build({'bar': 'BAR', 'x': 123}), equals("The\nBAR!"));
      expect(msg.build({'bar': 'BAZ', 'x': 123}), equals("The\nBAZ!"));
    });

    test('Message.entry[simple]', () {
      var msg = Message.entry({'key': 'foo', 'value': 'bar'});

      expect(msg.key, equals("foo"));
      expect(msg.build(), equals("bar"));
    });

    test('Message.entry[var]', () {
      var msg = Message.entry({
        'key': 'foo',
        'value': ['The ', '\$bar']
      });

      expect(msg.key, equals("foo"));
      expect(msg.build({'bar': 'BAR', 'x': 123}), equals("The BAR"));
      expect(msg.build({'bar': 'BAZ', 'x': 123}), equals("The BAZ"));
    });
  });

  group('IntlFallbackLanguage', () {
    setUp(() {});

    test('IntlFallbackLanguage', () {
      var fallbackLanguage = IntlFallbackLanguage("es");

      fallbackLanguage.set("de", "en");

      expect(fallbackLanguage.get("de"), equals("en"));

      expect(fallbackLanguage.get("pt"), equals("es"));
    });
  });

  group('IntlResourceDiscover', () {
    setUp(() {});

    test('IntlResourceDiscover.findWithLocales', () async {
      IntlResourceDiscover discover =
          IntlResourceDiscover("test/test-", ".intl");
      List<IntlResourceContent> resources =
          await discover.findWithLocales(['fr']);
      print(resources.map((r) => r.uri).toList());

      expect(resources.length, equals(1));

      expect(resources.map((r) => r.locale).toList(), equals(['fr']));
    });
  });

  group('IntlResourceDiscover', () {
    setUp(() {});

    test('IntlResourceDiscover.findAll', () async {
      IntlResourceDiscover discover =
          IntlResourceDiscover("test/test-", ".intl");
      List<IntlResourceContent> resources = await discover.findAll();
      print(resources.map((r) => r.uri).toList());

      expect(resources.length, equals(2));

      expect(resources.map((r) => r.locale).toList(), equals(['en', 'fr']));
    });

    test('IntlResourceDiscover.findWithLocales', () async {
      IntlResourceDiscover discover =
          IntlResourceDiscover("test/test-", ".intl");
      List<IntlResourceContent> resources =
          await discover.findWithLocales(['fr']);
      print(resources.map((r) => r.uri).toList());

      expect(resources.length, equals(1));

      expect(resources.map((r) => r.locale).toList(), equals(['fr']));
    });
  });

  group('IntlMessages', () {
    setUp(() {});

    test('IntlMessages.registerMessagesResourcesContents', () async {
      IntlLocale.setDefaultLocale("EN");

      var package = IntlMessages.package("test-rsc1");
      expect(package.getRegisteredLocales(), equals([]));

      IntlResourceDiscover discover =
          IntlResourceDiscover("test/test-", ".intl");

      var resources = await discover.findAll();
      expect(resources.length, equals(2));

      bool reg = await package.registerMessagesResourcesContents(resources);
      expect(reg, equals(true));

      var registeredLocales = package.getRegisteredLocales();
      registeredLocales.sort();

      expect(registeredLocales, equals(['en', 'fr']));
    });

    test('IntlMessages.findAndRegisterMessagesResources', () async {
      IntlLocale.setDefaultLocale("EN");

      var package = IntlMessages.package("test-rsc2");
      expect(package.getRegisteredLocales(), equals([]));

      IntlResourceDiscover discover =
          IntlResourceDiscover("test/test-", ".intl");

      bool reg = await package.findAndRegisterMessagesResources(discover);
      expect(reg, equals(true));

      var registeredLocales = package.getRegisteredLocales();
      registeredLocales.sort();

      expect(registeredLocales, equals(['en', 'fr']));
    });

    test('IntlMessages.findAndRegisterMessagesResourcesWithLocales', () async {
      IntlLocale.setDefaultLocale("EN");

      var package = IntlMessages.package("test-rsc3");
      expect(package.getRegisteredLocales(), equals([]));

      IntlResourceDiscover discover =
          IntlResourceDiscover("test/test-", ".intl");

      bool reg = await package
          .findAndRegisterMessagesResourcesWithLocales(discover, ['fr']);
      expect(reg, equals(true));

      var registeredLocales = package.getRegisteredLocales();
      registeredLocales.sort();

      expect(registeredLocales, equals(['fr']));
    });

    test('IntlMessages.discover', () async {
      IntlLocale.setDefaultLocale("EN");

      var package = IntlMessages.package("test-disc1");
      expect(package.getRegisteredLocales(), equals([]));

      IntlResourceDiscover discover =
          IntlResourceDiscover("test/test-", ".intl");
      Future<bool> reg = package.registerResourceDiscover(discover);

      expect(reg != null, equals(true));

      MessageBuilder msg = package.msg("foo");

      expect(msg.build(), equals(null));
      expect(msg.message, equals(null));

      List<String> onRegisterLocalizedMessages = [];

      package.onRegisterLocalizedMessages
          .listen((l) => onRegisterLocalizedMessages.add(l));

      var found = await package.autoDiscover();

      print("discovered locales[1]: ${package.getRegisteredLocales()}");
      expect(found, equals(true));
      expect(discover.findCount, equals(28));

      print("onRegisterLocalizedMessages[1]: $onRegisterLocalizedMessages");
      expect(onRegisterLocalizedMessages, equals(['en']));

      expect(msg.build(), equals("x"));
      expect(msg.description, equals("Some description"));

      //////////

      var found2 = await package.setLocale(IntlLocale('fr'));

      print("discovered locales[2]: ${package.getRegisteredLocales()}");
      expect(found2, equals(true));
      expect(discover.findCount, equals(60));

      print("onRegisterLocalizedMessages[2]: $onRegisterLocalizedMessages");
      expect(onRegisterLocalizedMessages, equals(['en', 'fr']));

      expect(msg.build(), equals("a"));
    });

    test('IntlMessages.package[test]', () {
      IntlLocale.setDefaultLocale("EN");

      var packageTest1 = IntlMessages.package("test1");
      var packageTest2 = IntlMessages.package("test2");

      expect(packageTest1.getRegisteredLocales(), equals([]));
      expect(packageTest2.getRegisteredLocales(), equals([]));

      var localeEN = IntlLocale.code('en');
      var localeFR = IntlLocale('fr');

      packageTest1.registerMessages(localeEN, "foo=x:\$n\nfuz=fx:\$n");
      packageTest2.registerMessages(localeEN.code, "foo=y:\$n\nfuz=fy:\$n");

      packageTest1.registerMessages(localeFR.code, "foo=a:\$n");
      packageTest2.registerMessages(localeFR, "foo=b:\$n");

      var msgA1 = packageTest1.msg("foo");
      var msgA2 = packageTest2["foo"];

      var msgB1 = packageTest1.msg("fuz");
      var msgB2 = packageTest2["fuz"];

      expect(msgA1.key, equals("foo"));
      expect(msgA2.key, equals("foo"));

      expect(msgA1.build(), equals("x:"));
      expect(msgA2.build(), equals("y:"));

      expect(msgA1.build({'n': 10}), equals("x:10"));
      expect(msgA2.build({'n': 20}), equals("y:20"));

      expect(msgB1.build({'n': 100}), equals("fx:100"));
      expect(msgB2.build({'n': 200}), equals("fy:200"));

      IntlLocale.setDefaultLocale("FR");

      expect(msgA1.build(), equals("a:"));
      expect(msgA2.build(), equals("b:"));

      expect(msgA1.build({'n': 10}), equals("a:10"));
      expect(msgA2.build({'n': 20}), equals("b:20"));

      expect(msgB1.build({'n': 100}), equals("fx:100"));
      expect(msgB2.build({'n': 200}), equals("fy:200"));
    });

    test('IntlMessages.comments', () {
      IntlLocale.setDefaultLocale("EN");

      var packageTest1 = IntlMessages.package("comments1");

      expect(packageTest1.getRegisteredLocales(), equals([]));

      var localeEN = IntlLocale.code('en');
      var localeFR = IntlLocale('fr');

      packageTest1.registerMessages(
          localeEN, "foo=x:\$n##Desc foo\nfuz=fx:\$n##Desc fuz!");

      packageTest1.registerMessages(
          localeFR.code, "foo=a:\$n##Desc foo FR\nfuz=fa:\$n");

      var msgA1 = packageTest1.msg("foo");
      var msgB1 = packageTest1.msg("fuz");

      expect(msgA1.key, equals("foo"));

      expect(msgA1.build(), equals("x:"));

      expect(msgA1.description, equals("Desc foo"));
      expect(msgB1.description, equals("Desc fuz!"));

      expect(msgA1.build({'n': 10}), equals("x:10"));
      expect(msgB1.build({'n': 100}), equals("fx:100"));

      IntlLocale.setDefaultLocale("FR");

      expect(msgA1.build(), equals("a:"));

      expect(msgA1.description, equals("Desc foo FR"));
      expect(msgB1.description, equals("Desc fuz!"));

      expect(msgA1.build({'n': 10}), equals("a:10"));
      expect(msgB1.build({'n': 100}), equals("fa:100"));
    });
  });

  group('Resource', () {
    setUp(() {});

    test('Message.keyValue[simple]', () {
      var pattern1 = RegExp(r'intl');
      var path1 = 'path/file-intl.txt';
      expect(replaceLocale(pattern1, path1, 'en'), equals("path/file-en.txt"));
      expect(replaceLocale(pattern1, path1, 'fr'), equals("path/file-fr.txt"));

      var pattern2 = RegExp(r'-(LOCALE)-intl');
      var path2 = 'path/file-LOCALE-intl.txt';
      expect(replaceLocale(pattern2, path2, 'en'),
          equals("path/file-en-intl.txt"));
      expect(replaceLocale(pattern2, path2, 'fr'),
          equals("path/file-fr-intl.txt"));
    });
  });
}
