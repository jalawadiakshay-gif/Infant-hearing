import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/route_constants.dart';

// Existing Imports
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/parent/screens/parent_info_screen.dart';
import 'features/baby/screens/baby_profile_screen.dart';

// Add these new Asha Screen imports
import 'features/asha/screens/asha_login_screen.dart';
import 'features/asha/screens/asha_dashboard_screen.dart';
import 'features/asha/screens/asha_village_screen.dart';
import 'features/asha/screens/batch_registration_screen.dart';
import 'features/asha/screens/asha_infant_detail_screen.dart';
import 'features/asha/screens/boa_test_screen.dart';

class InfantHearingApp extends StatelessWidget {
  const InfantHearingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infant Hearing Screening',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: RouteConstants.root,
      routes: {
        // Existing Routes
        RouteConstants.root: (_) => const LoginScreen(),
        RouteConstants.login: (_) => const LoginScreen(),
        RouteConstants.register: (_) => const RegisterScreen(),
        RouteConstants.parentInfo: (_) => const ParentInfoScreen(),
        RouteConstants.babyProfile: (_) => const BabyProfileScreen(),
        RouteConstants.home: (_) => const HomeScreen(),
        
        // New Asha Routes
        RouteConstants.ashaLogin: (_) => const AshaLoginScreen(),
        RouteConstants.ashaDashboard: (_) => const AshaDashboardScreen(),
        RouteConstants.ashaVillage: (_) => const AshaVillageScreen(),
        RouteConstants.ashaBatchRegistration: (_) => const BatchRegistrationScreen(),
        RouteConstants.ashaInfantDetail: (_) => const AshaInfantDetailScreen(),
        RouteConstants.ashaBoaTest: (_) => const BoaTestScreen(),
      },
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}