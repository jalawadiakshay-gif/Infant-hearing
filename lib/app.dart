import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/route_constants.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/parent/screens/parent_info_screen.dart';
import 'features/baby/screens/baby_profile_screen.dart';

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
        RouteConstants.root: (_) => const LoginScreen(),
        RouteConstants.login: (_) => const LoginScreen(),
        RouteConstants.register: (_) => const RegisterScreen(),
        RouteConstants.parentInfo: (_) => const ParentInfoScreen(),
        RouteConstants.babyProfile: (_) => const BabyProfileScreen(),
        RouteConstants.home: (_) => const HomeScreen(),
      },
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}
