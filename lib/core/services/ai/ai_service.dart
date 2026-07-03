import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:notebook_ai/core/config/ai_config.dart';

enum AiErrorKind {
  notConfigured,
  network,
  timeout,
  auth,
  permission,
  rateLimit,
  overloaded,
  server,
  invalidRequest,
  empty,
  unknown,
}

class AiException implements Exception {
  final AiErrorKind kind;
  final String message;

  const AiException(this.kind, this.message);

  @override
  String toString() => 'AiException($kind): $message';
}

class AiService {
  final Dio _dio;

  AiService([Dio? dio])
      : _dio = dio ??
            Dio(
              BaseOptions(
                headers: {
                  'content-type': 'application/json',
                  'x-goog-api-key': AiConfig.geminiApiKey,
                },
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 30),
              ),
            ) {
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          compact: false,
          maxWidth: 120,
        ),
      );
    }
  }

  Future<List<String>> classifyTags(String text, List<String> allowed) async {
    final data = await _generate(
      system:
          'You label notes with the 1 to 3 most relevant tags. Choose only from the allowed list; never invent tags.',
      parts: [
        {'text': 'Allowed tags: ${allowed.join(', ')}\n\nNote:\n$text'},
      ],
      maxTokens: 256,
      schema: {
        'type': 'OBJECT',
        'properties': {
          'tags': {
            'type': 'ARRAY',
            'items': {'type': 'STRING', 'enum': allowed},
          },
        },
        'required': ['tags'],
      },
    );
    final decoded = _decodeObject(_firstText(data));
    final tags = (decoded['tags'] as List? ?? const []).cast<String>();
    final filtered = tags.where(allowed.contains).take(2).toList();
    if (filtered.isEmpty) {
      throw const AiException(
        AiErrorKind.empty,
        'No matching tags were returned. Try adding more detail to the note.',
      );
    }
    return filtered;
  }

  Future<String> summarize(String text) async {
    final data = await _generate(
      system:
          'Summarize the note in one concise sentence. Respond with only that sentence.',
      parts: [
        {'text': text},
      ],
      maxTokens: 400,
    );
    final summary = _firstText(data).trim();
    if (summary.isEmpty) {
      throw const AiException(
        AiErrorKind.empty,
        'An empty summary was returned. Try again.',
      );
    }
    return summary;
  }

  Future<Map<String, dynamic>> _generate({
    required String system,
    required List<Map<String, dynamic>> parts,
    required int maxTokens,
    Map<String, dynamic>? schema,
  }) async {
    if (!AiConfig.isConfigured) {
      throw const AiException(
        AiErrorKind.notConfigured,
        'No Gemini API key set. Add GEMINI_API_KEY to your .env file.',
      );
    }
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        AiConfig.endpoint,
        data: {
          'system_instruction': {
            'parts': [
              {'text': system},
            ],
          },
          'contents': [
            {
              'role': 'user',
              'parts': parts,
            },
          ],
          'generationConfig': {
            'maxOutputTokens': maxTokens,
            'thinkingConfig': {'thinkingBudget': 0},
            if (schema != null) ...{
              'responseMimeType': 'application/json',
              'responseSchema': schema,
            },
          },
        },
      );
      return response.data ?? const {};
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  AiException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const AiException(
          AiErrorKind.timeout,
          'The request timed out. Check your connection and try again.',
        );
      case DioExceptionType.connectionError:
        return const AiException(
          AiErrorKind.network,
          'No internet connection. Connect and try again.',
        );
      case DioExceptionType.badCertificate:
        return const AiException(
          AiErrorKind.network,
          'Could not establish a secure connection. Try again.',
        );
      case DioExceptionType.cancel:
        return const AiException(
          AiErrorKind.unknown,
          'The request was cancelled.',
        );
      default:
        return _mapStatus(e.response?.statusCode, e.response?.data);
    }
  }

  AiException _mapStatus(int? status, dynamic data) {
    final apiMessage = _apiMessage(data);
    final looksLikeKey =
        apiMessage != null && apiMessage.toLowerCase().contains('api key');
    switch (status) {
      case 400:
        if (looksLikeKey) {
          return const AiException(
            AiErrorKind.auth,
            'Invalid API key. Check GEMINI_API_KEY in your .env file.',
          );
        }
        return AiException(
          AiErrorKind.invalidRequest,
          apiMessage ?? 'The request was rejected.',
        );
      case 401:
        return const AiException(
          AiErrorKind.auth,
          'Invalid API key. Check GEMINI_API_KEY in your .env file.',
        );
      case 403:
        return const AiException(
          AiErrorKind.permission,
          'This API key is not allowed to use this model.',
        );
      case 429:
        return AiException(
          AiErrorKind.rateLimit,
          apiMessage ??
              'Free-tier rate limit reached. Wait a moment and try again.',
        );
      case 503:
        return const AiException(
          AiErrorKind.overloaded,
          'The model is temporarily overloaded. Try again shortly.',
        );
      default:
        if (status != null && status >= 500) {
          return const AiException(
            AiErrorKind.server,
            'The AI service had a server error. Try again shortly.',
          );
        }
        return AiException(
          AiErrorKind.unknown,
          apiMessage ?? 'Something went wrong. Try again.',
        );
    }
  }

  String? _apiMessage(dynamic data) {
    final map = data is String ? _tryDecode(data) : data;
    if (map is Map && map['error'] is Map) {
      final message = (map['error'] as Map)['message'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
    return null;
  }

  dynamic _tryDecode(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  String _firstText(Map<String, dynamic> data) {
    final candidates = data['candidates'] as List? ?? const [];
    if (candidates.isEmpty) return '';
    final content = (candidates.first as Map)['content'] as Map? ?? const {};
    final parts = content['parts'] as List? ?? const [];
    for (final part in parts) {
      if (part is Map && part['text'] is String) {
        return part['text'] as String;
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
