import 'package:flutter/material.dart';
import 'package:infant_hearing_app/features/home/screens/home_screen.dart';
import 'package:infant_hearing_app/features/profile/screens/profile_screen.dart';
import 'package:infant_hearing_app/features/history/screens/history_screen.dart';
import 'package:infant_hearing_app/features/questionnaire/screens/screening_tab_screen.dart';
import 'package:infant_hearing_app/shared/widgets/bottom_nav_bar.dart';

import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ScreeningTabScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, RouteConstants.chatbot),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
