// lib/models/user_model.dart

class UserModel {
  final String id;
  final String email;
  final String token;          // JWT access token
  final String? refreshToken;  // JWT refresh token
  final String? firstName;
  final String? lastName;
  final String lang;           // "fr" | "tn" — langue préférée
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  const UserModel({
    required this.id,
    required this.email,
    required this.token,
    this.refreshToken,
    this.firstName,
    this.lastName,
    this.lang = "fr",
    this.isActive = true,
    this.createdAt,
    this.lastLogin,
  });

  // ─── Nom complet ─────────────────────────────────────────
  String get fullName {
    if (firstName != null && lastName != null) {
      return "$firstName $lastName";
    }
    if (firstName != null) return firstName!;
    // fallback → partie avant @ de l'email
    return email.split('@').first;
  }

  // ─── Initiales pour avatar ───────────────────────────────
  String get initials {
    if (firstName != null && lastName != null) {
      return "${firstName![0]}${lastName![0]}".toUpperCase();
    }
    return email.substring(0, 2).toUpperCase();
  }

  // ─── Factory : depuis JSON backend /login ────────────────
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:           json['id']?.toString()          ?? '',
      email:        json['email']                   as String,
      token:        json['access_token']            as String,
      refreshToken: json['refresh_token']           as String?,
      firstName:    json['first_name']              as String?,
      lastName:     json['last_name']               as String?,
      lang:         json['lang']                    as String? ?? 'fr',
      isActive:     json['is_active']               as bool?   ?? true,
      createdAt:    json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      lastLogin:    json['last_login'] != null
          ? DateTime.tryParse(json['last_login'] as String)
          : null,
    );
  }

  // ─── toJson : sérialisation complète ─────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id':            id,
      'email':         email,
      'access_token':  token,
      if (refreshToken != null) 'refresh_token': refreshToken,
      if (firstName != null)    'first_name':    firstName,
      if (lastName != null)     'last_name':     lastName,
      'lang':          lang,
      'is_active':     isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (lastLogin != null) 'last_login':  lastLogin!.toIso8601String(),
    };
  }

  // ─── toMap : pour SharedPreferences (stockage local) ─────
  // On ne stocke PAS le token ici — il a sa propre clé sécurisée
  Map<String, dynamic> toPrefsMap() {
    return {
      'id':         id,
      'email':      email,
      'first_name': firstName ?? '',
      'last_name':  lastName  ?? '',
      'lang':       lang,
    };
  }

  // ─── Factory : depuis SharedPreferences ──────────────────
  factory UserModel.fromPrefsMap(Map<String, dynamic> map, String token) {
    return UserModel(
      id:         map['id']         as String? ?? '',
      email:      map['email']      as String,
      token:      token,
      firstName:  map['first_name'] as String?,
      lastName:   map['last_name']  as String?,
      lang:       map['lang']       as String? ?? 'fr',
    );
  }

  // ─── copyWith ────────────────────────────────────────────
  UserModel copyWith({
    String?   id,
    String?   email,
    String?   token,
    String?   refreshToken,
    String?   firstName,
    String?   lastName,
    String?   lang,
    bool?     isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id:           id           ?? this.id,
      email:        email        ?? this.email,
      token:        token        ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      firstName:    firstName    ?? this.firstName,
      lastName:     lastName     ?? this.lastName,
      lang:         lang         ?? this.lang,
      isActive:     isActive     ?? this.isActive,
      createdAt:    createdAt    ?? this.createdAt,
      lastLogin:    lastLogin    ?? this.lastLogin,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, email: $email, lang: $lang)';
}