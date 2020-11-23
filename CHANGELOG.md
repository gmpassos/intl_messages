## 1.1.12

- Added example.

## 1.1.11

- Better auto discovery of message resources.
- Added `IntlMessagesLoader` to handle loading of `IntlMessages` and discovery of messages.  
- Properties now allows multiline entries, like in Dart, using ''' or """ as multiline quote for the entry value. 
- resource_portable: ^2.1.8
- swiss_knife: ^2.5.18

## 1.1.10

- Added `IntlKey`.
- dartfmt.
- More tests.
- swiss_knife: ^2.5.11
- pedantic: ^1.9.2
- test: ^1.15.3
- test_coverage: ^0.4.2

## 1.1.9

- Improve `IntlBasicDictionary`
- dartfmt.

## 1.1.8

- Added API documentation.
- dartfmt.
- swiss_knife: ^2.5.2

## 1.1.7

- IntlResourceUri
- swiss_knife: ^2.3.10

## 1.1.6

- LocalesManager.onPreDefineLocale
- if IntlLocale.getDefaultLocale() is null when the 1st local is defined, set it as default.
- Move ResourceContentCache and ResourceContent to package 'swiss_knife'.
- resource_portable: ^2.1.7
- swiss_knife: ^2.3.9

## 1.1.5

- swiss_knife: ^2.3.7

## 1.1.4

- sdk: '>=2.6.0 <3.0.0'
- swiss_knife: ^2.3.3

## 1.1.3

- Upgrade dependencies.
    - intl: ^0.16.1
    - enum_to_string: ^1.0.8
    - swiss_knife: ^2.2.1
- Code analysis.

## 1.1.2

- Add Author and License to README.

## 1.1.1

- Moved locales from swiss_knife to local source.
- Using package resource_portable to be Web compatible.

## 1.1.0

- Added plural block for `two`.
- Added description to messages, using `##` delimiter at end of message value.

## 1.0.0

- Initial version, created by Stagehand
