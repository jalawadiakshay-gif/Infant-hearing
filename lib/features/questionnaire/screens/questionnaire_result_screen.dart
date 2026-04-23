// ─────────────────────────────────────────────────────────────────────────────
// screens/questionnaire_result_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../providers/questionnaire_provider.dart';
import '../models/questionnaire_models.dart';

class QuestionnaireResultScreen extends StatelessWidget {
  const QuestionnaireResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestionnaireProvider>();
    final result = provider.scoringResult;

    if (result == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final resultColor = _resultColor(result.result);
    final resultIcon = _resultIcon(result.result);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Screening Result',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Result Hero Card ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: resultColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: resultColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: resultColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(resultIcon, color: resultColor, size: 44),
                    ),

                    const SizedBox(height: 16),

                    // Result label
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: resultColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        result.result.label,
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Risk percentage
                    Text(
                      '${result.riskPercentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.dmSans(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: resultColor,
                        letterSpacing: -2,
                      ),
                    ),
                    Text(
                      'Risk Score',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Progress arc (linear bar)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: result.riskPercentage / 100,
                        minHeight: 10,
                        backgroundColor: resultColor.withOpacity(0.15),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(resultColor),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Explanation
                    Text(
                      result.result.explanation,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Score breakdown ──────────────────────────────────────────
              _sectionHeader('SCORE BREAKDOWN'),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _ScoreRow(
                      label: 'Total Score',
                      value:
                          '${result.totalScore.toStringAsFixed(1)} / ${result.maxScore.toStringAsFixed(0)}',
                      color: resultColor,
                    ),
                    const Divider(height: 20),
                    ...provider.sections.map((s) {
                      final pct = result.sectionScores[s.index] ?? 0.0;
                      return Column(
                        children: [
                          _ScoreRow(
                            label: 'S${s.index + 1}: ${s.title}',
                            value: '${pct.toStringAsFixed(0)}%',
                            color: _pctColor(pct),
                            isSubRow: true,
                          ),
                          if (s != provider.sections.last)
                            const SizedBox(height: 6),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Risk legend ──────────────────────────────────────────────
              _sectionHeader('RISK SCALE'),
              const SizedBox(height: 12),
              _RiskLegend(currentResult: result.result),

              const SizedBox(height: 32),

              // ── Action buttons ───────────────────────────────────────────
              if (result.result == RiskResult.refer) ...[
                _ActionButton(
                  label: 'Proceed to BOA Test',
                  icon: Icons.hearing_rounded,
                  color: const Color(0xFFE9445E),
                  onTap: () =>
                      context.showSnackBar('BOA Test module coming soon!'),
                ),
                const SizedBox(height: 12),
              ],

              _ActionButton(
                label: 'Download Report',
                icon: Icons.download_rounded,
                color: AppColors.primary,
                onTap: () => context.showSnackBar('Report download coming soon!'),
              ),

              const SizedBox(height: 12),

              _ActionButton(
                label: 'Back to Home',
                icon: Icons.home_outlined,
                color: AppColors.textSecondary,
                outlined: true,
                onTap: () {
                  provider.reset();
                  context.pushReplacementNamed(RouteConstants.home);
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Color _resultColor(RiskResult r) {
    switch (r) {
      case RiskResult.pass:
        return const Color(0xFF34C789);
      case RiskResult.monitor:
        return const Color(0xFFFF8C42);
      case RiskResult.refer:
        return const Color(0xFFE9445E);
    }
  }

  IconData _resultIcon(RiskResult r) {
    switch (r) {
      case RiskResult.pass:
        return Icons.check_circle_rounded;
      case RiskResult.monitor:
        return Icons.watch_later_rounded;
      case RiskResult.refer:
        return Icons.warning_rounded;
    }
  }

  Color _pctColor(double pct) {
    if (pct <= 30) return const Color(0xFF34C789);
    if (pct <= 60) return const Color(0xFFFF8C42);
    return const Color(0xFFE9445E);
  }
}

// ── Score row ──────────────────────────────────────────────────────────────────
class _ScoreRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isSubRow;

  const _ScoreRow({
    required this.label,
    required this.value,
    required this.color,
    this.isSubRow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isSubRow) const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: isSubRow ? 13 : 14,
              fontWeight: isSubRow ? FontWeight.w500 : FontWeight.w700,
              color: isSubRow ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Risk legend ────────────────────────────────────────────────────────────────
class _RiskLegend extends StatelessWidget {
  final RiskResult currentResult;
  const _RiskLegend({required this.currentResult});

  @override
  Widget build(BuildContext context) {
    final items = [
      _LegendItem('0–30%', 'PASS', const Color(0xFF34C789), RiskResult.pass),
      _LegendItem(
          '31–60%', 'MONITOR', const Color(0xFFFF8C42), RiskResult.monitor),
      _LegendItem('61–100%', 'REFER', const Color(0xFFE9445E), RiskResult.refer),
    ];

    return Row(
      children: items
          .map((item) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.result == currentResult
                        ? item.color.withOpacity(0.12)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: item.result == currentResult
                          ? item.color
                          : AppColors.border,
                      width: item.result == currentResult ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        item.label,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: item.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.range,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
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

// ── Action button ──────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.outlined = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(14),
          border: outlined ? Border.all(color: AppColors.border, width: 1.5) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: outlined ? color : Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: outlined ? color : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
