import 'package:intl/intl.dart';
import 'package:resource/resource.dart' show Resource ;
import 'package:enum_to_string/enum_to_string.dart';

import 'package:swiss_knife/src/locales.dart' show ALL_LOCALES_CODES ;

import 'dart:convert' ;

import 'package:swiss_knife/swiss_knife.dart';

class IntlResourceContent {
  final String locale ;
  final Resource resource ;

  IntlResourceContent(this.locale, this.resource, [this._content]) ;

  String _content ;

  Future<String> getContent() async {
    if (_content != null) return _content ;
    _content = await resource.readAsString() ;
    return Future.value(_content) ;
  }

  Uri get uri => resource.uri ;

}

class IntlResourceDiscover {

  String _resourcePathPrefix ;
  String _resourcePathSuffix ;

  IntlResourceDiscover(String resourcePathPrefix, [String resourcePathSuffix]) {
    if (resourcePathPrefix == null) throw ArgumentError.notNull("resourcePathPrefix") ;
    if (resourcePathSuffix == null) this._resourcePathSuffix = "" ;

    this._resourcePathPrefix = resourcePathPrefix ;
    this._resourcePathSuffix = resourcePathSuffix ;
  }

  String get resourcePathSuffix => _resourcePathSuffix;
  String get resourcePathPrefix => _resourcePathPrefix;

  int _findCount = 0 ;

  int get findCount => _findCount;

  Map<String,IntlResourceContent> _findCache = {} ;

  void clearFindCache() {
    _findCache.clear() ;
  }

  Future<IntlResourceContent> find(String locale) async {
    if (locale == null || locale.isEmpty) return Future.value(null) ;

    var cached = _findCache[locale] ;
    if (cached != null) return cached ;

    String resourcePath = "$_resourcePathPrefix$locale$_resourcePathSuffix" ;
    Resource resource = Resource(resourcePath) ;

    try {
      _findCount++ ;

      String content = await resource.readAsString() ;

      if (content != null) {
        var resourceContent = IntlResourceContent(locale, resource, content);
        _findCache[locale] = resourceContent ;
        return resourceContent ;
      }
    }
    catch (e) {}

    return Future.value(null) ;
  }

  Future<List<IntlResourceContent>> findAll() async {
    return findWithLocales( _ALL_LOCALES_CODES ) ;
  }

  Future<List<IntlResourceContent>> findWithLocales(List<String> locales) async {
    if (locales == null || locales.isEmpty) return Future.value(null) ;

    List<IntlResourceContent> found = [] ;

    for (var l in locales) {
      var resource = await find(l) ;
      if (resource != null) found.add( resource ) ;
    }

    return found ;
  }

  @override
  String toString() {
    return 'IntlResourceDiscover{_resourcePathPrefix: $_resourcePathPrefix, _resourcePathSuffix: $_resourcePathSuffix, _findCount: $_findCount}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is IntlResourceDiscover &&
              runtimeType == other.runtimeType &&
              _resourcePathPrefix == other._resourcePathPrefix &&
              _resourcePathSuffix == other._resourcePathSuffix;

  @override
  int get hashCode =>
      _resourcePathPrefix.hashCode ^
      _resourcePathSuffix.hashCode;

}

class IntlMessages {

  static String normalizePackageName(String packageName) => packageName.toLowerCase().trim();

  //////////////////////////////

  static Map<String,IntlMessages> instances = {} ;

  static IntlMessages package(String packageName) {
    packageName = normalizePackageName(packageName) ;
    var instance = instances[packageName] ;

    if (instance == null) {
      instance = IntlMessages._(packageName) ;
      instances[packageName] = instance ;
    }

    return instance ;
  }

  //////////////////////////////

  final String packageName ;

  IntlMessages._(this.packageName);

  Future findAndRegisterMessagesResources(IntlResourceDiscover discover) async {
    List<IntlResourceContent> resources = await discover.findAll();
    return registerMessagesResourcesContents(resources) ;
  }

  Future findAndRegisterMessagesResourcesWithLocales(IntlResourceDiscover discover, List<String> locales) async {
    List<IntlResourceContent> resources = await discover.findWithLocales(locales) ;
    return registerMessagesResourcesContents(resources) ;
  }

  /////////////////////////////////////////////////

  Future<bool> registerMessagesResourcesContents(List<IntlResourceContent> resources) async {
    if (resources == null || resources.isEmpty) return Future.value(false) ;

    bool ok = false ;

    for (var r in resources) {
      bool registered = await registerMessagesResourceContent(r) ;
      if (registered) ok = true ;
    }

    return ok ;
  }

