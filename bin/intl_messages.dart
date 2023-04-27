import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:async_extension/async_extension.dart';
import 'package:intl_messages/intl_messages.dart';
import 'package:intl_messages/src/intl_messages_tools.dart';
import 'package:intl_messages/src/intl_messages_tools_io.dart';
import 'package:path/path.dart' as pack_path;

const String cliTitle = '[intl_messages/${IntlMessages.VERSION}]';

Future<void> main(List<String> args) async {
  final runner = CommandRunner<bool>('intl_messages', '$cliTitle - CLI Tool')
    ..addCommand(CheckCommand())
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
  String get description => 'Check `.intl` files';

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
  String get description => 'Format `.intl` files';

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
