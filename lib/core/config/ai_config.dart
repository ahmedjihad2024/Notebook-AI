import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AiConfig {
  static String get anthropicApiKey => dotenv.env['ANTHROPIC_API_KEY'] ?? '';

  static const String model = 'claude-haiku-4-5';

  static const String baseUrl = 'https://api.anthropic.com/v1/messages';

  static const String apiVersion = '2023-06-01';

  static bool get isConfigured => anthropicApiKey.isNotEmpty;
}
