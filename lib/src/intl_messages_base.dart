import 'dart:convert';

import 'package:async_extension/async_extension.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:intl/intl.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:resource_portable/resource.dart' show Resource;
import 'package:swiss_knife/swiss_knife.dart';

import 'locales.dart';

void _log(String message, [bool warning = false]) {
  if (warning) {
    print('intl_messages> ** [WARNING] $message');
  } else {
    print('intl_messages> -- $message');
  }
}

/// A internationalized [ResourceContent]
class IntlResourceContent extends ResourceContent {
  final String locale;

  IntlResourceContent(this.locale, Resource resource, [String? content])
      : super(resource, content);
}

/// Internationalized resource discover. Identifies and loads available
/// localized resource.
class IntlResourceDiscover {
  final ResourceContentCache _resourceContentCache = ResourceContentCache();

  final String resourcePathPrefix;

  String resourcePathSuffix;

  /// Creates a IntlResourceDiscover.
  /// [resourcePathPrefix] The prefix path of the resource file.
  /// [resourcePathSuffix] The suffix path of the resource file.
  IntlResourceDiscover(this.resourcePathPrefix, [this.resourcePathSuffix = '']);

  List<String>? _languagesCodesToLookup;

  FutureOr<List<String>> _getLanguagesCodesToLookup() {
    final languagesCodesToLookup = _languagesCodesToLookup;
    if (languagesCodesToLookup != null) return languagesCodesToLookup;

    return _getLanguagesToLookup().resolveMapped((list) {
      return _languagesCodesToLookup = list.map((l) => l.code).toList();
    });
  }

  List<IntlLocale>? _languagesToLookup;

  FutureOr<List<IntlLocale>>? _languagesToLookupAsync;

  FutureOr<List<IntlLocale>> _getLanguagesToLookup() {
    final languagesToLookup = _languagesToLookup;
    if (languagesToLookup != null) return languagesToLookup;

    final toLookup = _allLocales.toList();

    return _languagesToLookupAsync ??=
        _getDefinedLocales().resolveMapped((defined) {
      if (defined.isNotEmpty) {
        toLookup.retainWhere((l) => defined.contains(l));

        var localesManagers = LocalesManager.instances();
        for (var l in localesManagers) {
          l.addLanguagesToLookup(toLookup);
        }
      }

      _languagesToLookup = toLookup;
      _languagesToLookupAsync = null;
      return toLookup;
    });
  }

  FutureOr<List<IntlLocale>>? _definedLocales;

  FutureOr<List<IntlLocale>> _getDefinedLocales() {
    var definedLocales = _definedLocales;
    if (definedLocales != null) return definedLocales;

    _definedLocales = definedLocales = _findDefinedLocales();

    definedLocales.then((locales) {
      _definedLocales = locales;
    });

    return definedLocales;
  }

  Future<List<IntlLocale>> _findDefinedLocales() async {
    var list = await _findDefinedLocalesNames();
    return list.map((l) => IntlLocale(l)).toList();
  }

  Future<List<String>> _findDefinedLocalesNames() async {
    var resourcePath = '${resourcePathPrefix}locales$resourcePathSuffix';

    print('Find defined locales> $resourcePath');

    var resource = Resource(resourcePath);

    var resourceContent = _resourceContentCache.get(resource)!;

    try {
      String? content;
      try {
        content = await resourceContent.getContent();
      } catch (e) {
        //print("Find error: $e");
      }

      if (content != null) {
        content = content.trim();
        if (content.isEmpty) return <String>[];
        var list = content
            .split(RegExp(r'[,;\s|]+', multiLine: true))
            .where((l) => l.isNotEmpty)
            .toList();
        return list;
      }
      // ignore: empty_catches
    } catch (ignore) {}

    return <String>[];
  }

  int _findCount = 0;

  int get findCount => _findCount;

  final Map<String, IntlResourceContent> _findCache = {};

  /// Clears the cache used by [find].
  void clearFindCache() {
    _languagesToLookup = null;
    _definedLocales = null;
    _findCache.clear();
    _finding.clear();
  }

  final Map<String, Future<IntlResourceContent?>> _finding = {};

  /// Finds the resource with [locale].
  FutureOr<IntlResourceContent?> find(String locale) {
    if (locale.isEmpty) return null;

    var cached = _findCache[locale];
    if (cached != null) return cached;

    return _getLanguagesCodesToLookup().resolveMapped((languagesToLookup) {
      if (!languagesToLookup.contains(locale)) return null;

      var finding = _finding[locale];
      if (finding != null) return finding;

      _finding[locale] = finding = _findImpl(locale);

      finding.then((_) {
        _finding.remove(locale);
      });

      return finding;
    });
  }

  Future<IntlResourceContent?> _findImpl(String locale) async {
    var resourcePath = '$resourcePathPrefix$locale$resourcePathSuffix';
    var resource = Resource(resourcePath);

    var resourceContent = _resourceContentCache.get(resource)!;

    try {
      _findCount++;

      String? content;
      try {
        content = await resourceContent.getContent();
      } catch (e) {
        //print("Find error: $e");
      }

      if (content != null) {
        var resourceContent = IntlResourceContent(locale, resource, content);
        _findCache[locale] = resourceContent;
        return resourceContent;
      }
      // ignore: empty_catches
    } catch (ignore) {}

    return null;
  }

  /// Find all localized versions of the resource.
  Future<List<IntlResourceContent>> findAll() async {
    return findWithLocales(await _getLanguagesCodesToLookup());
  }

  /// Finds the resource withe [locales].
  Future<List<IntlResourceContent>> findWithLocales(
      List<String> locales) async {
    var found = <IntlResourceContent>[];
    if (locales.isEmpty) return found;

    for (var l in locales) {
      var resource = await find(l);
      if (resource != null) found.add(resource);
    }

    return found;
  }

  @override
  String toString() {
    return 'IntlResourceDiscover{_resourcePathPrefix: $resourcePathPrefix, _resourcePathSuffix: $resourcePathSuffix, _findCount: $_findCount}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntlResourceDiscover &&
          runtimeType == other.runtimeType &&
          resourcePathPrefix == other.resourcePathPrefix &&
          resourcePathSuffix == other.resourcePathSuffix;

  @override
  int get hashCode => resourcePathPrefix.hashCode ^ resourcePathSuffix.hashCode;
}

/// Represents a message table with keys and values.
class IntlMessages {
  // ignore: constant_identifier_names
  static const String VERSION = '2.1.7';

  static String normalizePackageName(String packageName) =>
      packageName.toLowerCase().trim();

  static Map<String, IntlMessages> instances = {};

  factory IntlMessages.package(String packageName) {
    packageName = normalizePackageName(packageName);
    var instance = instances[packageName];

    if (instance == null) {
      instance = IntlMessages._(packageName);
      instances[packageName] = instance;
    }

    return instance;
  }

  static void _notifySetLocale(String? locale) {
    for (var instance in instances.values) {
      instance._defineLocalesOrder(true);
    }
  }

