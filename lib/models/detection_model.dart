class DetectionModel {
  final int? id;
  final String label; // label anglais (ex: "chair")
  final String labelTraduit; // label traduit (ex: "chaise" / "كرسي")
  final double confidence;
  final double distanceMeters;
  final String dangerLevel; // "DANGER" | "ATTENTION" | "PROCHE" | "OK"
  final String voiceMessage; // message vocal prêt à lire
  final DateTime timestamp;
  final bool synced;

  const DetectionModel({
    this.id,
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
      id:             json['id']              as int?,
      label:          json['label']           as String? ?? '',
      labelTraduit:   json['label_fr']        as String? ?? '', // label_fr
      confidence:     (json['confidence']     as num?)?.toDouble() ?? 0.0,
      distanceMeters: (json['distance_meters'] as num?)?.toDouble() ?? 0.0,
      dangerLevel:    json['danger_level']    as String? ?? 'OK',
      voiceMessage:   json['voice_message']   as String? ?? '',
      timestamp:      json['detected_at'] != null 
          ? DateTime.parse(json['detected_at'] as String)
          : DateTime.now(),
      synced: false,
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
      label:          map['label']            as String? ?? '',
      labelTraduit:   map['label_traduit']    as String? ?? '',
      confidence:     (map['confidence']      as num?)?.toDouble() ?? 0.0,
      distanceMeters: (map['distance_meters'] as num?)?.toDouble() ?? 0.0,
      dangerLevel:    map['danger_level']     as String? ?? 'OK',
      voiceMessage:   map['voice_message']    as String? ?? '',
      timestamp:      DateTime.parse(map['timestamp'] as String),
      synced:         (map['synced'] as int?) == 1,
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
