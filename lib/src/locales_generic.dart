import 'package:intl/intl.dart';

import 'locales.dart';

/// Generic implementation of [LocalesManager].
class LocalesManagerGeneric extends LocalesManager {
  LocalesManagerGeneric(super.initializeLocaleFunction, [super.onDefineLocale]);

  @override
  final bool isBrowserURI = false;

  @override
  String defineLocaleFromSystem() {
    return Intl.systemLocale;
  }

  @override
  List<String> getLocalesSequence(String locale) {
    return getPossibleLocalesSequenceGeneric(locale);
  }
}

List<String> getPossibleLocalesSequenceGeneric(String locale) {
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

  for (var l in similarLocales) {
    if (!possibleLocalesSequence.contains(l)) {
      possibleLocalesSequence.add(l);
    }
  }

  print('possibleLocalesSequence: $possibleLocalesSequence');

  return possibleLocalesSequence;
}

List<String> getPossibleLocalesSequenceImpl(String locale) {
  return getPossibleLocalesSequenceGeneric(locale);
}

LocalesManager createLocalesManagerImpl(
    InitializeLocaleFunction initializeLocaleFunction,
    [void Function(String locale)? onDefineLocale]) {
  return LocalesManagerGeneric(initializeLocaleFunction, onDefineLocale);
}