  final String packageName;

  IntlMessages._(this.packageName);

  /// Finds with [discover] and register resolved [IntlResourceContent].
  Future<bool> findAndRegisterMessagesResources(
      IntlResourceDiscover discover) async {
    var resources = await discover.findAll();
    return registerMessagesResourcesContents(resources);
  }

  /// Finds with [discover] using [locales] and register resolved [IntlResourceContent].
  Future<bool> findAndRegisterMessagesResourcesWithLocales(
      IntlResourceDiscover discover, List<String> locales) async {
    var resources = await discover.findWithLocales(locales);
    return registerMessagesResourcesContents(resources);
  }

  /// Initializes the messages an tries to discover available locales and resources.
  void initialize() {
    autoDiscover();
  }

  /// Register resolved [resources].
  Future<bool> registerMessagesResourcesContents(
      List<IntlResourceContent> resources) async {
    if (resources.isEmpty) return Future.value(false);

    var ok = false;

    for (var r in resources) {
      var registered = await registerMessagesResourceContent(r);
      if (registered) ok = true;
    }

    return ok;
  }

  /// Register resolved [resource].
  Future<bool> registerMessagesResourceContent(
      IntlResourceContent resource) async {
    var content = await resource.getContent();
    var locale = IntlLocale.code(resource.locale);
    return registerMessages(locale, content ?? '');
  }

  /// Register a specific [resourcePath], without localized versions capability like [IntlResourceContent].
  Future<bool> registerMessagesResourcePath(String resourcePath) async {
    var resource = Resource(resourcePath);
    return registerMessagesResource(resource);
  }

  /// Register [resources], without localized versions capability like [IntlResourceContent].
  Future<bool> registerMessagesResources(List<Resource> resources) async {
    if (resources.isEmpty) return Future.value(false);

    var ok = false;

    for (var r in resources) {
      var content = await r.readAsString();
      var locale = IntlLocale.path(r.uri.toString());
      var registered = registerMessages(locale, content);
      if (registered) ok = true;
    }

    return ok;
  }

  /// Register specific [resource], without localized versions capability like [IntlResourceContent].
  Future<bool> registerMessagesResource(Resource resource) async {
    var content = await resource.readAsString();
    var locale = IntlLocale.path(resource.uri.toString());
    return registerMessages(locale, content);
  }

  /// Register messages present in [content] document.
  bool registerMessages(dynamic locale, String content) {
    var intlLocale = IntlLocale(locale);

    List<Message>? messages;

    if (isContentJSON(content)) {
      messages = _parseContentJSON(content);
    } else if (isContentYAML(content)) {
      messages = _parseContentYAML(content);
    } else if (isContentProperties(content)) {
      messages = _parseContentProperties(content);
    }

    registerLocalizedMessages(LocalizedMessages(intlLocale, messages));

    return true;
  }

  /// Identifies [content] with JSON format.
  bool isContentJSON(String content) {
    content = content.trim();
    return content.startsWith('{') && content.endsWith('}');
  }

  /// Identifies [content] with YAML format.
  bool isContentYAML(String content) {
    content = content
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'(?:^|\n)[ \t]*#[^\n]*'), '\n');

    content = content.replaceAll(RegExp(r'\n[ \t]*\n'), '\n\n');
    content = content.replaceAll(RegExp(r'\n[ \t]*\n'), '\n\n');
    content = content.replaceAll(RegExp(r'\n+'), '\n');

