import 'package:flutter/material.dart';

/// Generic overlay scaffold with backdrop and positioning
/// Works with any overlay type (popup, modal, toast, dialog, tooltip)
class OverlayScaffold extends StatelessWidget {
  final Widget child;
  final Color backdropColor;
  final VoidCallback? onBackdropTap;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;

  const OverlayScaffold({
    super.key,
    required this.child,
    this.backdropColor = const Color(0x80000000),
    this.onBackdropTap,
    this.alignment = Alignment.center,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop
        Positioned.fill(
          child: GestureDetector(
            onTap: onBackdropTap,
            child: Container(color: backdropColor),
          ),
        ),
        // Content with Material wrapper to prevent yellow underlines
        Align(
          alignment: alignment,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Material(type: MaterialType.transparency, child: child),
          ),
        ),
      ],
    );
  }
}

/// Generic animated overlay wrapper with configurable animations
/// Supports fade, scale, and slide animations in any combination
class AnimatedOverlay extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  /// Enable fade animation (default: true)
  final bool fade;

  /// Enable scale animation (default: true)
  final bool scale;

  /// Slide from offset (null = no slide)
  /// Examples:
  /// - Offset(0, 1) = slide from bottom
  /// - Offset(0, -1) = slide from top
  /// - Offset(-1, 0) = slide from left
  /// - Offset(1, 0) = slide from right
  final Offset? slideFrom;

  /// Scale animation start value (default: 0.95)
  final double scaleBegin;

  /// Scale animation end value (default: 1.0)
  final double scaleEnd;

  const AnimatedOverlay({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOut,
    this.fade = true,
    this.scale = true,
    this.slideFrom,
    this.scaleBegin = 0.95,
    this.scaleEnd = 1.0,
  });

  @override
  State<AnimatedOverlay> createState() => _AnimatedOverlayState();
}

class _AnimatedOverlayState extends State<AnimatedOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    final curvedAnimation =
        CurvedAnimation(parent: _controller, curve: widget.curve);

    // Fade animation
    _fadeAnimation = widget.fade
        ? Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation)
        : AlwaysStoppedAnimation(1.0);

    // Scale animation
    _scaleAnimation = widget.scale
        ? Tween<double>(begin: widget.scaleBegin, end: widget.scaleEnd)
            .animate(curvedAnimation)
        : AlwaysStoppedAnimation(1.0);

    // Slide animation
    _slideAnimation = widget.slideFrom != null
        ? Tween<Offset>(begin: widget.slideFrom!, end: Offset.zero)
            .animate(curvedAnimation)
        : null;

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = widget.child;

    // Apply scale if enabled
    if (widget.scale) {
      result = ScaleTransition(scale: _scaleAnimation, child: result);
    }

    // Apply slide if configured
    if (_slideAnimation != null) {
      result = SlideTransition(position: _slideAnimation, child: result);
    }

    // Apply fade if enabled
    if (widget.fade) {
      result = FadeTransition(opacity: _fadeAnimation, child: result);
    }

    return result;
  }
}

/// Position an overlay relative to a target widget
/// Useful for tooltips, dropdowns, and context menus
class PositionedOverlay extends StatelessWidget {
  final Widget child;
  final Rect targetRect;
  final OverlayPosition position;
  final double spacing;
  final EdgeInsetsGeometry margin;

  const PositionedOverlay({
    super.key,
    required this.child,
    required this.targetRect,
    this.position = OverlayPosition.bottom,
    this.spacing = 8.0,
    this.margin = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      delegate: _PositionedOverlayDelegate(
        targetRect: targetRect,
        position: position,
        spacing: spacing,
        margin: margin,
      ),
      child: child,
    );
  }
}

/// Position for PositionedOverlay
enum OverlayPosition {
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class _PositionedOverlayDelegate extends SingleChildLayoutDelegate {
  final Rect targetRect;
  final OverlayPosition position;
  final double spacing;
  final EdgeInsetsGeometry margin;

  _PositionedOverlayDelegate({
    required this.targetRect,
    required this.position,
    required this.spacing,
    required this.margin,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final margins = margin.resolve(TextDirection.ltr);
    return BoxConstraints.loose(
      Size(
        constraints.maxWidth - margins.horizontal,
        constraints.maxHeight - margins.vertical,
      ),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final margins = margin.resolve(TextDirection.ltr);
    final availableWidth = size.width - margins.horizontal;
    final availableHeight = size.height - margins.vertical;

    double left = 0;
    double top = 0;

    switch (position) {
      case OverlayPosition.top:
        left = targetRect.center.dx - childSize.width / 2;
        top = targetRect.top - childSize.height - spacing;
        break;
      case OverlayPosition.bottom:
        left = targetRect.center.dx - childSize.width / 2;
        top = targetRect.bottom + spacing;
        break;
      case OverlayPosition.left:
        left = targetRect.left - childSize.width - spacing;
        top = targetRect.center.dy - childSize.height / 2;
        break;
      case OverlayPosition.right:
        left = targetRect.right + spacing;
        top = targetRect.center.dy - childSize.height / 2;
        break;
      case OverlayPosition.topLeft:
        left = targetRect.left;
        top = targetRect.top - childSize.height - spacing;
        break;
      case OverlayPosition.topRight:
        left = targetRect.right - childSize.width;
        top = targetRect.top - childSize.height - spacing;
        break;
      case OverlayPosition.bottomLeft:
        left = targetRect.left;
        top = targetRect.bottom + spacing;
        break;
      case OverlayPosition.bottomRight:
        left = targetRect.right - childSize.width;
        top = targetRect.bottom + spacing;
        break;
    }

    // Constrain within available space
    left = left.clamp(
      margins.left,
      margins.left + availableWidth - childSize.width,
    );
    top = top.clamp(
      margins.top,
      margins.top + availableHeight - childSize.height,
    );

    return Offset(left, top);
  }

  @override
  bool shouldRelayout(_PositionedOverlayDelegate oldDelegate) {
    return targetRect != oldDelegate.targetRect ||
        position != oldDelegate.position ||
        spacing != oldDelegate.spacing ||
        margin != oldDelegate.margin;
  }
}
