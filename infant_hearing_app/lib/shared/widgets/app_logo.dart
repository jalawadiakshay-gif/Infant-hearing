import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Premium Medical Logo for Baalshravya
/// Rendered using CustomPaint for high-fidelity and scalability.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 120,
    this.showText = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _LogoPainter(
              color: color ?? AppColors.primary,
              accentColor: AppColors.secondary,
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'BAALSHRAVYA',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: size * 0.18,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'AI-ASSISTED INFANT HEARING SCREENING',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: size * 0.07,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;
  final Color accentColor;

  _LogoPainter({required this.color, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Draw Background Soft Circle with Gradient effect
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.01)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // 2. Draw Main Wave Path (Modernized Neural + Audio Flow)
    final mainPaint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.07
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    
    // Wave entry
    path.moveTo(size.width * 0.1, size.height * 0.5);
    
    // AI Activity spikes
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.5, size.width * 0.25, size.height * 0.4);
    path.lineTo(size.width * 0.35, size.height * 0.7);
    path.lineTo(size.width * 0.45, size.height * 0.2);
    path.lineTo(size.width * 0.55, size.height * 0.8);
    path.lineTo(size.width * 0.65, size.height * 0.5);
    
    // Smooth transition to Ear/Care form
    path.cubicTo(
      size.width * 0.75, size.height * 0.5,
      size.width * 0.9, size.height * 0.2,
      size.width * 0.85, size.height * 0.7
    );

    canvas.drawPath(path, mainPaint);

    // 3. AI Connectivity Points
    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    // Pulse nodes at key neural spikes
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.2), size.width * 0.045, accentPaint);
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.8), size.width * 0.035, accentPaint);
    
    // Innovation glow at the end
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.7), size.width * 0.08, glowPaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.7), size.width * 0.03, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
