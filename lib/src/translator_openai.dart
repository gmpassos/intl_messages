import 'dart:math' as math;

import 'package:async_extension/async_extension.dart';
import 'package:collection/collection.dart';
import 'package:dart_openai/dart_openai.dart';

import 'intl_messages_base.dart';
import 'translator.dart';

/// OpenAI translator (using ChatGPT).
class TranslatorOpenAI extends Translator {
  /// OpenAI API-Key.
  final String apiKey;

  /// Model name. Default: `gpt-3.5-turbo`
  final String model;

  @override
  final int maxBlockLength;

  /// Maximum retries for failed requests (HTTP Status 429).
  final int maxRetries = 3;

  TranslatorOpenAI(
      {required this.apiKey,
      this.model = 'gpt-3.5-turbo',
      this.maxBlockLength = 500,
      int maxParallelTranslations = 2,
      super.logger,
      super.cache})
      : super(
            translateBlocksInParallel: true,
            maxParallelTranslations:
                math.max(1, math.min(maxParallelTranslations, 10)));

  @override
  Future<Map<String, String>?> translateBlock(
      Map<String, String> entries,
      IntlLocale fromLocale,
      IntlLocale toLocale,
      String fromLanguage,
      String toLanguage,
      bool confirm) async {
    var blk = entries.entries.map((e) {
      var k = e.key.trim();
      var m = e.value.replaceAll(RegExp(r'\s+'), ' ').trim();
      return '$k=$m';
    }).join('\n');

    var headerKey = 'key';
    if (entries.containsKey(headerKey)) {
      for (var i = 0; i < 10000; ++i) {
        headerKey = 'key__$i';
        if (!entries.containsKey(headerKey)) break;
      }
    }

    var prompt1 = _buildPrompt1(toLanguage, blk);

    var content = await prompt(prompt1);
    if (content == null || content.isEmpty) return null;

    var translation1 = parseResult(entries, content);

    var invalidKeys1 = validateTranslation(entries, translation1, 1);
    if (invalidKeys1 == null) {
      return translation1;
    }

    var prompt2 = _buildPrompt2(toLanguage, blk);

    var content2 = await prompt(prompt2);
    if (content2 == null || content2.isEmpty) return null;

    var translation2 = parseResult(entries, content2);

    var invalidKeys2 = validateTranslation(entries, translation2, 2);

    if (invalidKeys2 != null) {
      var translation1Valids = {...translation1};
      var translation2Valids = {...translation2};

      translation1Valids.removeWhere((key, _) => invalidKeys1.contains(key));

      translation2Valids.removeWhere((key, _) => invalidKeys2.contains(key));
      translation2Valids
          .removeWhere((key, _) => translation1Valids.containsKey(key));

      var translation3 = {...translation1Valids, ...translation2Valids};

      log('FIXED TRANSLATION[3]>');
      for (var e in translation3.entries) {
        log('  -- ${e.key}: ${e.value}');
      }

      var invalidKeys3 = validateTranslation(entries, translation3, 3);
      if (invalidKeys3 != null) {
        for (var k in invalidKeys3) {
          var m = translation1[k] ?? translation2[k];
          if (m != null) {
            translation3[k] = m;

            log('** NOT TRANSLATED KEY> $k: $m');
          }
        }

        log('RETURNING PARTIAL TRANSLATION> Not translated keys: $invalidKeys3');
      }

      return translation3;
    } else {
      return translation2;
    }
  }

  List<String>? validateTranslation(
      Map<String, String> entries, Map<String, String> translation, int id) {
    var notTranslated = entries.entries.where((e) {
      var k = e.key;
      var m = entries[k]?.trim().toLowerCase();
      var t = translation[k]?.trim().toLowerCase();

      if (t == null || t.isEmpty) {
        if (m != null && m.isNotEmpty) return false;
      }
      return m == t;
    }).toList();

    if (notTranslated.isNotEmpty) {
      log('NOT TRANSLATED[$id] KEYS> <${notTranslated.map((e) => '${e.key}: ${e.value}').join('> <')}>');

      var invalidKeys = notTranslated.map((e) => e.key).toList();
      return invalidKeys;
    }

    return null;
  }

