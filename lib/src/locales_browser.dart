import 'dart:html';

import 'package:intl/intl.dart';
import 'package:intl/intl_browser.dart';

import 'locales.dart';

/// Browser implementation of [LocalesManager].
class LocalesManagerBrowser extends LocalesManager {
  LocalesManagerBrowser(InitializeLocaleFunction initializeLocaleFunction,
      [void Function(String locale)? onDefineLocale])
      : super(initializeLocaleFunction, onDefineLocale);

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
    return window.localStorage[_localKey_locales_preferredLocale];
  }

  @override
  void storePreferredLocale(String locale) {
    window.localStorage[_localKey_locales_preferredLocale] = locale;
  }

  @override
  List<String> getLocalesSequence(String locale) {
    return getPossibleLocalesSequenceInBrowser(locale);
  }

  @override
  dynamic buildLanguageSelector(Function() refreshOnChange) {
    var localeOptions = getLocaleOptions();

    var selectElement = SelectElement();

    for (var localeOption in localeOptions) {
      var opt = OptionElement(
          value: localeOption.locale,
          data: localeOption.name!,
          selected: localeOption.selected!);
      selectElement.children.add(opt);
    }

    var initializeAllLocales = this.initializeAllLocales();

    initializeAllLocales.then((ok) {
      if (ok) refreshOnChange();
    });

    selectElement.onChange.listen((e) {
      var locale = selectElement.selectedOptions[0].value;
      print('selected language: $locale');
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
      'window.navigator.language: ${window.navigator.language} ; ${window.navigator.languages} ');

  for (var l in window.navigator.languages!) {
    l = Intl.canonicalizedLocale(l);
    if (!possibleLocalesSequence.contains(l)) {
      possibleLocalesSequence.add(l);
    }
  }

  for (var l in similarLocales) {
    if (!possibleLocalesSequence.contains(l)) {
      possibleLocalesSequence.add(l);
    }
  }

  print('possibleLocalesSequence[browser]: $possibleLocalesSequence');

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
