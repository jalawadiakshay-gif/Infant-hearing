import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

/// Premium Medical UI Theme for Baalshravya
class AppTheme {
  // ── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnSecondary,
        onSurface: AppColors.textPrimary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _buildTextTheme(AppColors.textPrimary),
      elevatedButtonTheme: _elevatedButtonTheme(AppColors.primary),
      outlinedButtonTheme: _outlinedButtonTheme(AppColors.primary, AppColors.surface),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: AppColors.surface,
        borderColor: AppColors.border,
        focusedBorderColor: AppColors.primary,
        labelColor: AppColors.textSecondary,
        hintColor: AppColors.textHint,
      ),
      cardTheme: _cardTheme(AppColors.surface, AppColors.border),
      appBarTheme: _appBarTheme(AppColors.surface, AppColors.textPrimary),
      dividerTheme: DividerThemeData(
        color: AppColors.border.withValues(alpha: 0.5),
        thickness: 1,
        space: AppSpacing.xl,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? AppColors.primary : Colors.grey.shade400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? AppColors.primaryLight : Colors.grey.shade200;
        }),
      ),
    );
  }

  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const darkBg = Color(0xFF0F172A);       // slate-950
    const darkSurface = Color(0xFF1E293B);  // slate-800
    const darkBorder = Color(0xFF334155);   // slate-700
    const darkText = Color(0xFFF1F5F9);     // slate-100
    const darkTextSec = Color(0xFF94A3B8);  // slate-400

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: darkSurface,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnSecondary,
        onSurface: darkText,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkBg,
      textTheme: _buildTextTheme(darkText),
      elevatedButtonTheme: _elevatedButtonTheme(AppColors.primary),
      outlinedButtonTheme: _outlinedButtonTheme(AppColors.secondary, darkSurface),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: darkSurface,
        borderColor: darkBorder,
        focusedBorderColor: AppColors.primary,
        labelColor: darkTextSec,
        hintColor: const Color(0xFF64748B), // slate-500
      ),
      cardTheme: _cardTheme(darkSurface, darkBorder),
      appBarTheme: _appBarTheme(darkSurface, darkText),
      dividerTheme: DividerThemeData(
        color: darkBorder.withValues(alpha: 0.5),
        thickness: 1,
        space: AppSpacing.xl,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? AppColors.primary : Colors.grey.shade600;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.grey.shade800;
        }),
      ),
    );
  }

  // ── Shared Builder Helpers ─────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color baseColor) {
    return TextTheme(
      displayLarge: AppTextStyles.h1,
      displayMedium: AppTextStyles.h2,
      headlineMedium: AppTextStyles.h3,
      titleLarge: AppTextStyles.subheading1,
      titleMedium: AppTextStyles.subheading2,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      labelLarge: AppTextStyles.button,
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(Color bg) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        minimumSize: const Size(double.infinity, 54),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.m,
          horizontal: AppSpacing.xxl,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        ),
        textStyle: AppTextStyles.button,
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(Color fgColor, Color bgColor) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: fgColor,
        backgroundColor: Colors.transparent,
        side: BorderSide(color: fgColor, width: 1.8),
        minimumSize: const Size(double.infinity, 54),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.m,
          horizontal: AppSpacing.xxl,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        ),
        textStyle: AppTextStyles.button,
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme({
    required Color fillColor,
    required Color borderColor,
    required Color focusedBorderColor,
    required Color labelColor,
    required Color hintColor,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.l,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        borderSide: BorderSide(color: focusedBorderColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: hintColor),
      labelStyle: AppTextStyles.subheading2.copyWith(color: labelColor),
    );
  }

  static CardThemeData _cardTheme(Color cardColor, Color borderColor) {
    return CardThemeData(
      elevation: 0,
      color: cardColor,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        side: BorderSide(color: borderColor, width: 0.8),
      ),
    );
  }

  static AppBarTheme _appBarTheme(Color bgColor, Color textColor) {
    return AppBarTheme(
      backgroundColor: bgColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.h3.copyWith(color: textColor),
      iconTheme: IconThemeData(color: textColor, size: 22),
      systemOverlayStyle: bgColor.computeLuminance() > 0.5
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
    );
  }
}
