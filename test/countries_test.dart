import 'package:intl_messages/intl_messages.dart';
import 'package:test/test.dart';

void main() {
  group('Countries', () {
    test('allCountries', () {
      var set1 = allCountries.toSet();

      var set2 = allCountriesByCode.values.toSet();
      expect(set2, equals(set1));

      var set3 = allCountriesByName.values.toSet();
      expect(set3, equals(set1));
    });

    test('allCountriesByCode', () {
      {
        var countryInfo = allCountriesByCode['BR'];
        _expectCountryBR(countryInfo);
      }

      {
        var countryInfo = allCountriesByCode['US'];
        _expectCountryUS(countryInfo);
      }
    });

    test('allCountriesByDialCode', () {
      {
        var countryInfo = allCountriesByDialCode[55];
        _expectCountryBR(countryInfo);
      }

      {
        var countryInfo = allCountriesByDialCode[1];
        _expectCountryUS(countryInfo);
      }
    });

    test('allCountriesByName', () {
      {
        var countryInfo = allCountriesByName['brazil'];
        _expectCountryBR(countryInfo);
      }

      {
        var countryInfo = allCountriesByName['united states of america'];
        _expectCountryUS(countryInfo);
      }
    });

    test('getCountryInfo', () {
      {
        var countryInfo = getCountryInfo(countryCode: 'BR');
        _expectCountryBR(countryInfo);

        expect(getCountryInfo(countryCode: 'br'), equals(countryInfo));
        expect(getCountryInfo(dialCode: 55), equals(countryInfo));
        expect(getCountryInfo(countryName: 'Brazil'), equals(countryInfo));
      }

      {
        var countryInfo = getCountryInfo(countryCode: 'US');
        _expectCountryUS(countryInfo);

        expect(getCountryInfo(countryCode: 'us'), equals(countryInfo));
        expect(getCountryInfo(dialCode: 1), equals(countryInfo));
        expect(getCountryInfo(countryName: 'United States Of America'),
            equals(countryInfo));
      }

      {
        var countryInfo = getCountryInfo(countryCode: 'BE');
        _expectCountryBE(countryInfo);

        expect(getCountryInfo(countryCode: 'be'), equals(countryInfo));
        expect(getCountryInfo(dialCode: 32), equals(countryInfo));
        expect(getCountryInfo(countryName: 'belgium'), equals(countryInfo));
      }
    });
  });
}

void _expectCountryBR(CountryInfo? countryInfo) {
  expect(countryInfo!.code, equals('BR'));
  expect(countryInfo.dialCode, equals(55));
  expect(countryInfo.name, equals('Brazil'));
  expect(countryInfo.languages, equals(['pt']));
}

void _expectCountryUS(CountryInfo? countryInfo) {
  expect(countryInfo!.code, equals('US'));
  expect(countryInfo.dialCode, equals(1));
  expect(countryInfo.name, equals('United States of America'));
  expect(countryInfo.languages, equals(['en']));
}

void _expectCountryBE(CountryInfo? countryInfo) {
  expect(countryInfo!.code, equals('BE'));
  expect(countryInfo.dialCode, equals(32));
  expect(countryInfo.name, equals('Belgium'));
  expect(countryInfo.languages, equals(['nl', 'fr', 'de']));
}
