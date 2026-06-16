import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static const String supabaseUrl = 'https://vgsjpuxymtkkiaissrky.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_6D8ptLACddu7D5r2SN0LTQ_RQMtS15q';
  static String get openAiApiKey {
    const envKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
    if (envKey.isNotEmpty) return envKey;
    return dotenv.env['OPENAI_API_KEY'] ?? '';
  }

  static String get n8nWebhookUrl {
    const envKey = String.fromEnvironment('N8N_WEBHOOK_URL', defaultValue: '');
    if (envKey.isNotEmpty) return envKey;
    return dotenv.env['N8N_WEBHOOK_URL'] ?? '';
  }

  static String get baseApiUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  static const Duration defaultTimeout = Duration(seconds: 30);
  static const int defaultPageSize = 20;

  static const String prefsActiveWorldKey = 'active_world';
  static const String prefsThemeModeKey = 'theme_mode';
  static const String prefsAdminSessionKey = 'admin_session';
  static String get adminPassword {
    const envKey = String.fromEnvironment('ADMIN_PASSWORD', defaultValue: '');
    if (envKey.isNotEmpty) return envKey;
    return dotenv.env['ADMIN_PASSWORD'] ?? 'admin123';
  }
}
