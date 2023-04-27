import 'package:intl_messages/src/intl_messages_tools.dart';
import 'package:test/test.dart';

void main() {
  group('IntlRawEntry', () {
    setUp(() {});

    test('checkIntlEntries[OK]', () async {
      var lines = [
        'msgA=aaa aaa',
        'msgB=bbb bbb',
      ];

      var entries = IntlRawEntry.fromLines(lines)!;

      var logs = <String>[];

      var entries2 =
          checkIntlEntries(entries, log: (t, m) => logs.add('$t>>$m'));

      expect(
          entries2,
          equals([
            IntlRawEntry('msgA', 'aaa aaa'),
            IntlRawEntry('msgB', 'bbb bbb'),
          ]));

      expect(logs, isEmpty);
    });

    test('checkIntlEntries[OK: IGNORING IDENTICAL DUPLICATES]', () async {
      var lines = [
        'msgA=aaa aaa',
        'msgB=bbb bbb',
        'msgB=bbb bbb',
      ];

      var entries = IntlRawEntry.fromLines(lines)!;

      var logs = <String>[];

      var entries2 =
          checkIntlEntries(entries, log: (t, m) => logs.add('$t>>$m'));

      expect(
          entries2,
          equals([
            IntlRawEntry('msgA', 'aaa aaa'),
            IntlRawEntry('msgB', 'bbb bbb'),
          ]));

      expect(logs, [
        'CHECK>>-- [IGNORING IDENTICAL DUPLICATES] msgB = <<bbb bbb>><<bbb bbb>>',
      ]);
    });

    test('checkIntlEntries[ERROR: DUPLICATED]', () async {
      var lines = [
        'msgA=aaa aaa',
        'msgB=bbb bbb',
        'msgB=bbb bbb bbb',
      ];

      var entries = IntlRawEntry.fromLines(lines)!;

      var logs = <String>[];

      var entries2 =
          checkIntlEntries(entries, log: (t, m) => logs.add('$t>>$m'));

      expect(entries2, isNull);

      expect(logs, [
        'CHECK>>Duplicated `intl` entries in file.',
        'CHECK>>-- msgB = <<bbb bbb>><<bbb bbb bbb>>',
      ]);
    });

    test('checkIntlEntriesReference[OK]', () async {
      var linesRef = [
        'msgA=aaa aaa',
        '',
        'msgB=bbb bbb',
      ];

      var lines = [
        'msgB=BBB',
        'msgA=AAA',
        'msgB=BBB',
        'msgA=AAA',
      ];

      var entriesRef = IntlRawEntry.fromLines(linesRef)!;

      var entries = IntlRawEntry.fromLines(lines)!;

      var logs = <String>[];

      var errorKeys = checkIntlEntriesReference(entriesRef, entries,
          log: (t, m) => logs.add('$t>>$m'));

      expect(errorKeys, isNull);
      expect(logs, isEmpty);
    });

    test('checkIntlEntriesReference[ERROR]', () async {
      var linesRef = [
        'msgA=aaa aaa',
        '',
        'msgB=bbb bbb',
      ];

      var lines = [
        'msgB=BBB',
        'msgX=XXX',
        'msgB=BBB',
      ];

      var entriesRef = IntlRawEntry.fromLines(linesRef)!;

      var entries = IntlRawEntry.fromLines(lines)!;

      var logs = <String>[];

      var errorKeys = checkIntlEntriesReference(entriesRef, entries,
          log: (t, m) => logs.add('$t>>$m'));

      expect(
          errorKeys,
          equals([
            ['msgA'],
            ['msgX'],
          ]));

      expect(
          logs,
          equals([
            'CHECK>>Missing keys: [msgA]',
            'CHECK>>Extra keys: [msgX]',
          ]));
    });

    test('checkIntlEntriesReference[OK]', () async {
      var linesRef = [
        'msgA=aaa aaa',
        '',
        'msgB=bbb bbb',
      ];

      var lines = [
        'msgB=BBB',
        'msgA=AAA',
        'msgB=BBB',
      ];

      var entriesRef = IntlRawEntry.fromLines(linesRef)!;

      var entries = IntlRawEntry.fromLines(lines)!;

      var entries2 = entriesRef.formatEntries(entries.toMap());

      expect(
          entries2,
          equals([
            IntlRawEntry('msgA', 'AAA'),
            null,
            IntlRawEntry('msgB', 'BBB'),
          ]));

      var content = await entries2.toIntlFileContent();

      expect(
          content,
          equals('msgA=AAA\n'
              '\n'
              'msgB=BBB\n'));
    });
  });
}
