import 'intl_messages_base.dart';
import 'locales.dart';

/// Translator base class.
abstract class Translator {
  /// Optional logger.
  final void Function(Object? o)? logger;

  Translator({this.logger});

  /// Logs [o ] calling [logger].
  void log(Object o) {
    var logger = this.logger;
    if (logger != null) {
      logger(o);
    }
  }

  /// Resolves [locale] to the language name.
  String resolveLocaleName(IntlLocale locale) => getLocaleName(locale.code);

  /// Translates [entries] to [locale].
  Future<Map<String, String>?> translate(
      Map<String, String> entries, IntlLocale locale,
      {bool confirm = true});
}
