import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/core/providers/language_provider.dart';
import 'package:infant_hearing_app/core/theme/app_theme.dart';
import 'package:infant_hearing_app/features/auth/providers/auth_provider.dart';
import 'package:infant_hearing_app/features/auth/screens/phone_login_screen.dart';
import 'package:infant_hearing_app/features/auth/screens/register_screen.dart';
import 'package:infant_hearing_app/features/auth/screens/otp_verification_screen.dart';
import 'package:infant_hearing_app/features/auth/screens/role_selection_screen.dart';
import 'package:infant_hearing_app/features/auth/screens/language_selection_screen.dart';
import 'package:infant_hearing_app/features/baby/providers/baby_provider.dart';
import 'package:infant_hearing_app/features/baby/screens/baby_profile_screen.dart';
import 'package:infant_hearing_app/features/baby/screens/child_detail_screen.dart';
import 'package:infant_hearing_app/features/chatbot/screens/chatbot_screen.dart';
import 'package:infant_hearing_app/features/home/screens/home_screen.dart';
import 'package:infant_hearing_app/features/home/screens/main_layout_screen.dart';
import 'package:infant_hearing_app/features/parent/providers/parent_provider.dart';
import 'package:infant_hearing_app/features/parent/screens/parent_profile_screen.dart';
import 'package:infant_hearing_app/features/questionnaire/screens/questionnaire_screen.dart';
import 'package:infant_hearing_app/features/questionnaire/screens/questionnaire_result_screen.dart';
import 'package:infant_hearing_app/features/settings/screens/settings_screen.dart';
import 'package:infant_hearing_app/features/profile/screens/profile_screen.dart';
import 'package:infant_hearing_app/core/providers/app_provider.dart';
import 'package:infant_hearing_app/core/services/tts_service.dart';
import 'package:infant_hearing_app/features/history/screens/history_screen.dart';
import 'package:infant_hearing_app/features/home/screens/medical_insights_screen.dart';
import 'package:infant_hearing_app/shared/repositories/boa_repository.dart';

// ── BOA Module imports ───────────────────────────────────────────────────────
import 'package:infant_hearing_app/features/boa/presentation/pages/boa_intro_screen.dart';
import 'package:infant_hearing_app/features/boa/presentation/pages/boa_checklist_screen.dart';
import 'package:infant_hearing_app/features/boa/presentation/pages/boa_test_screen.dart';
import 'package:infant_hearing_app/features/boa/presentation/pages/boa_result_screen.dart';
import 'package:infant_hearing_app/features/boa/presentation/controllers/boa_controller.dart';
import 'package:infant_hearing_app/features/boa/presentation/controllers/boa_checklist_controller.dart';

class InfantHearingApp extends StatelessWidget {
  const InfantHearingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) {
        return MultiProvider(
          // BOA controllers scoped inside the app so they survive navigation
          // but are separate from the root provider tree.
          providers: [
            ChangeNotifierProvider(
              create: (ctx) => BoaController(
                boaRepository: ctx.read<BoaRepository>(),
                ttsService: ctx.read<TtsService>(),
              )..initialize(),
            ),
            ChangeNotifierProvider(create: (_) => BoaChecklistController()),
          ],
          child: MaterialApp(
            title: 'Baalshravya',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: langProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const _RootNavigator(),
            onGenerateRoute: (settings) {
              final routes = {
                // ── Existing routes ──────────────────────────────────────
                RouteConstants.phoneLogin:
                    (_) => const PhoneLoginScreen(),
                RouteConstants.register:
                    (_) => const RegisterScreen(),
                RouteConstants.otpVerification:
                    (_) => const OtpVerificationScreen(),
                RouteConstants.roleSelection:
                    (_) => const RoleSelectionScreen(),
                RouteConstants.parentProfile:
                    (_) => const ParentProfileScreen(),
                RouteConstants.babyProfile:
                    (_) => const BabyProfileScreen(),
                RouteConstants.home:
                    (_) => const HomeScreen(),
                RouteConstants.mainLayout:
                    (_) => const MainLayoutScreen(),
                RouteConstants.profile:
                    (_) => const ProfileScreen(),
                RouteConstants.chatbot:
                    (_) => const ChatbotScreen(),
                RouteConstants.settings:
                    (_) => const SettingsScreen(),
                RouteConstants.history:
                    (_) => const HistoryScreen(),
                RouteConstants.medicalInsights:
                    (_) => const MedicalInsightsScreen(),
                RouteConstants.questionnaire:
                    (_) => const QuestionnaireScreen(),
                RouteConstants.questionnaireResult:
                    (_) => const QuestionnaireResultScreen(),
                RouteConstants.childDetail:
                    (_) => const ChildDetailScreen(),

                // ── BOA routes ───────────────────────────────────────────
                RouteConstants.boaIntro:
                    (_) => const BoaIntroScreen(),
                RouteConstants.boaChecklist:
                    (_) => const BoaChecklistScreen(),
                RouteConstants.boaResult:
                    (_) => const BoaResultScreen(),
              };

              // BOA test screen is handled separately since BoaController
              // must already be initialised before entering it.
              if (settings.name == RouteConstants.boaTest ||
                  settings.name == '/boa-test-screen') {
                return MaterialPageRoute(
                    builder: (_) => const BoaTestScreen(),
                    settings: settings);
              }

              final builder = routes[settings.name];
              if (builder != null) {
                return MaterialPageRoute(
                    builder: builder, settings: settings);
              }
              return null;
            },
          ),
        );
      },
    );
  }
}

class _RootNavigator extends StatelessWidget {
  const _RootNavigator();

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    return Consumer4<AppProvider, AuthProvider, ParentProvider, BabyProvider>(
      builder: (context, app, auth, parent, baby, _) {
        debugPrint('RootNavigator: isInitialized=${app.isInitialized}, isAuthenticated=${auth.isAuthenticated}, hasParent=${parent.hasParentData}');

        if (!app.isInitialized || !langProvider.initialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (langProvider.isFirstRun) return const LanguageSelectionScreen(key: ValueKey('lang_select'));
        if (!auth.isAuthenticated) return const PhoneLoginScreen(key: ValueKey('login'));
        if (!parent.hasParentData) return const ParentProfileScreen(key: ValueKey('parent_profile'));
        if (!baby.hasChildren) return const BabyProfileScreen(key: ValueKey('baby_profile'));

        return const MainLayoutScreen(key: ValueKey('main_layout'));
      },
    );
  }
}