    return RegExp(r'(?:^|\n)[ \t]*[\w.]+:').hasMatch(content);
  }

  /// Identifies [content] with properties format.
  bool isContentProperties(String content) {
    content = content.trim();
    return content.startsWith(RegExp(r'[\w.-]+=\S+'));
  }

  List<Message> _parseContentJSON(String content) {
    dynamic json;
    try {
      json = jsonDecode(content);
    } catch (_) {
      return _parseContentProperties(content);
    }

    return _parseContentFromJson(json, content);
  }

  List<Message> _parseContentYAML(String content) {
    dynamic json;
    try {
      json = yaml.loadYaml(content);
    } catch (_) {
      return _parseContentProperties(content);
    }

    return _parseContentFromJson(json, content);
  }

  List<Message> _parseContentFromJson(json, String content) {
    if (json is Map) {
      var map = json;
      var messages = <Message>[];

      for (dynamic key in map.keys) {
        messages.add(Message.keyValue(key, map[key]));
      }

      return messages;
    } else if (json is List) {
      var list = json;
      var messages = <Message>[];

      for (dynamic entry in list) {
        try {
          var message = Message.entry(entry);
          messages.add(message);
          // ignore: empty_catches
        } catch (ignore) {}
      }

      return messages;
    } else {
      return _parseContentProperties(content);
    }
  }

  static final RegExp _messageKeyBlock = RegExp(
      r"""(?:^|[\r\n])([^\r\n]+?)=(?:'''[\r\n]?(.*?)[\r\n]?'''|"{3}[\r\n]?(.*?)[\r\n]?"{3})([^\r\n]*)""",
      multiLine: false, dotAll: true);

  List<Message> _parseContentProperties(String content) {
    var messages = <Message>[];

    content = content.replaceAllMapped(_messageKeyBlock, (match) {
      var key = match.group(1);
      var value1 = match.group(2);
      var value2 = match.group(3);
      var desc = match.group(4);

      var value = isNotEmptyString(value1, trim: true)
          ? value1
          : (isNotEmptyString(value2, trim: true) ? value2 : '');

      if (isEmptyString(desc, trim: true)) {
        desc = null;
      }

      try {
        var message = Message.keyValue(key, value, desc);
        messages.add(message);
        // ignore: empty_catches
      } catch (ignore) {}

      return '';
    });

    var lines = content.split(RegExp(r'[\r\n]+'));

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      try {
        var message = Message.line(line);
        messages.add(message);
        // ignore: empty_catches
      } catch (ignore) {}
    }

    return messages;
  }

  /// Returns the current resolved locales for this instance.
  IntlLocale? get currentLocale => getCurrentLocale();

  IntlLocale? _currentLocale;

  IntlLocale? getCurrentLocale() {
    if (_currentLocale != null) return _currentLocale;

    var locale = _IntlDefaultLocale.locale;

    if (locale != null) {
      return IntlLocale.code(locale);
    }

    return IntlLocale.code('en');
  }

  /// Sets the main locale for this instance.
  FutureOr<bool> setLocale(dynamic locale) {
    var intlLocale = IntlLocale(locale);
    if (_currentLocale == intlLocale) return false;

    _currentLocale = intlLocale;
    return _defineLocalesOrder(true);
  }

  final Map<IntlLocale, LocalizedMessages> _localizedMessages = {};

  List<IntlLocale>? _localesOrder;

  IntlLocale? _localesOrderLocale;

  List<IntlLocale>? _possibleLocalesOrder;

  List<IntlLocale>? _getLocalesOrder(bool callAutoDiscover) {
    if (_localesOrder == null) {
      _defineLocalesOrder(callAutoDiscover);
      return _localesOrder;
    }

    var currentLocale = this.currentLocale;
    if (currentLocale != _localesOrderLocale) {
      _defineLocalesOrder(callAutoDiscover);
    }

    return _localesOrder;
  }

  List<IntlLocale>? _getPossibleLocalesOrder(bool callAutoDiscover) {
    if (_possibleLocalesOrder == null) {
      _defineLocalesOrder(callAutoDiscover);
      return _possibleLocalesOrder;
    }

    var currentLocale = this.currentLocale;
    if (currentLocale != _localesOrderLocale) {
      _defineLocalesOrder(callAutoDiscover);
    }
    return _possibleLocalesOrder;
  }

  FutureOr<bool> _defineLocalesOrder(bool callAutoDiscover) {
    if (_defineLocalesOrderImpl()) {
      if (callAutoDiscover) {
        return autoDiscover();
      }
    }
    return false;
  }

  bool _defineLocalesOrderImpl() {
    var locales = List<IntlLocale>.from(_localizedMessages.keys);
    locales.sort();

    var currentLocale = this.currentLocale!;

    var idx = locales.indexOf(currentLocale);

    if (idx > 0) {
      var l = locales.removeAt(idx);
      locales.insert(0, l);
    }

    var sameLang = List<IntlLocale>.from(locales);
    sameLang.retainWhere(
        (l) => l.language == currentLocale.language && l != currentLocale);

    if (sameLang.isNotEmpty) {
      idx = locales.indexOf(currentLocale);

      sameLang.sort();
      locales.removeWhere((l) => sameLang.contains(l));

      if (idx >= 0) {
        locales.insertAll(idx + 1, sameLang);
      } else {
        locales.insertAll(0, sameLang);
      }
    }

    _localesOrder = locales;
    _localesOrderLocale = currentLocale;

    var allSameLang = List<IntlLocale>.from(_allLocales);
    allSameLang.retainWhere((l) => l.language == currentLocale.language);

    allSameLang.remove(currentLocale);
    allSameLang.insert(0, currentLocale);

    var fallbackLanguage = getFallbackLanguage(currentLocale.language);

    var allFallback = <IntlLocale>[];

    if (fallbackLanguage.isNotEmpty &&
        currentLocale.language != fallbackLanguage) {
      allFallback = List.from(_allLocales);
      allFallback.retainWhere((l) => l.language == fallbackLanguage);
    }

    var possibleLocalesOrder = <IntlLocale>[];
    possibleLocalesOrder.addAll(allSameLang);
    possibleLocalesOrder.addAll(allFallback);

    var prevPossibleLocalesOrder = _possibleLocalesOrder;
    _possibleLocalesOrder = possibleLocalesOrder;

    if (possibleLocalesOrder != prevPossibleLocalesOrder) {
      return true;
    }

    return false;
  }

  IntlMessages? _overrideMessages;

  IntlMessages? get overrideMessages => _overrideMessages;

  set overrideMessages(IntlMessages? value) {
    if (value != this) {
      _overrideMessages = value;

      if (value != null) {
        value.onRegisterLocalizedMessages.listen((locale) {
          if (_overrideMessages == value) {
            onRegisterLocalizedMessages.add(locale);
          }
        });
      }
    }
  }

  IntlMessages? _fallbackMessages;

  IntlMessages? get fallbackMessages => _fallbackMessages;

  set fallbackMessages(IntlMessages? value) {
    if (value != this) {
      _fallbackMessages = value;

      if (value != null) {
        value.onRegisterLocalizedMessages.listen((locale) {
          if (_fallbackMessages == value) {
            onRegisterLocalizedMessages.add(locale);
          }
        });
      }
    }
  }

  IntlFallbackLanguage fallbackLanguages = IntlFallbackLanguage();

  String getFallbackLanguage(String language) =>
      fallbackLanguages.get(language);

  void clearMessages() {
    _localizedMessages.clear();
    _defineLocalesOrder(true);
  }

  final EventStream<String> onRegisterLocalizedMessages = EventStream();

  static final EventStream<String> onRegisterLocalizedMessagesGlobal =
      EventStream();

  /// Register messages for this instance.
  void registerLocalizedMessages(LocalizedMessages localizedMessages) {
    var intlLocale = localizedMessages.locale;

    _localizedMessages[intlLocale] = localizedMessages;
    _defineLocalesOrder(true);

    print('registerLocalizedMessages> $intlLocale');

    onRegisterLocalizedMessages.add(intlLocale.code);
    onRegisterLocalizedMessagesGlobal.add(intlLocale.code);
  }

  bool get hasAnyRegisteredLocalizedMessage => _localizedMessages.isNotEmpty;

  bool hasRegisteredLocalizedMessage(dynamic locale) {
    var intlLocale = IntlLocale.from(locale);
    return intlLocale != null && _localizedMessages.containsKey(intlLocale);
  }

  /// Returns all registered [IntlLocale]
  List<IntlLocale> getRegisteredIntLocales() {
    return List.from(_localizedMessages.keys);
  }

  /// Same as [getRegisteredIntLocales], but as [String].
  List<String> getRegisteredLocales() {
    return getRegisteredIntLocales().map((l) => l.code).toList();
  }

  final Set<IntlResourceDiscover> _resourceDiscovers = {};

  /// Register a [discover] for resources.
  Future<bool> registerResourceDiscover(IntlResourceDiscover discover,
      {bool allowAutoDiscover = true}) async {
    if (_resourceDiscovers.contains(discover)) return false;

    var changed = _resourceDiscovers.add(discover);

    if (changed) {
      _clearAutoFindLocalizedMessagesLocales();
      if (allowAutoDiscover) {
        return autoDiscover();
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  bool unregisterResourceDiscover(IntlResourceDiscover discover) {
    var changed = _resourceDiscovers.remove(discover);
    if (changed) {
      _clearAutoFindLocalizedMessagesLocales();
      autoDiscover();
    }
    return changed;
  }

  Future<bool>? _autoDiscover;

  /// Starts auto discover process of resources and available locales.
  Future<bool> autoDiscover() =>
      _autoDiscover ??= _autoDiscoverImpl().resolveMapped((ok) {
        _autoDiscover = null;
        return ok;
      }).asFuture;

  FutureOr<bool> _autoDiscoverImpl() {
    if (_resourceDiscovers.isEmpty) return false;

    var possibleLocalesOrder = _getPossibleLocalesOrder(false)!;

    // Force load of `_getLanguagesToLookup` for the 1st `IntlResourceDiscover`:
    if (_resourceDiscovers.isNotEmpty) {
      var r = _resourceDiscovers.first;

      return r._getLanguagesToLookup().resolveMapped((_) {
        return _autoDiscoverImpl2(possibleLocalesOrder);
      });
    } else {
      return _autoDiscoverImpl2(possibleLocalesOrder);
    }
  }

  FutureOr<bool> _autoDiscoverImpl2(List<IntlLocale> possibleLocalesOrder) {
    var localesOkAsync = Map.fromEntries(possibleLocalesOrder.map((l) {
      var retAsync = _autoFindLocalizedMessagesAsync(l);
      return MapEntry(l, retAsync);
    })).resolveAllValues();

    return localesOkAsync.resolveMapped((localesOk) {
      final found =
          localesOk.entries.where((e) => e.value).map((e) => e.key).toSet();

      if (_resourceDiscovers.isNotEmpty) {
        return _autoDiscoverImpl3(found);
      } else {
        return found.isNotEmpty;
      }
    });
  }

  Future<bool> _autoDiscoverImpl3(Set<IntlLocale> found) async {
    for (var r in _resourceDiscovers) {
      var definedLocales = await r._getDefinedLocales();

      if (definedLocales.isNotEmpty) {
        for (var l in definedLocales.where((e) => !found.contains(e))) {
          var ret = await _autoFindLocalizedMessagesAsync(l);
          if (ret) {
            found.add(l);
          }
        }
      }
    }

    return found.isNotEmpty;
  }

  /// Auto discover a specific [locale].
  Future<bool> autoDiscoverLocale(dynamic locale) async {
    if (_resourceDiscovers.isEmpty) return false;

    var intlLocale = IntlLocale(locale);

    var futureFound = _autoFindLocalizedMessagesAsync(intlLocale);

    var futureFoundOverride = _overrideMessages != null
        ? _overrideMessages!.autoDiscoverLocale(locale)
        : Future.value(false);

    var futureFoundFallback = _fallbackMessages != null
        ? _fallbackMessages!.autoDiscoverLocale(locale)
        : Future.value(false);

    var found = await futureFound;
    var foundOverride = await futureFoundOverride;
    var foundFallback = await futureFoundFallback;

    var discovered = found || foundOverride || foundFallback;

    return discovered;
  }

  void _clearAutoFindLocalizedMessagesLocales() {
    _autoFindLocalizedMessagesLocales.clear();
  }

  final Map<IntlLocale, FutureOr<bool>> _autoFindLocalizedMessagesLocales = {};

  dynamic _autoFindLocalizedMessages(IntlLocale locale) {
    if (_resourceDiscovers.isEmpty) return false;

    if (_localizedMessages.containsKey(locale)) {
      return false;
    }

    var prev = _autoFindLocalizedMessagesLocales[locale];
    if (prev != null) return prev;

    var future = _autoFindLocalizedMessagesImpl(locale);
    _autoFindLocalizedMessagesLocales[locale] = future;

    future.then((ok) {
      _autoFindLocalizedMessagesLocales[locale] = ok;
    });

    return future;
  }

  FutureOr<bool> _autoFindLocalizedMessagesAsync(IntlLocale locale) {
    if (_resourceDiscovers.isEmpty) return false;

    var prev = _autoFindLocalizedMessagesLocales[locale];
    if (prev != null) return prev;

    if (_localizedMessages.containsKey(locale)) {
      prev = true;
      _autoFindLocalizedMessagesLocales[locale] = prev;
      return prev;
    }

    var future = _autoFindLocalizedMessagesImpl(locale);
    _autoFindLocalizedMessagesLocales[locale] = future;

    future.then((ok) {
      _autoFindLocalizedMessagesLocales[locale] = ok;
    });

    return future;
  }

  FutureOr<bool> _autoFindLocalizedMessagesImpl(IntlLocale locale) {
    if (_resourceDiscovers.isEmpty) {
      return false;
    } else if (_resourceDiscovers.length == 1) {
      var r = _resourceDiscovers.first;

      return r.find(locale.code).resolveMapped((resource) {
        if (resource != null) {
          return registerMessagesResourceContent(resource);
        }
        return false;
      });
    } else {
      return _autoFindLocalizedMessagesImpl2(locale);
    }
  }

  Future<bool> _autoFindLocalizedMessagesImpl2(IntlLocale locale) async {
    for (var r in _resourceDiscovers) {
      var resource = await r.find(locale.code);

      if (resource != null) {
        var registered = await registerMessagesResourceContent(resource);
        if (registered) {
          return true;
        }
      }
    }

    return false;
  }

  /// Builds a message present in [key] using [variables] table in context.
  String buildMsg(String key, [Map<String, dynamic>? variables]) {
    return msg(key).build(variables);
  }

  /// Returns a [IntlKey] for message [key],
  /// with optional parameters [variables] or [variablesProvider].
  IntlKey key(String key,
          {Map<String, dynamic>? variables,
          IntlVariablesProvider? variablesProvider}) =>
      IntlKey(this, key,
          variables: variables, variablesProvider: variablesProvider);

  /// Get a message with [key] and returns a corresponding [MessageBuilder].
  MessageBuilder msg(String key, {Object? preferredLocale}) {
    var locale = IntlLocale.from(preferredLocale);
    return MessageBuilder._(this, key, locale);
  }

  /// Return as message as [String]. Same as `msg(key).build(variables)`.
  String msgAsString(String key, [Map<String, dynamic>? variables]) {
    return msg(key).build(variables);
  }

  LocalizedMessage? _msg(String key, IntlLocale? preferredLocale) {
    if (_overrideMessages != null) {
      var msg = _overrideMessages!._msg(key, preferredLocale);
      if (msg != null) return msg;
    }

    var localesOrder = _getLocalesOrder(false)!;

    if (preferredLocale != null) {
      var preferredLocales = localesOrder
          .where((e) => e.language == preferredLocale.language)
          .toList();

      if (preferredLocales.isNotEmpty) {
        localesOrder = localesOrder.toList();
        localesOrder.removeWhere((e) => preferredLocales.contains(e));
        localesOrder.insertAll(0, preferredLocales);
      }
    }

    for (var l in localesOrder) {
      var localizedMessage = _localizedMessages[l];

      if (localizedMessage != null) {
        var msg = localizedMessage.msg(key);
        if (msg != null) return LocalizedMessage(l, key, msg);
      }
    }

    LocalizedMessage? fallbackMsg;
    if (fallbackMessages != null) {
      fallbackMsg = fallbackMessages!._msg(key, preferredLocale);
    }

    for (var l in _getPossibleLocalesOrder(false)!) {
      _autoFindLocalizedMessages(l);
    }

    return fallbackMsg;
  }

  String? _description(String key) {
    var localesOrder = _getLocalesOrder(false)!;

    for (var l in localesOrder) {
      var localizedMessage = _localizedMessages[l];

      if (localizedMessage != null) {
        var msg = localizedMessage.msg(key);
        if (msg != null && msg.hasDescription) return msg.description;
      }
    }

    for (var l in _getPossibleLocalesOrder(false)!) {
      var ret = _autoFindLocalizedMessages(l);

      if (ret is bool) {
        if (!ret) {
          return null;
        }
      }
    }

    return null;
  }

  MessageBuilder operator [](String key) => msg(key);

  @override
  String toString() {
    return 'IntlMessages{packageName: $packageName, locale: $currentLocale}';
  }
}

/// Helper to build a message.
class MessageBuilder {
  final IntlMessages _intlMessages;

  final String _key;

  /// Returns the preferred locale for this [MessageBuilder].
  final IntlLocale? preferredLocale;

  MessageBuilder._(this._intlMessages, this._key, this.preferredLocale);

  IntlMessages get intlMessages => _intlMessages;

  /// Returns the message key.
  String get key => _key;

  /// Returns the localized message.
  LocalizedMessage? get message => _intlMessages._msg(key, preferredLocale);

  /// Returns `true` if a localized [message] exists for [key].
  bool get exists => message != null;

  String? get description => _intlMessages._description(key);

  /// Builds this message.
  /// - Allows optional [variables].
  String build([Map<String, dynamic>? variables]) {
    var msg = message;
    if (msg == null) {
      _log("No message for '$key' @ '${_intlMessages.packageName}'", true);
      return '';
    }
    return msg.build(variables);
  }

  /// Returns a message as [String]. Same as [build].
  @override
  String toString([Map<String, dynamic>? variables]) {
    return build(variables);
  }
}

/// Represents a message in a specif locale.
class LocalizedMessage {
  /// Locale of the message.
  final IntlLocale locale;

  /// Key for external reference to this message.
  final String key;

  /// The actual message.
  final Message message;

  LocalizedMessage(this.locale, this.key, this.message);

  String? get description => message.description;

  String build([Map<String, dynamic>? variables]) {
    return message.build(variables);
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
  int get hashCode => locale.hashCode ^ key.hashCode ^ message.hashCode;
}

/// A table of keys and messages.
class LocalizedMessages {
  /// Locale for this table.
  final IntlLocale locale;

  /// Table of messages by key.
  final Map<String, Message> _messages = {};

  LocalizedMessages(this.locale, List<Message>? messages) {
    loadMessages(messages);
  }

  void clearMessages() {
    _messages.clear();
  }

  /// Loads [messages] to this table.
  void loadMessages(List<Message>? messages) {
    if (messages == null || messages.isEmpty) return;

    for (var msg in messages) {
      _messages[msg.key] = msg;
    }
  }

  /// Gets a message with [key].
  Message? msg(String key) {
    return _messages[key];
  }
}

List<String> _allLocalesCodes = allLocalesCodes();

List<IntlLocale> _allLocales =
    _allLocalesCodes.map((l) => IntlLocale(l)).toList();

int _getLocaledIndex(String locale) {
  var idx = _allLocalesCodes.indexOf(locale);
  if (idx >= 0) return idx;

  var intlLocale = IntlLocale.code(locale);

  locale = intlLocale.code;

  idx = _allLocalesCodes.indexOf(locale);
  if (idx >= 0) return idx;

  var lang = intlLocale._language;
  var prefix = '${lang}_';

  for (var i = 0; i < _allLocalesCodes.length; ++i) {
    var l = _allLocalesCodes[i];

    if (l == lang || l.startsWith(prefix)) {
      return i;
    }
  }

  return -1;
}

abstract class _IntlDefaultLocale {
  static String? _locale;

  static String? get locale => getLocale();

  static String? getLocale() {
    _initialize();
    return _locale;
  }

  static void setLocale(dynamic locale) {
    _setLocale(locale);
  }

  static bool _initialized = false;

  static void _initialize() {
    if (_initialized) return;
    _initialized = true;

    LocalesManager.onDefineLocaleLibraryIntegration
        .listen((l) => _setLocale(l));

    var defaultLocale = Intl.defaultLocale;

    if (defaultLocale != null) {
      _setLocale(defaultLocale);
      return;
    }

    var instancesInitialized = LocalesManager.instancesInitialized();

    if (instancesInitialized.isNotEmpty) {
      var initializedLocales = instancesInitialized[0].getInitializedLocales();
      if (initializedLocales.isNotEmpty) {
        _setLocale(initializedLocales[0]);
        return;
      }
    }
  }

  static final EventStream<String?> onDefineLocale = EventStream();

  static void _setLocale(dynamic locale) {
    if (locale == null) return;

    var intlLocale = IntlLocale(locale);
    _locale = intlLocale.code;

    Intl.defaultLocale = _locale;

    IntlMessages._notifySetLocale(_locale);

    onDefineLocale.add(_locale);
  }
}

/// Represents a locale, with language and region codes.
class IntlLocale implements Comparable<IntlLocale> {
  static void setDefaultLocale(dynamic locale) {
    _IntlDefaultLocale.setLocale(locale);
  }

  static String? getDefaultLocale() {
    return _IntlDefaultLocale.getLocale();
  }

  static IntlLocale getDefaultIntlLocale() {
    return IntlLocale.code(getDefaultLocale()!);
  }

  static String? get defaultLocale => getDefaultLocale();

  static EventStream<String> get onDefineDefaultLocale =>
      _IntlDefaultLocale.onDefineLocale as EventStream<String>;

  static String _normalizeLanguage(String lang) => lang.toLowerCase().trim();

  static String _normalizeRegion(String? reg) {
    if (reg == null) return '';
    return reg.trim().toUpperCase();
  }

  late final String _language;

  late final String _region;

  /// Instantiate using a string locale code.
  IntlLocale.code(String localeCode) {
    var split = localeCode.split('_');

    var lang = _normalizeLanguage(split[0]);
    var reg = _normalizeRegion(split.length > 1 ? split[1] : null);

    if (lang.isEmpty) throw ArgumentError.notNull('language');

    _language = lang;
    _region = reg;
  }

  static IntlLocale? from(dynamic locale) {
    if (locale == null) return null;
    if (locale is IntlLocale) return locale;
    if (locale is String) {
      var s = locale.trim();
      if (s.length <= 6 && !s.contains('/') && !s.contains('.')) {
        return IntlLocale.code(s);
      } else {
        return IntlLocale.path(s);
      }
    }
    return null;
  }

  /// Instantiate parsing a path and finding the locale code in it.
  factory IntlLocale.path(String path) {
    var idx = path.lastIndexOf('_');

    if (idx >= 0) {
      if (idx < 2) throw ArgumentError("Can't find locale delimiter in path");

      var lang = path.substring(idx - 2, idx);
      var reg = path.substring(idx + 1);

      if (reg.length > 3) reg = reg.substring(0, 3);
      if (reg.length == 3 &&
          !RegExp(r'[a-zA-Z]').hasMatch(reg.substring(2, 3))) {
        reg = reg.substring(0, 2);
      }

      return IntlLocale.langReg(lang, reg);
    }

    idx = path.lastIndexOf('.');

    if (idx > 2) {
      var lang = path.substring(idx - 2, idx);

      if (!RegExp(r'[a-zA-Z]').hasMatch(lang)) {
        throw ArgumentError("Can't find locale part with only language on it.");
      }

      return IntlLocale(lang);
    }

    throw ArgumentError("Can't find locale part in path");
  }

  IntlLocale.langReg(String language, [String? region]) {
    _language = _normalizeLanguage(language);
    if (_language.isEmpty) throw ArgumentError.notNull('language');

    _region = _normalizeRegion(region);
  }

  /// Dynamic parsing and instantiation.
  factory IntlLocale(dynamic locale) {
    if (locale == null) return IntlLocale.getDefaultIntlLocale();

    if (locale is IntlLocale) {
      return locale;
    }

    if (locale is List) {
      if (locale.isEmpty) return getDefaultIntlLocale();

      String lang = locale[0];
      String? reg = locale.length > 1 ? locale[1] : null;
      return IntlLocale.langReg(lang, reg);
    } else if (locale is Map) {
      if (locale.isEmpty) return IntlLocale.getDefaultIntlLocale();

      String? lang = locale['language'] ?? locale['lang'];
      if (lang == null || lang.isEmpty) {
        return IntlLocale.getDefaultIntlLocale();
      }

      String? reg = locale['region'] ?? locale['reg'];
      return IntlLocale.langReg(lang, reg);
    }

    return IntlLocale.code('$locale');
  }

  String get language => _language;

  String get region => _region;

  bool get hasRegion => _region.isNotEmpty;

  /// Full locale code, example: 'en_US', 'pt_BR'
  String get code => hasRegion ? '${_language}_$_region' : _language;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntlLocale &&
          runtimeType == other.runtimeType &&
          _language == other._language &&
          _region == other._region;

  @override
  int get hashCode => _language.hashCode ^ _region.hashCode;

  @override
  int compareTo(IntlLocale o) {
    if (this == o) return 0;

    var idx1 = _getLocaledIndex(code);
    var idx2 = _getLocaledIndex(o.code);

    return idx1.compareTo(idx2);
  }

  @override
  String toString() {
    return 'IntlLocale{$code}';
  }
}

/// Defines the fallback language hierarchie.
class IntlFallbackLanguage {
  late final String _defaultFallback;

  IntlFallbackLanguage([String? defaultFallback]) {
    if (defaultFallback == null || defaultFallback.trim() == '') {
      defaultFallback = 'en';
    }

    _defaultFallback = IntlLocale._normalizeLanguage(defaultFallback);
  }

  String get defaultFallback => _defaultFallback;

  final Map<String, String> _fallbacks = {};

  Map<String, String> get fallbacks => Map.from(_fallbacks);

  void set(String language, fallbackLanguage) {
    language = IntlLocale._normalizeLanguage(language);
    fallbackLanguage = IntlLocale._normalizeLanguage(fallbackLanguage);

    _fallbacks[language] = fallbackLanguage;
  }

  String get(String language) {
    language = IntlLocale._normalizeLanguage(language);
    var fallback = _fallbacks[language];
    return fallback ?? _defaultFallback;
  }

  String? remove(String language) {
    language = IntlLocale._normalizeLanguage(language);
    var fallback = _fallbacks.remove(language);
    return fallback;
  }

  void clear() {
    _fallbacks.clear();
  }
}

/// A message.
class Message {
  /// External message key.
  late final String _key;

  /// The content of the message.
  late final MessageValue _value;

  /// Description to help translators to undertant message context and usage.
  late final String? _description;

  Message.keyValue(dynamic key, dynamic value, [String? description]) {
    _key = key.toString().trim();

    if (value is String) value = value.toString().trim();

    _value = MessageValue(value);
    _description = description?.trim();
  }

  Message.line(String line) {
    var idx = line.indexOf('=');

    _key = line.substring(0, idx).trim();

    var valStr = line.substring(idx + 1);

    var idx2 = valStr.lastIndexOf('##');

    String? description;
    if (idx2 > 0) {
      var desc = valStr.substring(idx2 + 2).trim();
      valStr = valStr.substring(0, idx2);

      if (desc.isNotEmpty) {
        description = desc;
      }
    }

    _value = MessageValue(valStr.trim());
    _description = description;
  }

  Message.entry(dynamic entry) {
    Object? key;
    Object? val;
    Object? desc;

    if (entry is List) {
      var list = entry;
      key = list[0];
      val = list[1];
      desc = list.length > 2 ? list[2] : null;
    } else if (entry is Map) {
      var map = entry;
      key = map['key'];
      val = map['value'] ?? map['val'];
      desc = map['description'] ?? map['desc'];
    }

    if (key != null) {
      _key = key.toString().trim();

      if (val is String) val = val.toString().trim();
      _value = MessageValue(val);

      String? description;
      if (desc != null) {
        var d = desc.toString().trim();
        description = d.isNotEmpty ? d : null;
      }

      _description = description;
    } else {
      throw ArgumentError.value(
          entry, 'entry', 'Invalid entry as Message: Not a List or a Map.');
    }
  }

  String get key => _key;

  String? get description => _description;

  bool get hasDescription => _description != null && _description!.isNotEmpty;

  String build([Map<String, dynamic>? variables]) {
    return _value.build(variables);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          _key == other._key &&
          _value == other._value;

  @override
  int get hashCode => _key.hashCode ^ _value.hashCode;

  @override
  String toString() {
    return build();
  }
}

enum MessageBlockBranchType { zero, one, two, many, other, defaultBranch }

class MessageBlock {
  List<MessageBlockBranch> _branches;

  MessageBlock._(this._branches) {
    _branches.sort((a, b) => a.compareTo(b));
  }

  static final RegExp _regexpBlockSplitter =
      RegExp(r'(\\)?\|', multiLine: true);

  factory MessageBlock(String block) {
    var parts = <String>[];

    var appendToPrevBlock = false;

    var cursor = 0;
    for (var m in _regexpBlockSplitter.allMatches(block)) {
      var prev = m.start > cursor ? block.substring(cursor, m.start) : '';

      var escapedChar = m.group(1);
      var escaped = false;

      if (escapedChar != null && escapedChar.isNotEmpty) {
        prev += '|';
        escaped = true;
      }

      if (prev.isNotEmpty) {
        if (appendToPrevBlock) {
          parts[parts.length - 1] += prev;
        } else {
          parts.add(prev);
        }
      }

      appendToPrevBlock = escaped;

      cursor = m.end;
    }

    if (block.length > cursor) {
      var tail = block.substring(cursor);
      if (appendToPrevBlock) {
        parts[parts.length - 1] += tail;
      } else {
        parts.add(tail);
      }
    }

    var branches = <MessageBlockBranch>[];

    for (var part in parts) {
      branches.add(MessageBlockBranch(part));
    }

    return MessageBlock._(branches);
  }

  MessageBlockBranch? matchBranch(Map<String, dynamic>? variables) {
    for (var branch in _branches) {
      if (branch.matches(variables)) {
        return branch;
      }
    }

    for (var branch in _branches) {
      if (branch._type == MessageBlockBranchType.defaultBranch) {
        return branch;
      }
    }

    for (var branch in _branches) {
      if (branch._type == MessageBlockBranchType.other) {
        return branch;
      }
    }

    return null;
  }

  String build(Map<String, dynamic>? variables) {
    var branch = matchBranch(variables);
    if (branch == null) return '';
    return branch.build(variables);
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
  MessageBlockBranchType _type;

  String? _variableName;

  MessageValue _value;

  MessageBlockBranch._(this._type, this._variableName, this._value);

  factory MessageBlockBranch(String branch) {
    var idx = branch.indexOf(':');

    if (idx < 0) {
      return MessageBlockBranch._(
          MessageBlockBranchType.defaultBranch, null, MessageValue(branch));
    }

    var typeStr = branch.substring(0, idx).trim();

    var value = branch.substring(idx + 1);

    var idx2 = typeStr.indexOf('[');
    var idx3 = typeStr.indexOf(']');

    if (idx2 > 0 && idx3 > idx2) {
      var type = typeStr.substring(0, idx2).toUpperCase().trim();
      var varName = typeStr.substring(idx2 + 1, idx3).trim();

      return MessageBlockBranch._(
          EnumToString.fromString(MessageBlockBranchType.values, type) ??
              MessageBlockBranchType.defaultBranch,
          varName,
          MessageValue(value));
    } else {
      typeStr = typeStr.toUpperCase();
      return MessageBlockBranch._(
          EnumToString.fromString(MessageBlockBranchType.values, typeStr) ??
              MessageBlockBranchType.defaultBranch,
          null,
          MessageValue(value));
    }
  }

  String build(Map<String, dynamic>? variables) {
    return _value.build(variables);
  }

  bool matches(Map<String, dynamic>? variables) {
    switch (_type) {
      case MessageBlockBranchType.zero:
        return matchesZero(variables);
      case MessageBlockBranchType.one:
        return matchesOne(variables);
      case MessageBlockBranchType.two:
        return matchesTwo(variables);
      case MessageBlockBranchType.many:
        return matchesMany(variables);
      case MessageBlockBranchType.other:
        return matchesOther(variables);
      case MessageBlockBranchType.defaultBranch:
        return false;
      default:
        return false;
    }
  }

  bool matchesZero(Map<String, dynamic>? variables) {
    if (variables == null || variables.isEmpty || _variableName == null) {
      return true;
    }
    var varVal = variables[_variableName!];
    if (varVal == null) return true;

    var nStr = '$varVal';
    var nStrLC = nStr.toLowerCase();

    if (nStr == '0' || nStrLC == 'zero' || nStrLC == 'null') return true;

    var n = double.tryParse(nStr);

    if (n == null) {
      return nStr == '0.0' || nStr == '0,0';
    }

    return _delta(0, n) < 0.0001;
  }

  bool matchesOne(Map<String, dynamic>? variables) {
    if (variables == null || variables.isEmpty || _variableName == null) {
      return false;
    }
    var varVal = variables[_variableName!];
    if (varVal == null) return false;

    var nStr = '$varVal';
    if (nStr == '1' || nStr.toLowerCase() == 'one') return true;

    var n = double.tryParse(nStr);

    if (n == null) {
      return nStr == '1.0' || nStr == '1,0';
    }

    if (n == 1) return true;

    return _delta(1, n) < 0.0001;
  }

  bool matchesTwo(Map<String, dynamic>? variables) {
    if (variables == null || variables.isEmpty || _variableName == null) {
      return false;
    }
    var varVal = variables[_variableName!];
    if (varVal == null) return false;

    var nStr = '$varVal';
    if (nStr == '2' || nStr.toLowerCase() == 'two') return true;

    var n = double.tryParse(nStr);

    if (n == null) {
      return nStr == '2.0' || nStr == '2,0';
    }

    if (n == 2) return true;

    return _delta(2, n) < 0.0001;
  }

  bool matchesMany(Map<String, dynamic>? variables) {
    if (variables == null || variables.isEmpty || _variableName == null) {
      return false;
    }
    var varVal = variables[_variableName!];
    if (varVal == null) return false;

    var nStr = '$varVal';

    var n = double.tryParse(nStr);
    if (n == null) {
      return false;
    }

    return n >= 2;
  }

  bool matchesOther(Map<String, dynamic>? variables) {
    if (variables == null || variables.isEmpty || _variableName == null) {
      return false;
    }
    var varVal = variables[_variableName!];
    if (varVal == null) return false;

    var nStr = '$varVal';

    var n = double.tryParse(nStr);
    if (n == null) {
      return false;
    }

    return true;
  }

  static double _delta(double a, double b) {
    var delta = a - b;
    if (delta < 0) delta = -delta;
    return delta;
  }

  int compareTo(MessageBlockBranch b) {
    if (_type == b._type) return 0;
    return _type.index.compareTo(b._type.index);
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
      _type.hashCode ^ (_variableName?.hashCode ?? 0) ^ _value.hashCode;
}

class MessageValue {
  List<dynamic> _values;

  MessageValue._(this._values);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageValue &&
          runtimeType == other.runtimeType &&
          _values == other._values;

  @override
  int get hashCode => _values.hashCode;

  static final RegExp _regexpBlock =
      RegExp(r'\{((?:[^}]+|\\})+?)\}', multiLine: true);

  factory MessageValue(dynamic value) {
    var built = <dynamic>[];

    if (value is List) {
      var list = value;

      for (dynamic e in list) {
        var val = MessageValue(e);
        built.addAll(val._values);
      }
    } else {
      var line = '$value';

      var cursor = 0;
      for (var m in _regexpBlock.allMatches(line)) {
        if (m.start > cursor) {
          var prev = line.substring(cursor, m.start);
          built.addAll(_buildValueFromString(prev));
        }

        var block = m.group(1)!;
        built.add(MessageBlock(block));

        cursor = m.end;
      }

      if (line.length > cursor) {
        var tail = line.substring(cursor);
        built.addAll(_buildValueFromString(tail));
      }
    }

    return MessageValue._(built);
  }

  static final RegExp _regexpVarName = RegExp(r'(\\)?\$(\w+)', multiLine: true);

  static List<dynamic> _buildValueFromString(String line) {
    var built = <dynamic>[];

    var cursor = 0;
    for (var m in _regexpVarName.allMatches(line)) {
      if (m.start > cursor) {
        var prev = line.substring(cursor, m.start);
        prev = _normalizeValueString(prev);
        built.add(prev);
      }

      var escapedVar = false;

      var prevVar = m.group(1);
      if (prevVar != null && prevVar.isNotEmpty) {
        escapedVar = true;
      }

      var varName = m.group(2);

      if (escapedVar) {
        var varEscaped = '\$$varName';
        built.add(varEscaped);
      } else {
        built.add(MessageVariable(varName!));
      }

      cursor = m.end;
    }

    if (line.length > cursor) {
      var tail = line.substring(cursor);
      tail = _normalizeValueString(tail);
      built.add(tail);
    }

    return built;
  }

  static String _normalizeValueString(String value) {
    var valNorm = value.replaceAll('\\n', '\n').replaceAll('\\r', '\r');
    return valNorm;
  }

  String build([Map<String, dynamic>? variables]) {
    var built = '';

    for (var e in _values) {
      if (e is MessageVariable) {
        built += e.build(variables);
      } else if (e is MessageBlock) {
        built += e.build(variables);
      } else {
        built += e.toString();
      }
    }

    return built;
  }
}

class MessageVariable {
  final String name;

  MessageVariable(this.name);

  String build(Map<String, dynamic>? variables) {
    if (variables == null || variables.isEmpty) return '';

    var built = variables[name];
    return built != null ? built.toString() : '';
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

typedef IntlVariablesProvider = Map<String, dynamic> Function();

/// Represents a internationalized key from a [IntlMessages].
class IntlKey {
  /// The messages tables.
  final IntlMessages intlMessages;

  /// Key of the message at [intlMessages] table.
  final String key;

  /// The variables to pass when calling [MessageBuilder].
  final Map<String, dynamic>? variables;

  /// The variables provider [Function] to pass when calling [MessageBuilder].
  final IntlVariablesProvider? variablesProvider;

  IntlKey(this.intlMessages, this.key,
      {this.variables, this.variablesProvider});

  /// Returns a copy of this [IntlKey] with [variables].
  IntlKey withVariables(Map<String, dynamic> variables) =>
      IntlKey(intlMessages, key, variables: variables);

  /// Returns a copy of this [IntlKey] with [variablesProvider].
  IntlKey withVariablesProvider(IntlVariablesProvider variablesProvider) =>
      IntlKey(intlMessages, key, variablesProvider: variablesProvider);

  /// If [true], [message] will be generate only one time and cached.
  /// If locale changes after [message] is built and cached,
  /// it can be in a wrong locale.
  bool singleCall = false;

  String? _builtMessage;

  /// The built message for this key.
  ///
  /// Will generate for each call, unless [singleCall] is true.
  String? get message {
    if (_builtMessage != null) {
      return _builtMessage;
    }

    String msg;
    if (variablesProvider != null) {
      var vars = variablesProvider!();
      msg = intlMessages.msg(key).build(vars);
    } else {
      msg = intlMessages.msg(key).build(variables);
    }

    if (singleCall) {
      _builtMessage = msg;
    }

    return msg;
  }

  @override
  String toString() {
    return 'IntlKey{messages: $intlMessages, key: $key, variables: $variables, variablesProvider: $variablesProvider}';
  }
}

/// Loader of [IntlMessages] with registered [IntlResourceDiscover] based into [package] and [pathPrefix].
class IntlMessagesLoader {
  static String? _normalizePackage(String? package) {
    if (package == null) return null;
    package = package.trim();
    if (package.isEmpty) return null;
    return package;
  }

  static String? _normalizePathPrefix(String? pathPrefix) {
    if (pathPrefix == null) return null;
    pathPrefix = pathPrefix.trim();
    if (pathPrefix.isEmpty) return null;

    if (!pathPrefix.endsWith('-')) {
      pathPrefix += '-';
    }
    return pathPrefix;
  }

  static String _normalizeExtension(String extension) {
    extension = extension.trim();
    if (extension.isEmpty) {
      extension = '.intl';
    }
    if (!extension.startsWith('.')) {
      extension = '.$extension';
    }
    return extension;
  }

  static final Map<IntlMessagesLoader, IntlMessagesLoader> _instances = {};

  /// Returns a cached instance.
  factory IntlMessagesLoader(String? package, String? pathPrefix,
      {String extension = '.intl', bool autoLoad = true}) {
    package = _normalizePackage(package);
    pathPrefix = _normalizePathPrefix(pathPrefix);
    extension = _normalizeExtension(extension);

    if (package == null) {
      throw ArgumentError('invalid package: $package');
    }

    if (pathPrefix == null) {
      throw ArgumentError('invalid pathPrefix: $pathPrefix');
    }

    var key = IntlMessagesLoader._key(package, pathPrefix, extension);

    var instance = _instances[key];

    if (instance == null) {
      instance = IntlMessagesLoader._(package, pathPrefix, extension, autoLoad);
      _instances[instance] = instance;
    }

    return instance;
  }

  String _package;
  String _pathPrefix;
  String _extension;

  late IntlMessages _messages;

  IntlMessagesLoader._(
      this._package, this._pathPrefix, this._extension, bool autoLoad) {
    _messages = IntlMessages.package(_package)
      ..registerResourceDiscover(IntlResourceDiscover(_pathPrefix, _extension),
          allowAutoDiscover: false);

    if (autoLoad) {
      ensureLoaded();
    }
  }

  IntlMessagesLoader._key(this._package, this._pathPrefix, this._extension);

  /// The package of the [intlMessages] instance.
  String get package => _package;

  /// The path prefix for the registered [IntlResourceDiscover].
  String get pathPrefix => _pathPrefix;

  /// Returns [true] if [pathPrefix] (after normalization) matches [this.pathPrefix].
  bool matchesPathPrefix(String pathPrefix) {
    return _pathPrefix == _normalizePathPrefix(pathPrefix);
  }

  /// The extension for the registered [IntlResourceDiscover].
  String get extension => _extension;

  /// The handled [IntlMessages] instance.
  IntlMessages get intlMessages => _messages;

  /// Returns [true] if [IntlMessages.autoDiscover] has registered any [LocalizedMessage].
  bool get hasLoadedAnyMessage => _messages.hasAnyRegisteredLocalizedMessage;

  /// Returns [true] if [IntlMessages.autoDiscover] is fully loaded and found all [LocalizedMessage].
  bool get isLoaded => _fullyLoaded ?? false;

  bool? _fullyLoaded;

  final EventStream<bool> onLoad = EventStream();

  Future<bool>? _messagesDiscover;

  /// Returns response of [IntlMessages.autoDiscover] called on loader construction.
  Future<bool> ensureLoaded() async {
    if (_fullyLoaded != null) return _fullyLoaded!;
    if (_messagesDiscover != null) return _messagesDiscover!;

    _messagesDiscover = _messages.autoDiscover();
    var loaded = await _messagesDiscover!;

    if (_fullyLoaded == null) {
      _fullyLoaded = loaded;
      onLoad.add(loaded);
    }

    return loaded;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntlMessagesLoader &&
          runtimeType == other.runtimeType &&
          _package == other._package &&
          _pathPrefix == other._pathPrefix &&
          _extension == other._extension;

  @override
  int get hashCode =>
      _package.hashCode ^ _pathPrefix.hashCode ^ _extension.hashCode;

  @override
  String toString() {
    return 'IntlMessagesLoader{package: $package, pathPrefix: $pathPrefix, extension: $extension}';
  }
}
