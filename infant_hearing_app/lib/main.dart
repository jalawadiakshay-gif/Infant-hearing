import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/app_provider.dart';
import 'core/services/tts_service.dart';
import 'core/services/notification_service.dart';
import 'core/constants/env.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/services/auth_api_service.dart';
import 'features/baby/providers/baby_provider.dart';
import 'features/baby/services/baby_api_service.dart';
import 'features/chatbot/providers/chatbot_provider.dart';
import 'features/chatbot/services/speech_service.dart';
import 'features/parent/providers/parent_provider.dart';
import 'features/parent/services/parent_api_service.dart';
import 'features/questionnaire/providers/questionnaire_provider.dart';
import 'features/questionnaire/services/questionnaire_api_service.dart';
import 'features/boa/services/boa_api_service.dart';
import 'shared/repositories/auth_repository.dart';
import 'shared/repositories/baby_repository.dart';
import 'shared/repositories/parent_repository.dart';
import 'shared/repositories/questionnaire_repository.dart';
import 'shared/repositories/boa_repository.dart';
import 'shared/services/local_storage_service.dart';
import 'app.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // ── 0. Infrastructure & Core Services ──────────────────────────────────────
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

    // ── 1. Network Layer ──────────────────────────────────────────────────────
    final apiClient = ApiClient(baseUrl: Env.baseUrl, storage: storage);

    // ── 2. API Services ───────────────────────────────────────────────────────
    final authApiService = AuthApiService(apiClient);
    final babyApiService = BabyApiService(apiClient);
    final parentApiService = ParentApiService(apiClient);
    final questionnaireApiService = QuestionnaireApiService(apiClient);
    final boaApiService = BoaApiService(apiClient);

    // ── 3. Repositories ───────────────────────────────────────────────────────
    final authRepository = AuthRepository(
      authApiService: authApiService,
      storage: storage,
    );
    final babyRepository = BabyRepository(babyApiService: babyApiService);
    final parentRepository = ParentRepository(parentApiService: parentApiService);
    final questionnaireRepository = QuestionnaireRepository(
      questionnaireApiService: questionnaireApiService,
    );
    final boaRepository = BoaRepository(boaApiService: boaApiService);

    // ── 4. Providers ──────────────────────────────────────────────────────────
    final authProvider = AuthProvider(authRepository: authRepository);
    final parentProvider = ParentProvider(parentRepository: parentRepository);
    final babyProvider = BabyProvider(babyRepository: babyRepository);
    
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

          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider.value(value: parentProvider),
          ChangeNotifierProvider.value(value: babyProvider),

          ChangeNotifierProvider(
            create: (ctx) => QuestionnaireProvider(
              questionnaireRepository: questionnaireRepository,
              storage: ctx.read<LocalStorageService>(),
            ),
          ),
          Provider<BoaRepository>.value(value: boaRepository),
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
