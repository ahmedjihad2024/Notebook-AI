import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AiConfig {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static String get model {
    final configured = dotenv.env['GEMINI_MODEL'];
    return (configured != null && configured.isNotEmpty)
        ? configured
        : 'gemini-2.5-flash';
  }

  static const String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  static String get endpoint => '$baseUrl/$model:generateContent';

  static bool get isConfigured => geminiApiKey.isNotEmpty;
}
