import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  // URLs Backend
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://192.168.1.145:8000';

  static String get authEndpoint    => "$baseUrl/auth/google";
  static String get detectEndpoint  => "$baseUrl/detect";
  static String get historyEndpoint => "$baseUrl/history";
  static String get syncEndpoint    => "$baseUrl/history/sync";
  static String get healthEndpoint  => "$baseUrl/health";

  // Google
  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  // SharedPreferences keys — depuis .env
  static String get keyJwtToken =>
      dotenv.env['KEY_JWT_TOKEN'] ?? 'jwt_token';
  static String get keyUserData =>
      dotenv.env['KEY_USER_DATA'] ?? 'user_data';
  static String get keyLang =>
      dotenv.env['KEY_LANG'] ?? 'app_lang';

  // Langues
  static const String langFr = "fr";
  static const String langTn = "tn";

  // Seuils de danger
  static const double dangerZone    = 0.5;
  static const double attentionZone = 1.0;
  static const double closeZone     = 2.0;

  // Scanner
  static const int    scanIntervalMs = 800;
  static const int    httpTimeoutSec = 10;
  static const double minConfidence  = 0.45;

  // SQLite
  static const String dbName          = "object_finder.db";
  static const String detectionsTable = "detections";
}