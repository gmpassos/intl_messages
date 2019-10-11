# intl_messages

A Simple and easy library for Message Internationalization and Localization (I18N).

#### Main features:
 
- Structure of messages by package/module.

- Dynamic load of assets/files of messages.

- Global notification of locale change and registration/discovery of localized messages.

## Usage

A simple usage example:

```dart
import 'package:intl_messages/intl_messages.dart';

main() async {

    var messages = IntlMessages.package("demo");
    
    IntlResourceDiscover discover = IntlResourceDiscover("assets/msgs-", ".intl") ;
    await messages.registerResourceDiscover(discover) ; // Default locale: 'en'. Discovered: assets/msgs-en.intl
    
    MessageBuilder msgHello = messages.msg("hello") ;
    
    print( msgHello.build() ) ; // Hello world!
    
    await messages.setLocale( 'fr' ) ; ; // Locale set to: 'fr'. Discovered: assets/msgs-fr.intl
    
    print( msgHello.build() ) ; // Bonjour le monde!

}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/gmpassos/intl_messages/issues
