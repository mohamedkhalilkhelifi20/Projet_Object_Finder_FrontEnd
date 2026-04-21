import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/detection_model.dart';
import '../../../core/sqlite_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../scanner/services/api_service.dart';

class HistoryState {
  final List<DetectionModel> detections;
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final String? syncMessage;

  const HistoryState({
    this.detections = const [],
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
    this.syncMessage,
  });

  HistoryState copyWith({
    List<DetectionModel>? detections,
    bool? isLoading,
    bool? isSyncing,
    String? error,
    String? syncMessage,
  }) {
    return HistoryState(
      detections: detections ?? this.detections,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error,
      syncMessage: syncMessage,
    );
  }
}

// ─── Notifier
class HistoryNotifier extends Notifier<HistoryState> {
  @override
  HistoryState build() {
    loadHistory();
    return const HistoryState();
  }

  // ─── Lire depuis SQLite
  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final detections = await SqliteService.instance.getAllDetections();
      state = state.copyWith(isLoading: false, detections: detections);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ─── Sync vers backend
  Future<void> syncToBackend() async {
    final token = ref.read(authProvider).token;
    if (token == null) {
      state = state.copyWith(error: "Non connecté");
      return;
    }

    state = state.copyWith(isSyncing: true);

    try {
      final unsynced = await SqliteService.instance.getUnsyncedDetections();

      if (unsynced.isEmpty) {
        state = state.copyWith(
          isSyncing: false,
          syncMessage: "Tout est déjà synchronisé",
        );
        return;
      }

      final success = await ApiService.instance.syncHistory(
        detections: unsynced.map((d) => d.toJson()).toList(),
        token: token,
      );

      if (success) {
        // Marquer chaque détection comme synced
        for (int i = 0; i < unsynced.length; i++) {
          await SqliteService.instance.markAsSynced(i + 1);
        }

        await loadHistory(); // Recharger pour mettre à jour l'état
        state = state.copyWith(
          isSyncing: false,
          syncMessage: "${unsynced.length} détection(s) synchronisée(s)",
        );
      }else {
        state = state.copyWith(
          isSyncing: false,
          error:     "Erreur de synchronisation",
        );
      }
    } catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString());
    }
  }

  // ─── Vider l'historique
  Future<void> clearHistory() async {
    await SqliteService.instance.clearAll();
    state = state.copyWith(detections: []);
  }
}

// ─── Provider
final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(
  HistoryNotifier.new,
);