  Future<bool> registerMessagesResourceContent(IntlResourceContent resource) async {
    if (resource == null) return Future.value(false) ;

    var content = await resource.getContent();
    IntlLocale locale = IntlLocale.code( resource.locale ) ;
    return registerMessages(locale, content) ;
  }

  Future<bool> registerMessagesResourcePath(String resourcePath) async {
    var resource = Resource(resourcePath) ;
    return registerMessagesResource(resource) ;
  }

  Future<bool> registerMessagesResources(List<Resource> resources) async {
    if (resources == null || resources.isEmpty) return Future.value(false) ;

    bool ok = false ;

    for (var r in resources) {
      var content = await r.readAsString();
      IntlLocale locale = IntlLocale.path(r.uri.toString()) ;
      bool registered = registerMessages(locale, content) ;
      if (registered) ok = true ;
    }

    return ok ;
  }

  Future registerMessagesResource(Resource resource) async {
    var content = await resource.readAsString();

    IntlLocale locale = IntlLocale.path(resource.uri.toString()) ;
    return registerMessages(locale, content) ;
  }

  bool registerMessages(dynamic locale, String content) {
    IntlLocale intlLocale = IntlLocale(locale) ;

    var msgs ;

    if ( isContentJSON(content) ) {
      msgs = _parseContentJSON(content) ;
    }
    else if ( isContentProperties(content) ) {
      msgs = _parseContentProperties(content) ;
    }

    registerLocalizedMessages( LocalizedMessages(intlLocale, msgs) ) ;

    return true ;
  }

  bool isContentJSON(String content) {
    content = content.trim();
    return content.startsWith("{") && content.endsWith("}") ;
  }

  bool isContentProperties(String content) {
    content = content.trim();
    return content.startsWith( RegExp(r'[\w.-]+=\S+') ) ;
  }

  List<Message> _parseContentJSON(String content) {
    var json = jsonDecode(content) ;
    if (json is Map) {
      Map map = json ;
      List<Message> messages = [] ;

      for ( dynamic key in map.keys ) {
        messages.add( Message.keyValue(key, map[key]) ) ;
      }

      return messages ;
    }
    else if (json is List) {
      List list = json ;
      List<Message> messages = [] ;

      for ( dynamic entry in list ) {
        messages.add( Message.entry(entry) ) ;
      }

      return messages ;
    }
    else {
      return _parseContentProperties(content) ;
    }
  }

  List<Message> _parseContentProperties(String content) {
    var lines = content.split( RegExp(r"[\r\n]+") ) ;

    List<Message> messages = [] ;

    for (String line in lines) {
      messages.add( Message.line(line) ) ;
    }

    return messages ;
  }

  //////////////////////////////////////////////////////////////////////

  IntlLocale _currentLocale ;

  IntlLocale get currentLocale => getCurrentLocale() ;

  IntlLocale getCurrentLocale() {
    if (_currentLocale != null) return _currentLocale ;
    
    String locale = _IntlDefaultLocale.locale ;

    if (locale != null) {
      return IntlLocale.code(locale) ;
    }

    return IntlLocale.code('en') ;
  }

  Future<bool> setLocale(dynamic locale) async {
    IntlLocale intlLocale = IntlLocale(locale) ;

    if ( this._currentLocale == intlLocale ) return false ;

    this._currentLocale = intlLocale ;

    return _defineLocalesOrder();
  }

  Map<IntlLocale , LocalizedMessages> _localizedMessages = {} ;

  List<IntlLocale> _localesOrder ;
  IntlLocale _localesOrderLocale ;
  List<IntlLocale> _possibleLocalesOrder ;

  List<IntlLocale> _getLocalesOrder() {
    if (_localesOrder == null) {
      _defineLocalesOrder();
      return _localesOrder ;
    }

    IntlLocale currentLocale = this.currentLocale ;
    if ( currentLocale != _localesOrderLocale ) {
      _defineLocalesOrder();
    }

    return _localesOrder ;
  }

  List<IntlLocale> _getPossibleLocalesOrder() {
    if (_possibleLocalesOrder == null) {
      _defineLocalesOrder();
      return _possibleLocalesOrder ;
    }

    IntlLocale currentLocale = this.currentLocale ;
    if ( currentLocale != _localesOrderLocale ) {
      _defineLocalesOrder();
    }

    return _possibleLocalesOrder ;
  }

