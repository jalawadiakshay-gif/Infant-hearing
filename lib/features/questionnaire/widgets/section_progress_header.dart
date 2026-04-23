// ─────────────────────────────────────────────────────────────────────────────
// widgets/section_progress_header.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section pill
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Section ${currentSection + 1} of $totalSections',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '$answeredCount/$totalCount answered',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.textHint,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Section title
        Text(
          sectionTitle,
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          sectionSubtitle,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 16),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0 ? const Color(0xFF34C789) : AppColors.primary,
            ),
          ),
        ),

        const SizedBox(height: 20),

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
                      ? const Color(0xFF34C789)
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
