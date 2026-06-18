import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/core/providers/app_provider.dart';
import 'package:infant_hearing_app/core/providers/language_provider.dart';
import 'package:infant_hearing_app/features/auth/providers/auth_provider.dart';
import 'package:infant_hearing_app/features/asha/providers/asha_provider.dart';
import 'package:infant_hearing_app/features/parent/providers/parent_provider.dart';
import 'package:infant_hearing_app/features/baby/providers/baby_provider.dart';

// Screens
import 'package:infant_hearing_app/features/auth/screens/phone_login_screen.dart';
import 'package:infant_hearing_app/features/auth/screens/register_screen.dart';
import 'package:infant_hearing_app/features/auth/screens/otp_verification_screen.dart';
import 'package:infant_hearing_app/features/auth/screens/role_selection_screen.dart';
import 'package:infant_hearing_app/features/auth/screens/language_selection_screen.dart';
import 'package:infant_hearing_app/features/home/screens/main_layout_screen.dart';
import 'package:infant_hearing_app/features/asha/screens/asha_dashboard_screen.dart';
import 'package:infant_hearing_app/features/asha/screens/asha_login_screen.dart';
import 'package:infant_hearing_app/features/asha/screens/asha_village_screen.dart';
import 'package:infant_hearing_app/features/asha/screens/asha_infant_detail_screen.dart';
import 'package:infant_hearing_app/features/asha/screens/batch_registration_screen.dart';
import 'package:infant_hearing_app/features/boa/presentation/pages/boa_intro_screen.dart';
import 'package:infant_hearing_app/features/boa/presentation/pages/boa_wizard_screen.dart';
import 'package:infant_hearing_app/features/boa/presentation/pages/boa_checklist_screen.dart';
import 'package:infant_hearing_app/features/boa/presentation/pages/boa_test_screen.dart';
import 'package:infant_hearing_app/features/boa/presentation/pages/boa_result_screen.dart';
import 'package:infant_hearing_app/features/chatbot/screens/chatbot_screen.dart';
import 'package:infant_hearing_app/features/profile/screens/profile_screen.dart';
import 'package:infant_hearing_app/features/settings/screens/settings_screen.dart';
import 'package:infant_hearing_app/features/history/screens/history_screen.dart';
import 'package:infant_hearing_app/features/home/screens/medical_insights_screen.dart';
import 'package:infant_hearing_app/features/questionnaire/screens/questionnaire_screen.dart';
import 'package:infant_hearing_app/features/questionnaire/screens/questionnaire_result_screen.dart';
import 'package:infant_hearing_app/features/baby/screens/child_detail_screen.dart';
import 'package:infant_hearing_app/features/baby/screens/baby_profile_screen.dart';
import 'package:infant_hearing_app/features/parent/screens/parent_profile_screen.dart';
import 'package:infant_hearing_app/features/parent/screens/simple_parent_profile_screen.dart';
import 'package:infant_hearing_app/data/models/v2/child.dart';

class AppRouter {
  static GoRouter router(Listenable refreshListenable) => GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final app = context.read<AppProvider>();
      final langProvider = context.read<LanguageProvider>();
      final auth = context.read<AuthProvider>();
      final asha = context.read<AshaProvider>();
      final parent = context.read<ParentProvider>();
      final baby = context.read<BabyProvider>();

      if (!app.isInitialized || !langProvider.initialized) {
        return null;
      }

      if (langProvider.isFirstRun) {
        return RouteConstants.languageSelect;
      }

      // Special case for ASHA login flow
      if (asha.status == AshaStatus.success && asha.asha != null) {
        if (state.matchedLocation == RouteConstants.ashaLogin || 
            state.matchedLocation == RouteConstants.login ||
            state.matchedLocation == '/') {
          return RouteConstants.ashaDashboard;
        }
        return null;
      }

      if (!auth.isAuthenticated) {
        if (state.matchedLocation == RouteConstants.phoneLogin || 
            state.matchedLocation == RouteConstants.register ||
            state.matchedLocation == RouteConstants.ashaLogin ||
            state.matchedLocation == RouteConstants.roleSelection) {
          return null;
        }
        return RouteConstants.roleSelection;
      }

      if (!parent.hasParentData) {
        if (state.matchedLocation == RouteConstants.parentProfile) return null;
        return RouteConstants.parentProfile;
      }

      if (!baby.hasChildren) {
        if (state.matchedLocation == RouteConstants.babyProfile) return null;
        return RouteConstants.babyProfile;
      }

      // If already at root and all good, go to main layout
      if (state.matchedLocation == '/') {
        return RouteConstants.mainLayout;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: RouteConstants.languageSelect,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: RouteConstants.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: RouteConstants.phoneLogin,
        builder: (context, state) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.ashaLogin,
        builder: (context, state) => const AshaLoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteConstants.otpVerification,
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: RouteConstants.mainLayout,
        builder: (context, state) => const MainLayoutScreen(),
      ),
      GoRoute(
        path: RouteConstants.ashaDashboard,
        builder: (context, state) => const AshaDashboardScreen(),
      ),
      GoRoute(
        path: RouteConstants.parentProfile,
        builder: (context, state) => const ParentProfileScreen(),
      ),
      GoRoute(
        path: RouteConstants.simpleParentProfile,
        builder: (context, state) => const SimpleParentProfileScreen(),
      ),
      GoRoute(
        path: RouteConstants.babyProfile,
        builder: (context, state) => const BabyProfileScreen(),
      ),
      GoRoute(
        path: RouteConstants.ashaVillage,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final village = extra?['village'] as String? ?? 'Village';
          return AshaVillageScreen(village: village);
        },
      ),
      GoRoute(
        path: RouteConstants.ashaInfantDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final infant = extra?['infant'] as Child;
          return AshaInfantDetailScreen(infant: infant);
        },
      ),
      GoRoute(
        path: RouteConstants.ashaBatchRegistration,
        builder: (context, state) => const BatchRegistrationScreen(),
      ),
      GoRoute(
        path: RouteConstants.ashaBoaTest,
        builder: (context, state) => const BoaTestScreen(),
      ),
      GoRoute(
        path: RouteConstants.boaIntro,
        builder: (context, state) => const BoaIntroScreen(),
      ),
      GoRoute(
        path: RouteConstants.boaWizard,
        builder: (context, state) => const BoaWizardScreen(),
      ),
      GoRoute(
        path: RouteConstants.boaChecklist,
        builder: (context, state) => const BoaChecklistScreen(),
      ),
      GoRoute(
        path: RouteConstants.boaTest,
        builder: (context, state) => const BoaTestScreen(),
      ),
      GoRoute(
        path: RouteConstants.boaResult,
        builder: (context, state) => const BoaResultScreen(),
      ),
      GoRoute(
        path: RouteConstants.chatbot,
        builder: (context, state) => const ChatbotScreen(),
      ),
      GoRoute(
        path: RouteConstants.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteConstants.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteConstants.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: RouteConstants.medicalInsights,
        builder: (context, state) => const MedicalInsightsScreen(),
      ),
      GoRoute(
        path: RouteConstants.questionnaire,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return QuestionnaireScreen(arguments: extra);
        },
      ),
      GoRoute(
        path: RouteConstants.questionnaireResult,
        builder: (context, state) => const QuestionnaireResultScreen(),
      ),
      GoRoute(
        path: RouteConstants.childDetail,
        builder: (context, state) => const ChildDetailScreen(),
      ),
    ],
  );
}
