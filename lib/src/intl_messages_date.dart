import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/date_symbols.dart';
import 'package:intl/intl.dart';
import 'package:swiss_knife/swiss_knife.dart';

import 'intl_messages_base.dart';
import 'intl_messages_basic_dictionary.dart';

/// Returns the localized title message for [rangeType].
String? getDateRangeTypeTitle(DateRangeType rangeType,
    [IntlLocale? locale, IntlLocale? localeFallback]) {
  switch (rangeType) {
    case DateRangeType.today:
      return IntlBasicDictionary.msg('today', locale, localeFallback);
    case DateRangeType.yesterday:
      return IntlBasicDictionary.msg('yesterday', locale, localeFallback);
    case DateRangeType.last7Days:
      return IntlBasicDictionary.buildMsg(
          'last N days', ['7'], locale, localeFallback);
    case DateRangeType.thisWeek:
      return IntlBasicDictionary.msg('this week', locale, localeFallback);
    case DateRangeType.lastWeek:
      return IntlBasicDictionary.msg('last week', locale, localeFallback);
    case DateRangeType.last30Days:
      return IntlBasicDictionary.buildMsg(
          'last N days', ['30'], locale, localeFallback);
    case DateRangeType.last60Days:
      return IntlBasicDictionary.buildMsg(
          'last N days', ['60'], locale, localeFallback);
    case DateRangeType.last90Days:
      return IntlBasicDictionary.buildMsg(
          'last N days', ['90'], locale, localeFallback);
    case DateRangeType.lastMonth:
      return IntlBasicDictionary.msg('last month', locale, localeFallback);
    case DateRangeType.thisMonth:
      return IntlBasicDictionary.msg('this month', locale, localeFallback);
    default:
      throw UnsupportedError("Can't handle: $rangeType");
  }
}

/// Returns [DateFormat] for [locale] and skeleton `yMMMd`.
// ignore: non_constant_identifier_names
DateFormat getDateFormat_yMMMd([IntlLocale? locale]) {
  locale ??= IntlLocale.getDefaultIntlLocale();
  return DateFormat.yMMMd(locale.code);
}

/// Returns [DateFormat] for [locale] and skeleton yMMMMd`.
// ignore: non_constant_identifier_names
DateFormat getDateFormat_yMMMMd([IntlLocale? locale]) {
  locale ??= IntlLocale.getDefaultIntlLocale();
  return DateFormat.yMMMMd(locale.code);
}

/// A [DateSymbols], with many information for [locale]
DateSymbols? getLocaleDateSymbols([IntlLocale? locale]) {
  locale ??= IntlLocale.getDefaultIntlLocale();

  var code = locale.code;

  var map = dateTimeSymbolMap();
  DateSymbols? dateSymbols = map[code];

  dateSymbols ??= map[locale.language];

  if (dateSymbols != null) return dateSymbols;

  for (var entry in map.entries) {
    if (entry.key.toString().startsWith(locale.language)) {
      return entry.value;
    }
  }

  return map['en_ISO'];
}

/// Returns [DateTimeWeekDay] for [locale].
DateTimeWeekDay getFirstDayOfWeek([IntlLocale? locale]) {
  var dateSymbols = getLocaleDateSymbols(locale);
  if (dateSymbols == null) return DateTimeWeekDay.monday;
  var firstdayofweek = dateSymbols.FIRSTDAYOFWEEK;
  var dateTimeWeekDay = getDateTimeWeekDay_from_ISO_8601_index(firstdayofweek)!;
  return dateTimeWeekDay;
}

/// Returns [true] if [locale] us AMPM format.
bool getTimeFormatUsesAMPM([IntlLocale? locale]) {
  var dateSymbols = getLocaleDateSymbols(locale);
  if (dateSymbols == null) return false;
  var timeFormat = dateSymbols.TIMEFORMATS[0];
  return timeFormat.contains('h') && timeFormat.contains('a');
}

/// Gets a date range, [startTime] and [endTime], and formats it's texts with [locale], trying to use less characters.
String formatDateRangeText(
    DateTime startTime, DateTime endTime, bool hasTimePicker,
    [IntlLocale? locale]) {
  locale ??= IntlLocale.getDefaultIntlLocale();

  var startFormat = getDateFormat_yMMMd();
  var endFormat = startFormat;

  var sameDay = false;

  if (startTime.year == endTime.year) {
    if (startTime.month == endTime.month) {
      if (startTime.day == endTime.day) {
        sameDay = true;
      } else {
        if (!startFormat.pattern!.startsWith('MMM') && !hasTimePicker) {
          startFormat = DateFormat('d', locale.code);
        } else {
          startFormat = DateFormat('MMMd', locale.code);
        }
      }
    } else {
      startFormat = DateFormat('MMMd', locale.code);
    }
  }

  var startText = startFormat.format(startTime);
  var endText = endFormat.format(endTime);

  var mergeDate = sameDay || startText == endText;

  var isFullDayTimeRange = startTime.hour == 0 &&
      startTime.minute == 0 &&
      endTime.hour == 23 &&
      endTime.minute == 59;

  var usesAMPM = getTimeFormatUsesAMPM(locale);

  var timeFormat =
      usesAMPM ? DateFormat('h:mm a', locale.code) : DateFormat.Hm();
  var timeGroupOpen = usesAMPM ? '' : '[';
  var timeGroupClose = usesAMPM ? '' : ']';

  var hasTimeText = hasTimePicker && !isFullDayTimeRange;

  String? timeStartText;
  String? timeEndText;

  if (hasTimeText) {
    timeStartText = timeFormat.format(startTime);
    timeEndText = timeFormat.format(endTime);
  }

  String? dateText;

  if (mergeDate) {
    dateText = startText;

    if (hasTimeText) {
      if (timeStartText == timeEndText) {
        dateText += ' $timeGroupOpen${timeStartText!}$timeGroupClose';
      } else {
        dateText +=
            ' $timeGroupOpen${timeStartText!} - ${timeEndText!}$timeGroupClose';
      }
    }
  } else {
    if (hasTimeText) {
      startText += ' $timeGroupOpen${timeStartText!}$timeGroupClose';
      endText += ' $timeGroupOpen${timeEndText!}$timeGroupClose';
    }

    dateText = '$startText - $endText';
  }

  return dateText;
}
