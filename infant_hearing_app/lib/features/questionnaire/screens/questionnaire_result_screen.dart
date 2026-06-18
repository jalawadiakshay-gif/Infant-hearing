import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/language_provider.dart';
import '../providers/questionnaire_provider.dart';
import '../models/questionnaire_models.dart';
import '../services/questionnaire_report_service.dart';
import '../../baby/providers/baby_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/report_type_dialog.dart';
import '../../auth/providers/auth_provider.dart';

class QuestionnaireResultScreen extends StatelessWidget {
  const QuestionnaireResultScreen({super.key});

  Future<void> _shareReport(BuildContext context, QuestionnaireProvider provider, AppLocalizations l10n, String langCode) async {
    final auth = context.read<AuthProvider>();
    final isAsha = auth.phoneNumber == null; // A heuristic: ASHA logs in with email

    final selection = await ReportTypeSelectionDialog.show(context, isAshaDefault: isAsha);
    if (selection == null || !context.mounted) return; // User cancelled

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final baby = context.read<BabyProvider>().baby;
      final reportService = QuestionnaireReportService();
      
      await reportService.generateAndShareReport(
        reportType: selection == ReportSelectionType.clinical ? ReportType.clinical : ReportType.parent,
        babyName: baby?.name ?? 'Unknown',
        age: baby?.ageMonths != null ? '${baby!.ageMonths} months' : 'N/A',
        screeningId: 'Q-${DateTime.now().millisecondsSinceEpoch}',
        result: provider.scoringResult!,
        sections: provider.sections,
        answers: provider.answers,
        langCode: langCode,
        l10n: l10n,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e')),
        );
      }
    } finally {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestionnaireProvider>();
    final result = provider.scoringResult;
    final l10n = AppLocalizations.of(context);
    final langCode = context.watch<LanguageProvider>().currentLanguage.code;

    if (result == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final resultColor = _resultColor(result.result);
    final resultIcon  = _resultIcon(result.result);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.screeningResult, style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            provider.reset();
            context.go(RouteConstants.mainLayout);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _shareReport(context, provider, l10n, langCode),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Result Hero Card ─────────────────────────────────────────
              AppCard(
                color: resultColor.withValues(alpha: 0.05),
                borderRadius: AppSpacing.radiusXL,
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: resultColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(resultIcon, color: resultColor, size: 40),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.l, vertical: AppSpacing.s),
                      decoration: BoxDecoration(
                        color: resultColor,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusXL),
                      ),
                      child: Text(
                        _getOutcomeLabel(result.result, l10n),
                        style: AppTextStyles.button
                            .copyWith(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Text(
                      '${result.riskPercentage.toStringAsFixed(1)}%',
                      style: AppTextStyles.h1
                          .copyWith(fontSize: 48, color: resultColor),
                    ),
                    Text(l10n.riskScore, style: AppTextStyles.caption),
                    const SizedBox(height: AppSpacing.l),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusS),
                      child: LinearProgressIndicator(
                        value: result.riskPercentage / 100,
                        minHeight: 8,
                        backgroundColor: resultColor.withValues(alpha: 0.1),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(resultColor),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Text(
                      _getOutcomeNote(result.result, l10n),
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Score breakdown ──────────────────────────────────────────
              _sectionHeader(l10n.scoreBreakdown),
              const SizedBox(height: AppSpacing.s),
              AppCard(
                child: Column(
                  children: [
                    _ScoreRow(
                      label: 'Total Score',
                      value:
                          '${result.totalScore.toStringAsFixed(1)} / ${result.maxScore.toStringAsFixed(0)}',
                      color: resultColor,
                    ),
                    const Divider(),
                    ...provider.sections.map((s) {
                      final pct = result.sectionScores[s.index] ?? 0.0;
                      return _ScoreRow(
                        label: 'S${s.index + 1}: ${s.localizedTitle(langCode)}',
                        value: '${pct.toStringAsFixed(0)}%',
                        color: _pctColor(pct),
                        isSubRow: true,
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              _sectionHeader(l10n.riskScale),
              const SizedBox(height: AppSpacing.s),
              _RiskLegend(currentResult: result.result, l10n: l10n),

              const SizedBox(height: AppSpacing.xxxl),

              // ── BOA CTA: only shown when result is REFER ─────────────────
              if (result.result == RiskResult.refer) ...[
                _BoaReferralBanner(l10n: l10n),
                const SizedBox(height: AppSpacing.m),
                AppPrimaryButton(
                  label: l10n.proceedToBoa,
                  icon: Icons.hearing_rounded,
                  onPressed: () => context.push(RouteConstants.boaIntro),
                ),
                const SizedBox(height: AppSpacing.m),
              ],

              AppPrimaryButton(
                label: l10n.downloadReport,
                icon: Icons.download_rounded,
                onPressed: () => _shareReport(context, provider, l10n, langCode),
              ),

              const SizedBox(height: AppSpacing.m),

              AppSecondaryButton(
                label: l10n.back,
                icon: Icons.home_outlined,
                onPressed: () {
                  provider.reset();
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

  String _getOutcomeLabel(RiskResult result, AppLocalizations l10n) {
    switch (result) {
      case RiskResult.pass: return l10n.outcomePass;
      case RiskResult.monitor: return l10n.outcomeMonitor;
      case RiskResult.refer: return l10n.outcomeRefer;
    }
  }

  String _getOutcomeNote(RiskResult result, AppLocalizations l10n) {
    switch (result) {
      case RiskResult.pass: return l10n.passNote;
      case RiskResult.monitor: return l10n.monitorNote;
      case RiskResult.refer: return l10n.referralNote;
    }
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.bold, color: AppColors.primary),
    );
  }

  Color _resultColor(RiskResult r) {
    switch (r) {
      case RiskResult.pass:    return AppColors.success;
      case RiskResult.monitor: return AppColors.warning;
      case RiskResult.refer:   return AppColors.error;
    }
  }

  IconData _resultIcon(RiskResult r) {
    switch (r) {
      case RiskResult.pass:    return Icons.check_circle_rounded;
      case RiskResult.monitor: return Icons.watch_later_rounded;
      case RiskResult.refer:   return Icons.warning_rounded;
    }
  }

  Color _pctColor(double pct) {
    if (pct <= 30) return AppColors.success;
    if (pct <= 60) return AppColors.warning;
    return AppColors.error;
  }
}

// ── BOA Referral banner ───────────────────────────────────────────────────────
class _BoaReferralBanner extends StatelessWidget {
  final AppLocalizations l10n;
  const _BoaReferralBanner({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.hearing_rounded, color: AppColors.error, size: 22),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.boaRequiredTitle,
                    style: AppTextStyles.subheading1
                        .copyWith(color: AppColors.error)),
                const SizedBox(height: 4),
                Text(
                  l10n.boaRequiredDesc,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Existing helper widgets (unchanged) ──────────────────────────────────────

class _ScoreRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isSubRow;

  const _ScoreRow(
      {required this.label,
      required this.value,
      required this.color,
      this.isSubRow = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: isSubRow
                  ? AppTextStyles.bodyMedium
                  : AppTextStyles.subheading2
                      .copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s, vertical: 2),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusS)),
            child: Text(value,
                style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}

class _RiskLegend extends StatelessWidget {
  final RiskResult currentResult;
  final AppLocalizations l10n;
  const _RiskLegend({required this.currentResult, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final items = [
      _LegendItem('0–30%', l10n.outcomePass, AppColors.success, RiskResult.pass),
      _LegendItem(
          '31–60%', l10n.outcomeMonitor, AppColors.warning, RiskResult.monitor),
      _LegendItem('61–100%', l10n.outcomeRefer, AppColors.error, RiskResult.refer),
    ];

    return Row(
      children: items.map((item) {
        final isSelected = item.result == currentResult;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.all(AppSpacing.s),
            decoration: BoxDecoration(
              color: isSelected
                  ? item.color.withValues(alpha: 0.1)
                  : AppColors.surface,
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusM),
              border: Border.all(
                  color: isSelected ? item.color : AppColors.border,
                  width: isSelected ? 2 : 1),
            ),
            child: Column(
              children: [
                Text(item.label,
                    style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: item.color),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                ),
                Text(item.range,
                    style: AppTextStyles.caption
                        .copyWith(fontSize: 10)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LegendItem {
  final String range;
  final String label;
  final Color color;
  final RiskResult result;
  _LegendItem(this.range, this.label, this.color, this.result);
}