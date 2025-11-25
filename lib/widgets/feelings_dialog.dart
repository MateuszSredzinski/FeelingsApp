import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class FeelingsDialog extends StatefulWidget {
  const FeelingsDialog({
    super.key,
    required this.child,
    this.widthFactor = 0.9,
  });

  final Widget child;
  final double widthFactor;

  @override
  State<FeelingsDialog> createState() => _FeelingsDialogState();
}

class _FeelingsDialogState extends State<FeelingsDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dialogWidth = size.width * widget.widthFactor;
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: dialogWidth,
            maxHeight: size.height * 0.9,
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = _controller.value * 2 * pi;
              final colors = [
                Colors.blue.withOpacity(0.8),
                Colors.purple.withOpacity(0.7),
                Colors.cyan.withOpacity(0.7),
              ];

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: SweepGradient(
                    startAngle: 0,
                    endAngle: 2 * pi,
                    colors: colors,
                    transform: GradientRotation(angle),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 14,
                        offset: Offset(6, 6),
                      ),
                      BoxShadow(
                        color: Colors.white24,
                        blurRadius: 12,
                        offset: Offset(-6, -6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),
              );
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
