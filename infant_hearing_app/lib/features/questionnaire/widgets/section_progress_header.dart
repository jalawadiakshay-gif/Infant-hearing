import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

import 'package:infant_hearing_app/core/localization/app_localizations.dart';

class SectionProgressHeader extends StatelessWidget {
  final int currentSection;
  final int totalSections;
  final String sectionTitle;
  final String sectionSubtitle;
  final int answeredCount;
  final int totalCount;

  const SectionProgressHeader({
    super.key,
    required this.currentSection,
    required this.totalSections,
    required this.sectionTitle,
    required this.sectionSubtitle,
    required this.answeredCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount > 0 ? answeredCount / totalCount : 0.0;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section pill
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusS),
              ),
              child: Text(
                '${l10n.sectionLabel} ${currentSection + 1} ${l10n.ofWord} $totalSections',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '$answeredCount/$totalCount ${l10n.done.toLowerCase()}',
              style: AppTextStyles.caption,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.m),

        // Section title
        Text(
          sectionTitle,
          style: AppTextStyles.h2,
        ),

        const SizedBox(height: AppSpacing.xs),

        Text(
          sectionSubtitle,
          style: AppTextStyles.bodyMedium,
        ),

        const SizedBox(height: AppSpacing.l),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0 ? AppColors.success : AppColors.primary,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.m),

        // Section step dots
        Row(
          children: List.generate(totalSections, (i) {
            final isActive = i == currentSection;
            final isDone = i < currentSection;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 4,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.success
                      : isActive
                          ? AppColors.primary
                          : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
