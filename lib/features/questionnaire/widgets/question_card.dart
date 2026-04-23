// ─────────────────────────────────────────────────────────────────────────────
// widgets/question_card.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/questionnaire_models.dart';

class QuestionCard extends StatelessWidget {
  final int questionNumber;
  final Question question;
  final AnswerValue selectedAnswer;
  final ValueChanged<AnswerValue> onAnswerSelected;

  const QuestionCard({
    super.key,
    required this.questionNumber,
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selectedAnswer != AnswerValue.unanswered
              ? _borderColor(selectedAnswer).withOpacity(0.5)
              : AppColors.border,
          width: selectedAnswer != AnswerValue.unanswered ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number badge
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$questionNumber',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Question text + audio icon
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          question.text,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Audio placeholder icon
                      GestureDetector(
                        onTap: () {
                          // TODO: TTS playback
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.volume_up_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Answer buttons
            Row(
              children: [
                _AnswerButton(
                  label: 'Yes',
                  value: AnswerValue.yes,
                  selected: selectedAnswer == AnswerValue.yes,
                  color: const Color(0xFF34C789),
                  onTap: () => onAnswerSelected(AnswerValue.yes),
                ),
                const SizedBox(width: 8),
                _AnswerButton(
                  label: 'Partial',
                  value: AnswerValue.partial,
                  selected: selectedAnswer == AnswerValue.partial,
                  color: const Color(0xFFFF8C42),
                  onTap: () => onAnswerSelected(AnswerValue.partial),
                ),
                const SizedBox(width: 8),
                _AnswerButton(
                  label: 'No',
                  value: AnswerValue.no,
                  selected: selectedAnswer == AnswerValue.no,
                  color: const Color(0xFFE9445E),
                  onTap: () => onAnswerSelected(AnswerValue.no),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _borderColor(AnswerValue v) {
    switch (v) {
      case AnswerValue.yes:
        return const Color(0xFF34C789);
      case AnswerValue.partial:
        return const Color(0xFFFF8C42);
      case AnswerValue.no:
        return const Color(0xFFE9445E);
      default:
        return AppColors.border;
    }
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final AnswerValue value;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 38,
          decoration: BoxDecoration(
            color: selected ? color : color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? color : color.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
