import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../models/detection_model.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../services/vibration_service.dart';
import 'camera_provider.dart';

// ─── State ───────────────────────────────────────────────
class DetectionState {
  final List<DetectionModel> detections;
  final bool isScanning;
  final bool isLoading;
  final String? error;
  final DateTime? lastScan;

  const DetectionState({
    this.detections = const [],
    this.isScanning = false,
    this.isLoading  = false,
    this.error,
    this.lastScan,
  });

  DetectionModel? get mostDangerous =>
      detections.isNotEmpty ? detections.first : null;

  DetectionState copyWith({
    List<DetectionModel>? detections,
    bool? isScanning,
    bool? isLoading,
    String? error,
    DateTime? lastScan,
  }) {
    return DetectionState(
      detections: detections ?? this.detections,
      isScanning: isScanning ?? this.isScanning,
      isLoading:  isLoading  ?? this.isLoading,
      error:      error,
      lastScan:   lastScan   ?? this.lastScan,
    );
  }
}

// ─── Notifier Riverpod 2.x ───────────────────────────────
class DetectionNotifier extends Notifier<DetectionState> {
  Timer? _scanTimer;
  String _lang = AppConstants.langFr;

  @override
  DetectionState build() => const DetectionState();

  // ─── Démarrer le scan ────────────────────────────────
  void startScanning({String lang = AppConstants.langFr}) {
    if (state.isScanning) return;
    _lang = lang;
    state = state.copyWith(isScanning: true);

    _scanTimer = Timer.periodic(
      Duration(milliseconds: AppConstants.scanIntervalMs),
      (_) => _scan(),
    );
  }

  // ─── Arrêter le scan ─────────────────────────────────
  void stopScanning() {
    _scanTimer?.cancel();
    _scanTimer = null;
    TtsService.instance.stop();
    VibrationService.instance.stop();
    state = state.copyWith(isScanning: false);
  }

  // ─── Un cycle de scan ────────────────────────────────
  Future<void> _scan() async {
    if (state.isLoading) return;

    // Lire l'état caméra
    final cameraState = ref.read(cameraProvider);
    if (!cameraState.isInitialized) return;

    final frame = await ref
        .read(cameraProvider.notifier)
        .captureFrame();

    if (frame == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final bytes      = await File(frame.path).readAsBytes();
      final detections = await ApiService.instance.detect(
        imageBytes: bytes,
        lang:       _lang,
      );

      state = state.copyWith(
        isLoading:  false,
        detections: detections,
        lastScan:   DateTime.now(),
        error:      null,
      );

      if (detections.isNotEmpty) {
        final top = detections.first;
        await VibrationService.instance.vibrateForDanger(top.dangerLevel);
        await TtsService.instance.speakDetection(
          voiceMessage: top.voiceMessage,
          dangerLevel:  top.dangerLevel,
        );
      }

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:     e.toString(),
      );
    }
  }

  // ─── Changer langue ──────────────────────────────────
  Future<void> setLang(String lang) async {
    _lang = lang;
    await TtsService.instance.setLanguage(lang);
  }

  // ─── Dispose ─────────────────────────────────────────
  void cancel() {
    _scanTimer?.cancel();
  }
}

// ─── Provider Riverpod 2.x ───────────────────────────────
final detectionProvider =
    NotifierProvider<DetectionNotifier, DetectionState>(
  DetectionNotifier.new,
);