import 'dart:math';
import 'package:flutter/material.dart';

/// Animated audio waveform widget shown during BOA stimulus playback.
/// Renders animated sine bars to provide clear visual feedback to caregiver.
class AudioWaveformWidget extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final double progress;
  final int barCount;

  const AudioWaveformWidget({
    super.key,
    required this.isPlaying,
    required this.color,
    this.progress = 0.0,
    this.barCount = 20,
  });

  @override
  State<AudioWaveformWidget> createState() => _AudioWaveformWidgetState();
}

class _AudioWaveformWidgetState extends State<AudioWaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isPlaying) _controller.repeat();
  }

  @override
  void didUpdateWidget(AudioWaveformWidget old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _WaveformPainter(
              animValue: _controller.value,
              color: widget.color,
              barCount: widget.barCount,
              progress: widget.progress,
            ),
            size: const Size(double.infinity, 40),
          );
        },
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double animValue;
  final Color color;
  final int barCount;
  final double progress;
  final Random _random = Random(42); // Fixed seed for consistent bar heights

  _WaveformPainter({
    required this.animValue,
    required this.color,
    required this.barCount,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / (barCount * 1.8);
    final spacing = size.width / barCount;
    final maxH = size.height * 0.85;
    final minH = size.height * 0.12;
    final centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final x = i * spacing + spacing / 2;

      // Each bar has a unique phase offset for organic look
      final phase = (i / barCount) * 2 * pi;
      final wave = sin(animValue * 2 * pi + phase);
      final baseH = minH + (maxH - minH) * ((i % 5) / 4.0) * 0.6;
      final barH = (baseH + wave * baseH * 0.4).clamp(minH, maxH);

      // Bars to the left of progress marker are solid; right are faded
      final isElapsed = (i / barCount) < progress;
      final paint = Paint()
        ..color = isElapsed
            ? color.withOpacity(0.9)
            : color.withOpacity(0.25)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = barWidth;

      canvas.drawLine(
        Offset(x, centerY - barH / 2),
        Offset(x, centerY + barH / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.animValue != animValue || old.progress != progress;
}
