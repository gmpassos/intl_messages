import 'package:swiss_knife/swiss_knife.dart';

import 'intl_messages_base.dart';

/// A basic dictionary of common messages for an applicatin.
class IntlBasicDictionary {
  static final _dictionary = <String, Map<String, String>>{
    'en': {
      'unknown': 'unknown',
      'close': 'close',
      'open': 'open',
      'help': 'help',
      'loading': 'loading',
      'error': 'error',
      'empty': 'empty',
      'empty_list': 'empty list',
      'empty_result': 'empty result',
      'no_options': 'no options',
      'no_result': 'no result',
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
      'december': 'December',
      'month1': 'January',
      'month2': 'February',
      'month3': 'March',
      'month4': 'April',
      'month5': 'May',
      'month6': 'June',
      'month7': 'July',
      'month8': 'August',
      'month9': 'September',
      'month10': 'October',
      'month11': 'November',
      'month12': 'December'
    },
    'pt': {
      'unknown': 'desconhecido',
      'close': 'fechar',
      'open': 'abrir',
      'help': 'ajuda',
      'loading': 'carregando',
      'error': 'erro',
      'empty': 'vazio',
      'empty_list': 'lista vazia',
      'empty_result': 'resultado vazio',
      'no_options': 'sem opções',
      'no_result': 'sem resultado',
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
      'december': 'dezembro',
      'month1': 'janeiro',
      'month2': 'fevereiro',
      'month3': 'março',
      'month4': 'abril',
      'month5': 'maio',
      'month6': 'junho',
      'month7': 'julho',
      'month8': 'agosto',
      'month9': 'setembro',
      'month10': 'outubro',
      'month11': 'novembro',
      'month12': 'dezembro'
    },
    'fr': {
      'unknown': 'inconnue',
      'close': 'fermer',
      'open': 'ouvrir',
      'help': 'aider',
      'loading': 'chargement',
      'error': 'erreur',
      'empty': 'vide',
      'empty_list': 'liste vide',
      'empty_result': 'résultat vide',
      'no_options': "pas d'options",
      'no_result': 'pas de résultat',
      'end': 'fin',
      'start': 'début',
      'welcome': 'bienvenu',
      'idiom': 'idiome',
      'language': 'langue',
      'today': "aujourd'hui",
      'yesterday': 'hier',
      'last month': 'mois dernier',
      'this month': 'ce mois-ci',
      'this week': 'cette semaine',
      'last week': 'semaine dernière',
      'last n days': '\$0 derniers jours',
      'apply': 'appliquer',
      'cancel': 'annuler',
      'custom': 'personnalisé',
      'january': 'janvier',
      'february': 'février',
      'march': 'mars',
      'april': 'avril',
      'may': 'mai',
      'june': 'juin',
      'july': 'juillet',
      'august': 'août',
      'september': 'septembre',
      'october': 'octobre',
      'november': 'november',
      'december': 'décembre',
      'month1': 'janvier',
      'month2': 'février',
      'month3': 'mars',
      'month4': 'avril',
      'month5': 'mai',
      'month6': 'juin',
      'month7': 'juillet',
      'month8': 'août',
      'month9': 'septembre',
      'month10': 'octobre',
      'month11': 'november',
      'month12': 'décembre'
    },
  };

  static String? msgUpperCaseInitials(String key,
      [IntlLocale? locale, IntlLocale? localeFallback]) {
    var m = msg(key, locale, localeFallback);
    if (m == null) return null;
    return toUpperCaseInitials(m);
  }

  static String? msg(String key,
      [IntlLocale? locale, IntlLocale? localeFallback]) {
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

  static String? buildMsg(String key, List<String> vars,
      [IntlLocale? locale, IntlLocale? localeFallback]) {
    var m = msg(key, locale, localeFallback);
    if (m == null) return null;

    var m2 = m.replaceAllMapped(RegExp(r'\$(\d+)'), (m) {
      var idx = int.parse(m.group(1)!);
      var val = idx < vars.length ? vars[idx] : '';
      return val;
    });

    return m2;
  }
}
