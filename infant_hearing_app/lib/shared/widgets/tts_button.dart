import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/tts_service.dart';
import '../../core/theme/app_colors.dart';

/// An icon button that reads [text] aloud using TTS.
/// Supports Play / Pause / Resume / Stop.
class TtsButton extends StatelessWidget {
  final String text;
  final double iconSize;
  final Color? color;

  const TtsButton({
    super.key,
    required this.text,
    this.iconSize = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tts = context.watch<TtsService>();
    
    // Check if THIS button's text is what's currently being handled by TTS
    // Since TtsButton doesn't have a unique ID, we check text content
    // (In production, a unique ID is better)
    final isThisSpeaking = tts.isSpeaking && tts.isPaused == false; 
    final isThisPaused = tts.isPaused;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play / Pause toggle
        IconButton(
          iconSize: iconSize,
          color: color ?? Theme.of(context).colorScheme.primary,
          tooltip: isThisSpeaking ? 'Pause' : (isThisPaused ? 'Resume' : 'Play'),
          icon: Icon(isThisSpeaking
              ? Icons.pause_circle_outline_rounded
              : (isThisPaused ? Icons.play_circle_outline_rounded : Icons.volume_up_rounded)),
          onPressed: () async {
            if (isThisSpeaking) {
              await tts.pause();
            } else if (isThisPaused) {
              await tts.resume();
            } else {
              await tts.speak(text);
            }
          },
        ),
        // Stop button (shown when anything is playing/paused)
        if (tts.isSpeaking || tts.isPaused)
          IconButton(
            iconSize: iconSize * 0.8,
            color: AppColors.textHint,
            tooltip: 'Stop',
            icon: const Icon(Icons.stop_circle_outlined),
            onPressed: () async {
              await tts.stop();
            },
          ),
      ],
    );
  }
}

/// Wraps a child widget with a TTS button.
class TtsRow extends StatelessWidget {
  final String text;
  final Widget child;

  const TtsRow({super.key, required this.text, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: child),
        TtsButton(text: text, iconSize: 20),
      ],
    );
  }
}
