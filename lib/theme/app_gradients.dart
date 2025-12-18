import 'package:flutter/material.dart';

/// Shared palette for the animated popup border and tile highlights.
class AppGradients {
  static const List<Color> sweepColors = [
    Color(0xCC2196F3), // blue with opacity ~0.8
    Color(0xB3703FBF), // purple with opacity ~0.7
    Color(0xB32DC3C9), // cyan with opacity ~0.7
  ];

  static const List<Color> tileSweepColors = [
    Color(0x802196F3), // lighter blue tint
    Color(0x80703FBF), // lighter purple tint
    Color(0x802DC3C9), // lighter cyan tint
    Color(0x8038A3D8), // blend between cyan and blue to soften transition
  ];

  static SweepGradient frozenSweep() => const SweepGradient(
        startAngle: 0,
        endAngle: 2 * 3.1415926535,
        colors: tileSweepColors,
      );

  static SweepGradient animatedSweep(double angle) => SweepGradient(
        startAngle: 0,
        endAngle: 2 * 3.1415926535,
        colors: sweepColors,
        transform: GradientRotation(angle),
      );
}
