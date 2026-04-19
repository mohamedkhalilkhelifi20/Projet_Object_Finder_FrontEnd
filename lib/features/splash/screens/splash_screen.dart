import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double>    _fadeAnim;
  late Animation<double>    _scaleAnim;

  @override
  void initState() {
    super.initState();

    // ─── Animations ──────────────────────────────────
    _controller = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // Lancer l'animation
    _controller.forward();

    // ─── Navigation après 2.5s ───────────────────────
    Future.delayed(const Duration(milliseconds: 2500), () {
      _navigate();
    });
  }

  void _navigate() {
    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (authState.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/scanner');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // ─── Logo animé ──────────────────────
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width:        120,
                  height:       120,
                  decoration:   BoxDecoration(
                    color:        Colors.white10,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white24,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.visibility,
                    size:  60,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ─── Titre ───────────────────────────
              const Text(
                'Object Finder',
                style: TextStyle(
                  color:         Colors.white,
                  fontSize:      32,
                  fontWeight:    FontWeight.bold,
                  letterSpacing: 2,
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
              ),

              const SizedBox(height: 48),

              // ─── Loading ─────────────────────────
              const SizedBox(
                width:  40,
                height: 40,
                child:  CircularProgressIndicator(
                  color:       Colors.white,
                  strokeWidth: 2,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Chargement...',
                style: TextStyle(
                  color:    Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}