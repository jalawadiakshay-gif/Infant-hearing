import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/shared/widgets/app_button.dart';
import 'package:infant_hearing_app/shared/widgets/language_switcher.dart';
import '../controllers/boa_checklist_controller.dart';
import '../controllers/boa_controller.dart';

class BoaChecklistScreen extends StatelessWidget {
  const BoaChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final checklist = context.watch<BoaChecklistController>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.boaPreChecklist),
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
        actions: const [
          LanguagePopupButton(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _ChecklistProgress(
              checked: checklist.checkedCount,
              total: checklist.items.length,
              l10n: l10n,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.l),
                    Text(
                      '${l10n.boaPreChecklist}:',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: AppSpacing.l),
                    ...checklist.items.map((item) => _ChecklistTile(
                          item: item,
                          onToggle: () => checklist.toggle(item.id),
                          l10n: l10n,
                        )),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),

            _ChecklistFooter(allChecked: checklist.allChecked, l10n: l10n),
          ],
        ),
      ),
    );
  }
}

class _ChecklistProgress extends StatelessWidget {
  final int checked;
  final int total;
  final AppLocalizations l10n;

  const _ChecklistProgress({required this.checked, required this.total, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? checked / total : 0.0;
    final isComplete = checked == total;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$checked ${l10n.ofWord} $total ${l10n.done.toLowerCase()}',
                style: AppTextStyles.subheading2,
              ),
              if (isComplete)
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(isComplete ? AppColors.success : AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  final dynamic item;
  final VoidCallback onToggle;
  final AppLocalizations l10n;

  const _ChecklistTile({required this.item, required this.onToggle, required this.l10n});

  @override
  Widget build(BuildContext context) {
    String description = '';
    
    switch (item.id) {
      case 'preCheckQuiet':
        description = l10n.preCheckQuiet;
        break;
      case 'preCheckInfantAlert':
        description = l10n.preCheckInfantAlert;
        break;
      case 'preCheckNoDistraction':
        description = l10n.preCheckNoDistraction;
        break;
      case 'preCheckDeviceVolume':
        description = l10n.preCheckDeviceVolume;
        break;
      case 'preCheckCaregiverFreeze':
        description = l10n.preCheckCaregiverFreeze;
        break;
      case 'preCheckCatchTrial':
        description = l10n.preCheckCatchTrial;
        break;
      default:
        // Safe localized fallback instead of English hardcode
        description = '${l10n.boaPreChecklist} (${item.id})';
    }

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: item.isChecked ? AppColors.success.withValues(alpha: 0.06) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusL),
          border: Border.all(
            color: item.isChecked ? AppColors.success.withValues(alpha: 0.4) : AppColors.border,
            width: item.isChecked ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.isChecked ? AppColors.success.withValues(alpha: 0.1) : AppColors.border.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.isChecked ? Icons.check_rounded : item.icon,
                color: item.isChecked ? AppColors.success : AppColors.textHint,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(
                description,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: item.isChecked ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistFooter extends StatelessWidget {
  final bool allChecked;
  final AppLocalizations l10n;
  const _ChecklistFooter({required this.allChecked, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      color: AppColors.surface,
      child: AppPrimaryButton(
        label: l10n.boaStartTest,
        onPressed: allChecked
            ? () {
                // Initialize controller (camera, etc) before navigating
                context.read<BoaController>().initialize();
                context.push(RouteConstants.boaTest);
              }
            : null,
      ),
    );
  }
}
