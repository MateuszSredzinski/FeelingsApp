import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntensityButton extends StatelessWidget {
  const IntensityButton({
    super.key,
    required this.value,
    required this.maxValue,
    required this.onChanged,
    this.size = 30,
    this.enabled = true,
  });

  final int value;
  final int maxValue;
  final void Function(int) onChanged;
  final double size;
  final bool enabled;

  void _handleTap() {
    if (!enabled) return;
    HapticFeedback.lightImpact();
    final next = value >= maxValue ? 1 : value + 1;
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(1, maxValue);
    final textColor = enabled ? Colors.black87 : Colors.black45;
    return Semantics(
      label: 'Intensywnosc $clampedValue z $maxValue. Stuknij aby zmienic',
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? _handleTap : null,
        child: CustomPaint(
          size: Size.square(size),
          painter: _IntensityPainter(
            value: clampedValue,
            maxValue: maxValue,
            enabled: enabled,
          ),
          child: Center(
            child: Text(
              '$clampedValue',
              style: TextStyle(
                fontSize: size * 0.42,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntensityPainter extends CustomPainter {
  _IntensityPainter({
    required this.value,
    required this.maxValue,
    required this.enabled,
  });

  final int value;
  final int maxValue;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = enabled ? Colors.black26 : Colors.black12;

    final backgroundPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = enabled ? Colors.white.withOpacity(0.65) : Colors.white.withOpacity(0.4);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = enabled ? Colors.blueAccent.withOpacity(0.55) : Colors.blueGrey.withOpacity(0.25);

    final clipPath = Path()..addOval(rect);
    canvas.drawPath(clipPath, backgroundPaint);

    final fillFraction = (value / maxValue).clamp(0.0, 1.0);
    final fillHeight = size.height * fillFraction;
    final fillRect = Rect.fromLTWH(0, size.height - fillHeight, size.width, fillHeight);

    canvas.save();
    canvas.clipPath(clipPath);
    canvas.drawRect(fillRect, fillPaint);
    canvas.restore();

    canvas.drawPath(clipPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _IntensityPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.enabled != enabled;
  }
}
