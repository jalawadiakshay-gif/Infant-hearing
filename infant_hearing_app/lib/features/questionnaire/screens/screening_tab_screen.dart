import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/shared/widgets/app_button.dart';
import 'package:infant_hearing_app/shared/widgets/app_card.dart';
import '../providers/questionnaire_provider.dart';
import '../models/questionnaire_models.dart';
import '../../boa/presentation/controllers/boa_controller.dart';

class ScreeningTabScreen extends StatelessWidget {
  const ScreeningTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final questionnaireProvider = context.watch<QuestionnaireProvider>();
    final boaController = context.watch<BoaController>();
    
    final isQuestionnaireComplete = questionnaireProvider.isCompleted;
    final questionnaireResult = questionnaireProvider.scoringResult;
    final needsBoa = questionnaireResult?.result == RiskResult.refer;
    final isBoaComplete = boaController.state.isComplete;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hearing Screening', style: AppTextStyles.h3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.l),
            _buildInfoCard(
              context: context,
              icon: Icons.headphones_rounded,
              title: 'Phase 1: Questionnaire',
              description: 'A quick 7-section assessment of your baby\'s hearing development and medical history.',
              color: AppColors.primary,
              status: isQuestionnaireComplete ? 'COMPLETED' : 'PENDING',
              statusColor: isQuestionnaireComplete ? AppColors.success : AppColors.primary,
              onTap: () {
                if (isQuestionnaireComplete) {
                  Navigator.pushNamed(context, RouteConstants.questionnaireResult);
                } else {
                  Navigator.pushNamed(context, RouteConstants.questionnaire);
                }
              },
            ),
            const SizedBox(height: AppSpacing.m),
            _buildInfoCard(
              context: context,
              icon: Icons.graphic_eq_rounded,
              title: 'Phase 2: BOA Test',
              description: 'Behavioral Observation Audiometry. Performed if results suggest a referral is needed.',
              color: isQuestionnaireComplete ? AppColors.secondary : AppColors.textHint,
              status: isBoaComplete ? 'COMPLETED' : needsBoa ? 'REQUIRED' : isQuestionnaireComplete ? 'NOT REQUIRED' : 'LOCKED',
              statusColor: isBoaComplete ? AppColors.success : needsBoa ? AppColors.error : AppColors.textHint,
              onTap: () {
                if (!isQuestionnaireComplete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please complete Phase 1: Questionnaire first.')),
                  );
                  return;
                }
                if (!needsBoa && !isBoaComplete) {
                  // BOA not required — show informational dialog
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('BOA Not Required'),
                      content: const Text('Phase 2 BOA test is only triggered for REFER outcomes from Phase 1. Your Phase 1 result does not require this test.'),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                    ),
                  );
                  return;
                }
                if (isBoaComplete) {
                  Navigator.pushNamed(context, RouteConstants.boaResult);
                } else {
                  Navigator.pushNamed(context, RouteConstants.boaIntro);
                }
              },
            ),
            const SizedBox(height: AppSpacing.xxxxl),
            AppPrimaryButton(
              onPressed: () {
                if (isBoaComplete) {
                  Navigator.pushNamed(context, RouteConstants.history);
                } else if (isQuestionnaireComplete) {
                  if (needsBoa) {
                    Navigator.pushNamed(context, RouteConstants.boaIntro);
                  } else {
                    Navigator.pushNamed(context, RouteConstants.questionnaireResult);
                  }
                } else {
                  Navigator.pushNamed(context, RouteConstants.questionnaire);
                }
              },
              label: isBoaComplete
                ? 'View Screening History'
                : isQuestionnaireComplete 
                  ? (needsBoa ? 'Start Phase 2: BOA' : 'View Phase 1 Result')
                  : 'Start Phase 1: Questionnaire',
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
                color: color.withOpacity(0.1),
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
                          color: statusColor.withOpacity(0.1),
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
