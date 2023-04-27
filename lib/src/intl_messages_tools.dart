import 'dart:async';

import 'package:async_extension/async_extension.dart';
import 'package:collection/collection.dart';

/// A message line in a `.intl` file.
class IntlRawEntry {
  static List<IntlRawEntry?>? fromLines(List<String>? lines,
      {bool strict = false}) {
    if (lines == null) return null;

    var entries =
        lines.map((l) => IntlRawEntry.parse(l, strict: strict)).toList();

    return entries;
  }

  /// The message key.
  final String key;

  /// The translated message.
  final String? msg;

  IntlRawEntry(String key, [String? msg])
      : key = key.trim(),
        msg = msg?.trim();

  IntlRawEntry copyWith({String? msg}) => IntlRawEntry(key, msg ?? this.msg);

  /// Parses message line ('.intl' file format).
  static IntlRawEntry? parse(String s, {bool strict = false}) {
    s = s.trim();
    if (s.isEmpty) return null;

    var idx = s.indexOf('=');
    if (idx <= 0) {
      if (strict) {
        throw StateError("Invalid entry line: $s");
      }
      return null;
    }

    var k = s.substring(0, idx).trim();
    var m = s.substring(idx + 1).trim();

    return IntlRawEntry(k, m);
  }

  bool get exists => msg != null;

  bool equals(IntlRawEntry other, {bool checkMsg = true}) {
    if (identical(this, other)) return true;

    if (key != other.key) return false;

    if (checkMsg) {
      if (msg != other.msg) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntlRawEntry &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() {
    return msg != null ? '$key: $msg' : '$key:?';
  }
}

extension ListIntlRawEntryExtension on List<IntlRawEntry?> {
  /// Group entries by [IntlRawEntry.key].
  Map<String, List<IntlRawEntry>> groupByKey() {
    var groupByKey = whereNotNull().groupListsBy((e) => e.key);
    return groupByKey;
  }

  /// List the duplicated keys.
  List<MapEntry<String, List<IntlRawEntry>>> duplicated() {
    var duplicated =
        groupByKey().entries.where((e) => e.value.length > 1).toList();
    return duplicated;
  }

  /// Convert this [List] to a [Map]:
  /// - Key: [IntlRawEntry.key]
  /// - Value: [List] of [IntlRawEntry].
  Map<String, IntlRawEntry> toMap() => Map<String, IntlRawEntry>.fromEntries(
      whereNotNull().map((e) => MapEntry(e.key, e)));

  /// Converts this [List] of [IntlRawEntry] to a [String] with all the entries (`.intl` file format).
  FutureOr<String> toIntlFileContent(
      {FutureOr<String?> Function(String key, String? msg)? resolver}) async {
    var s = StringBuffer();

    var entries = toList();
    while (entries.isNotEmpty && entries.last == null) {
      entries.removeLast();
    }

    for (var e in entries) {
      if (e == null) {
        s.write('\n');
      } else {
        var key = e.key;
        var msg = e.msg;

        if (msg == null && resolver != null) {
          msg = await resolver(key, msg);
        }

        msg ??= '';
        msg = msg.trim();

        s.write(key);
        s.write('=');
        s.write(msg);
        s.write('\n');
      }
    }

    return s.toString();
  }

  /// Format [entries] using `this` [List] of entries as reference.
  List<IntlRawEntry?> formatEntries(Map<String, IntlRawEntry> entries) {
    var entries2 = map((e) {
      if (e == null) return null;
      var e2 = entries[e.key];
      assert(e2 != null);
      return e2;
    }).toList();

    return entries2;
  }
}

/// Checks an `.intl` file. Returns the file entries ([IntlRawEntry]) if OK or `null` if the check fails.
List<IntlRawEntry?>? checkIntlEntries(List<IntlRawEntry?> entries,
    {String? file,
    String fileType = 'FILE',
    void Function(String type, Object? msg)? log}) {
  log ??= _log;

  if (entries.isEmpty) {
    log('CHECK', "Empty `intl` ${file != null ? 'file: $file' : 'file.'}");
    return null;
  }

  var duplicated = entries.duplicated();

  if (duplicated.isNotEmpty) {
    var changed = false;

    for (var e in duplicated) {
      var values = e.value;
      if (values.length <= 1) continue;

      var first = values.first;
      if (values.every((e) => e.equals(first, checkMsg: true))) {
        log('CHECK',
            "-- [IGNORING IDENTICAL DUPLICATES] ${e.key} = <<${e.value.map((e) => e.msg ?? '').join('>><<')}>>");

        var count = 0;

        entries.removeWhere((e) {
          var match = e?.key == first.key;
          if (!match) return false;
          ++count;
          return count > 1;
        });

        changed = true;
      }
    }

    if (changed) {
      duplicated = entries.duplicated();
    }
  }

  if (duplicated.isNotEmpty) {
    log('CHECK',
        "Duplicated `intl` entries in ${file != null ? 'file: $file' : 'file.'}");

    for (var e in duplicated) {
      log('CHECK',
          "-- ${e.key} = <<${e.value.map((e) => e.msg ?? '').join('>><<')}>>");
    }

    return null;
  }

  return entries;
}

/// Checks [entries] comparing with [referenceEntries].
/// Returns `null` if all [entries] are OK, or return a [List] with
/// `missingKeys` and `extraKeys` if the check fails.
List<List<String>>? checkIntlEntriesReference(
    List<IntlRawEntry?> referenceEntries, List<IntlRawEntry?> entries,
    {void Function(String type, Object? msg)? log}) {
  log ??= _log;

  var refMap = referenceEntries.toMap();

  var fileMap = entries.toMap();

  var missingKeys =
      refMap.keys.whereNot((k) => fileMap.containsKey(k)).toList();

  var extraKeys = fileMap.keys.whereNot((k) => refMap.containsKey(k)).toList();

  var ok = true;

  if (missingKeys.isNotEmpty) {
    log('CHECK', "Missing keys: $missingKeys");
    ok = false;
  }

  if (extraKeys.isNotEmpty) {
    log('CHECK', "Extra keys: $extraKeys");
    ok = false;
  }

  return ok ? null : [missingKeys, extraKeys];
}

void _log(String type, Object? message) {
  print('## [$type]\t$message');
}
