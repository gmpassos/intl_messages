

import 'package:swiss_knife/swiss_knife.dart';

import 'intl_messages_base.dart';
import 'locales.dart';

class IntlResourceUri {

  final RegExp uriLocalePattern ;
  final String mainUri ;

  ResourceContentCache _resourceContentCache ;

  IntlResourceUri(this.uriLocalePattern, this.mainUri, [this._resourceContentCache]);

  Future<ResourceContent> resolveResourceContent() async {
    var defaultLocale = IntlLocale.getDefaultLocale() ?? 'en' ;
    var localesSequence = getPossibleLocalesSequence(defaultLocale) ;

    for (var locale in localesSequence) {
      var uri = replaceLocale(uriLocalePattern, mainUri, locale) ;

      var resourceContent = _cached( ResourceContent.fromURI(uri) ) ;

      await resourceContent.getContent() ;

      if ( resourceContent.isLoaded && !resourceContent.isLoadedWithError ) {
        return resourceContent ;
      }
    }

    return null ;
  }

  ResourceContent _cached(ResourceContent resourceContent) {
    if (_resourceContentCache != null) {
      return _resourceContentCache.get(resourceContent) ;
    }
    return resourceContent ;
  }

}


String replaceLocale(RegExp pattern, String s, String locale) {
  var match = pattern.firstMatch(s) ;
  if (match == null) return s ;

  var s2 = s.substring(0, match.start) ;

  var g0 = match.group(0) ;

  if ( match.groupCount == 0 ) {
    s2 += locale ;
  }
  else if ( match.groupCount == 1 ) {
    var g1 = match.group(1) ;

    int idx = g0.indexOf(g1) ;

    assert(idx >= 0) ;

    s2 += g0.substring(0,idx) ;
    s2 += locale ;
    s2 += g0.substring( idx+g1.length) ;
  }
  else {
    throw StateError('Locale pattern only can have 1 group: match groups: ${ match.groupCount }') ;
  }

  s2 += s.substring(match.end) ;

  return s2 ;
}


