
import 'package:intl/intl.dart';

import 'locales.dart';

class LocalesManagerGeneric extends LocalesManager {

  LocalesManagerGeneric(InitializeLocaleFunction initializeLocaleFunction, [ void onDefineLocale(String locale) ]) : super(initializeLocaleFunction, onDefineLocale) ;

  @override
  String defineLocaleFromSystem() {
    return Intl.systemLocale ;
  }

  @override
  List<String> getLocalesSequence(String locale) {
    return getPossibleLocalesSequenceGeneric(locale) ;
  }

}

List<String> getPossibleLocalesSequenceGeneric(String locale) {
  var similarLocales = getSimilarLocales(locale);

  List<String> possibleLocalesSequence = [ Intl.canonicalizedLocale(locale) ] ;

  bool firstIsShortLocale = possibleLocalesSequence[0].length == 2 ;

  int similarPrioritySize = firstIsShortLocale ? 2 : 3 ;

  for (var l in similarLocales) {
    if ( !possibleLocalesSequence.contains(l) ) {
      possibleLocalesSequence.add(l) ;
      if (possibleLocalesSequence.length >= similarPrioritySize) break ;
    }
  }

  for (var l in similarLocales) {
    if ( !possibleLocalesSequence.contains(l) ) {
      possibleLocalesSequence.add(l) ;
    }
  }

  print("possibleLocalesSequence: $possibleLocalesSequence") ;

  return possibleLocalesSequence ;
}

List<String> getPossibleLocalesSequenceImpl(String locale) {
  return getPossibleLocalesSequenceGeneric(locale) ;
}

LocalesManager createLocalesManagerImpl( InitializeLocaleFunction initializeLocaleFunction, [ void onDefineLocale(String locale) ] ) {
  return LocalesManagerGeneric(initializeLocaleFunction , onDefineLocale ) ;
}

