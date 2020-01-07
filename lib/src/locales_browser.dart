
import 'dart:html';

import 'package:intl/intl.dart';
import 'package:intl/intl_browser.dart' ;

import 'locales.dart';

class LocalesManagerBrowser extends LocalesManager {

  LocalesManagerBrowser(InitializeLocaleFunction initializeLocaleFunction, [ void onDefineLocale(String locale) ]) : super(initializeLocaleFunction, onDefineLocale) ;

  final String _LOCAL_KEY_locales_preferredLocale = "__locales__preferredLocale" ;

  @override
  String defineLocaleFromSystem() {
    findSystemLocale() ;
    return Intl.systemLocale ;
  }

  @override
  String readPreferredLocale() {
    return window.localStorage[_LOCAL_KEY_locales_preferredLocale] ;
  }

  @override
  storePreferredLocale(String locale) {
    window.localStorage[_LOCAL_KEY_locales_preferredLocale] = locale ;
  }

  @override
  List<String> getLocalesSequence(String locale) {
    return getPossibleLocalesSequenceInBrowser(locale) ;
  }

  @override
  dynamic buildLanguageSelector( refreshOnChange() ) {
    var localeOptions = getLocaleOptions() ;

    SelectElement selectElement = SelectElement() ;

    for (var localeOption in localeOptions ) {
      var opt = OptionElement(value: localeOption.locale, data: localeOption.name, selected: localeOption.selected);
      selectElement.children.add(opt) ;
    }

    var initializeAllLocales = this.initializeAllLocales() ;

    if (refreshOnChange != null) {
      initializeAllLocales.then((ok) {
        if (ok) refreshOnChange();
      });
    }

    selectElement.onChange.listen((e) {
      var locale = selectElement.selectedOptions[0].value ;
      print("selected language: $locale") ;
      setPreferredLocale(locale);
      if (refreshOnChange != null) refreshOnChange();
    });

    return selectElement ;
  }

}


List<String> getPossibleLocalesSequenceInBrowser(String locale) {
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

  print("window.navigator.language: ${ window.navigator.language } ; ${ window.navigator.languages } ") ;

  for (var l in window.navigator.languages) {
    l = Intl.canonicalizedLocale(l) ;
    if ( !possibleLocalesSequence.contains(l) ) {
      possibleLocalesSequence.add(l) ;
    }
  }

  for (var l in similarLocales) {
    if ( !possibleLocalesSequence.contains(l) ) {
      possibleLocalesSequence.add(l) ;
    }
  }

  print("possibleLocalesSequence[browser]: $possibleLocalesSequence") ;

  return possibleLocalesSequence ;
}

List<String> getPossibleLocalesSequenceImpl(String locale) {
  return getPossibleLocalesSequenceInBrowser(locale) ;
}

LocalesManager createLocalesManagerImpl( InitializeLocaleFunction initializeLocaleFunction, [ void onDefineLocale(String locale) ] ) {
  return LocalesManagerBrowser(initializeLocaleFunction , onDefineLocale ) ;
}

