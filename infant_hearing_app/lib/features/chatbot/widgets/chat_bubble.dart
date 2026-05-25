import 'package:flutter/material.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/features/chatbot/services/chat_message.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onSpeak;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onStop;
  final bool isSpeaking;
  final bool isPaused;

  const ChatBubble({
    super.key,
    required this.message,
    this.onSpeak,
    this.onPause,
    this.onResume,
    this.onStop,
    this.isSpeaking = false,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final showControls = !isUser && (isSpeaking || isPaused);
    final l10n = AppLocalizations.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          gradient: isUser ? AppColors.primaryGradient : null,
          color: isUser ? null : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppSpacing.radiusM),
            topRight: const Radius.circular(AppSpacing.radiusM),
            bottomLeft: Radius.circular(isUser ? AppSpacing.radiusM : AppSpacing.radiusS),
            bottomRight: Radius.circular(isUser ? AppSpacing.radiusS : AppSpacing.radiusM),
          ),
          border: isUser ? null : Border.all(color: AppColors.border),
          boxShadow: showControls ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 4, spreadRadius: 1)] : (isUser ? AppColors.softShadow : null),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    message.content,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (!isUser && onSpeak != null && !showControls) ...[
                  const SizedBox(width: AppSpacing.s),
                  Tooltip(
                    message: 'Read aloud',
                    child: GestureDetector(
                      onTap: onSpeak,
                      child: const Icon(Icons.volume_up_outlined, size: 20, color: AppColors.primary),
                    ),
                  ),
                ],
              ],
            ),
            if (showControls) ...[
              const SizedBox(height: AppSpacing.s),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSpeaking)
                    Tooltip(
                      message: 'Pause narration',
                      child: _ControlButton(
                        icon: Icons.pause_circle_filled_rounded,
                        color: AppColors.primary,
                        onTap: onPause,
                      ),
                    )
                  else if (isPaused)
                    Tooltip(
                      message: 'Resume narration',
                      child: _ControlButton(
                        icon: Icons.play_circle_filled_rounded,
                        color: AppColors.success,
                        onTap: onResume,
                      ),
                    ),
                  const SizedBox(width: AppSpacing.m),
                  Tooltip(
                    message: 'Stop narration',
                    child: _ControlButton(
                      icon: Icons.stop_circle_rounded,
                      color: AppColors.error,
                      onTap: onStop,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    isSpeaking ? l10n.chatbotNarrating : 'Paused',
                    style: AppTextStyles.caption.copyWith(
                      color: isSpeaking ? AppColors.primary : AppColors.textHint,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ControlButton({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color, size: 24),
    );
  }
}
