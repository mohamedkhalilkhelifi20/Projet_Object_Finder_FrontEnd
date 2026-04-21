import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

// 1. STATE
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? userEmail;
  final String? userName;
  final String? token;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.userEmail,
    this.userName,
    this.token,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    String? userEmail,
    String? userName,
    String? token,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      token: token ?? this.token,
    );
  }
}

// 2. NOTIFIER
class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _authService;

  @override
  AuthState build() {
    _authService = AuthService();
    _checkLoginStatus();
    return const AuthState();
  }

  // ─── Vérifier LocalStorage au démarrage
  Future<void> _checkLoginStatus() async {
    final bool loggedIn = await _authService.isLoggedIn();

    if (loggedIn) {
      final String?               token    = await _authService.getToken();
      final Map<String, dynamic>? userData = await _authService.getUserData();

      state = state.copyWith(
        isAuthenticated: true,
        token:           token,
        userEmail:       userData?['email'],
        userName:        userData?['name'],
      );
    }
  }

  // ─── Connexion Google SSO
 Future<void> signInWithGoogle() async {
  state = state.copyWith(isLoading: true);

  try {
    print('🔵 Début signInWithGoogle');
    final data = await _authService.signInWithGoogle();
    print('✅ Data reçue : $data');
    state = state.copyWith(
      isAuthenticated: true,
      isLoading:       false,
      token:           data['access_token'],
      userEmail:       data['email'],
      userName:        data['name'],
    );
  } catch (e) {
    print('❌ Erreur : $e');
    if (e.toString().contains('canceled')) {
      state = state.copyWith(isLoading: false);
      return;
    }
    state = state.copyWith(isLoading: false, error: e.toString());
  }
}

  // ─── Déconnexion ─────────────────────────────────────
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.signOut();
      // Reset complet du state
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:     e.toString(),
      );
    }
  }
}

// 3. PROVIDER
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);


/*
AuthState      → données : isAuthenticated, token, email, name
AuthNotifier   → logique :
  build()              → vérifie LocalStorage au démarrage
  _checkLoginStatus()  → si token existe → connecté automatiquement
  signInWithGoogle()   → popup Google → Firebase → FastAPI → state mis à jour
  signOut()            → déconnexion → state reset
authProvider   → expose le Notifier à Flutter

App démarre
    ↓
AuthNotifier.build()
    ↓
_checkLoginStatus() → lit SharedPreferences
    ↓
Token existe ?
  OUI → isAuthenticated = true → ScannerScreen
  NON → isAuthenticated = false → LoginScreen
*/