import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'features/scanner/screens/scanner_screen.dart';
import 'features/scanner/services/tts_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await GoogleSignIn.instance.initialize();

  // Initialiser TTS au démarrage
  await TtsService.instance.init();
  

  runApp(
    const ProviderScope(  // pour Riverpod
      child: ObjectFinderApp(),
    ),
  );
}

class ObjectFinderApp extends StatelessWidget {
  const ObjectFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:            'Object Finder',
      debugShowCheckedModeBanner: false,
      theme:            AppTheme.darkTheme,
      home:             const ScannerScreen(),
    );
  }
}