  Future<bool> _defineLocalesOrder() async {
    List<IntlLocale> locales = List.from( _localizedMessages.keys ) ;
    locales.sort() ;

    IntlLocale currentLocale = this.currentLocale ;

    int idx = locales.indexOf(currentLocale) ;

    if (idx > 0) {
      var l = locales.removeAt(idx) ;
      locales.insert(0, l) ;
    }

    List<IntlLocale> sameLang = List.from(locales);
    sameLang.retainWhere( (l) => l.language == currentLocale.language && l != currentLocale ) ;

    if ( sameLang.isNotEmpty ) {
      idx = locales.indexOf(currentLocale) ;

      sameLang.sort() ;
      locales.removeWhere( (l) => sameLang.contains(l) ) ;

      if (idx >= 0) {
        locales.insertAll(idx+1, sameLang);
      }
      else {
        locales.insertAll(0, sameLang);
      }
    }

    this._localesOrder = locales ;
    this._localesOrderLocale = currentLocale ;

    /////////

    List<IntlLocale> allSameLang = List.from(_ALL_LOCALES) ;
    allSameLang.retainWhere( (l) => l.language == currentLocale.language ) ;

    allSameLang.remove(currentLocale) ;
    allSameLang.insert(0, currentLocale) ;

    String fallbackLanguage = getFallbackLanguage( currentLocale.language ) ;

    List<IntlLocale> allFallback = [] ;

    if (fallbackLanguage != null && fallbackLanguage.isNotEmpty && currentLocale.language != fallbackLanguage) {
      allFallback = List.from(_ALL_LOCALES) ;
      allFallback.retainWhere( (l) => l.language == fallbackLanguage ) ;
    }

    List<IntlLocale> possibleLocalesOrder = [] ;
    possibleLocalesOrder.addAll(allSameLang) ;
    possibleLocalesOrder.addAll(allFallback) ;

    List<IntlLocale> prevPossibleLocalesOrder = this._possibleLocalesOrder ;

    this._possibleLocalesOrder = possibleLocalesOrder ;

    if ( possibleLocalesOrder != prevPossibleLocalesOrder ) {
      return autoDiscover() ;
    }

    return false ;
  }

  IntlFallbackLanguage _fallbackLanguages = IntlFallbackLanguage() ;

  IntlFallbackLanguage get fallbackLanguages => _fallbackLanguages;

  set fallbackLanguages(IntlFallbackLanguage value) {
    _fallbackLanguages = value;
  }

  String getFallbackLanguage(String language) {
    if (_fallbackLanguages == null) return "en" ;
    return _fallbackLanguages.get(language) ;
  }

  void clearMessages() {
    _localizedMessages.clear();
    _defineLocalesOrder() ;
  }

  final EventStream<String> onRegisterLocalizedMessages = EventStream() ;

  static final EventStream<String> onRegisterLocalizedMessagesGlobal = EventStream() ;

  void registerLocalizedMessages( LocalizedMessages localizedMessages ) {
    if (localizedMessages == null) return ;

    var intlLocale = localizedMessages.locale;

    _localizedMessages[ intlLocale ] = localizedMessages ;
    _defineLocalesOrder() ;

    onRegisterLocalizedMessages.add( intlLocale.locale ) ;
    onRegisterLocalizedMessagesGlobal.add( intlLocale.locale ) ;
  }

  List<IntlLocale> getRegisteredIntLocales() {
    return List.from( _localizedMessages.keys ) ;
  }

  List<String> getRegisteredLocales() {
    return getRegisteredIntLocales().map( (l) => l.locale ).toList() ;
  }

  final Set<IntlResourceDiscover> _resourceDiscovers = {} ;

  Future<bool> registerResourceDiscover(IntlResourceDiscover discover) async {
    var changed = _resourceDiscovers.add(discover) ;

    if (changed) {
      _clearAutoFindLocalizedMessagesLocales() ;
      return autoDiscover() ;
    }
    else {
      return false;
    }
  }

  bool unregisterResourceDiscover(IntlResourceDiscover discover) {
    var changed = _resourceDiscovers.remove(discover) ;
    if (changed) {
      _clearAutoFindLocalizedMessagesLocales() ;
      autoDiscover() ;
    }
    return changed ;
  }

  Future<bool> autoDiscover() async {
    if ( _resourceDiscovers.isEmpty ) return false ;

    bool found = false ;

    for ( var l in _getPossibleLocalesOrder() ) {
      var ret = await _autoFindLocalizedMessagesAsync(l) ;
      if (ret) {
        found = true ;
      }
    }

    return found ;
  }

  void _clearAutoFindLocalizedMessagesLocales() {
    _autoFindLocalizedMessagesLocales.clear() ;
  }

  final Map<IntlLocale,Future<bool>> _autoFindLocalizedMessagesLocales = {} ;

