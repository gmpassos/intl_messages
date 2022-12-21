# intl_messages

[![pub package](https://img.shields.io/pub/v/intl_messages.svg?logo=dart&logoColor=00b9fc)](https://pub.dartlang.org/packages/intl_messages)
[![Null Safety](https://img.shields.io/badge/null-safety-brightgreen)](https://dart.dev/null-safety)
[![Dart CI](https://github.com/gmpassos/intl_messages/actions/workflows/dart.yml/badge.svg?branch=master)](https://github.com/gmpassos/intl_messages/actions/workflows/dart.yml)
[![GitHub Tag](https://img.shields.io/github/v/tag/gmpassos/intl_messages?logo=git&logoColor=white)](https://github.com/gmpassos/intl_messages/releases)
[![New Commits](https://img.shields.io/github/commits-since/gmpassos/intl_messages/latest?logo=git&logoColor=white)](https://github.com/gmpassos/intl_messages/network)
[![Last Commits](https://img.shields.io/github/last-commit/gmpassos/intl_messages?logo=git&logoColor=white)](https://github.com/gmpassos/intl_messages/commits/master)
[![Pull Requests](https://img.shields.io/github/issues-pr/gmpassos/intl_messages?logo=github&logoColor=white)](https://github.com/gmpassos/intl_messages/pulls)
[![Code size](https://img.shields.io/github/languages/code-size/gmpassos/intl_messages?logo=github&logoColor=white)](https://github.com/gmpassos/intl_messages)
[![License](https://img.shields.io/github/license/gmpassos/intl_messages?logo=open-source-initiative&logoColor=green)](https://github.com/gmpassos/intl_messages/blob/master/LICENSE)


A Simple and easy library for Message Internationalization and Localization (I18N).

#### Main features:
 
- Structure of messages by package/module.

- Dynamic load of assets/files of messages.

- Global notification of locale change and registration/discovery of localized messages.

## Usage

A simple usage example:


- Internationalization file `msgs-en.intl`:
    ```text
    hello=Hello world! ## A description of the key.
    ```

- Internationalization file `msgs-fr.intl`:
    ```text
    hello=Bonjour le monde!
    ```

- Dart code:
    ```dart
    import 'package:intl_messages/intl_messages.dart';
    
    main() async {
    
        var messages = IntlMessages.package("demo");
        
        IntlResourceDiscover discover = IntlResourceDiscover("assets/msgs-", ".intl") ;
        await messages.registerResourceDiscover(discover) ; // Default locale: 'en'. Discovered: assets/msgs-en.intl
        
        MessageBuilder msgHello = messages.msg("hello") ;
        
        print( msgHello.build() ) ; // Hello world!
        
        await messages.setLocale( 'fr' ) ; // Locale set to: 'fr'. Discovered: assets/msgs-fr.intl
        
        print( msgHello.build() ) ; // Bonjour le monde!
    
    }
    ```

## Plurals:

Yes we have plurals ;-)

To use plurals you should declare messages using `{...}` blocks with conditions `zero`, `one`, `two` and `many` and respective variable name.

Here's an example of plural usage with variable `n`:

- Internationalization file `msgs-en.intl`:
    ```text
    total_emails={zero[n]:No e-mails for \$user.|one[n]:One e-mail for \$user.|two[n]:A pair of e-mails for \$user.|many[n]:Received \$n e-mails for \$user.}
    ```

- Dart code:
    ```dart
    import 'package:intl_messages/intl_messages.dart';
    
    main() async {
    
        var messages = IntlMessages.package("demo-plural");
        
        IntlResourceDiscover discover = IntlResourceDiscover("assets/msgs-", ".intl") ;
        await messages.registerResourceDiscover(discover) ; // Default locale: 'en'. Discovered: assets/msgs-en.intl
        
        MessageBuilder msgEmail = messages.msg("total_emails") ;
        
        print( msgEmail.build({'n': 0, 'user': 'john@mail.com'}) ) ; // No e-mails for john@mail.com.
        print( msgEmail.build({'n': 1, 'user': 'john@mail.com'}) ) ; // One e-mail for john@mail.com.
        print( msgEmail.build({'n': 2, 'user': 'john@mail.com'}) ) ; // A pair of e-mails for john@mail.com.
        print( msgEmail.build({'n': 8, 'user': 'john@mail.com'}) ) ; // Received 8 e-mails for john@mail.com.
    
    }
    ```


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/gmpassos/intl_messages/issues

## Author

Graciliano M. Passos: [gmpassos@GitHub][github].

[github]: https://github.com/gmpassos

## License

Dart free & open-source [license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).
