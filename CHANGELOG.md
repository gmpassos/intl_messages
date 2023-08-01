## 2.2.0

- sdk: '>=3.0.0 <4.0.0'
- async_extension: ^1.1.1
- collection: ^1.18.0
- dart_openai: ^4.0.0
- lints: ^2.1.1
- test: ^1.24.4

## 2.1.15

- resource_portable: ^3.1.0
  - Fix path resolution on Windows.

## 2.1.14

- `TranslatorInMemory`:
  - Added `keyNormalizer`.

## 2.1.13

- `TranslatorOpenAI.parseResult`: improve parsing of translations with keys also translated.

- args: ^2.4.2
- dart_openai: ^2.0.1

## 2.1.12

- `TranslatorInMemory`: fix internal tree of translations.

## 2.1.11

- Added `TranslatorInMemory`.

## 2.1.10

- `TranslatorOpenAI`:
  - `parseResult`: improve parsing detecting results in `key=...` and `translation=...` lines.

## 2.1.9

- dart_openai: ^1.9.91

## 2.1.8

- Fix `TranslatorCacheDirectory`.

## 2.1.7

- `TranslatorCacheDirectory`:
  - `get`: ensure that the cached `message` matches the parameter `message` to return a cached `translation`.

## 2.1.6

- `Translator`:
  - Fix `_translateEntries` for when `results` is empty.
- `bin/intl_messages.dart`:
  - Check if `missingKeys` is not empty.

## 2.1.5

- Added `TranslatorCache`.
- Added locale: `lb_LU`.
- dart_openai: ^1.9.8
- yaml: ^3.1.2
- args: ^2.4.1

## 2.1.4

- `TranslatorOpenAI`:
  - Improve translation prompt to avoid wrong responses.

## 2.1.3

- `Translator`:
  - Added fields: `translateBlocksInParallel` and `maxParallelTranslations`.
- `TranslatorOpenAI`:
  - `translateBlocksInParallel: true`
  - `maxParallelTranslations = 3`

## 2.1.2

- `TranslatorOpenAI`:
  - Fix: split requests into blocks of 500 characters;

## 2.1.1

- Added `TranslatorOpenAI` and `TranslatorConsole`.
- CLI `intl_messages`:
  - Added command `fix` with `openai` and `console` translators.

## 2.1.0

- Added executable `intl_messages` (CLI Tool).
- sdk: '>=2.18.0 <3.0.0'
- intl: ^0.18.1
- args: ^2.4.0
- pubspec: ^2.3.0
- path: ^1.8.3
- collection: ^1.17.1
- test: ^1.24.1

## 2.0.8

- Fix issue when all initial locales (from `getPossibleLocalesSequenceGeneric`) are not supported.
  - A supported locale still need to be loaded.
- New `IntlMessageLookup` is set as `messageLookup` (if not set yet).
- resource_portable: ^3.0.2
- swiss_knife: ^3.1.5

## 2.0.7

- `IntlMessages`:
  - `registerMessages`: add support for YAML.
    - Added `isContentYAML`.
  - `msg`: added optional parameter `preferredLocale`.
- yaml: ^3.1.1

## 2.0.6

- Optimize internal asynchrnous call.
  - Optimize resolution and download of resources.
- test: ^1.23.1
- coverage: ^1.6.3
- async_extension: ^1.1.0

## 2.0.5

- intl: ^0.18.0
- swiss_knife: ^3.1.3
- test: ^1.22.1

## 2.0.4

- Added `CountryInfo`:
  - All countries info: `name`, `code` and `dialCode`. 
- swiss_knife: ^3.1.2
- lints: ^2.0.1
- test: ^1.22.0
- dependency_validator: ^3.2.2
- coverage: ^1.6.1

## 2.0.3

- `IntlBasicDictionary`: added week related words.
- lints: ^2.0.0
- test: ^1.21.3
- coverage: ^1.4.0

## 2.0.2

- Improve GitHub CI.
- Added browser tests.
- swiss_knife: ^3.1.1
- lints: ^1.0.1
- test: ^1.16.5
- dependency_validator: ^3.1.0
- coverage: ^1.0.4

## 2.0.1

- Sound null safety compatibility.
- enum_to_string: ^2.0.1
- swiss_knife: ^3.0.6
  
## 2.0.0-nullsafety.3

- Null Safety adjustments.

## 2.0.0-nullsafety.2

- Null Safety adjustments.
- swiss_knife: ^3.0.5

## 2.0.0-nullsafety.1

- Dart 2.12.0:
  - Sound null safety compatibility.
  - Update CI dart commands.
  - sdk: '>=2.12.0 <3.0.0'
- intl: ^0.17.0
- resource_portable: ^3.0.0
- enum_to_string: ^2.0.0-nullsafety.1
- swiss_knife: ^3.0.1
- pedantic: ^1.11.0
- test: ^1.16.5
  
## 1.1.13

- `IntlBasicDictionary`: Added months names.
- swiss_knife: ^2.5.23
- enum_to_string: ^1.0.13

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
