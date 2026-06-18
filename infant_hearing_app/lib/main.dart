import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/app_provider.dart';
import 'core/services/tts_service.dart';
import 'core/services/notification_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/baby/providers/baby_provider.dart';
import 'features/chatbot/providers/chatbot_provider.dart';
import 'features/chatbot/services/speech_service.dart';
import 'features/parent/providers/parent_provider.dart';
import 'features/questionnaire/providers/questionnaire_provider.dart';
import 'features/asha/providers/asha_provider.dart';
import 'features/boa/presentation/controllers/boa_controller.dart';
import 'shared/services/local_storage_service.dart';
import 'data/services/v2/app_firestore_service.dart';
import 'app.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // ── 0. Firebase Initialization ─────────────────────────────────────────
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Enable Firestore offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // ── 1. Infrastructure & Core Services ──────────────────────────────────
    await NotificationService.instance.initialize();

    final storage = LocalStorageService();
    await storage.initialize();

    final langProvider = LanguageProvider();
    await langProvider.initialize();

    final tts = TtsService();
    await tts.initialize();
    try {
      await tts.setLanguage(langProvider.ttsLocale);
    } catch (e) {
      debugPrint('Main: TTS Language set error: $e');
    }

    final speech = SpeechService();
    try {
      await speech.initialize();
    } catch (e) {
      debugPrint('Main: Speech initialization error: $e');
    }

    // ── 2. Firebase Services (V2 Architecture) ────────────────────────────
    final appFirestoreService = AppFirestoreService();

    // ── 3. Providers ──────────────────────────────────────────────────────
    final authProvider = AuthProvider(firestoreService: appFirestoreService);
    final parentProvider = ParentProvider(firestoreService: appFirestoreService);
    final babyProvider = BabyProvider(firestoreService: appFirestoreService);

    // ASHA provider
    final ashaProvider = AshaProvider(
      firestoreService: appFirestoreService,
    );

    final appProvider = AppProvider(
      authProvider: authProvider,
      parentProvider: parentProvider,
      babyProvider: babyProvider,
    );

    // Initialize App Data (Fetches profile/babies if logged in)
    // Wrap in try-catch to ensure app starts even if API fails
    try {
      await appProvider.initializeApp();
    } catch (e) {
      debugPrint('Main: App initialization error: $e');
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: langProvider),
          ChangeNotifierProvider.value(value: tts),
          ChangeNotifierProvider.value(value: speech),
          ChangeNotifierProvider.value(value: storage),
          ChangeNotifierProvider.value(value: appProvider),
          ChangeNotifierProvider.value(value: ashaProvider),

          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider.value(value: parentProvider),
          ChangeNotifierProvider.value(value: babyProvider),

          ChangeNotifierProvider(
            create: (ctx) => QuestionnaireProvider(
              firestoreService: appFirestoreService,
              storage: ctx.read<LocalStorageService>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (ctx) => BoaController(
              firestoreService: appFirestoreService,
              ttsService: tts,
            )..initialize(),
          ),
          ChangeNotifierProvider(create: (_) => ChatbotProvider()),
        ],
        child: const InfantHearingApp(),
      ),
    );
  } catch (e, stack) {
    debugPrint('FATAL ERROR in main(): $e');
    debugPrint(stack.toString());
    
    // Minimal fallback app if everything fails
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text('Fatal Error: $e')))));
  }
}
