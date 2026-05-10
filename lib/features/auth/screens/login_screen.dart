import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Erreur → Snackbar
    if (authState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:         Text(authState.error!),
            backgroundColor: Colors.red,
            behavior:        SnackBarBehavior.floating,
            duration:        const Duration(seconds: 3),
          ),
        );
      });
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // ─── Logo ────────────────────────────
              Container(
                width:        100,
                height:       100,
                decoration:   BoxDecoration(
                  color:        Colors.white10,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: const Icon(
                  Icons.visibility,
                  size:  50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // ─── Titre ───────────────────────────
              const Text(
                'Object Finder',
                style: TextStyle(
                  color:         Colors.white,
                  fontSize:      30,
                  fontWeight:    FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 8),

              // ─── Sous-titre ──────────────────────
              const Text(
                'Assistant pour malvoyants',
                style: TextStyle(
                  color:    Colors.grey,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 64),

              // ─── Bouton Google SSO ────────────────
              authState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : SizedBox(
                      width:  double.infinity,
                      height: 56,
                      child:  ElevatedButton.icon(
                        onPressed: () => ref
                            .read(authProvider.notifier)
                            .signInWithGoogle(),
                        icon:  Image.network(
                          'https://www.google.com/favicon.ico',
                          height: 24,
                          width:  24,
                        ),
                        label: const Text(
                          'Se connecter avec Google',
                          style: TextStyle(
                            fontSize:   16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          shape:           RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),

              const SizedBox(height: 24),

              // ─── Message accessibilité ────────────
              const Text(
                'Application conçue pour les personnes malvoyantes',
                style: TextStyle(
                  color:    Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}