  dynamic _autoFindLocalizedMessages(IntlLocale locale) {
    if ( _resourceDiscovers.isEmpty ) return false ;

    if ( _localizedMessages.containsKey(locale) ) {
      return false ;
    }

    var prev = _autoFindLocalizedMessagesLocales[locale] ;
    if ( prev != null ) return prev ;

    var future = _autoFindLocalizedMessagesImpl(locale);
    _autoFindLocalizedMessagesLocales[locale] = future ;

    return future ;
  }

  Future<bool> _autoFindLocalizedMessagesAsync(IntlLocale locale) async {
    if ( _resourceDiscovers.isEmpty ) return false ;

    var prev = _autoFindLocalizedMessagesLocales[locale] ;
    if ( prev != null ) return prev ;

    if ( _localizedMessages.containsKey(locale) ) {
      prev = Future.value(true) ;
      _autoFindLocalizedMessagesLocales[locale] = prev ;
      return prev ;
    }

    var future = _autoFindLocalizedMessagesImpl(locale);
    _autoFindLocalizedMessagesLocales[locale] = future ;

    return future ;
  }

  Future<bool> _autoFindLocalizedMessagesImpl(IntlLocale locale) async {
    for (var r in _resourceDiscovers) {
      var resource = await r.find(locale.locale) ;

      if (resource != null) {
        var registered = await registerMessagesResourceContent(resource) ;
        if (registered) {
          return true ;
        }
      }
    }

    return false ;
  }

  MessageBuilder msg(String key) {
    return MessageBuilder._(this, key) ;
  }

  LocalizedMessage _msg(String key) {
    var localesOrder = _getLocalesOrder();

    for (var l in localesOrder) {
      var localizedMessage = _localizedMessages[l];

      if (localizedMessage != null) {
        var msg = localizedMessage.msg(key);
        if (msg != null) return LocalizedMessage(l, key, msg);
      }
    }

    for ( var l in _getPossibleLocalesOrder() ) {
      var ret = _autoFindLocalizedMessages(l) ;

      if (ret is bool) {
        if (!ret) {
          return null ;
        }
      }
      else if (ret is Future) {
        //...
      }
    }

    return null ;
  }

  @override
  MessageBuilder operator [](String key) => msg(key) ;

}

class MessageBuilder {
  final IntlMessages _intlMessages ;
  final String _key;

  MessageBuilder._(this._intlMessages, this._key) ;

  IntlMessages get intlMessages => _intlMessages;

  String get key => _key ;

  String build( [ Map<String,dynamic> variables ] ) {
    var msg = message ;
    if (msg == null) return null ;
    return msg.build(variables) ;
  }

  LocalizedMessage get message => this._intlMessages._msg(key);

  @override
  String toString() {
    return build() ;
  }

}

////////////////////////////////////////////////////////////////////////////////

class LocalizedMessage {

  final IntlLocale locale;
  final String key;
  final Message message ;

  LocalizedMessage(this.locale, this.key, this.message);

  String build( [ Map<String,dynamic> variables ] ) {
    if (message == null) return null ;
    return message.build(variables) ;
  }

  @override
  String toString() {
    return 'LocalizedMessage{locale: $locale, message: $message}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LocalizedMessage &&
              runtimeType == other.runtimeType &&
              locale == other.locale &&
              key == other.key &&
              message == other.message;

  @override
  int get hashCode =>
      locale.hashCode ^
      key.hashCode ^
      message.hashCode;

}

class LocalizedMessages {

  final IntlLocale locale ;
  final Map<String,Message> _messages = {} ;

  LocalizedMessages(this.locale, List<Message> messages) {
    if ( this.locale == null ) throw ArgumentError.notNull("locale") ;
    loadMessages(messages) ;
  }

  void clearMessages() {
    _messages.clear();
  }

  void loadMessages(List<Message> messages) {
    if (messages == null || messages.isEmpty) return ;

    for (Message msg in messages) {
      this._messages[ msg.key ] = msg ;
    }
  }

  Message msg(String key) {
    return this._messages[ key ] ;
  }

}

List<String> _ALL_LOCALES_CODES = ALL_LOCALES_CODES() ;

List<IntlLocale> _ALL_LOCALES = _ALL_LOCALES_CODES.map( (l) => IntlLocale(l) ).toList() ;

int _getLocaledIndex(String locale) {
  int idx = _ALL_LOCALES_CODES.indexOf(locale) ;
  if (idx >= 0) return idx ;

  IntlLocale intlLocale = IntlLocale.code(locale) ;

  locale = intlLocale.locale ;

  idx = _ALL_LOCALES_CODES.indexOf(locale) ;
  if (idx >= 0) return idx ;

  var lang = intlLocale._language;
  String prefix = "${ lang }_" ;

  for (var i = 0; i < _ALL_LOCALES_CODES.length; ++i) {
    var l = _ALL_LOCALES_CODES[i];

    if ( l == lang || l.startsWith(prefix) ) {
      return i ;
    }
  }

  return -1 ;
}

abstract class _IntlDefaultLocale {

