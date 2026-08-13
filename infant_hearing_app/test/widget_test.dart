import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/features/auth/widgets/auth_header.dart';
import 'package:infant_hearing_app/core/constants/app_strings.dart';

void main() {
  group('Design Tokens & Brand Accessibility Tests', () {
    test('AppColors define standardized surface tokens', () {
      expect(AppColors.surfaceSuccess, equals(const Color(0xFFECFDF5)));
      expect(AppColors.surfaceError, equals(const Color(0xFFFEF2F2)));
      expect(AppColors.surfaceWarning, equals(const Color(0xFFFFFBEB)));
      expect(AppColors.surfaceInfo, equals(const Color(0xFFEFF6FF)));
    });

    testWidgets('AuthBrand renders logo and app strings correctly without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthBrand(),
          ),
        ),
      );

      expect(find.text(AppStrings.appName), findsOneWidget);
      expect(find.text(AppStrings.appTagline), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
