import 'dart:convert';
import 'dart:io';

import 'package:intl_messages/src/intl_messages_base.dart';
import 'package:path/path.dart' as pack_path;

import 'translator.dart';

class TranslatorCacheDirectory extends TranslatorCache {
  final Directory directory;

  TranslatorCacheDirectory(this.directory, {super.logger}) {
    if (!directory.existsSync()) {
      throw StateError(
          "Invalid `TranslatorCache` directory: ${directory.path}");
    }
  }

  Directory _cacheDirectory(IntlLocale fromLocale, IntlLocale toLocale) {
    return Directory(
        pack_path.join(directory.path, fromLocale.code, toLocale.code));
  }

  File _cacheFile(IntlLocale fromLocale, IntlLocale toLocale, String key) {
    var fileName = '${_normalizeKey(key)}.json';
    var dir = _cacheDirectory(fromLocale, toLocale);
    return File(pack_path.join(dir.path, fileName));
  }

  String _normalizeKey(String key) => key.replaceAll(RegExp(r'\W'), '_');

  @override
  String? get(
      String key, String message, IntlLocale fromLocale, IntlLocale toLocale) {
    var file = _cacheFile(fromLocale, toLocale, key);
    if (!file.existsSync()) {
      return null;
    }

    var j = file.readAsStringSync();
    var o = json.decode(j);

    if (o is! Map) {
      return null;
    }

    var from = o['from'] as String?;
    if (from != fromLocale.code) {
      log('[ERROR] Invalid `from` code (`$from` != `${fromLocale.code}`) at file: ${file.path}');
      return null;
    }

    var to = o['to'] as String?;
    if (to != toLocale.code) {
      log('[ERROR] Invalid `to` code (`$to` != `${toLocale.code}`) at file: ${file.path}');
      return null;
    }

    var k = o['key'] as String?;
    if (k != _normalizeKey(key)) {
      log('[ERROR] Invalid `key` (`$k` != `$key`) at file: ${file.path}');
      return null;
    }

    var translationSource = o['message'] as String?;
    var translation = o['translation'] as String?;

    var translationSourceNorm = _normalizeMessage(translationSource);
    var translationNorm = _normalizeMessage(translation);

    if (translationSourceNorm != translationNorm) {
      log('[WARNING] Not matching `message` at file: ${file.path}\n<$translationSourceNorm> != <$translationNorm>');
      return null;
    }

    return translation;
  }

  static String? _normalizeMessage(String? s) {
    if (s == null) return null;
    s = s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  @override
  bool store(String key, String message, String translatedMessage,
      IntlLocale fromLocale, IntlLocale toLocale) {
    var file = _cacheFile(fromLocale, toLocale, key);

    var dir = file.parent;
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    var o = {
      'from': fromLocale.code,
      'to': toLocale.code,
      'key': key,
      'message': message,
      'translation': translatedMessage,
    };

    var j = json.encode(o);

    try {
      file.writeAsStringSync(j);
      return true;
    } catch (e) {
      log('[ERROR] Error storing `${fromLocale.code}` -> ${toLocale.code}> key: $key ; message: $message');
      return false;
    }
  }
}
