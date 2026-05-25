import 'package:flutter/material.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/features/chatbot/services/chatbot_knowledge_base.dart';

class QuickActionBar extends StatelessWidget {
  final void Function(String intent) onTap;

  const QuickActionBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final actions = [
      (ChatbotKnowledgeBase.intentMilestones,        l10n.qaHearingMilestones, Icons.child_care_outlined),
      (ChatbotKnowledgeBase.intentSymptoms,          l10n.qaCheckSymptoms,     Icons.health_and_safety_outlined),
      (ChatbotKnowledgeBase.intentBookScreening,     l10n.qaBookScreening,     Icons.calendar_today_outlined),
      (ChatbotKnowledgeBase.intentQuestionnaireHelp, l10n.qaQuestionnaireHelp, Icons.help_outline_rounded),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s),
        itemBuilder: (context, i) {
          final (intent, label, icon) = actions[i];
          return _Chip(intent: intent, label: label, icon: icon, onTap: onTap);
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String intent;
  final String label;
  final IconData icon;
  final void Function(String) onTap;

  const _Chip({
    required this.intent,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(intent),
      borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: AppSpacing.s),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