  static String _locale ;

  static String get locale => getLocale();

  static String getLocale() {
    _initialize() ;
    return _locale ;
  }

  static void setLocale(dynamic locale) {
    _setLocale(locale) ;
  }

  static bool _initialized = false ;

  static void _initialize() {
    if (_initialized) return ;
    _initialized = true ;

    var defaultLocale = Intl.defaultLocale ;

    if (defaultLocale != null) {
      _setLocale(defaultLocale) ;
      return ;
    }

    var instancesInitialized = LocalesManager.instancesInitialized() ;

    if ( instancesInitialized.isNotEmpty ) {
      var initializedLocales = instancesInitialized[0].getInitializedLocales();
      if ( initializedLocales.isNotEmpty ) {
        _setLocale( initializedLocales[0] ) ;
        return ;
      }
    }

    if ( _locale == null ) {
      LocalesManager.onDefineLocaleGlobal.listen( (l) => _setLocale(l) ) ;
    }
  }

  static final EventStream<String> onDefineLocale = EventStream() ;

  static void _setLocale(dynamic locale) {
    if (locale == null) return ;

    IntlLocale intlLocale = IntlLocale(locale) ;
    _locale = intlLocale.locale ;

    onDefineLocale.add(_locale) ;
  }

}

class IntlLocale implements Comparable<IntlLocale> {

  static void setDefaultLocale(dynamic locale) {
    _IntlDefaultLocale.setLocale( locale ) ;
  }

  static String getDefaultLocale() {
    return _IntlDefaultLocale.getLocale() ;
  }

  static IntlLocale getDefaultIntlLocale() {
    return IntlLocale.code( getDefaultLocale() ) ;
  }

  static String get defaultLocale => getDefaultLocale() ;

  static EventStream<String> get onDefineDefaultLocale => _IntlDefaultLocale.onDefineLocale ;

  static String _normalizeLanguage(String lang) => lang.toLowerCase().trim();

  static String _normalizeRegion(String reg) {
    if (reg == null) return "" ;
    return reg.trim().toUpperCase() ;
  }

  ///////////////////////////////////////////

  String _language ;
  String _region ;

  IntlLocale.code(String localeCode) {
    var split = localeCode.split('_') ;

    String lang = _normalizeLanguage(split[0]) ;
    String reg = _normalizeRegion( split.length > 1 ? split[1] : null ) ;

    if (lang == null || lang.isEmpty) throw ArgumentError.notNull("language") ;

    this._language = lang ;
    this._region = reg ;
  }

  factory IntlLocale.path(String path) {
    int idx = path.lastIndexOf('_') ;

    if (idx >= 0) {
      if (idx < 2) throw ArgumentError("Can't find locale delimiter in path") ;

      String lang = path.substring(idx-2,idx) ;
      String reg = path.substring(idx+1);

      if (reg.length > 3) reg = reg.substring(0,3) ;
      if (reg.length == 3 && !RegExp(r'[a-zA-Z]').hasMatch(reg.substring(2,3))) {
        reg = reg.substring(0,2) ;
      }

      return IntlLocale.langReg(lang, reg) ;
    }

    idx = path.lastIndexOf('.') ;

    if (idx > 2) {
      String lang = path.substring(idx-2,idx) ;

      if (!RegExp(r'[a-zA-Z]').hasMatch(lang)) {
        throw ArgumentError("Can't corrent locale part (only language)") ;
      }

      return IntlLocale(lang) ;
    }

    throw ArgumentError("Can't find locale part in path") ;
  }

  IntlLocale.langReg(String language, [String region]) {
    if (language == null || language.isEmpty) throw ArgumentError.notNull("language") ;
    if (region == null) region = "" ;

    this._language = language.toLowerCase().trim() ;
    this._region = region.toUpperCase().trim() ;
  }

