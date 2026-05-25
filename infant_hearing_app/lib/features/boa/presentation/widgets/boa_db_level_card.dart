import 'package:flutter/material.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import '../../domain/boa_models.dart';
import '../state/boa_state.dart';

/// Card showing the current dB level with color-coded clinical context.
class BoaDbLevelCard extends StatelessWidget {
  final BoaState state;

  const BoaDbLevelCard({super.key, required this.state});

  Color get _levelColor {
    switch (state.currentDbLevel) {
      case BoaDbLevel.db70: return AppColors.warning;
      case BoaDbLevel.db45: return AppColors.success;
      case BoaDbLevel.db90: return AppColors.error;
    }
  }

  String get _levelLabel {
    switch (state.currentDbLevel) {
      case BoaDbLevel.db70: return 'Initial Level';
      case BoaDbLevel.db45: return 'Reduced Level';
      case BoaDbLevel.db90: return 'Elevated Level';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: _levelColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: _levelColor.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            _levelLabel.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: _levelColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            state.currentDbLevel.label,
            style: AppTextStyles.h1.copyWith(
              fontSize: 48,
              color: _levelColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            state.currentDbLevel.clinicalNote,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.m),
          // Level indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: BoaDbLevel.values.map((level) {
              final isActive = level == state.currentDbLevel;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? _levelColor
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}