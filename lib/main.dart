import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/scanner/screens/scanner_screen.dart';
import 'features/scanner/services/tts_service.dart';
//import 'features/history/screens/history_screen.dart';
import 'features/splash/splash_screen.dart';
import "core/constants.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {

  // 1. Flutter binding
  final binding = WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env"); 

   // 2. Garder splash natif visible
  FlutterNativeSplash.preserve(widgetsBinding: binding);

   // 3. Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 4. Google Sign In init
  await GoogleSignIn.instance.initialize(
  serverClientId: AppConstants.googleWebClientId,
);

  // 5. Initialiser TTS au démarrage
  await TtsService.instance.init();

  // 6. Supprimer splash natif
  FlutterNativeSplash.remove();
  

  runApp(
    const ProviderScope(  // pour Riverpod
      child: ObjectFinderApp(),
    ),
  );
}

class ObjectFinderApp extends ConsumerWidget  {
  const ObjectFinderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title:                      'Object Finder 👁️',
      debugShowCheckedModeBanner: false,
      theme:                      AppTheme.darkTheme,
      home:                       const SplashScreen(),
      routes: {
        '/login':   (_) => const LoginScreen(),
        '/scanner': (_) => const ScannerScreen(),
        //'/history': (_) => const HistoryScreen(),
      },
    );
  }
}