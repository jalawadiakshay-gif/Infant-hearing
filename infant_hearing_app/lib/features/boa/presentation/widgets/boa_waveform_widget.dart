import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import '../../domain/boa_models.dart';
import '../state/boa_state.dart';

/// Animated waveform / sound indicator shown during BOA playback.
/// Uses a CustomPainter to draw sine-wave bars that animate when active.
class BoaWaveformWidget extends StatefulWidget {
  final BoaState state;

  const BoaWaveformWidget({super.key, required this.state});

  @override
  State<BoaWaveformWidget> createState() => _BoaWaveformWidgetState();
}

class _BoaWaveformWidgetState extends State<BoaWaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = widget.state.phase == BoaTestPhase.playing || widget.state.phase == BoaTestPhase.catchTrial;
    final isAwaiting = widget.state.phase == BoaTestPhase.awaitingResponse;

    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(
          color: isPlaying
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.border,
        ),
      ),
      child: isPlaying
          ? AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => CustomPaint(
                painter: _WaveformPainter(
                  progress: _anim.value,
                  color: AppColors.primary,
                ),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAwaiting
                        ? Icons.remove_red_eye_outlined
                        : Icons.graphic_eq_rounded,
                    size: 36,
                    color: isAwaiting
                        ? AppColors.secondary
                        : AppColors.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    isAwaiting
                        ? 'Observe infant response'
                        : 'Ready to play ${widget.state.currentDbLevel.label}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isAwaiting
                          ? AppColors.secondary
                          : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double progress;
  final Color color;

  _WaveformPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const barCount = 24;
    final barWidth = size.width / (barCount * 2);
    final centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final x = (i * 2 + 1) * barWidth;
      // Each bar gets a phase offset to create wave motion
      final phase = (i / barCount) * 2 * math.pi;
      final height = (math.sin(progress * 2 * math.pi + phase).abs() * 0.6 + 0.2) *
          (size.height * 0.4);

      canvas.drawLine(
        Offset(x, centerY - height),
        Offset(x, centerY + height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) => old.progress != progress;
}