  factory IntlLocale(dynamic locale) {
    if ( locale == null ) return IntlLocale.getDefaultIntlLocale() ;

    if ( locale is IntlLocale ) {
      return locale ;
    }

    if ( locale is List ) {
      if ( locale.isEmpty ) return getDefaultIntlLocale() ;

      String lang = locale[0] ;
      String reg = locale.length > 1 ? locale[1] : null ;
      return IntlLocale.langReg(lang, reg) ;
    }

    if ( locale is Map ) {
      if ( locale.isEmpty ) return IntlLocale.getDefaultIntlLocale() ;

      String lang = locale['language'] ?? locale['lang'] ;
      if ( lang == null || lang.isEmpty ) return IntlLocale.getDefaultIntlLocale() ;

      String reg = locale['region'] ?? locale['reg'] ;
      return IntlLocale.langReg(lang, reg) ;
    }

    return IntlLocale.code( "$locale" ) ;
  }

  String get language => _language;
  String get region => _region;

  bool get hasRegion => _region.isNotEmpty ;

  String get locale => hasRegion ? "${_language}_$_region" : _language ;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is IntlLocale &&
              runtimeType == other.runtimeType &&
              _language == other._language &&
              _region == other._region;

  @override
  int get hashCode =>
      _language.hashCode ^
      _region.hashCode;

  int compareTo(IntlLocale o) {
    if (this == o) return 0 ;

    int idx1 = _getLocaledIndex( this.locale ) ;
    int idx2 = _getLocaledIndex( o.locale ) ;

    return idx1.compareTo(idx2) ;
  }

  @override
  String toString() {
    return 'IntlLocale{$locale}';
  }

}

class IntlFallbackLanguage {

  String _defaultFallback ;

  IntlFallbackLanguage([String defaultFallback]) {
    if (defaultFallback == null || defaultFallback.trim() == "") {
      defaultFallback = "en" ;
    }

    this._defaultFallback = IntlLocale._normalizeLanguage(defaultFallback) ;
  }

  String get defaultFallback => _defaultFallback;

  Map<String,String> _fallbacks = {} ;

  Map<String, String> get fallbacks => Map.from( _fallbacks ) ;

  void set(String language, fallbackLanguage) {
    language = IntlLocale._normalizeLanguage(language) ;
    fallbackLanguage = IntlLocale._normalizeLanguage(fallbackLanguage) ;

    _fallbacks[ language ] = fallbackLanguage ;
  }

  String get(String language) {
    language = IntlLocale._normalizeLanguage(language) ;
    var fallback = _fallbacks[language] ;
    return fallback ?? _defaultFallback ;
  }

  String remove(String language) {
    language = IntlLocale._normalizeLanguage(language) ;
    var fallback = _fallbacks.remove(language) ;
    return fallback ;
  }

  void clear() {
    _fallbacks.clear() ;
  }

}

class Message {

  String _key ;
  MessageValue _value ;

  Message.keyValue(dynamic key, dynamic value) {
    this._key = key.toString() ;
    this._value = MessageValue(value) ;
  }

  Message.line(String line) {
    int idx = line.indexOf('=') ;
    this._key = line.substring(0,idx) ;
    this._value = MessageValue( line.substring(idx+1) ) ;
  }

  Message.entry(dynamic entry) {
    if (entry is List) {
      List list = entry ;
      this._key = list[0];
      this._value = MessageValue(list[1]) ;
    }
    else if (entry is Map) {
      Map map = entry ;
      this._key = map['key'] ;
      this._value = MessageValue( map['value'] ) ;
    }
    else {
      throw ArgumentError.value(entry, "entry", "Invalid entry as Message") ;
    }
  }

  String get key => _key ;

  String build( [ Map<String,dynamic> variables ] ) {
    return this._value.build(variables) ;
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Message &&
              runtimeType == other.runtimeType &&
              _key == other._key &&
              _value == other._value;

  @override
  int get hashCode =>
      _key.hashCode ^
      _value.hashCode;

  @override
  String toString() {
    return build() ;
  }

}

enum MessageBlockBranchType {
  ZERO,
  ONE,
  MANY,
  OTHER,
  DEFAULT
}

class MessageBlock {
  List<MessageBlockBranch> _branches ;

  MessageBlock._(this._branches) {
    _branches.sort( (a,b) => a.compareTo(b) ) ;
  }

  static final RegExp REGEXP_BLOCK_SPLITTER = RegExp(r'([\\])?\|', multiLine: true) ;

