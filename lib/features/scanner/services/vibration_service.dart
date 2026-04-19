import 'package:vibration/vibration.dart';

class VibrationService {
  // ─── Singleton
  VibrationService._();
  static final VibrationService instance = VibrationService._();

  bool? _hasVibrator;

  // ─── Vérifier si le téléphone supporte la vibration
  Future<bool> _canVibrate() async {
    _hasVibrator ??= (await Vibration.hasVibrator()) == true;
    return _hasVibrator!;
  }

  // ─── Vibrer selon danger
  Future<void> vibrateForDanger(String dangerLevel) async {
    if (!await _canVibrate()) return;

    switch (dangerLevel) {
      case 'Danger':
         await Vibration.vibrate(
          pattern:     [0, 300, 100, 300, 100, 300],
          intensities: [0, 255, 0,   255, 0,   255],
        );
        break;
      case 'ATTENTION':
        await Vibration.vibrate(
          pattern:     [0, 200, 150, 200],
          intensities: [0, 180, 0,   180],
        );
        break;
      case 'PROCHE':
        // 1 vibration douce
        await Vibration.vibrate(
          duration:  150,
          amplitude: 100,
        );
        break;

      case 'OK':

      default:
        // Pas de vibration
        break;
    }
  }

  // ─── Vibration de confirmation
  Future<void> vibrateSuccess() async {
    if (!await _canVibrate()) return;
    await Vibration.vibrate(duration: 100, amplitude: 128);
  }

  // ─── Stop ────────────────────────────────────────────────
  Future<void> stop() async {
    if (await _canVibrate()) {
      await Vibration.cancel();
    }
  }
}
