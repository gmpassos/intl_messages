import 'package:intl_messages/intl_messages.dart';
import 'package:swiss_knife/swiss_knife.dart';

void main() {
  var uriBase = getUriBase(); // expected `intl_messages/` source dirctory.
  print('uriBase: $uriBase');

  App();

  App('fr');
}

class App {
  final IntlMessagesLoader intlMessagesLoader =
      IntlMessagesLoader('example', 'example/i18n/msgs-');

  IntlMessages get messages => intlMessagesLoader.intlMessages;

  String get msgWelcome => messages.msg('welcome').build();

  String get msgLanguage => messages.msg('language').build();

  String msgTotalEmails(int n, String user) =>
      messages.msg('total_emails').build({'n': n, 'user': user});

  final String? forceLocale;

  App([this.forceLocale]) {
    if (intlMessagesLoader.isLoaded) {
      run();
    } else {
      intlMessagesLoader.onLoad.listen((event) => run());
    }
  }

  void run() {
    if (forceLocale != null) {
      messages.setLocale(forceLocale);
    }

    print('----------------------------- ${messages.currentLocale}');

    print(msgWelcome);

    print('$msgLanguage: ${messages.currentLocale!.language}');

    for (var i = 0; i <= 4; i++) {
      print('$i> ${msgTotalEmails(i, 'Joe')}');
    }
  }
}