  factory MessageBlock(String block) {
    List<String> parts = [] ;

    bool appendToPrevBlock = false ;

    int cursor = 0 ;
    for ( var m in REGEXP_BLOCK_SPLITTER.allMatches(block) ) {
      String prev ;
      if (m.start > cursor) {
        prev = block.substring(cursor, m.start);
      }

      String escapedChar = m.group(1) ;
      bool escaped = false ;

      if (escapedChar != null && escapedChar.isNotEmpty) {
        prev += "|" ;
        escaped = true ;
      }

      if (prev != null && prev.isNotEmpty) {
        if (appendToPrevBlock) {
          parts[ parts.length-1 ] += prev ;
        }
        else {
          parts.add(prev);
        }
      }

      appendToPrevBlock = escaped ;

      cursor = m.end ;
    }

    if (block.length > cursor) {
      String tail = block.substring(cursor);
      if (appendToPrevBlock) {
        parts[ parts.length-1 ] += tail ;
      }
      else {
        parts.add(tail);
      }
    }

    List<MessageBlockBranch> branches = [] ;

    for (String part in parts) {
      branches.add( MessageBlockBranch(part) ) ;
    }

    return MessageBlock._(branches) ;
  }



  MessageBlockBranch matchBranch( Map<String,dynamic> variables ) {
    for ( var branch in _branches ) {
      if ( branch.matches( variables ) ) {
        return branch ;
      }
    }

    for ( var branch in _branches ) {
      if ( branch._type == MessageBlockBranchType.DEFAULT ) {
        return branch ;
      }
    }

    for ( var branch in _branches ) {
      if ( branch._type == MessageBlockBranchType.OTHER ) {
        return branch ;
      }
    }

    return null ;
  }

  String build( Map<String,dynamic> variables ) {
    var branch = matchBranch(variables) ;
    if (branch == null) return "" ;
    return branch.build(variables) ;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MessageBlock &&
              runtimeType == other.runtimeType &&
              _branches == other._branches;

  @override
  int get hashCode => _branches.hashCode;

}

class MessageBlockBranch {
  MessageBlockBranchType _type ;
  String _variableName ;
  MessageValue _value ;

  MessageBlockBranch._(this._type, this._variableName, this._value) ;

  factory MessageBlockBranch(String branch) {
    int idx = branch.indexOf(':') ;

    if (idx < 0) {
      return MessageBlockBranch._( MessageBlockBranchType.DEFAULT , null , MessageValue(branch) ) ;
    }

    String typeStr = branch.substring(0,idx).trim() ;

    String value = branch.substring(idx+1) ;

    int idx2 = typeStr.indexOf('[') ;
    int idx3 = typeStr.indexOf(']') ;

    if (idx2 > 0 && idx3 > idx2) {
      String type = typeStr.substring(0,idx2).toUpperCase().trim() ;
      String varName = typeStr.substring(idx2+1,idx3).trim() ;

      return MessageBlockBranch._( EnumToString.fromString(MessageBlockBranchType.values, type) , varName , MessageValue(value) ) ;
    }
    else {
      typeStr = typeStr.toUpperCase() ;
      return MessageBlockBranch._( EnumToString.fromString(MessageBlockBranchType.values, typeStr) , null , MessageValue(value) ) ;
    }
  }

  String build( Map<String,dynamic> variables ) {
    return _value.build( variables ) ;
  }

  bool matches(Map<String,dynamic> variables) {
    switch (_type) {
      case MessageBlockBranchType.ZERO: return matchesZero(variables) ;
      case MessageBlockBranchType.ONE: return matchesOne(variables) ;
      case MessageBlockBranchType.MANY: return matchesMany(variables) ;
      case MessageBlockBranchType.OTHER: return matchesOther(variables) ;
      case MessageBlockBranchType.DEFAULT: return false ;
      default: return false ;
    }
  }

  bool matchesZero(Map<String,dynamic> variables) {
    if (variables == null || variables.isEmpty) return true ;
    var varVal = variables[_variableName] ;
    if (varVal == null) return true ;

    var nStr = "$varVal";
    var nStrLC = nStr.toLowerCase();

    if (nStr == "0" || nStrLC == "zero" || nStrLC == "null") return true ;

    double n = double.tryParse(nStr) ;

    if (n == null) {
      return nStr == "0.0" || nStr == "0,0" ;
    }

    return _delta(0, n) < 0.0001 ;
  }

  bool matchesOne(Map<String,dynamic> variables) {
    if (variables == null || variables.isEmpty) return false ;
    var varVal = variables[_variableName] ;
    if (varVal == null) return false ;

    var nStr = "$varVal" ;
    if ( nStr == "1" || nStr.toLowerCase() == "one" ) return true ;

    double n = double.tryParse(nStr) ;

    if (n == null) {
      return nStr == "1.0" || nStr == "1,0" ;
    }

    if (n == 1) return true ;

    return _delta(1, n) < 0.0001 ;
  }

