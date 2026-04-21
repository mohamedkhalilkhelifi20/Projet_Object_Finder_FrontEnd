import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants.dart';

class AuthService {
  // ─── Instance Firebase ───────────────────────────────
  final _firebaseAuth = FirebaseAuth.instance;

  // ============================================================
  // 1. CONNEXION GOOGLE SSO
  // ============================================================
  Future<Map<String, dynamic>> signInWithGoogle() async {
    print('🔵 Step 1 — Firebase Google SignIn');
    final GoogleAuthProvider googleProvider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile');

    print('🔵 Step 2 — signInWithProvider');
    final UserCredential userCredential =
        await _firebaseAuth.signInWithProvider(googleProvider);

    print('🔵 Step 3 — getIdToken');
    final String? idToken = await userCredential.user!.getIdToken();
    final String email    = userCredential.user!.email ?? '';
    final String name     = userCredential.user!.displayName ?? '';

    print('🔵 Step 4 — Envoyer à FastAPI');
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body:    jsonEncode({'id_token': idToken}),
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur serveur : ${response.body}");
    }

    final data = jsonDecode(response.body);

    await _saveToken(data['access_token']);
    await _saveUserData({'email': email, 'name': name});

    return data;
  }

  // ============================================================
  // 2. SAVE TOKEN — comme saveData() du prof
  // ============================================================
  Future<void> _saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyJwtToken, token);
  }

  // ============================================================
  // 3. SAVE USER DATA en JSON — comme saveCart() du prof
  // ============================================================
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(userData);
    await prefs.setString(AppConstants.keyUserData, encodedData);
  }

  // ============================================================
  // 4. LOAD TOKEN — comme chargerData() du prof
  // ============================================================
  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyJwtToken);
  }

  // ============================================================
  // 5. LOAD USER DATA — comme loadCart() du prof
  // ============================================================
  Future<Map<String, dynamic>?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString(AppConstants.keyUserData);
    if (userData != null) {
      return json.decode(userData) as Map<String, dynamic>;
    }
    return null;
  }

  // ============================================================
  // 6. VÉRIFIER SI CONNECTÉ — containsKey comme le prof
  // ============================================================
  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(AppConstants.keyJwtToken);
  }

  // ============================================================
  // 7. DÉCONNEXION — clear() comme le prof
  // ============================================================
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}