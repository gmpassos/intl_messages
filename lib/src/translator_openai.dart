import 'dart:math' as math;

import 'package:async_extension/async_extension.dart';
import 'package:collection/collection.dart';
import 'package:dart_openai/openai.dart';

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

  /// Message role.
  final OpenAIChatMessageRole role;

  TranslatorOpenAI(
      {required this.apiKey,
      this.model = 'gpt-3.5-turbo',
      this.maxBlockLength = 500,
      this.role = OpenAIChatMessageRole.user,
      super.logger});

  @override
  Future<Map<String, String>?> translateBlock(Map<String, String> entries,
      IntlLocale locale, String language, confirm) async {
    var blk = entries.entries.map((e) {
      var k = e.key.trim();
      var m = e.value.replaceAll(RegExp(r'\s+'), ' ').trim();
      return '$k=$m';
    }).join('\n');

    var prompt =
        'Translate the texts on each line after "=" into $language keeping the same format:\n\n$blk\n';

    var content = await this.prompt(prompt);
    if (content == null || content.isEmpty) return null;

    return parseResult(entries, content);
  }

  /// Prompts OpenAI API (using ChatGPT).
  Map<String, String> parseResult(Map<String, String> entries, String content) {
    var lines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    var entries2 = lines.map((l) {
      var idx = l.indexOf('=');
      if (idx < 0) {
        idx = l.indexOf(':');
      }
      if (idx < 0) return null;

      var k = l.substring(0, idx);
      var m = l.substring(idx + 1);
      return MapEntry(k, m);
    }).whereNotNull();

    var map = Map<String, String>.fromEntries(entries2);

    var entriesTranslated = entries.keys.map((k) {
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
    }).whereNotNull();

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
              role: role,
              content: prompt,
            ),
          ],
        );
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

    var content = responses.first.trim();
    if (content.isEmpty) return null;

    log('OPEN-AI RESPONSE>\n$content');

    return content;
  }
}
