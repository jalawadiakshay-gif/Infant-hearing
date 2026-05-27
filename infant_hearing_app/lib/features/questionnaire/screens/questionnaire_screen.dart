import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/services/tts_service.dart';
import '../../../features/baby/providers/baby_provider.dart';
import '../../../features/asha/providers/asha_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../providers/questionnaire_provider.dart';
import '../widgets/question_card.dart';
import '../widgets/section_progress_header.dart';
import 'questionnaire_result_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  const QuestionnaireScreen({super.key, this.arguments});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> with WidgetsBindingObserver {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = widget.arguments;
      final int ageMonths;
      
      if (args != null && args.containsKey('ageMonths')) {
        ageMonths = args['ageMonths'] as int;
      } else {
        final baby = context.read<BabyProvider>().baby;
        ageMonths = baby?.ageMonths ?? 0;
      }
      
      context.read<QuestionnaireProvider>().initialize(ageMonths);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTts();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _stopTts();
    super.deactivate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _stopTts();
    }
  }

  void _stopTts() {
    // Access provider/service safely
    if (mounted) {
      Provider.of<TtsService>(context, listen: false).stop();
    }
  }

  void _onNext(QuestionnaireProvider provider) async {
    if (!provider.currentSectionComplete) {
      _showIncompleteDialog();
      return;
    }

    if (provider.isLastSection) {
      await provider.submit();
      
      final args = widget.arguments;
      if (args != null && args['filledByAsha'] == true) {
        final infantId = args['infantId'] as String;
        final ashaProvider = context.read<AshaProvider>();
        
        await ashaProvider.saveQuestionnaireResult(
          infantId: infantId,
          result: {
            'totalScore': provider.scoringResult?.totalScore,
            'riskPercentage': provider.scoringResult?.riskPercentage,
            'result': provider.scoringResult?.result.toString(),
            'answers': provider.answers.map((k, v) => MapEntry(k, v.toString())),
          },
        );
      }

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: provider,
            child: const QuestionnaireResultScreen(),
          ),
        ),
      );
    } else {
      _stopTts();
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
      _stopTts();
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusL)),
        title: Text('Unanswered Questions', style: AppTextStyles.h3),
        content: Text(
          'Please answer all questions in this section before proceeding.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(ctx).pop,
            child: Text('OK', style: AppTextStyles.button.copyWith(color: AppColors.primary)),
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
        final langCode = context.watch<LanguageProvider>().currentLanguage.code;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => _onBack(provider),
            ),
            title: Text('Phase 1 Screening', style: AppTextStyles.h3),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.l),
                  child: Text(
                    '${(provider.overallProgress * 100).toInt()}%',
                    style: AppTextStyles.button.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionProgressHeader(
                          currentSection: provider.currentSectionIndex,
                          totalSections: provider.sections.length,
                          sectionTitle: section.localizedTitle(langCode),
                          sectionSubtitle: section.localizedSubtitle(langCode),
                          answeredCount: provider.answeredInCurrentSection,
                          totalCount: section.questions.length,
                        ),

                        const SizedBox(height: AppSpacing.s),

                        if (!section.questions.first.scored)
                          AppCard(
                            color: AppColors.info.withOpacity(0.05),
                            padding: const EdgeInsets.all(AppSpacing.m),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.info),
                                const SizedBox(width: AppSpacing.s),
                                Expanded(
                                  child: Text(
                                    'This section is for information only and does not affect the risk score.',
                                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.info),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: AppSpacing.m),

                        ...section.questions.asMap().entries.map((entry) {
                          final i = entry.key;
                          final q = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.m),
                            child: QuestionCard(
                              questionNumber: i + 1,
                              question: q,
                              selectedAnswer: provider.getAnswer(q.id),
                              onAnswerSelected: (v) => provider.answer(q.id, v),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

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
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (!provider.isFirstSection) ...[
            Expanded(
              child: AppSecondaryButton(
                onPressed: onBack,
                label: l10n.back,
                icon: Icons.arrow_back_ios_new_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
          ],
          Expanded(
            flex: 2,
            child: AppPrimaryButton(
              onPressed: isComplete ? onNext : null,
              label: isLast ? l10n.submit : l10n.next,
              icon: isLast ? Icons.check_circle_outline : Icons.arrow_forward_ios_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
