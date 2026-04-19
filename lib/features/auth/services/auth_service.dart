import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants.dart';

class AuthService {
  // ─── Instances ───────────────────────────────────────
  final _googleSignIn = GoogleSignIn.instance;
  final _firebaseAuth = FirebaseAuth.instance;

  // ─── Clés SharedPreferences ──────────────────────────
  static const String _keyToken = 'jwt_token';
  static const String _keyUser = 'user_data';

  // 1. CONNEXION GOOGLE SSO
  Future<Map<String, dynamic>> signInWithGoogle() async {

    // Étape 1 — Ouvrir popup Google
    final googleUser = await _googleSignIn.authenticate();

    // Étape 2 — Récupérer tokens Google
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

    // Étape 3 — Authentifier avec Firebase
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final idToken = await userCredential.user!.getIdToken();

    // Étape 4 — Envoyer à FastAPI
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': idToken}),
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur serveur : ${response.body}");
    }

    final data = jsonDecode(response.body);

    // Étape 5 — Sauvegarder données localement
    // JWT token simple
    await _saveToken(data['access_token']);

    // User data en JSON
    await _saveUserData({'email': data['email'], 'name': data['name']});

    return data;
  }

  // SAVE TOKEN
  Future<void> _saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  // SAVE USER DATA en JSON
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Convertir objet → JSON avant sauvegarder
    final String encodedData = json.encode(userData);
    await prefs.setString(_keyUser, encodedData);
  }

  // LOAD TOKEN
  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // LOAD USER DATA
  Future<Map<String, dynamic>?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString(_keyUser);

    if (userData != null) {
      // JSON → objet
      return json.decode(userData) as Map<String, dynamic>;
    }
    return null;
  }

  // VÉRIFIER SI CONNECTÉ — containsKey
  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyToken);
  }

  // DÉCONNEXION — clear(
   Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _firebaseAuth.signOut();

    // Effacer LocalStorage
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
