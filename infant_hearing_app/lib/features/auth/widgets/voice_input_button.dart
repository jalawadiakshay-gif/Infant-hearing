import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/language_provider.dart';
import '../../chatbot/services/speech_service.dart';

/// A mic button that starts/stops speech recognition in the selected language.
///
/// Usage:
/// ```dart
/// VoiceInputButton(
///   onResult: (text) => setState(() => _inputText = text),
/// )
/// ```
class VoiceInputButton extends StatelessWidget {
  final void Function(String recognizedText) onResult;
  final double size;

  const VoiceInputButton({
    super.key,
    required this.onResult,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final speechService = context.watch<SpeechService>();
    final langProvider = context.watch<LanguageProvider>();

    final isListening = speechService.isListening;
    final isUnavailable = speechService.status == SttStatus.unavailable;

    return Tooltip(
      message: isUnavailable
          ? l10n.sttNotAvailable
          : isListening
              ? l10n.chatbotListening
              : l10n.chatbotTapToSpeak,
      child: GestureDetector(
        onTap: isUnavailable
            ? null
            : () => _toggle(context, speechService, langProvider),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isUnavailable
                ? Colors.grey.shade300
                : isListening
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
            boxShadow: isListening
                ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 4,
                    )
                  ]
                : [],
          ),
          child: Icon(
            isListening ? Icons.stop : Icons.mic,
            color: Colors.white,
            size: size * 0.45,
          ),
        ),
      ),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    SpeechService speechService,
    LanguageProvider langProvider,
  ) async {
    if (speechService.isListening) {
      await speechService.stopListening();
      return;
    }

    await speechService.startListening(
      sttLocale: langProvider.sttLocale,
      onResult: (words, isFinal) {
        if (isFinal && words.isNotEmpty) {
          onResult(words);
        }
      },
    );
  }
}