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

  /// Message role.
  final OpenAIChatMessageRole role;

  TranslatorOpenAI(
      {required this.apiKey,
      this.model = 'gpt-3.5-turbo',
      this.role = OpenAIChatMessageRole.user,
      super.logger});

  @override
  Future<Map<String, String>?> translate(
      Map<String, String> entries, IntlLocale locale,
      {bool confirm = true}) async {
    var language = resolveLocaleName(locale);

    var blk = entries.entries.map((e) {
      var k = e.key.trim();
      var m = e.value.replaceAll(RegExp(r'\s+'), ' ').trim();
      return '$k=$m';
    }).join('\n');

    var prompt =
        'Translate the texts on each line after "=" into $language keeping the same format:\n\n$blk\n';

    var content = await this.prompt(prompt);
    if (content == null || content.isEmpty) return null;

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

  /// Prompts OpenAI API (using ChatGPT).
  Future<String?> prompt(String prompt, {int? n}) async {
    log('OPEN-AI PROMPT> $prompt');

    OpenAI.apiKey = apiKey;

    var chatCompletion = await OpenAI.instance.chat.create(
      model: model,
      n: n,
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: role,
          content: prompt,
        ),
      ],
    );

    var responses =
        chatCompletion.choices.map((c) => c.message.content).toList();

    if (responses.isEmpty) return null;

    var content = responses.first.trim();
    if (content.isEmpty) return null;

    log('OPEN-AI RESPONSE>\n$content');

    return content;
  }
}
