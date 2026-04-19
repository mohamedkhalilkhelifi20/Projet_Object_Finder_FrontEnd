import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../../core/constants.dart';
import '../../../core/errors.dart';
import '../../../models/detection_model.dart';

class ApiService {
  // ─── Singleton ───────────────────────────────────────────
  ApiService._();
  static final ApiService instance = ApiService._();

  // ─── Client HTTP réutilisable ────────────────────────────
  final http.Client _client = http.Client();

  // ─── POST /detect ────────────────────────────────────────
  Future<List<DetectionModel>> detect({
   required Uint8List imageBytes,
    String lang = AppConstants.langFr,
    String? token,
  }) async {
    try {
      // Construire la requête multipart
      final uri = Uri.parse(
        "${AppConstants.detectEndpoint}?lang=$lang",
      );

      final request = http.MultipartRequest('POST', uri);

      // Header JWT si connecté
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Image en multipart
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'frame.jpg',
        ),
      );

      // Envoyer avec timeout
      final streamed = await request.send().timeout(
        Duration(seconds: AppConstants.httpTimeoutSec),
        onTimeout: () => throw TimeoutException(
          "API timeout", Duration(seconds: 10),
        ),
      );

      // Lire la réponse
      final body = await streamed.stream.bytesToString();

      // Vérifier le status code
      if (streamed.statusCode == 200) {
        final json = jsonDecode(body) as Map<String, dynamic>;
        final bool success = json['success'] as bool;

        // Aucun objet détecté → liste vide
        if (!success || json['count'] == 0) return [];

        // Parser chaque détection
        return (json['detections'] as List)
            .map((d) => DetectionModel.fromJson(d as Map<String, dynamic>))
            .toList();
      }

      if (streamed.statusCode == 401) {
        throw const AuthException("Token expiré");
      }

      throw ServerException(
        statusCode: streamed.statusCode,
        message:    body,
      );
    } on SocketException {
      throw const NetworkException("Pas de connexion réseau");
    } on TimeoutException {
      throw const NetworkException("API ne répond pas");
    }
  }

  // ─── GET /health ─────────────────────────────────────────
  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(Uri.parse(AppConstants.healthEndpoint))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── POST /sync-history ──────────────────────────────────
  Future<bool> syncHistory({
    required List<Map<String, dynamic>> detections,
    required String token,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(AppConstants.syncEndpoint),
            headers: {
              'Content-Type':  'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'detections': detections}),
          )
          .timeout(Duration(seconds: AppConstants.httpTimeoutSec));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── Libérer le client HTTP ──────────────────────────────
  void dispose() => _client.close();
}