  String _buildPrompt1(String language, String blk) =>
      'Translate the texts on each line after "=" into $language keeping the same format:\n\n$blk\n';

  String _buildPrompt2(String language, String blk) {
    return 'Split the text below in lines, then translate to $language the text in each line after "=", preserving key before "=". Respond keeping the same format:\n\n'
        'key=message\n'
        '$blk\n';
  }

  /// Prompts OpenAI API (using ChatGPT).
  Map<String, String> parseResult(Map<String, String> entries, String content) {
    var lines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    var entries2 = lines
        .map((l) {
          var idx = l.indexOf('=');
          if (idx < 0) {
            idx = l.indexOf(':');
          }
          if (idx < 0) return null;

          var k = l.substring(0, idx);
          var m = l.substring(idx + 1);
          return MapEntry(k, m);
        })
        .whereNotNull()
        .toList();

    if (entries2.every((e) => e.key == 'key' || e.key == 'translation')) {
      var entries3 = <MapEntry<String, String>>[];

      for (var i = 0; i < entries2.length; i += 2) {
        var e1 = entries2[i];
        var e2 = entries2[i + 1];

        if (e1.key == 'translation' && e2.key == 'key') {
          var tmp = e1;
          e1 = e2;
          e2 = tmp;
        }

        if (e1.key == 'key' && e2.key == 'translation') {
          entries3.add(MapEntry(e1.value, e2.value));
        }
      }

      entries2 = entries3;
    }

    var map = Map<String, String>.fromEntries(entries2);

    var entriesTranslated = entries.keys
        .map((k) {
          var m = map[k];
          if (m != null) {
            return MapEntry(k, m);
          }

          var kLC = k.trim().toLowerCase();

          var e = map.entries
              .firstWhereOrNull((e) => e.key.trim().toLowerCase() == kLC);
          if (e != null) {
            return MapEntry(k, e.value);
          }

          return null;
        })
        .whereNotNull()
        .toList();

    if (entriesTranslated.length < entries2.length &&
        entries2.length == entries.length) {
      entriesTranslated = entries.keys
          .mapIndexed((i, k) => MapEntry(k, entries2[i].value))
          .toList();
    }

    var mapTranslated = Map<String, String>.fromEntries(entriesTranslated);
    return mapTranslated;
  }

  Future<String?> prompt(String prompt, {int? n}) async {
    log('OPEN-AI PROMPT> $prompt');

    OpenAI.apiKey = apiKey;

    Object? error;
    OpenAIChatCompletionModel? chatCompletion;

    var maxRetries = math.max(1, this.maxRetries);

    for (var i = 0; i <= maxRetries; ++i) {
      try {
        chatCompletion = await OpenAI.instance.chat.create(
          model: model,
          n: n,
          messages: [
            OpenAIChatCompletionChoiceMessageModel(
                role: OpenAIChatMessageRole.user,
                content: [
                  OpenAIChatCompletionChoiceMessageContentItemModel.text(
                    prompt,
                  ),
                ]),
          ],
        );

        break;
      } catch (e) {
        error = e;

        if (e.toString().contains('statusCode: 429')) {
          log('REQUEST ERROR> statusCode: 429 ; Retrying request: ${i + 1} / $maxRetries');
          var sleep = i == 0 ? 2 : 3;
          await Future.delayed(Duration(seconds: sleep));
        } else {
          rethrow;
        }
      }
    }

    if (chatCompletion == null) {
      if (error != null) {
        throw error;
      }
      throw StateError("Null response");
    }

    var responses =
        chatCompletion.choices.map((c) => c.message.content).toList();

    if (responses.isEmpty) return null;

    var contents = responses.first;

    var content = contents?.map((e) => e.text).whereNotNull().join('\n').trim();
    if (content == null || content.isEmpty) return null;

    log('\nOPEN-AI RESPONSE>\n$content\n');

    return content;
  }
}
