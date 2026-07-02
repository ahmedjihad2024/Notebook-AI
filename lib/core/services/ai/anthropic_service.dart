import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:notebook_ai/core/config/ai_config.dart';

class AnthropicService {
  final Dio _dio;

  AnthropicService([Dio? dio])
      : _dio = dio ??
            Dio(
              BaseOptions(
                headers: {
                  'content-type': 'application/json',
                  'anthropic-version': AiConfig.apiVersion,
                  'x-api-key': AiConfig.anthropicApiKey,
                },
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 30),
              ),
            );

  Future<List<String>> classifyTags(String text, List<String> allowed) async {
    final data = await _create(
      system:
          'You label notes with the 1 to 3 most relevant tags. Choose only from the allowed list; never invent tags.',
      userText: 'Allowed tags: ${allowed.join(', ')}\n\nNote:\n$text',
      maxTokens: 128,
      schema: {
        'type': 'object',
        'properties': {
          'tags': {
            'type': 'array',
            'items': {'type': 'string', 'enum': allowed},
          },
        },
        'required': ['tags'],
        'additionalProperties': false,
      },
    );
    final decoded = _decodeObject(_firstText(data));
    final tags = (decoded['tags'] as List? ?? const []).cast<String>();
    return tags.where(allowed.contains).take(3).toList();
  }

  Future<String> summarize(String text) async {
    final data = await _create(
      system:
          'Summarize the note in one concise sentence. Respond with only that sentence.',
      userText: text,
      maxTokens: 128,
    );
    return _firstText(data).trim();
  }

  Future<Map<String, dynamic>> _create({
    required String system,
    required String userText,
    required int maxTokens,
    Map<String, dynamic>? schema,
  }) async {
    if (!AiConfig.isConfigured) {
      throw StateError('Anthropic API key is not configured');
    }
    final response = await _dio.post<Map<String, dynamic>>(
      AiConfig.baseUrl,
      data: {
        'model': AiConfig.model,
        'max_tokens': maxTokens,
        'system': system,
        'messages': [
          {'role': 'user', 'content': userText},
        ],
        if (schema != null)
          'output_config': {
            'format': {'type': 'json_schema', 'schema': schema},
          },
      },
    );
    return response.data ?? const {};
  }

  String _firstText(Map<String, dynamic> data) {
    final content = data['content'] as List? ?? const [];
    for (final block in content) {
      if (block is Map && block['type'] == 'text') {
        return (block['text'] as String?) ?? '';
      }
    }
    return '';
  }

  Map<String, dynamic> _decodeObject(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start == -1 || end <= start) return const {};
    final decoded = jsonDecode(raw.substring(start, end + 1));
    return decoded is Map<String, dynamic> ? decoded : const {};
  }
}
