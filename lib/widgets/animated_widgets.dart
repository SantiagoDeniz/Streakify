import 'package:flutter/material.dart';

/// Widget que anima números cuando cambian, con efecto de crecimiento
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: value.toDouble(),
      ),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Text(
          value.toInt().toString(),
          style: style,
        );
      },
    );
  }
}

/// Widget que escala al cambiar (efecto bounce)
class BouncingCounter extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final Duration bounceDuration;

  const BouncingCounter({
    super.key,
    required this.value,
    this.style,
    this.bounceDuration = const Duration(milliseconds: 300),
  });

  @override
  State<BouncingCounter> createState() => _BouncingCounterState();
}

class _BouncingCounterState extends State<BouncingCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late int _displayValue;

  @override
  void initState() {
    super.initState();
    _displayValue = widget.value;
    _controller = AnimationController(
      duration: widget.bounceDuration,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void didUpdateWidget(BouncingCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _displayValue = widget.value;
      _controller.forward(from: 0.0);
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
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Text(
            _displayValue.toString(),
            style: widget.style,
          ),
        );
      },
    );
  }
}

/// Widget para botón con animación bounce al presionar
class BounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;

  const BounceButton({
    super.key,
    required this.child,
    this.onPressed,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed != null ? _onTap : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Widget para transición suave entre temas
class ThemeFadeTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const ThemeFadeTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: child,
    );
  }
}
