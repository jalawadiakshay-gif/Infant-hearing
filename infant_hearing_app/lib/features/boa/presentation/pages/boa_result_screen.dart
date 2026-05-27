import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/features/baby/providers/baby_provider.dart';
import 'package:infant_hearing_app/features/parent/providers/parent_provider.dart';
import 'package:infant_hearing_app/shared/widgets/app_button.dart';
import 'package:infant_hearing_app/shared/widgets/app_card.dart';
import '../../domain/boa_models.dart';
import '../controllers/boa_controller.dart';
import '../controllers/boa_checklist_controller.dart';
import '../../services/boa_report_service.dart';

class BoaResultScreen extends StatelessWidget {
  const BoaResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BoaController>();
    final state = controller.state;
    final outcome = state.outcome;
    final l10n = AppLocalizations.of(context);
    
    final baby = context.read<BabyProvider>().baby;
    final parent = context.read<ParentProvider>().parent;

    if (outcome == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final resultColor = _outcomeColor(outcome);
    final resultIcon = _outcomeIcon(outcome);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.screeningResult),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _generatePDF(context, controller, baby, parent),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ResultHeroCard(
                outcome: outcome,
                label: _getOutcomeLabel(outcome, l10n),
                color: resultColor,
                icon: resultIcon,
                l10n: l10n,
              ),
              const SizedBox(height: AppSpacing.xl),

              _SectionLabel('INFANT DETAILS'),
              const SizedBox(height: AppSpacing.s),
              AppCard(
                child: Column(
                  children: [
                    _InfoRow(label: 'Name', value: baby?.name ?? 'Unknown'),
                    _InfoRow(label: 'Age', value: baby?.age ?? 'N/A'),
                    _InfoRow(label: 'Parent', value: parent?.name ?? 'N/A'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              _SectionLabel('TRIAL SUMMARY'),
              const SizedBox(height: AppSpacing.s),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _TrialsTable(trials: state.trials),
                    if (state.trials.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.l),
                        child: Text('No trials recorded.'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              _SectionLabel(l10n.recommendedAction.toUpperCase()),
              const SizedBox(height: AppSpacing.s),
              AppCard(
                child: Text(
                  outcome.recommendation,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: resultColor),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              AppCard(
                color: AppColors.surface,
                child: Text(
                  outcome.explanation,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              if (outcome == BoaOutcome.suspectedHearingLoss) ...[
                _ReferralCard(l10n: l10n),
                const SizedBox(height: AppSpacing.xl),
              ],

              const SizedBox(height: AppSpacing.xxxl),

              AppPrimaryButton(
                label: l10n.submit,
                icon: Icons.cloud_upload_outlined,
                onPressed: () async {
                  await controller.submitResult();
                  if (context.mounted) {
                    context.go(RouteConstants.mainLayout);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.m),
              AppSecondaryButton(
                label: 'Download PDF Report',
                icon: Icons.picture_as_pdf_outlined,
                onPressed: () => _generatePDF(context, controller, baby, parent),
              ),
              const SizedBox(height: AppSpacing.m),
              AppSecondaryButton(
                label: l10n.back,
                icon: Icons.home_outlined,
                onPressed: () {
                  controller.reset();
                  context.read<BoaChecklistController>().reset();
                  context.go(RouteConstants.mainLayout);
                },
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generatePDF(BuildContext context, BoaController controller, baby, parent) async {
    final reportService = BoaReportService();
    await reportService.generateAndShareReport(
      babyName: baby?.name ?? 'Unknown',
      age: baby?.age ?? 'N/A',
      screeningId: 'BOA-${DateTime.now().millisecondsSinceEpoch}',
      outcome: controller.state.outcome!,
      trials: controller.state.trials,
    );
  }

  String _getOutcomeLabel(BoaOutcome outcome, AppLocalizations l10n) {
    switch (outcome) {
      case BoaOutcome.favorableHearingResponse: return l10n.boaFavorableResponse;
      case BoaOutcome.monitor: return l10n.boaMonitorResponse;
      case BoaOutcome.suspectedHearingLoss: return l10n.boaSuspectedLoss;
    }
  }

  Color _outcomeColor(BoaOutcome o) {
    switch (o) {
      case BoaOutcome.favorableHearingResponse: return AppColors.success;
      case BoaOutcome.monitor:                  return AppColors.warning;
      case BoaOutcome.suspectedHearingLoss:     return AppColors.error;
    }
  }

  IconData _outcomeIcon(BoaOutcome o) {
    switch (o) {
      case BoaOutcome.favorableHearingResponse: return Icons.check_circle_rounded;
      case BoaOutcome.monitor:                  return Icons.watch_later_rounded;
      case BoaOutcome.suspectedHearingLoss:     return Icons.warning_rounded;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _TrialsTable extends StatelessWidget {
  final List<BoaTrial> trials;
  const _TrialsTable({required this.trials});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder(horizontalInside: BorderSide(color: AppColors.border.withOpacity(0.5))),
      children: [
        TableRow(
          decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.2)),
          children: const [
            _TableCell('Level', isHeader: true),
            _TableCell('Freq', isHeader: true),
            _TableCell('Result', isHeader: true),
          ],
        ),
        ...trials.map((t) => TableRow(
          children: [
            _TableCell(t.dbLevel.label),
            _TableCell(t.frequency.label),
            _TableCell(t.response.label, color: t.response == BoaResponse.responseDetected ? AppColors.success : AppColors.error),
          ],
        )),
      ],
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  final Color? color;
  const _TableCell(this.text, {this.isHeader = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Text(
        text,
        style: isHeader 
            ? AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold) 
            : AppTextStyles.bodySmall.copyWith(color: color, fontWeight: color != null ? FontWeight.bold : null),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.caption.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _ResultHeroCard extends StatelessWidget {
  final BoaOutcome outcome;
  final String label;
  final Color color;
  final IconData icon;
  final AppLocalizations l10n;

  const _ResultHeroCard({
    required this.outcome,
    required this.label,
    required this.color,
    required this.icon,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: color.withOpacity(0.04),
      borderRadius: AppSpacing.radiusXL,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 44),
          ),
          const SizedBox(height: AppSpacing.l),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            ),
            child: Text(
              label,
              style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 15),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            l10n.sectionComplete,
            style: AppTextStyles.subheading2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  final AppLocalizations l10n;
  const _ReferralCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: AppColors.error.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_hospital_outlined, color: AppColors.error, size: 20),
              const SizedBox(width: AppSpacing.s),
              Text(l10n.outcomeRefer, style: AppTextStyles.subheading1.copyWith(color: AppColors.error)),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            l10n.referralNote,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
