import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraState {
  final CameraController? controller;
  final bool isInitialized;
  final String? error;

  const CameraState({this.controller, this.isInitialized = false, this.error});

  CameraState copyWith({
    CameraController? controller,
    bool? isInitialized,
    String? error,
  }) {
    return CameraState(
      controller: controller ?? this.controller,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error,
    );
  }
}

class CameraNotifier extends Notifier<CameraState> {
  @override
  CameraState build() => const CameraState();

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        state = state.copyWith(error: "Aucune caméra disponible");
        return;
      }

      // Prendre la caméra arrière
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

       // Créer le controller
      final controller = CameraController(
        camera,
        ResolutionPreset.medium, // medium = bon compromis qualité/perf
        enableAudio: false,      // pas besoin du micro
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      state = CameraState(
        controller:    controller,
        isInitialized: true,
      );

    } catch (e) {
      state = state.copyWith(error: "Erreur d'initialisation de la caméra");
    }
  }

   // ─── Capturer un frame ───────────────────────────────
  Future<XFile?> captureFrame() async {
    if (!state.isInitialized || state.controller == null) return null;
    try {
      return await state.controller!.takePicture();
    } catch (_) {
      return null;
    }
  }

 void disposeCamera() {
    state.controller?.dispose();
  }
}

final cameraProvider = NotifierProvider<CameraNotifier, CameraState>(
  CameraNotifier.new,
);
