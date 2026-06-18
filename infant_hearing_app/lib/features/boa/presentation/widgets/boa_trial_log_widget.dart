import 'package:flutter/material.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import '../../domain/boa_models.dart';

/// Displays a compact log of all trials completed so far.
class BoaTrialLogWidget extends StatelessWidget {
  final List<BoaTrial> trials;

  const BoaTrialLogWidget({super.key, required this.trials});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TRIAL LOG',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusL),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: trials.asMap().entries.map((entry) {
              final idx = entry.key;
              final trial = entry.value;
              final isLast = idx == trials.length - 1;

              return Column(
                children: [
                  _TrialRow(trial: trial, index: idx + 1),
                  if (!isLast)
                    const Divider(height: 1, indent: AppSpacing.l),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _TrialRow extends StatelessWidget {
  final BoaTrial trial;
  final int index;

  const _TrialRow({required this.trial, required this.index});

  Color get _responseColor {
    switch (trial.response) {
      case BoaResponse.responseDetected: return AppColors.success;
      case BoaResponse.noResponse:       return AppColors.error;
      case BoaResponse.uncertain:        return AppColors.warning;
    }
  }

  IconData get _responseIcon {
    switch (trial.response) {
      case BoaResponse.responseDetected: return Icons.check_circle_rounded;
      case BoaResponse.noResponse:       return Icons.cancel_rounded;
      case BoaResponse.uncertain:        return Icons.help_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l, vertical: AppSpacing.m),
      child: Row(
        children: [
          // Trial number
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$index',
                  style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: AppSpacing.m),

          // dB level
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusS),
            ),
            child: Text(
              trial.dbLevel.label,
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: AppSpacing.s),

          // Frequency
          Expanded(
            child: Text(
              trial.frequency.label,
              style: AppTextStyles.bodyMedium,
            ),
          ),

          // Response badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_responseIcon, size: 14, color: _responseColor),
              const SizedBox(width: 4),
              Text(
                trial.response.label,
                style: AppTextStyles.caption.copyWith(
                  color: _responseColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}