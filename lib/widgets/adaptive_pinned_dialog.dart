import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:feelings/widgets/feelings_dialog.dart';

class AdaptivePinnedDialog extends StatefulWidget {
  const AdaptivePinnedDialog({
    super.key,
    required this.header,
    required this.footer,
    required this.bodyChildren,
    this.maxWidthFactor = 0.94,
    this.maxHeightFactor = 0.85,
    this.padding = const EdgeInsets.all(16),
    this.fadeHeight = 20,
    this.fadeRadius = 18,
    this.enableFadePulse = true,
  });

  final Widget header;
  final Widget footer;
  final List<Widget> bodyChildren;
  final double maxWidthFactor;
  final double maxHeightFactor;
  final EdgeInsets padding;
  final double fadeHeight;
  final double fadeRadius;
  final bool enableFadePulse;

  @override
  State<AdaptivePinnedDialog> createState() => _AdaptivePinnedDialogState();
}

class _AdaptivePinnedDialogState extends State<AdaptivePinnedDialog>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _pulseController;
  bool _showTopFade = false;
  bool _showBottomFade = false;
  bool _hasOverflow = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_updateFades);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFades());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _updateFades() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final nextOverflow = position.maxScrollExtent > 0.0;
    final nextShowTop = nextOverflow && position.pixels > 2;
    final nextShowBottom =
        nextOverflow && position.maxScrollExtent - position.pixels > 2;
    if (nextOverflow != _hasOverflow ||
        nextShowTop != _showTopFade ||
        nextShowBottom != _showBottomFade) {
      setState(() {
        _hasOverflow = nextOverflow;
        _showTopFade = nextShowTop;
        _showBottomFade = nextShowBottom;
      });
    }
  }

  Widget _buildFade(bool isTop) {
    final direction = isTop ? Alignment.topCenter : Alignment.bottomCenter;
    final opposite = isTop ? Alignment.bottomCenter : Alignment.topCenter;
    final radius = isTop
        ? BorderRadius.vertical(top: Radius.circular(widget.fadeRadius))
        : BorderRadius.vertical(bottom: Radius.circular(widget.fadeRadius));
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final t = widget.enableFadePulse
            ? (math.sin(_pulseController.value * math.pi * 2) + 1) / 2
            : 0.0;
        final opacity = 0.06 + 0.03 * t;
        return ClipRRect(
          borderRadius: radius,
          child: Container(
            height: widget.fadeHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: direction,
                end: opposite,
                colors: [
                  Colors.white.withOpacity(opacity),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FeelingsDialog(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: size.width * widget.maxWidthFactor,
            maxHeight: size.height * widget.maxHeightFactor,
          ),
          child: Padding(
            padding: widget.padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.header,
                const SizedBox(height: 12),
                Flexible(
                  fit: FlexFit.loose,
                  child: Stack(
                    children: [
                      ListView(
                        controller: _scrollController,
                        shrinkWrap: true,
                        physics: _hasOverflow
                            ? const BouncingScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        children: widget.bodyChildren,
                      ),
                      if (_showTopFade)
                        Align(
                          alignment: Alignment.topCenter,
                          child: _buildFade(true),
                        ),
                      if (_showBottomFade)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: _buildFade(false),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                widget.footer,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
