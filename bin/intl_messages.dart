import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:async_extension/async_extension.dart';
import 'package:collection/collection.dart';
import 'package:intl_messages/intl_messages.dart';
import 'package:intl_messages/src/intl_messages_tools.dart';
import 'package:intl_messages/src/intl_messages_tools_io.dart';
import 'package:intl_messages/src/translator_console.dart';
import 'package:intl_messages/src/translator_io.dart';
import 'package:intl_messages/src/translator_openai.dart';
import 'package:path/path.dart' as pack_path;

const String cliTitle = '[intl_messages/${IntlMessages.VERSION}]';

Future<void> main(List<String> args) async {
  final runner = CommandRunner<bool>('intl_messages', '$cliTitle - CLI Tool')
    ..addCommand(CheckCommand())
    ..addCommand(FixCommand())
    ..addCommand(FormatCommand());

  runner.argParser.addFlag('version',
      abbr: 'v', negatable: false, defaultsTo: false, help: 'Show version.');

  var argsResult = runner.argParser.parse(args);

  if (argsResult['version']) {
    showVersion();
    exit(0);
  }

  var help = (argsResult['help'] as bool?) ?? false;
  var cmdHelp = (argsResult.command?['help'] as bool?) ?? false;

  var ok = await runner.run(args);
  ok ??= false;

  if (!ok) {
    if (help || cmdHelp) {
      exit(0);
    } else {
      _consolePrinter('** Failed!');
      exit(1);
    }
  } else {
    exit(0);
  }
}

void showVersion() {
  print('intl_messages/${IntlMessages.VERSION} - CLI Tool');
}

class CheckCommand extends Command<bool> {
  CheckCommand() {
    argParser.addOption('file', abbr: 'f', help: 'File to check.');
    argParser.addOption('ref', help: 'Reference file.');
  }

  @override
  String get name => 'check';

  @override
  String get description => 'Check `.intl` files.';

  @override
  List<String> get aliases => ['c'];

  File? get argRef => _toFile(argResults?['ref']);

  File? get argFile => _toFile(argResults?['file']);

  @override
  FutureOr<bool> run() {
    var argFile = this.argFile;

    if (argFile == null) {
      _log('CHECK', "Missing argument `file`.");
      return false;
    }

    var fileEntries = checkIntlFile(argFile, fileType: 'FILE');
    if (fileEntries == null) return false;

    var argRef = this.argRef;

    var ok = true;

    if (argRef != null) {
      var refEntries = checkIntlFile(argRef, fileType: 'REF');
      if (refEntries == null) return false;

      var errorKeys = checkIntlEntriesReference(refEntries, fileEntries);

      ok = errorKeys == null;
    }

    if (ok) {
      _consolePrinter('** File OK: ${argFile.path}');
    }

    return ok;
  }
}

class FixCommand extends Command<bool> {
  FixCommand() {
    argParser.addOption('file', abbr: 'f', help: 'File to check.');
    argParser.addOption('ref', help: 'Reference file.');
    argParser.addOption(
      'translator',
      abbr: 't',
      help: 'The translator to use.',
      defaultsTo: 'console',
      allowed: [
        'openai',
        'console',
      ],
      allowedHelp: {
        'openai': 'OpenAI translator (using ChatGPT) [requires `api-key`].',
        'console': 'Translate using console prompts.',
      },
    );
    argParser.addOption('api-key', help: 'The translator API-Key.');
    argParser.addFlag('confirm', help: 'Confirm translation.');
    argParser.addOption('cache', help: 'Translator cache directory.');
    argParser.addFlag('overwrite',
        help: 'Overwrite `file` with the fixed version.');
  }

  @override
  String get name => 'fix';

  @override
  String get description => 'Fix missing entries in `.intl` files.';

  @override
  List<String> get aliases => [];

  File? get argRef => _toFile(argResults?['ref']);

  File? get argFile => _toFile(argResults?['file']);

  String? get argTranslator => argResults?['translator'];

  String? get argApiKey => argResults?['api-key'];

  Directory? get argCache {
    var cacheDir = argResults?['cache'] as String?;
    cacheDir = cacheDir?.trim();
    if (cacheDir == null || cacheDir.isEmpty) return null;
    return Directory(cacheDir).absolute;
  }

  bool get argConfirm => argResults?['confirm'] ?? false;

