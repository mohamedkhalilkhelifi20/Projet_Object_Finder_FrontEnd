class DetectionModel {
  final String label; // label anglais (ex: "chair")
  final String labelTraduit; // label traduit (ex: "chaise" / "كرسي")
  final double confidence;
  final double distanceMeters;
  final String dangerLevel; // "DANGER" | "ATTENTION" | "PROCHE" | "OK"
  final String voiceMessage; // message vocal prêt à lire
  final DateTime timestamp;
  final bool synced;

  const DetectionModel({
    required this.label,
    required this.labelTraduit,
    required this.confidence,
    required this.distanceMeters,
    required this.dangerLevel,
    required this.voiceMessage,
    required this.timestamp,
    this.synced = false,
  });

  // Miroir exact du JSON retourné par yolo_service.py
  factory DetectionModel.fromJson(Map<String, dynamic> json) {
    return DetectionModel(
      label:          json['label']          as String,
      labelTraduit:   json['label_traduit']  as String,
      confidence:     (json['confidence']    as num).toDouble(),
      distanceMeters: (json['distance_meters'] as num).toDouble(),
      dangerLevel:    json['danger_level']   as String,
      voiceMessage:   json['voice_message']  as String,
      timestamp:      DateTime.now(),
      synced:         false,
    );
  }

  // ─── toMap : pour SQLite
   Map<String, dynamic> toMap() {
    return {
      'label':           label,
      'label_traduit':   labelTraduit,
      'confidence':      confidence,
      'distance_meters': distanceMeters,
      'danger_level':    dangerLevel,
      'voice_message':   voiceMessage,
      'timestamp':       timestamp.toIso8601String(),
      'synced':          synced ? 1 : 0, // SQLite stocke bool en int
    };
  }

  // ─── Factory : depuis SQLite
  factory DetectionModel.fromMap(Map<String, dynamic> map) {
    return DetectionModel(
      label:          map['label']           as String,
      labelTraduit:   map['label_traduit']   as String,
      confidence:     (map['confidence']     as num).toDouble(),
      distanceMeters: (map['distance_meters'] as num).toDouble(),
      dangerLevel:    map['danger_level']    as String,
      voiceMessage:   map['voice_message']   as String,
      timestamp:      DateTime.parse(map['timestamp'] as String),
      synced:         (map['synced'] as int) == 1,
    );
  }

  // ─── toJson : pour sync backend ──────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'label':           label,
      'label_traduit':   labelTraduit,
      'confidence':      confidence,
      'distance_meters': distanceMeters,
      'danger_level':    dangerLevel,
      'voice_message':   voiceMessage,
      'timestamp':       timestamp.toIso8601String(),
    };
  }

   // ─── copyWith : mettre à jour synced sans recréer ────────
  DetectionModel copyWith({bool? synced}) {
    return DetectionModel(
      label:          label,
      labelTraduit:   labelTraduit,
      confidence:     confidence,
      distanceMeters: distanceMeters,
      dangerLevel:    dangerLevel,
      voiceMessage:   voiceMessage,
      timestamp:      timestamp,
      synced:         synced ?? this.synced,
    );
  }

   // ─── Helper : distance formatée ──────────────────────────
  String get distanceFormatted {
    if (distanceMeters >= 99) return "loin";
    if (distanceMeters < 1)   return "${(distanceMeters * 100).round()} cm";
    return "${distanceMeters.toStringAsFixed(1)} m";
  }

  @override
  String toString() {
    return 'DetectionModel('
        'label: $label, '
        'distance: $distanceFormatted, '
        'danger: $dangerLevel)';
  }
}
