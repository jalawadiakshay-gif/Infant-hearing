import 'package:flutter/material.dart';

/// Baalshravya Premium Medical Branding Palette
class AppColors {
  // Primary: Professional Medical Blue
  static const Color primary = Color(0xFF2A72E5); 
  static const Color primaryLight = Color(0xFFE8F1FF);
  static const Color primaryDark = Color(0xFF1B4EAB);

  // Secondary: Modern Cyan/Teal (Represents Clarity/Hearing)
  static const Color secondary = Color(0xFF00B8D4); 
  static const Color secondaryLight = Color(0xFFE0F7FA);
  static const Color secondaryDark = Color(0xFF00838F);

  // Accent: Gentle AI Purple (Represents Innovation/Intelligence)
  static const Color accent = Color(0xFF7C4DFF);
  static const Color accentLight = Color(0xFFF1EDFF);

  // Background & Surface: High-Contrast Medical UI
  static const Color background = Color(0xFFF8FAFD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F4F9);
  static const Color border = Color(0xFFE2E8F0);

  // Text Colors: Optimized for Clinical Readability
  static const Color textPrimary = Color(0xFF1E293B); // Slate 800
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textHint = Color(0xFF94A3B8); // Slate 400
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Semantic Colors: Standardized Clinical Alerts
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color info = Color(0xFF3B82F6); // Blue 500
  static const Color scrim = Color(0x99000000); // 60% black

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF4A90E2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];
}