  bool get argOverwrite => (argResults?['overwrite'] as bool?) ?? false;

  @override
  Future<bool> run() async {
    var argFile = this.argFile;

    if (argFile == null) {
      _log('CHECK', "Missing argument `file`.");
      return false;
    }

    var fileEntries = checkIntlFile(argFile, fileType: 'FILE');
    if (fileEntries == null) return false;

    var argRef = this.argRef;

    List<IntlRawEntry?>? refEntries;
    List<String>? missingKeys;
    List<String>? extraKeys;
    IntlLocale? refLocale;

    if (argRef != null) {
      var refName = pack_path.basename(argRef.path);
      refLocale = IntlLocale.path(refName);

      refEntries = checkIntlFile(argRef, fileType: 'REF');
      if (refEntries == null) return false;

      var errorKeys = checkIntlEntriesReference(refEntries, fileEntries);

      if (errorKeys != null && errorKeys.length == 2) {
        missingKeys = errorKeys[0];
        extraKeys = errorKeys[1];
      }
    }

    if (missingKeys == null && extraKeys == null) {
      _consolePrinter('** File OK: ${argFile.path}');
      return true;
    }

    if (missingKeys != null && refEntries != null && missingKeys.isNotEmpty) {
      assert(refLocale != null);

      var fileName = pack_path.basename(argFile.path);
      var fileLocale = IntlLocale.path(fileName);

      var language = allLocales()[fileLocale.code];
      if (language == null) {
        throw StateError(
            "Can't find language for locale: $fileLocale (${argFile.path})");
      }

      var translator = resolveTranslator(fileLocale);

      var missingEntries = missingKeys.map((key) {
        var refEntry = refEntries!.firstWhereOrNull((e) => e?.key == key);
        if (refEntry == null) {
          throw StateError("Can't find reference entry for key: $key");
        }

        return MapEntry(refEntry.key, refEntry.msg ?? '');
      });

      var missingMap = Map.fromEntries(missingEntries);

      var confirm = argConfirm;

      var translations = await translator
          .translate(missingMap, refLocale!, fileLocale, confirm: confirm);

      if (translations != null) {
        var translatorConsole = TranslatorConsole();

        var translatedEntries = translations.entries
            .map((e) => IntlRawEntry(e.key, e.value))
            .toList();
        fileEntries.addAll(translatedEntries);

        if (confirm) {
          for (var i = 0; i < translatedEntries.length; ++i) {
            var e = translatedEntries[i];
            var k = e.key;
            var m = e.msg;
            if (m == null || m.isEmpty) continue;

            var ok = translatorConsole.confirmTranslation(
                k, m, refLocale, fileLocale);

            if (!ok) {
              var m0 = missingMap[k] ?? m;
              var m2 = await translatorConsole.promptTranslation(
                  k, m0, refLocale, fileLocale);
              translatedEntries[i] = IntlRawEntry(k, m2);
            }
          }
        }

        print('\n** Translated entries:');
        for (var e in translatedEntries) {
          print('  -- $e');
        }
        print('');

        var formattedFileContent = await fileEntries.toIntlFileContent();

        var fileContent = argFile.readAsStringSync();

        if (fileContent.trim() == formattedFileContent.trim()) {
          _log('FORMAT', 'Fixed file IDENTICAL to: ${argFile.path}');
          return true;
        }

        var file2 = argOverwrite ? argFile : _fileFixed(argFile);

        _log('FIX', 'Fixed file: ${file2.path}');

        file2.writeAsStringSync(formattedFileContent);

        return true;
      }
    }

    return false;
  }

  Translator resolveTranslator(IntlLocale locale) {
    var cacheDir = argCache;

    TranslatorCache? translatorCache;
    if (cacheDir != null) {
      if (!cacheDir.existsSync()) {
        throw StateError(
            'Invalid `Translator` cache directory: ${cacheDir.path}');
      }

      translatorCache =
          TranslatorCacheDirectory(cacheDir, logger: _translatorLog);
    }

    var argTranslator = this.argTranslator;

    if (argTranslator == 'console') {
      return TranslatorConsole(logger: _translatorLog, cache: translatorCache);
    } else if (argTranslator == 'openai') {
      var apiKey = argApiKey?.trim();

      if (apiKey == null || apiKey.isEmpty) {
        print('\n** Selected OpenAI Translator.');
        stdout.write('API-KEY> ');
        apiKey = stdin.readLineSync() ?? '';
        apiKey = apiKey.trim();
      }

      if (apiKey.isEmpty) {
        throw ArgumentError("OpenAI requires an `api-key` parameter.");
      }

      return TranslatorOpenAI(
          apiKey: apiKey, logger: _translatorLog, cache: translatorCache);
    } else {
      throw ArgumentError("Can't handle translator: `$argTranslator`");
    }
  }

