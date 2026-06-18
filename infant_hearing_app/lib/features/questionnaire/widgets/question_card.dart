import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/providers/language_provider.dart';
import 'package:infant_hearing_app/core/services/tts_service.dart';
import 'package:infant_hearing_app/shared/widgets/app_card.dart';
import '../models/questionnaire_models.dart';

class QuestionCard extends StatefulWidget {
  final int questionNumber;
  final Question question;
  final AnswerValue selectedAnswer;
  final void Function(AnswerValue) onAnswerSelected;

  const QuestionCard({
    super.key,
    required this.questionNumber,
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final tts = context.watch<TtsService>();

    final questionText =
        widget.question.localizedText(langProvider.currentLanguage.code);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${widget.questionNumber}',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  questionText,
                  style: AppTextStyles.subheading2.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              _AudioControls(
                text: questionText,
                isSpeaking: tts.isSpeaking,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              _AnswerChip(
                label: _localizedLabel(
                    AnswerValue.yes, langProvider.currentLanguage.code),
                value: AnswerValue.yes,
                selected: widget.selectedAnswer,
                activeColor: AppColors.success,
                onTap: widget.onAnswerSelected,
              ),
              const SizedBox(width: AppSpacing.s),
              _AnswerChip(
                label: _localizedLabel(
                    AnswerValue.partial, langProvider.currentLanguage.code),
                value: AnswerValue.partial,
                selected: widget.selectedAnswer,
                activeColor: AppColors.warning,
                onTap: widget.onAnswerSelected,
              ),
              const SizedBox(width: AppSpacing.s),
              _AnswerChip(
                label: _localizedLabel(
                    AnswerValue.no, langProvider.currentLanguage.code),
                value: AnswerValue.no,
                selected: widget.selectedAnswer,
                activeColor: AppColors.error,
                onTap: widget.onAnswerSelected,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _localizedLabel(AnswerValue v, String langCode) {
    const labels = {
      'en': {
        AnswerValue.yes: 'Yes',
        AnswerValue.partial: 'Partial',
        AnswerValue.no: 'No',
      },
      'hi': {
        AnswerValue.yes: 'हाँ',
        AnswerValue.partial: 'आंशिक',
        AnswerValue.no: 'नहीं',
      },
      'kn': {
        AnswerValue.yes: 'ಹೌದು',
        AnswerValue.partial: 'ಭಾಗಶಃ',
        AnswerValue.no: 'ಇಲ್ಲ',
      },
      'mr': {
        AnswerValue.yes: 'हो',
        AnswerValue.partial: 'अंशतः',
        AnswerValue.no: 'नाही',
      },
    };
    return labels[langCode]?[v] ?? labels['en']![v]!;
  }
}

class _AudioControls extends StatefulWidget {
  final String text;
  final bool isSpeaking;

  const _AudioControls({
    required this.text,
    required this.isSpeaking,
  });

  @override
  State<_AudioControls> createState() => _AudioControlsState();
}

class _AudioControlsState extends State<_AudioControls> {
  bool _isPlayingThis = false;

  @override
  Widget build(BuildContext context) {
    final tts = context.watch<TtsService>();
    
    // If global TTS is not speaking, this card is also not playing
    if (!widget.isSpeaking && _isPlayingThis) {
      _isPlayingThis = false;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isPlayingThis) ...[
          IconButton(
            onPressed: () => tts.stop(),
            icon: const Icon(Icons.stop_circle_rounded, color: AppColors.error, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: AppSpacing.s),
          IconButton(
            onPressed: () => tts.speak(widget.text),
            icon: const Icon(Icons.replay_circle_filled_rounded, color: AppColors.primary, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ] else
          IconButton(
            onPressed: () {
              setState(() => _isPlayingThis = true);
              tts.speak(widget.text);
            },
            icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 28),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }
}

class _AnswerChip extends StatelessWidget {
  final String label;
  final AnswerValue value;
  final AnswerValue selected;
  final Color activeColor;
  final void Function(AnswerValue) onTap;

  const _AnswerChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(value),
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? activeColor : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