  bool matchesMany(Map<String,dynamic> variables) {
    if (variables == null || variables.isEmpty) return false ;
    var varVal = variables[_variableName] ;
    if (varVal == null) return false ;

    var nStr = "$varVal" ;

    double n = double.tryParse(nStr) ;
    if (n == null) {
      return false ;
    }

    return n >= 2 ;
  }

  bool matchesOther(Map<String,dynamic> variables) {
    if (variables == null || variables.isEmpty) return false ;
    var varVal = variables[_variableName] ;
    if (varVal == null) return false ;

    var nStr = "$varVal" ;

    double n = double.tryParse(nStr) ;
    if (n == null) {
      return false ;
    }

    return true ;
  }

  static double _delta(double a, double b) {
    double delta = a-b ;
    if (delta < 0) delta = -delta ;
    return delta ;
  }

  int compareTo(MessageBlockBranch b) {
    if (b == null) return 1 ;
    if (this._type == b._type) return 0 ;

    if (this._type == null) return 1 ;
    if (b._type == null) return 1 ;

    return this._type.index.compareTo( b._type.index ) ;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MessageBlockBranch &&
              runtimeType == other.runtimeType &&
              _type == other._type &&
              _variableName == other._variableName &&
              _value == other._value;

  @override
  int get hashCode =>
      _type.hashCode ^
      _variableName.hashCode ^
      _value.hashCode;

}

class MessageValue {
  List<dynamic> _values ;

  MessageValue._(this._values);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MessageValue &&
              runtimeType == other.runtimeType &&
              _values == other._values;

  @override
  int get hashCode => _values.hashCode;

  static final RegExp REGEXP_BLOCK = RegExp(r'\{((?:[^}]+|\\})+?)\}', multiLine: true) ;

  factory MessageValue(dynamic value) {
      List<dynamic> built = [] ;

      if ( value is List ) {
        List list = value ;

        for (dynamic e in list) {
          var val = MessageValue(e) ;
          built.addAll(val._values) ;
        }
      }
      else {
        String line = "$value" ;

        int cursor = 0 ;
        for ( var m in REGEXP_BLOCK.allMatches(line) ) {
          if (m.start > cursor) {
            String prev = line.substring(cursor, m.start);
            built.addAll( _buildValue_fromString(prev) ) ;
          }

          String block = m.group(1) ;
          built.add( MessageBlock(block) ) ;

          cursor = m.end ;
        }

        if (line.length > cursor) {
          String tail = line.substring(cursor);
          built.addAll( _buildValue_fromString(tail) ) ;
        }
      }

      return MessageValue._(built) ;
  }

  static final RegExp REGEXP_VAR_NAME = RegExp(r'(\\)?\$(\w+)', multiLine: true) ;

  static List<dynamic> _buildValue_fromString(String line) {
    List<dynamic> built = [] ;

    int cursor = 0 ;
    for ( var m in REGEXP_VAR_NAME.allMatches(line) ) {
      if (m.start > cursor) {
        String prev = line.substring(cursor, m.start);
        prev = _normalizeValueString(prev);
        built.add(prev);
      }

      bool escapedVar = false ;

      String prevVar = m.group(1) ;
      if ( prevVar != null && prevVar.isNotEmpty ) {
        escapedVar = true ;
      }

      String varName = m.group(2) ;

      if (escapedVar) {
        String varEscaped = "\$$varName" ;
        built.add(varEscaped);
      }
      else {
        built.add( MessageVariable(varName) );
      }

      cursor = m.end ;
    }

    if (line.length > cursor) {
      String tail = line.substring(cursor);
      tail = _normalizeValueString(tail) ;
      built.add(tail);
    }

    return built ;
  }

  static String _normalizeValueString(String value) {
    var valNorm = value
        .replaceAll("\\n", "\n" )
        .replaceAll("\\r", "\r" ) ;
    return valNorm ;
  }

  String build( [ Map<String,dynamic> variables ] ) {
    String built = "" ;

    for ( var e in this._values ) {
      if (e is MessageVariable) {
        built += e.build(variables) ;
      }
      else if (e is MessageBlock) {
        built += e.build(variables) ;
      }
      else {
        built += e.toString() ;
      }
    }

    return built ;
  }

}

class MessageVariable {
  final String name ;

  MessageVariable(this.name);

  String build( Map<String,dynamic> variables ) {
    if (variables == null || variables.isEmpty) return "" ;

    var built = variables[name] ;
    return built != null ? built.toString() : "" ;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MessageVariable &&
              runtimeType == other.runtimeType &&
              name == other.name;

  @override
  int get hashCode => name.hashCode;

}