  void _translatorLog(Object? o) {
    if (o == null) return;
    var s = o.toString();
    if (s.isEmpty) return;
    print(s);
  }

  File _fileFixed(File file) {
    var fileName = pack_path.basenameWithoutExtension(file.path);
    var fileExtension = pack_path.extension(file.path);
    if (fileExtension == '.' || fileExtension.isEmpty) {
      fileExtension = '.intl';
    }

    var fileName2 = '$fileName-fixed$fileExtension';

    var file2 = File(pack_path.join(file.parent.path, fileName2));
    return file2;
  }
}

class FormatCommand extends Command<bool> {
  FormatCommand() {
    argParser
      ..addOption('file', abbr: 'f', help: 'File to check.')
      ..addOption('ref', help: 'Reference file.')
      ..addFlag('overwrite',
          help: 'Overwrite `file` with the formatted version.');
  }

  @override
  String get name => 'format';

  @override
  String get description => 'Format `.intl` files.';

  @override
  List<String> get aliases => ['f'];

  File? get argRef => _toFile(argResults?['ref']);

  File? get argFile => _toFile(argResults?['file']);

  bool get argOverwrite => (argResults?['overwrite'] as bool?) ?? false;

  @override
  Future<bool> run() async {
    var argFile = this.argFile;

    if (argFile == null) {
      _log('FORMAT', "Missing argument `file`.");
      return false;
    }

    var fileEntries = checkIntlFile(argFile, fileType: 'FILE');
    if (fileEntries == null) return false;

    var argRef = this.argRef;

    if (argRef?.path == argFile.path) {
      _log('FORMAT',
          "`ref` parameter value is the same of `file` parameter: ${argFile.path}");
      return false;
    }

    var ok = true;

    List<IntlRawEntry?>? refEntries;
    if (argRef != null) {
      refEntries = checkIntlFile(argRef, fileType: 'REF');
      if (refEntries == null) return false;

      var errorKeys = checkIntlEntriesReference(refEntries, fileEntries);
      ok = errorKeys == null;
    }

    if (ok) {
      _consolePrinter('** File OK: ${argFile.path}');

      String formattedFileContent;
      if (refEntries != null) {
        var fileMap = fileEntries.toMap();

        var fileEntries2 = refEntries.map((e) {
          if (e == null) return null;
          var e2 = fileMap[e.key];
          assert(e2 != null);
          return e2;
        }).toList();

        formattedFileContent = await fileEntries2.toIntlFileContent();
      } else {
        formattedFileContent = await fileEntries.toIntlFileContent();
      }

      var fileContent = argFile.readAsStringSync();

      if (fileContent.trim() == formattedFileContent.trim()) {
        _log('FORMAT', 'Formatted file IDENTICAL to: ${argFile.path}');
        return true;
      }

      var file2 = argOverwrite ? argFile : _fileFormatted(argFile);

      _log('FORMAT', 'Formatted file: ${file2.path}');

      file2.writeAsStringSync(formattedFileContent);
    }

    return ok;
  }

  File _fileFormatted(File file) {
    var fileName = pack_path.basenameWithoutExtension(file.path);
    var fileExtension = pack_path.extension(file.path);
    if (fileExtension == '.' || fileExtension.isEmpty) {
      fileExtension = '.intl';
    }

    var fileName2 = '$fileName-formatted$fileExtension';

    var file2 = File(pack_path.join(file.parent.path, fileName2));
    return file2;
  }
}

File? _toFile(String? s) {
  s = s?.trim();
  if (s == null || s.isEmpty) return null;

  var file = File(s);
  return file.existsSync() ? file.absolute : null;
}

void _log(String type, Object? message) {
  print('## [$type]\t$message');
}

void _consolePrinter(Object? o) {
  print(o);
}
