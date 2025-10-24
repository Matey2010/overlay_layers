import 'package:flutter/widgets.dart';

/// Base popup scaffold with backdrop and positioning
class PopupScaffold extends StatelessWidget {
  final Widget child;
  final Color backdropColor;
  final VoidCallback? onBackdropTap;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;

  const PopupScaffold({
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
            child: Container(
              color: backdropColor,
            ),
          ),
        ),
        // Content
        Align(
          alignment: alignment,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ],
    );
  }
}

/// Animated popup wrapper with fade and scale animation
class AnimatedPopup extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedPopup({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOut,
  });

  @override
  State<AnimatedPopup> createState() => _AnimatedPopupState();
}

class _AnimatedPopupState extends State<AnimatedPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Popup positioned at a specific location relative to a target widget
class PositionedPopup extends StatelessWidget {
  final Widget child;
  final Rect targetRect;
  final PopupPosition position;
  final double spacing;
  final EdgeInsetsGeometry margin;

  const PositionedPopup({
    super.key,
    required this.child,
    required this.targetRect,
    this.position = PopupPosition.bottom,
    this.spacing = 8.0,
    this.margin = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      delegate: _PopupPositionDelegate(
        targetRect: targetRect,
        position: position,
        spacing: spacing,
        margin: margin,
      ),
      child: child,
    );
  }
}

enum PopupPosition {
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class _PopupPositionDelegate extends SingleChildLayoutDelegate {
  final Rect targetRect;
  final PopupPosition position;
  final double spacing;
  final EdgeInsetsGeometry margin;

  _PopupPositionDelegate({
    required this.targetRect,
    required this.position,
    required this.spacing,
    required this.margin,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final margins = margin.resolve(TextDirection.ltr);
    return BoxConstraints.loose(Size(
      constraints.maxWidth - margins.horizontal,
      constraints.maxHeight - margins.vertical,
    ));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final margins = margin.resolve(TextDirection.ltr);
    final availableWidth = size.width - margins.horizontal;
    final availableHeight = size.height - margins.vertical;

    double left = 0;
    double top = 0;

    switch (position) {
      case PopupPosition.top:
        left = targetRect.center.dx - childSize.width / 2;
        top = targetRect.top - childSize.height - spacing;
        break;
      case PopupPosition.bottom:
        left = targetRect.center.dx - childSize.width / 2;
        top = targetRect.bottom + spacing;
        break;
      case PopupPosition.left:
        left = targetRect.left - childSize.width - spacing;
        top = targetRect.center.dy - childSize.height / 2;
        break;
      case PopupPosition.right:
        left = targetRect.right + spacing;
        top = targetRect.center.dy - childSize.height / 2;
        break;
      case PopupPosition.topLeft:
        left = targetRect.left;
        top = targetRect.top - childSize.height - spacing;
        break;
      case PopupPosition.topRight:
        left = targetRect.right - childSize.width;
        top = targetRect.top - childSize.height - spacing;
        break;
      case PopupPosition.bottomLeft:
        left = targetRect.left;
        top = targetRect.bottom + spacing;
        break;
      case PopupPosition.bottomRight:
        left = targetRect.right - childSize.width;
        top = targetRect.bottom + spacing;
        break;
    }

    // Constrain within available space
    left = left.clamp(margins.left, margins.left + availableWidth - childSize.width);
    top = top.clamp(margins.top, margins.top + availableHeight - childSize.height);

    return Offset(left, top);
  }

  @override
  bool shouldRelayout(_PopupPositionDelegate oldDelegate) {
    return targetRect != oldDelegate.targetRect ||
        position != oldDelegate.position ||
        spacing != oldDelegate.spacing ||
        margin != oldDelegate.margin;
  }
}
