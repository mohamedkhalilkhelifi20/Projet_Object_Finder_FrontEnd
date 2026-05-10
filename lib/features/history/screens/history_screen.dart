import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../widgets/detection_card.dart';
import '../../../widgets/loading_overlay.dart';
import '../providers/history_provider.dart';


class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final historyState = ref.watch(historyProvider);

    // ─── Snackbar sync/erreur
    ref.listen<HistoryState>(historyProvider, (_, next) {
      if (next.syncMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.syncMessage!),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.history_rounded, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text("Historique"),
          ],
        ),
        actions: [
         
          // ─── Bouton vider
          if (historyState.detections.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: "Vider l'historique",
              onPressed: () => _confirmClear(context),
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: historyState.isLoading,
        message: "Chargement...",
        child: _buildBody(historyState),
      ),
    );
  }

  // ─── Body
  Widget _buildBody(HistoryState state) {
    if (state.detections.isEmpty) return _buildEmpty();

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: () => ref.read(historyProvider.notifier).loadHistory(),
      child: ListView.builder(
        itemBuilder: (_, index) => DetectionCard(
          detection: state.detections[index],
          showTimestamp: true,
        ),
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: state.detections.length,
      ),
    );
  }

  // ─── État vide
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 72,
            color: Colors.white.withAlpha(51),
          ),
          const SizedBox(height: 16),
          const Text(
            "Aucune détection enregistrée",
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            "Lance le scanner pour commencer",
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ─── Confirmer suppression
  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text("Vider l'historique", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          "Toutes les détections locales seront supprimées définitivement.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          // ─── Annuler
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white38),
            ),
            child: const Text("Annuler"),
          ),
          // ─── Supprimer
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Supprimer"),
          ),
       ],
      ),
    );
    if (confirmed == true) {
      ref.read(historyProvider.notifier).clearHistory();
    }
  }
}
