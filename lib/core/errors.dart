import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

// ─── Types d'erreurs métier ──────────────────────────────
enum AppErrorType {
  network,   // pas de réseau
  timeout,   // API trop lente
  server,    // erreur 5xx
  auth,      // token expiré / non autorisé
  unknown,   // autre
}

class AppError {
  final AppErrorType type;
  final String message;
  final String? details;

  const AppError({
    required this.type,
    required this.message,
    this.details,
  });

  // ─── Factory : convertit n'importe quelle exception ─────
  factory AppError.from(Object e) {
    if (e is SocketException || e is NetworkException) {
      return const AppError(
        type:    AppErrorType.network,
        message: "Pas de connexion réseau",
        details: "Vérifiez votre WiFi ou activez les données mobiles",
      );
    }
    if (e is TimeoutException) {
      return const AppError(
        type:    AppErrorType.timeout,
        message: "L'API ne répond pas",
        details: "Vérifiez que le serveur FastAPI est bien lancé",
      );
    }
    if (e is AuthException) {
      return const AppError(
        type:    AppErrorType.auth,
        message: "Session expirée",
        details: "Veuillez vous reconnecter",
      );
    }
    return AppError(
      type:    AppErrorType.unknown,
      message: "Une erreur est survenue",
      details: e.toString(),
    );
  }

  // ─── Icône selon le type ─────────────────────────────────
  IconData get icon {
    switch (type) {
      case AppErrorType.network:  return Icons.wifi_off_rounded;
      case AppErrorType.timeout:  return Icons.timer_off_rounded;
      case AppErrorType.server:   return Icons.cloud_off_rounded;
      case AppErrorType.auth:     return Icons.lock_outline_rounded;
      default:                    return Icons.error_outline_rounded;
    }
  }
}

// ─── Exceptions personnalisées ───────────────────────────
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final int statusCode;
  final String message;
  const ServerException({required this.statusCode, required this.message});
  @override
  String toString() => "[$statusCode] $message";
}

// ─── Helper global : afficher SnackBar d'erreur ──────────
void showErrorSnackBar(BuildContext context, AppError error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(error.icon, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error.message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15,
                  ),
                ),
                if (error.details != null)
                  Text(
                    error.details!,
                    style: const TextStyle(
                      fontSize: 13, color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 4),
    ),
  );
}

// ─── Helper global : afficher SnackBar de succès ─────────
void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF43A047),
      duration: const Duration(seconds: 3),
    ),
  );
}