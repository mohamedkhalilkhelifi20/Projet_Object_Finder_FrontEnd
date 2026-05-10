import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/constants.dart';
import '../../../core/errors.dart';
import '../../../widgets/danger_badge.dart';
import '../../../widgets/loading_overlay.dart';
import '../providers/camera_provider.dart';
import '../providers/detection_provider.dart';
import '../../../widgets/app_drawer.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToHistory;

  const ScannerScreen({super.key, this.onNavigateToHistory});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with AutomaticKeepAliveClientMixin {
  //Garde la caméra active dans IndexedStack
  // ─── Garde la page en mémoire dans IndexedStack

  @override
  bool get wantKeepAlive => true;

  String _selectedLang = AppConstants.langFr;

  @override
  void initState() {
    super.initState();
    // Initialiser caméra après le premier build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cameraProvider.notifier).initializeCamera();
    });
  }

  @override
  void dispose() {
    ref.read(detectionProvider.notifier).stopScanning();
    ref.read(cameraProvider.notifier).disposeCamera();
    super.dispose();
  }

  // ─── Toggle scan ─────────────────────────────────────────
  void _toggleScan() {
    final isScanning = ref.read(detectionProvider).isScanning;
    if (isScanning) {
      ref.read(detectionProvider.notifier).stopScanning();
    } else {
      ref.read(detectionProvider.notifier).startScanning(lang: _selectedLang);
    }
  }

  // ─── Changer langue ──────────────────────────────────────
  void _toggleLang() {
    setState(() {
      _selectedLang = _selectedLang == AppConstants.langFr
          ? AppConstants.langTn
          : AppConstants.langFr;
    });
    ref.read(detectionProvider.notifier).setLang(_selectedLang);
    showSuccessSnackBar(
      context,
      _selectedLang == AppConstants.langFr
          ? "Langue : Français"
          : "اللغة : تونسي",
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // obligatoire avec AutomaticKeepAliveClientMixin

    final cameraState = ref.watch(cameraProvider);
    final detectionState = ref.watch(detectionProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      // ─── AppBar ──────────────────────────────────────────
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.remove_red_eye_rounded, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text("Object Finder"),
          ],
        ),
        actions: [
          // Bouton langue FR ↔ TN
          Semantics(
            label: "Changer la langue",
            button: true,
            child: TextButton(
              onPressed: _toggleLang,
              child: Text(
                _selectedLang == AppConstants.langFr ? "TN" : "FR",
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),

      // ─── Drawer ──────────────────────────────────────────
      drawer: AppDrawer(
        selectedLang:        _selectedLang,
        onToggleLang:        _toggleLang,
        onNavigateToHistory: widget.onNavigateToHistory,
      ),
      // ─── Body ────────────────────────────────────────────
      body: LoadingOverlay(
        isLoading: !cameraState.isInitialized && cameraState.error == null,
        message: "Initialisation caméra...",
        child: _buildBody(cameraState, detectionState),
      ),
    );
  }

  // ─── Body
  Widget _buildBody(CameraState camera, DetectionState detection) {
    if (camera.error != null) return _buildError(camera.error!);

    return Stack(
      children: [
        // ─── Vue caméra plein écran ───────────────────────
        if (camera.isInitialized && camera.controller != null)
          Positioned.fill(child: CameraPreview(camera.controller!))
        else
          const Positioned.fill(child: ColoredBox(color: Colors.black)),

        // ─── Overlay détection
        if (detection.detections.isNotEmpty)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildDetectionOverlay(detection),
          ),

        // ─── Indicateur chargement API ─
        if (detection.isLoading)
          const Positioned(
            top: 16,
            right: 16,
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
                strokeWidth: 2,
              ),
            ),
          ),

        // ─── Erreur API
        if (detection.error != null)
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red),
              ),
              child: Text(
                detection.error!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        // ─── Bouton scan ──────────────────────────────────
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: _buildScanButton(camera, detection),
        ),
      ],
    );
  }

  // ─── Overlay détection ───────────────────────────────────
  Widget _buildDetectionOverlay(DetectionState detection) {
    final top = detection.mostDangerous!;
    final color = AppTheme.dangerLevelColor(top.dangerLevel);

    return Semantics(
      label: top.voiceMessage,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(178),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Label + Badge ────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    top.labelTraduit,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                DangerBadge(dangerLevel: top.dangerLevel, large: true),
              ],
            ),

            const SizedBox(height: 8),

            // ─── Distance + Confiance ─────────────────────
            Row(
              children: [
                const Icon(
                  Icons.straighten_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  top.distanceFormatted,
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.psychology_rounded,
                  color: Colors.white54,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  "${(top.confidence * 100).round()}%",
                  style: const TextStyle(fontSize: 16, color: Colors.white54),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ─── Message vocal ────────────────────────────
            Row(
              children: [
                Icon(Icons.volume_up_rounded, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    top.voiceMessage,
                    style: TextStyle(
                      fontSize: 15,
                      color: color,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),

            // ─── Autres détections ────────────────────────
            if (detection.detections.length > 1) ...[
              const SizedBox(height: 8),
              const Divider(color: Colors.white24),
              Text(
                "${detection.detections.length - 1} autre(s) objet(s)",
                style: const TextStyle(fontSize: 13, color: Colors.white38),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Bouton scan ─────────────────────────────────────────
  Widget _buildScanButton(CameraState camera, DetectionState detection) {
    final isScanning = detection.isScanning;

    return Center(
      child: Semantics(
        label:  isScanning ? "Arrêter le scan" : "Démarrer le scan",
        button: true,

        child: GestureDetector(
          onTap:  camera.isInitialized ? _toggleScan : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width:  80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isScanning
                  ? AppTheme.dangerColor
                  : AppTheme.primaryColor,
              boxShadow:[
                BoxShadow(
                  color: isScanning
                      ? AppTheme.dangerColor.withAlpha(100)
                      : AppTheme.primaryColor.withAlpha(100),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              isScanning ? Icons.stop_rounded : Icons.play_arrow_rounded,
              color: Colors.black,
              size: 40,
            ),
          ),
        ),
      )
    );
  }

  
  // ─── Erreur caméra ───────────────────────────────────────
  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_rounded,
                color: AppTheme.dangerColor, size: 64),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  ref.read(cameraProvider.notifier).initializeCamera(),
              child: const Text("Réessayer"),
            ),
          ],
        ),
      ),
    );
  }
}
