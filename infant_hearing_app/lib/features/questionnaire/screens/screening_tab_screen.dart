import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:infant_hearing_app/shared/widgets/app_button.dart';
import 'package:infant_hearing_app/shared/widgets/app_card.dart';
import '../providers/questionnaire_provider.dart';
import '../models/questionnaire_models.dart';
import '../../boa/presentation/controllers/boa_controller.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';

class ScreeningTabScreen extends StatelessWidget {
  const ScreeningTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final questionnaireProvider = context.watch<QuestionnaireProvider>();
    final boaController = context.watch<BoaController>();
    
    final isQuestionnaireComplete = questionnaireProvider.isCompleted;
    final questionnaireResult = questionnaireProvider.scoringResult;
    final needsBoa = questionnaireResult?.result == RiskResult.refer;
    final isBoaComplete = boaController.state.isComplete;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.hearingScreening, style: AppTextStyles.h3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.l),
            _buildInfoCard(
              context: context,
              icon: Icons.headphones_rounded,
              title: l10n.phase1Screening,
              description: l10n.phase1Desc,
              color: AppColors.primary,
              status: isQuestionnaireComplete ? l10n.statusCompleted : l10n.statusPending,
              statusColor: isQuestionnaireComplete ? AppColors.success : AppColors.primary,
              onTap: () {
                if (isQuestionnaireComplete) {
                  context.push(RouteConstants.questionnaireResult);
                } else {
                  context.push(RouteConstants.questionnaire);
                }
              },
            ),
            const SizedBox(height: AppSpacing.m),
            _buildInfoCard(
              context: context,
              icon: Icons.graphic_eq_rounded,
              title: l10n.phase2Boa,
              description: l10n.phase2Desc,
              color: isQuestionnaireComplete ? AppColors.secondary : AppColors.textHint,
              status: isBoaComplete ? l10n.statusCompleted : needsBoa ? l10n.statusRequired : isQuestionnaireComplete ? l10n.statusNotRequired : l10n.statusLocked,
              statusColor: isBoaComplete ? AppColors.success : needsBoa ? AppColors.error : AppColors.textHint,
              onTap: () {
                if (!isQuestionnaireComplete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.completePhase1First)),
                  );
                  return;
                }
                if (!needsBoa && !isBoaComplete) {
                  // BOA not required — show informational dialog
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(l10n.boaNotRequired),
                      content: Text(l10n.boaNotRequiredDesc),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.ok))],
                    ),
                  );
                  return;
                }
                if (isBoaComplete) {
                  context.push(RouteConstants.boaResult);
                } else {
                  context.push(RouteConstants.boaIntro);
                }
              },
            ),
            const SizedBox(height: AppSpacing.xxxxl),
            AppPrimaryButton(
              onPressed: () {
                if (isBoaComplete) {
                  context.push(RouteConstants.history);
                } else if (isQuestionnaireComplete) {
                  if (needsBoa) {
                    context.push(RouteConstants.boaIntro);
                  } else {
                    context.push(RouteConstants.questionnaireResult);
                  }
                } else {
                  context.push(RouteConstants.questionnaire);
                }
              },
              label: isBoaComplete
                ? l10n.viewScreeningHistory
                : isQuestionnaireComplete 
                  ? (needsBoa ? l10n.startPhase2 : l10n.viewPhase1Result)
                  : l10n.startPhase1Desc,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusM),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: AppTextStyles.subheading1.copyWith(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: AppTextStyles.caption.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(description, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
