// ─────────────────────────────────────────────────────────────────────────────
// screens/questionnaire_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../features/baby/providers/baby_provider.dart';
import '../providers/questionnaire_provider.dart';
import '../models/questionnaire_models.dart';
import '../widgets/question_card.dart';
import '../widgets/section_progress_header.dart';
import 'questionnaire_result_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final baby = context.read<BabyProvider>().baby;
      context.read<QuestionnaireProvider>().initialize(
            baby?.ageMonths ?? 0,
          );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onNext(QuestionnaireProvider provider) {
    if (!provider.currentSectionComplete) {
      _showIncompleteDialog();
      return;
    }

    if (provider.isLastSection) {
      final result = provider.submit();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: provider,
            child: const QuestionnaireResultScreen(),
          ),
        ),
      );
    } else {
      provider.nextSection();
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onBack(QuestionnaireProvider provider) {
    if (provider.isFirstSection) {
      Navigator.of(context).pop();
    } else {
      provider.previousSection();
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showIncompleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Unanswered Questions',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Please answer all questions in this section before proceeding.',
          style: GoogleFonts.dmSans(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(ctx).pop,
            child: Text(
              'OK',
              style: GoogleFonts.dmSans(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestionnaireProvider>(
      builder: (context, provider, _) {
        if (provider.sections.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final section = provider.currentSection;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => _onBack(provider),
            ),
            title: Text(
              'Phase 1 Screening',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '${(provider.overallProgress * 100).toInt()}%',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // ── Scrollable content ────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header
                        SectionProgressHeader(
                          currentSection: provider.currentSectionIndex,
                          totalSections: provider.sections.length,
                          sectionTitle: section.title,
                          sectionSubtitle: section.subtitle,
                          answeredCount: provider.answeredInCurrentSection,
                          totalCount: section.questions.length,
                        ),

                        const SizedBox(height: 8),

                        // Unscored badge for section 0
                        if (!section.questions.first.scored)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F8EF7).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded,
                                    size: 16, color: Color(0xFF4F8EF7)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'This section is for information only and does not affect the risk score.',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: const Color(0xFF4F8EF7),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Questions
                        ...section.questions.asMap().entries.map((entry) {
                          final i = entry.key;
                          final q = entry.value;
                          return QuestionCard(
                            questionNumber: i + 1,
                            question: q,
                            selectedAnswer: provider.getAnswer(q.id),
                            onAnswerSelected: (v) => provider.answer(q.id, v),
                          );
                        }),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // ── Bottom navigation bar ─────────────────────────────────
                _BottomNavBar(
                  provider: provider,
                  onBack: () => _onBack(provider),
                  onNext: () => _onNext(provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Bottom navigation bar ──────────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  final QuestionnaireProvider provider;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _BottomNavBar({
    required this.provider,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = provider.isLastSection;
    final isComplete = provider.currentSectionComplete;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back button
          if (!provider.isFirstSection)
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Back',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (!provider.isFirstSection) const SizedBox(width: 12),

          // Next / Submit button
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: onNext,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                decoration: BoxDecoration(
                  color: isComplete ? AppColors.primary : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLast ? 'Submit & View Result' : 'Next Section',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
