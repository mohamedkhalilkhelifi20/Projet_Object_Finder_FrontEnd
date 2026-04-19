class AppConstants {
  AppConstants._();

  //URLs Backend
  static const String baseUrl = "http://192.168.1.145:8000";

  static const String detectEndpoint      = "$baseUrl/detect";
  static const String loginEndpoint       = "$baseUrl/login";
  static const String registerEndpoint    = "$baseUrl/register";
  static const String syncEndpoint        = "$baseUrl/sync-history";
  static const String healthEndpoint      = "$baseUrl/health";

  //Langues supportées
  static const String langFr = "fr";
  static const String langTn = "tn";

  // ─── Seuils de danger
  static const double dangerZone    = 0.5;  // < 0.5m  → DANGER
  static const double attentionZone = 1.0;  // < 1.0m  → ATTENTION
  static const double closeZone     = 2.0;  // < 2.0m  → PROCHE

  // ─── Scanner
  // Intervalle entre deux appels API (ms) — anti-spam
  static const int scanIntervalMs = 800;
  // Timeout requête HTTP
  static const int httpTimeoutSec = 10;
  // Confiance minimum pour accepter une détection
  static const double minConfidence = 0.45;

  // ─── SQLite
  static const String dbName         = "object_finder.db";
  static const String detectionsTable = "detections";

  // ─── SharedPreferences keys
  static const String keyJwtToken  = "jwt_token";
  static const String keyUserEmail = "user_email";
  static const String keyLang      = "app_lang";
}