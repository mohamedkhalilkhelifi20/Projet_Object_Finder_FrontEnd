import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../features/auth/providers/auth_provider.dart';
import '../main.dart';

class AppDrawer extends ConsumerWidget {
  final String selectedLang;
  final VoidCallback onToggleLang;
  final VoidCallback? onNavigateToHistory;

  const AppDrawer({
    super.key,
    required this.selectedLang,
    required this.onToggleLang,
    this.onNavigateToHistory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Drawer(
      backgroundColor: AppTheme.surfaceColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ─── Header ──────────────────────────────────
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.bgColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.remove_red_eye_rounded,
                  color: AppTheme.primaryColor,
                  size: 48,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Object Finder",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  authState.userEmail ?? "Assistance malvoyants",
                  style: TextStyle(
                    color: Colors.white.withAlpha(153),
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // ─── Scanner ─────────────────────────────────
          ListTile(
            leading: const Icon(
              Icons.camera_alt_rounded,
              color: AppTheme.primaryColor,
            ),
            title: const Text("Scanner", style: TextStyle(color: Colors.white)),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),

          // ─── Historique ───────────────────────────────
          ListTile(
            leading: const Icon(Icons.history_rounded, color: Colors.white54),
            title: const Text(
              "Historique",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              onNavigateToHistory?.call();
            },
          ),

          const Divider(color: Colors.white12),

          // ─── Langue ───────────────────────────────────
          ListTile(
            leading: const Icon(Icons.language_rounded, color: Colors.white54),
            title: const Text("Langue", style: TextStyle(color: Colors.white)),
            trailing: Text(
              selectedLang == AppConstants.langFr ? "FR" : "TN",
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              onToggleLang();
            },
          ),

          const Divider(color: Colors.white12),

          // ─── Logout ───────────────────────────────────
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text(
              "Déconnexion",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              _confirmLogout(context, ref);
            },
          ),
        ],
      ),
    );
  }

  // ─── Dialog confirmation logout
Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.logout_rounded, color: Colors.orange, size: 24),
          SizedBox(width: 8),
          Text("Déconnexion", style: TextStyle(color: Colors.white)),
        ],
      ),
      content: const Text(
        "Voulez-vous vous déconnecter ?",
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white38),
          ),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text("Déconnecter"),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    // ─── Fermer le drawer puis signOut
    if (context.mounted) Navigator.pop(context);
    await ref.read(authProvider.notifier).signOut();
    // Le guard main.dart → LoginScreen automatiquement
  }
}
}
