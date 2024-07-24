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
      'week': 'week',
      'year': 'year',
      'month': 'month',
      'day': 'day',
      'hour': 'hour',
      'minute': 'minute',
      'second': 'second',
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
      'week_day_1': 'Monday',
      'week_day_2': 'Tuesday',
      'week_day_3': 'Wednesday',
      'week_day_4': 'Thursday',
      'week_day_5': 'Friday',
      'week_day_6': 'Saturday',
      'week_day_7': 'Sunday',
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
      'week': 'semana',
      'year': 'ano',
      'month': 'mês',
      'day': 'dia',
      'hour': 'hora',
      'minute': 'minuto',
      'second': 'segundo',
      'monday': 'Segunda',
      'tuesday': 'Terça',
      'wednesday': 'Quarta',
      'thursday': 'Quinta',
      'friday': 'Sexta',
      'saturday': 'Sábado',
      'sunday': 'Domingo',
      'week_day_1': 'Segunda',
      'week_day_2': 'Terça',
      'week_day_3': 'Quarta',
      'week_day_4': 'Quinta',
      'week_day_5': 'Sexta',
      'week_day_6': 'Sábado',
      'week_day_7': 'Domingo',
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
      'week': 'semaine',
      'year': 'an',
      'month': 'mois',
      'day': 'jour',
      'hour': 'heure',
      'minute': 'minute',
      'second': 'seconde',
      'monday': 'lundi',
      'tuesday': 'mardi',
      'wednesday': 'mercredi',
      'thursday': 'jeudi',
      'friday': 'vendredi',
      'saturday': 'samedi',
      'sunday': 'dimanche',
      'week_day_1': 'lundi',
      'week_day_2': 'mardi',
      'week_day_3': 'mercredi',
      'week_day_4': 'jeudi',
      'week_day_5': 'vendredi',
      'week_day_6': 'samedi',
      'week_day_7': 'dimanche',
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

  static String decimalDelimiter(
      [IntlLocale? locale, IntlLocale? localeFallback]) {
    locale ??= IntlLocale.getDefaultIntlLocale();
    localeFallback ??= IntlLocale.code('en');

    var delimiter = _decimalDelimiterImpl(locale) ??
        _decimalDelimiterImpl(localeFallback) ??
        '.';

    return delimiter;
  }

  static String? _decimalDelimiterImpl(IntlLocale locale) {
    final language = locale.language;
    final region = locale.region;

    switch (language) {
      case 'en':
        switch (region) {
          case 'US':
          case 'GB': // UK
          case 'UK':
          case 'CA':
          case 'AU':
          case 'NZ':
          case 'IE':
            return '.';
          default:
            return '.';
        }
      case 'es':
        switch (region) {
          case 'ES':
          case 'MX':
          case 'AR':
          case 'CO':
          case 'CL':
            return ',';
          default:
            return ',';
        }
      case 'fr':
        switch (region) {
          case 'FR':
          case 'CA':
          case 'BE':
          case 'CH':
          case 'LU':
            return ',';
          default:
            return ',';
        }
      case 'pt':
      case 'it':
      case 'de':
      case 'ru':
      case 'nl':
      case 'sv':
      case 'pl':
      case 'tr':
      case 'no':
        return ',';
      case 'ar':
        return '٫'; // Arabic decimal separator (U+066B).
      case 'zh':
      case 'ja':
      case 'ko':
      case 'he':
      case 'th':
      case 'vi':
      case 'hi':
      case 'jv':
      case 'aa':
      case 'ab':
      case 'af':
      case 'ak':
      case 'am':
      case 'an':
      case 'as':
      case 'av':
      case 'ay':
      case 'az':
      case 'ba':
      case 'be':
      case 'bg':
      case 'bi':
      case 'bm':
      case 'bn':
      case 'bo':
      case 'br':
      case 'bs':
      case 'ca':
      case 'ce':
      case 'ch':
      case 'co':
      case 'cr':
      case 'cs':
      case 'cu':
      case 'cv':
      case 'cy':
      case 'da':
      case 'dv':
      case 'dz':
      case 'ee':
      case 'el':
      case 'eo':
      case 'et':
      case 'eu':
      case 'fa':
      case 'ff':
      case 'fi':
      case 'fj':
      case 'fo':
      case 'fy':
      case 'ga':
      case 'gd':
      case 'gl':
      case 'gn':
      case 'gu':
      case 'gv':
      case 'ha':
      case 'ho':
      case 'hr':
      case 'ht':
      case 'hu':
      case 'hy':
      case 'hz':
      case 'ia':
      case 'id':
      case 'ie':
      case 'ig':
      case 'ii':
      case 'ik':
      case 'io':
      case 'is':
      case 'iu':
      case 'ka':
      case 'kg':
      case 'ki':
      case 'kj':
      case 'kk':
      case 'kl':
      case 'km':
      case 'kn':
      case 'kr':
      case 'ks':
      case 'ku':
      case 'kv':
      case 'kw':
      case 'ky':
      case 'la':
      case 'lb':
      case 'lg':
      case 'li':
      case 'ln':
      case 'lo':
      case 'lt':
      case 'lu':
      case 'lv':
      case 'mg':
      case 'mh':
      case 'mi':
      case 'mk':
      case 'ml':
      case 'mn':
      case 'mr':
      case 'ms':
      case 'mt':
      case 'my':
      case 'na':
      case 'nb':
      case 'nd':
      case 'ne':
      case 'ng':
      case 'nn':
      case 'nr':
      case 'nv':
      case 'ny':
      case 'oc':
      case 'oj':
      case 'om':
      case 'or':
      case 'os':
      case 'pa':
      case 'pi':
      case 'pl':
      case 'ps':
      case 'qu':
      case 'rm':
      case 'rn':
      case 'ro':
      case 'rw':
      case 'sa':
      case 'sc':
      case 'sd':
      case 'se':
      case 'sg':
      case 'si':
      case 'sk':
      case 'sl':
      case 'sm':
      case 'sn':
      case 'so':
      case 'sq':
      case 'sr':
      case 'ss':
      case 'st':
      case 'su':
      case 'sw':
      case 'ta':
      case 'te':
      case 'tg':
      case 'ti':
      case 'tk':
      case 'tl':
      case 'tn':
      case 'to':
      case 'ts':
      case 'tt':
      case 'tw':
      case 'ty':
      case 'ug':
      case 'uk':
      case 'ur':
      case 'uz':
      case 've':
      case 'vo':
      case 'wa':
      case 'wo':
      case 'xh':
      case 'yi':
      case 'yo':
      case 'za':
      case 'zu':
        return '.';
      default:
        return null;
    }
  }
}
