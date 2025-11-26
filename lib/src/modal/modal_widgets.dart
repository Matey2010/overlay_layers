import 'package:flutter/material.dart';

/// Base modal scaffold with backdrop and positioning
/// Modals typically cover the full screen with centered content
class ModalScaffold extends StatelessWidget {
  final Widget child;
  final Color backdropColor;
  final VoidCallback? onBackdropTap;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;

  const ModalScaffold({
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

/// Animated modal wrapper with fade and scale animation
class AnimatedModal extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedModal({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
  });

  @override
  State<AnimatedModal> createState() => _AnimatedModalState();
}

class _AnimatedModalState extends State<AnimatedModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

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
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

/// Modal that slides up from the bottom (like bottom sheet)
class SlideUpModal extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const SlideUpModal({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
  });

  @override
  State<SlideUpModal> createState() => _SlideUpModalState();
}

class _SlideUpModalState extends State<SlideUpModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

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
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
