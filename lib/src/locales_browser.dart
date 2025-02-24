import 'dart:js_interop';

import 'package:intl/intl.dart';
import 'package:intl/intl_browser.dart';
import 'package:web/web.dart' as web;

import 'locales.dart';

/// Browser implementation of [LocalesManager].
class LocalesManagerBrowser extends LocalesManager {
  LocalesManagerBrowser(super.initializeLocaleFunction, [super.onDefineLocale]);

  // ignore: non_constant_identifier_names
  final String _localKey_locales_preferredLocale = '__locales__preferredLocale';

  @override
  final bool isBrowserURI = true;

  @override
  String defineLocaleFromSystem() {
    findSystemLocale();
    return Intl.systemLocale;
  }

  @override
  String? readPreferredLocale() {
    return web.window.localStorage[_localKey_locales_preferredLocale];
  }

  @override
  void storePreferredLocale(String locale) {
    web.window.localStorage[_localKey_locales_preferredLocale] = locale;
  }

  @override
  List<String> getLocalesSequence(String locale) {
    return getPossibleLocalesSequenceInBrowser(locale);
  }

  @override
  dynamic buildLanguageSelector(Function() refreshOnChange) {
    var localeOptions = getLocaleOptions();

    var selectElement = web.HTMLSelectElement();

    for (var localeOption in localeOptions) {
      var opt = web.HTMLOptionElement()
        ..value = localeOption.locale
        ..text = localeOption.name!
        ..selected = localeOption.selected!;

      selectElement.appendChild(opt);
    }

    var initializeAllLocales = this.initializeAllLocales();

    initializeAllLocales.then((ok) {
      if (ok) refreshOnChange();
    });

    selectElement.onChange.listen((e) {
      var opt = selectElement.selectedOptions.item(0) as web.HTMLOptionElement?;
      var locale = opt?.value ?? '';
      print('-- Selected language: $locale');
      setPreferredLocale(locale);
      refreshOnChange();
    });

    return selectElement;
  }
}

List<String> getPossibleLocalesSequenceInBrowser(String locale) {
  var similarLocales = getSimilarLocales(locale);

  var possibleLocalesSequence = <String>[Intl.canonicalizedLocale(locale)];

  var firstIsShortLocale = possibleLocalesSequence[0].length == 2;

  var similarPrioritySize = firstIsShortLocale ? 2 : 3;

  for (var l in similarLocales) {
    if (!possibleLocalesSequence.contains(l)) {
      possibleLocalesSequence.add(l);
      if (possibleLocalesSequence.length >= similarPrioritySize) break;
    }
  }

  print(
      '-- window.navigator.language: ${web.window.navigator.language} ; ${web.window.navigator.languages} ');

  for (var l in web.window.navigator.languages.toDart) {
    var s = Intl.canonicalizedLocale(l.toDart);
    if (!possibleLocalesSequence.contains(s)) {
      possibleLocalesSequence.add(s);
    }
  }

  for (var l in similarLocales) {
    if (!possibleLocalesSequence.contains(l)) {
      possibleLocalesSequence.add(l);
    }
  }

  print('-- possibleLocalesSequence[browser]: $possibleLocalesSequence');

  return possibleLocalesSequence;
}

List<String> getPossibleLocalesSequenceImpl(String locale) {
  return getPossibleLocalesSequenceInBrowser(locale);
}

LocalesManager createLocalesManagerImpl(
    InitializeLocaleFunction initializeLocaleFunction,
    [void Function(String locale)? onDefineLocale]) {
  return LocalesManagerBrowser(initializeLocaleFunction, onDefineLocale);
}
