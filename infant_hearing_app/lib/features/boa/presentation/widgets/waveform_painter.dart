import 'dart:math';
import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final double progress;
  final Color color;
  final List<double> values;

  WaveformPainter({required this.progress, required this.color, required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final middle = size.height / 2;
    final width = size.width;
    final step = width / values.length;

    for (int i = 0; i < values.length; i++) {
      final x = i * step;
      final height = values[i] * size.height * 0.8 * (0.5 + 0.5 * sin(progress * 2 * pi + i));
      canvas.drawLine(
        Offset(x, middle - height / 2),
        Offset(x, middle + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) => true;
}

class AudioWaveform extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  const AudioWaveform({super.key, required this.isPlaying, required this.color});

  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveform> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _values = List.generate(30, (index) => Random().nextDouble());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    if (widget.isPlaying) _controller.repeat();
  }

  @override
  void didUpdateWidget(AudioWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 40),
          painter: WaveformPainter(
            progress: _controller.value,
            color: widget.color,
            values: _values,
          ),
        );
      },
    );
  }
}
