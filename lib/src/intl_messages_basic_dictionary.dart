import 'package:swiss_knife/swiss_knife.dart';

import 'intl_messages_base.dart';

/// A basic dictionary of common messages for an applicatin.
class IntlBasicDictionary {
  static final _dictionary = <String, Map<String, String>>{
    'en': {
      'end': 'end',
      'start': 'start',
      'welcome': 'welcome',
      'idiom': 'idiom',
      'language': 'language',
      'today': 'today',
      'yesterday': 'yesterday',
      'last month': 'last month',
      'this month': 'this month',
      'this week': 'this week',
      'last week': 'last week',
      'last n days': 'last \$0 days',
      'apply': 'apply',
      'cancel': 'cancel',
      'custom': 'custom',
      'january': 'January',
      'february': 'February',
      'march': 'March',
      'april': 'April',
      'may': 'May',
      'june': 'June',
      'july': 'July',
      'august': 'August',
      'september': 'September',
      'october': 'October',
      'november': 'November',
      'december': 'December'
    },
    'pt': {
      'end': 'fim',
      'start': 'início',
      'welcome': 'bem-vindo',
      'idiom': 'idioma',
      'language': 'língua',
      'today': 'hoje',
      'yesterday': 'ontem',
      'last month': 'último mês',
      'this month': 'este mês',
      'this week': 'esta semana',
      'last week': 'última semana',
      'last n days': 'últimos \$0 dias',
      'apply': 'aplicar',
      'cancel': 'cancelar',
      'custom': 'customizado',
      'january': 'janeiro',
      'february': 'fevereiro',
      'march': 'março',
      'april': 'abril',
      'may': 'maio',
      'june': 'junho',
      'july': 'julho',
      'august': 'agosto',
      'september': 'setembro',
      'october': 'outubro',
      'november': 'novembro',
      'december': 'dezembro'
    },
  };

  static String msgUpperCaseInitials(String key,
      [IntlLocale locale, IntlLocale localeFallback]) {
    var m = msg(key, locale, localeFallback);
    if (m == null) return null;
    return toUpperCaseInitials(m);
  }

  static String msg(String key,
      [IntlLocale locale, IntlLocale localeFallback]) {
    if (key == null) return null;
    key = key.trim().toLowerCase();
    if (key.isEmpty) return null;

    locale ??= IntlLocale.getDefaultIntlLocale();
    localeFallback ??= IntlLocale.code('en');

    var dictionaryEntries = _dictionary[locale.language];

    if (dictionaryEntries == null) {
      if (localeFallback != locale) {
        return msg(key, localeFallback);
      } else {
        return null;
      }
    }

    var m = dictionaryEntries[key];

    if (m != null) return m;

    if (localeFallback != locale) {
      return msg(key, localeFallback);
    } else {
      return key;
    }
  }

  static String buildMsg(String key, List<String> vars,
      [IntlLocale locale, IntlLocale localeFallback]) {
    var m = msg(key, locale, localeFallback);
    if (m == null) return null;

    var m2 = m.replaceAllMapped(RegExp(r'\$(\d+)'), (m) {
      var idx = int.parse(m.group(1));
      var val = idx < vars.length ? vars[idx] : '';
      return val;
    });

    return m2;
  }
}
