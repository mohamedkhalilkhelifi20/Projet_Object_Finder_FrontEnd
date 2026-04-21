import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'firebase_options.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/scanner/screens/scanner_screen.dart';
import 'features/scanner/services/tts_service.dart';
import 'features/history/screens/history_screen.dart';
import 'features/splash/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/history/providers/history_provider.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize(
    serverClientId: AppConstants.googleWebClientId,
  );
  await TtsService.instance.init();
  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: ObjectFinderApp(),
    ),
  );
}

class ObjectFinderApp extends ConsumerWidget {
  const ObjectFinderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title:                      'Object Finder',
      debugShowCheckedModeBanner: false,
      theme:                      AppTheme.darkTheme,
      // ─── Guard navigation
      home: authState.isAuthenticated
          ? const MainScreen()
          : const SplashScreen(),
      routes: {
        '/login':  (_) => const LoginScreen(),
        '/main':   (_) => const MainScreen(),
        '/splash': (_) => const SplashScreen(),
      },
    );
  }
}

// ─── MainScreen avec IndexedStack ────────────────────────
// IndexedStack garde la caméra active quand on switch d'onglet
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  // Les écrans restent en mémoire grâce à IndexedStack
  final List<Widget> _screens = const [
    ScannerScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index:    _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          // Recharger l'historique quand on arrive dessus
          if (index == 1) {
            ref.read(historyProvider.notifier).loadHistory();
          }
        },
        destinations: const [
          NavigationDestination(
            icon:          Icon(Icons.camera_alt_outlined),
            selectedIcon:  Icon(Icons.camera_alt_rounded),
            label:         'Scanner',
          ),
          NavigationDestination(
            icon:          Icon(Icons.history_outlined),
            selectedIcon:  Icon(Icons.history_rounded),
            label:         'Historique',
          ),
        ],
      ),
    );
  }
}