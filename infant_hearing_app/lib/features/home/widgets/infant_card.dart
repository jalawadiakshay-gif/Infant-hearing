import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../baby/models/baby_model.dart';
import '../../questionnaire/providers/questionnaire_provider.dart';

class InfantCard extends StatelessWidget {
  final BabyModel baby;
  const InfantCard({super.key, required this.baby});

  @override
  Widget build(BuildContext context) {
    final qProvider = context.watch<QuestionnaireProvider>();
    final isComplete = qProvider.isCompleted;

    return AppCard(
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Center(
              child: Text(
                baby.name.isNotEmpty ? baby.name[0].toUpperCase() : '?',
                style: AppTextStyles.h2.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.l),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baby.name,
                  style: AppTextStyles.subheading1.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.s,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _chip('DOB: ${DateFormat('dd MMM yyyy').format(baby.dob)}'),
                    _chip(baby.gender),
                    if (baby.nicuAdmission) _chip('NICU', isWarning: true),
                  ],
                ),
              ],
            ),
          ),

          // Risk badge
          _buildRiskBadge(isComplete ? baby.riskLevel : 'Screening Pending', isComplete),
        ],
      ),
    );
  }

  Widget _buildRiskBadge(String level, bool isComplete) {
    if (!isComplete) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.textHint.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        ),
        child: Text(
          level.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    Color color;
    switch (level.toLowerCase()) {
      case 'high':
        color = AppColors.error;
        break;
      case 'medium':
        color = AppColors.warning;
        break;
      case 'low':
      default:
        color = AppColors.success;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
      ),
      child: Text(
        level.toUpperCase(),
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _chip(String label, {bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 2),
      decoration: BoxDecoration(
        color: isWarning
            ? AppColors.warning.withValues(alpha: 0.10)
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: isWarning ? AppColors.warning : AppColors.primary,
        ),
      ),
    );
  }
}
