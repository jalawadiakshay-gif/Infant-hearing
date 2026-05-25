import 'package:flutter/material.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/features/home/widgets/awareness_carousel.dart';

class MedicalInsightsScreen extends StatelessWidget {
  const MedicalInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.awareness, style: AppTextStyles.h3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.knowTheSigns,
              style: AppTextStyles.h2.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              l10n.knowTheSignsDesc,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xl),
            
            _InsightSection(
              title: 'Hearing Milestones',
              content: '0-3 Months: Startles to loud sounds.\n3-6 Months: Moves eyes toward sounds.\n6-12 Months: Turns head toward sound, responds to name.',
              icon: Icons.auto_graph_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.l),
            
            _InsightSection(
              title: 'Clinical Screening',
              content: 'Early Hearing Detection and Intervention (EHDI) programs recommend screening by 1 month, diagnosis by 3 months, and intervention by 6 months.',
              icon: Icons.medical_services_rounded,
              color: AppColors.secondary,
            ),
            const SizedBox(height: AppSpacing.l),
            
            _InsightSection(
              title: 'Risk Factors',
              content: 'Low birth weight, premature birth, NICU stay, family history, and certain infections during pregnancy are common risk factors that require close monitoring.',
              icon: Icons.warning_rounded,
              color: AppColors.warning,
            ),
            const SizedBox(height: AppSpacing.xxxxl),
          ],
        ),
      ),
    );
  }
}

class _InsightSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _InsightSection({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: AppSpacing.s),
              Text(title, style: AppTextStyles.subheading1.copyWith(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(content, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
