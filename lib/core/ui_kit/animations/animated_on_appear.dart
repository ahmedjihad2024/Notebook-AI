import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'animations_enum.dart';

enum BlurAnimationDirection { x, y, both }

/// A widget that animates its child when it first appears on screen.
///
/// Unlike [AnimatedOnScroll], this widget automatically animates when it is built,
/// making it ideal for page transitions or initial animations.
///
/// Supports both enter and exit animations for list items, as well as ambient
/// looping effects (pulse / glow) that continue after the enter animation.
class AnimatedOnAppear extends StatefulWidget {
  // ===== Original fields (kept identical for backward compatibility) =====
  final Widget child;
  final int delay;
  final SlideDirection slideDirection;
  final RotationDirection rotationDirection;
  final double slideDistance;
  final double rotationAngle; // in degrees
  final Duration animationDuration;
  final Curve animationCurve;
  final Set<AnimationType> animationTypes;
  final bool animate;
  final VoidCallback? onAnimationComplete;
  final double scaleSize;
  final ShaderRevealDirection shaderDirection;
  final Color shaderRevealColor;
  final double shaderSoftness;
  final BlendMode shaderBlendMode;
  final double pluseInterval;
  final double pluseScale;

  // Exit animation properties
  final bool animateExit;
  final Duration exitDuration;
  final Curve exitCurve;
  final VoidCallback? onExitComplete;

  // Blur animation
  final Curve blurAnimationCurve;
  final double blurIntensity;
  final bool blurEnabled;
  final BlurAnimationDirection blurDirection;

  // ===== New: 3D flip =====
  /// Axis the flip rotates around. Defaults to [FlipAxis.vertical] (card-flip).
  final FlipAxis flipAxis;

  /// Starting flip angle in degrees. The widget animates from this value to 0.
  /// 90 = quarter turn, 180 = full flip.
  final double flipBeginAngle;

  /// Perspective applied to the flip transform. Larger values exaggerate depth.
  /// Typical range: 0.0005 – 0.003.
  final double flipPerspective;

  // ===== New: skew / 3D tilt =====
  /// Starting X-axis skew (radians). Animates to 0.
  final double skewBeginX;

  /// Starting Y-axis skew (radians). Animates to 0.
  final double skewBeginY;

  /// Perspective applied to the skew transform.
  final double skewPerspective;

  // ===== New: tint overlay =====
  /// Color overlaid on the child. Fades from full opacity to transparent during
  /// the enter animation. Defaults to transparent (no effect).
  final Color tintColor;

  /// BlendMode used when compositing [tintColor]. Use [BlendMode.srcATop] for a
  /// solid recolor or [BlendMode.modulate] for a multiplicative tint.
  final BlendMode tintBlendMode;

  // ===== New: glow / shadow pulse =====
  final Color glowColor;
  final double glowBlurRadius;
  final double glowSpreadRadius;
  final BorderRadius glowBorderRadius;

  // ===== New: loop / repeat ambient effects =====
  /// Whether ambient effects (pulse / glow) keep cycling after the enter
  /// animation completes.
  final LoopMode loopMode;

  /// Duration of one full loop cycle.
  final Duration loopDuration;

  /// Number of loop cycles. 0 = infinite (only meaningful when [loopMode] is
  /// not [LoopMode.none]).
  final int loopRepeatCount;

  /// Whether this widget should be kept alive when scrolled off-screen inside
  /// a lazy list. Defaults to `false` so list items are properly disposed and
  /// the surrounding `ListView` can stay lazy.
  final bool wantKeepAlive;

  const AnimatedOnAppear({
    super.key,
    required this.child,
    this.delay = 0,
    this.slideDirection = SlideDirection.up,
    this.rotationDirection = RotationDirection.left,
    this.slideDistance = 50.0,
    this.rotationAngle = 5.0,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeOutCubic,
    this.animationTypes = const {AnimationType.slide, AnimationType.fade},
    this.animate = true,
    this.onAnimationComplete,
    this.scaleSize = 0.9,
    this.shaderDirection = ShaderRevealDirection.bottomToTop,
    this.shaderRevealColor = Colors.white,
    this.shaderSoftness = 0.2,
    this.shaderBlendMode = BlendMode.dstIn,
    this.animateExit = false,
    this.exitDuration = const Duration(milliseconds: 300),
    this.exitCurve = Curves.easeInCubic,
    this.onExitComplete,
    this.blurDirection = BlurAnimationDirection.y,
    this.blurEnabled = false,
    this.blurIntensity = 7.0,
    this.blurAnimationCurve = Curves.fastEaseInToSlowEaseOut,
    this.pluseInterval = 0.7,
    this.pluseScale = 1.08,
    // New defaults — chosen to be no-ops unless the caller opts in via
    // [animationTypes] / [loopMode].
    this.flipAxis = FlipAxis.vertical,
    this.flipBeginAngle = 90.0,
    this.flipPerspective = 0.001,
    this.skewBeginX = 0.0,
    this.skewBeginY = 0.2,
    this.skewPerspective = 0.001,
    this.tintColor = Colors.transparent,
    this.tintBlendMode = BlendMode.srcATop,
    this.glowColor = const Color(0xFFFFFFFF),
    this.glowBlurRadius = 16.0,
    this.glowSpreadRadius = 2.0,
    this.glowBorderRadius = BorderRadius.zero,
    this.loopMode = LoopMode.none,
    this.loopDuration = const Duration(seconds: 2),
    this.loopRepeatCount = 0,
    this.wantKeepAlive = false,
  }) : assert(
         shaderSoftness >= 0 && shaderSoftness <= 1,
         'shaderSoftness must be between 0 and 1',
       );

  // Convert degrees to turns (used by rotation transition)
  double get _rotationInTurns => rotationAngle / 360.0;

  @override
  State<AnimatedOnAppear> createState() => _AnimatedOnAppearState();
}

class _AnimatedOnAppearState extends State<AnimatedOnAppear>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _animationController;
  AnimationController? _loopController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _shaderAnimation;
  late Animation<double> _blurAnimation;

  // New animations — all driven by _animationController via delayedCurve and
  // animate from their "start" value down to 0 (i.e. fully settled at end).
  late Animation<double> _flipAnimation;
  late Animation<double> _skewAnimation;
  late Animation<double> _tintAnimation;
  late Animation<double> _glowAnimation;

  // Loop animations driven by _loopController.
  Animation<double>? _loopPulseAnimation;
  Animation<double>? _loopGlowAnimation;

  bool _isExiting = false;
  bool _exitAnimationComplete = false;
  int _completedLoopCycles = 0;

  @override
  void initState() {
    super.initState();

    final totalDuration =
        widget.animationDuration + Duration(milliseconds: widget.delay);

    _animationController = AnimationController(
      vsync: this,
      duration: totalDuration,
    );

    final double delayFraction = widget.delay / totalDuration.inMilliseconds;
    final Interval delayedCurve = Interval(
      delayFraction,
      1.0,
      curve: widget.animationCurve,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: delayedCurve),
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: delayedCurve),
    );

    _scaleAnimation = Tween<double>(begin: widget.scaleSize, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: delayedCurve),
    );

    _blurAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: delayedCurve),
    );

    final double startAngle = widget.rotationDirection == RotationDirection.left
        ? widget._rotationInTurns
        : -widget._rotationInTurns;
    _rotationAnimation = Tween<double>(begin: startAngle, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: delayedCurve),
    );

    _shaderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.blurAnimationCurve,
      ),
    );

    final pulseStart =
        delayFraction + ((1.0 - delayFraction) * widget.pluseInterval);
    _pulseAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 1.0,
              end: widget.pluseScale,
            ).chain(CurveTween(curve: Curves.fastEaseInToSlowEaseOut)),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: widget.pluseScale,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.fastEaseInToSlowEaseOut)),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(pulseStart, 1.0),
          ),
        );

    // ===== New animations =====
    // All start at 1.0 (fully "off") and end at 0.0 (settled), so they are
    // no-ops once the enter animation completes.
    _flipAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: delayedCurve),
    );
    _skewAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: delayedCurve),
    );
    _tintAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: delayedCurve),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: delayedCurve),
    );

    _animationController.addStatusListener(_animationStatusListener);

    if (widget.animate) {
      _animationController.forward();
    }

    if (widget.loopMode != LoopMode.none) {
      _initLoopController();
    }
  }

  void _initLoopController() {
    _loopController = AnimationController(
      vsync: this,
      duration: widget.loopDuration,
    );

    _loopPulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: widget.pluseScale,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: widget.pluseScale,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_loopController!);

    _loopGlowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.4,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.4,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_loopController!);

    _loopController!.addStatusListener(_loopStatusListener);
  }

  void _loopStatusListener(AnimationStatus status) {
    if (widget.loopRepeatCount <= 0) return; // infinite — controller handles it
    if (status == AnimationStatus.completed ||
        (widget.loopMode == LoopMode.pingPong &&
            status == AnimationStatus.dismissed)) {
      _completedLoopCycles++;
      if (_completedLoopCycles >= widget.loopRepeatCount) {
        _loopController?.stop();
      }
    }
  }

  void _startLoopIfNeeded() {
    if (_loopController == null || _isExiting) return;
    if (widget.loopRepeatCount > 0 &&
        _completedLoopCycles >= widget.loopRepeatCount) {
      return;
    }
    _loopController!.repeat(reverse: widget.loopMode == LoopMode.pingPong);
  }

  void _animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (_isExiting) {
        _exitAnimationComplete = true;
        widget.onExitComplete?.call();
      } else {
        widget.onAnimationComplete?.call();
        _startLoopIfNeeded();
      }
    } else if (status == AnimationStatus.dismissed && _isExiting) {
      _exitAnimationComplete = true;
      widget.onExitComplete?.call();
    }
  }

  Alignment _shaderBeginAlignment(
    ShaderRevealDirection direction,
    TextDirection textDirection,
  ) {
    switch (direction) {
      case ShaderRevealDirection.bottomToTop:
        return Alignment.bottomCenter;
      case ShaderRevealDirection.topToBottom:
        return Alignment.topCenter;
      case ShaderRevealDirection.leftToRight:
        return Alignment.centerLeft;
      case ShaderRevealDirection.rightToLeft:
        return Alignment.centerRight;
      case ShaderRevealDirection.startToEnd:
        return textDirection == TextDirection.rtl
            ? Alignment.centerRight
            : Alignment.centerLeft;
      case ShaderRevealDirection.endToStart:
        return textDirection == TextDirection.rtl
            ? Alignment.centerLeft
            : Alignment.centerRight;
    }
  }

  Alignment _shaderEndAlignment(
    ShaderRevealDirection direction,
    TextDirection textDirection,
  ) {
    switch (direction) {
      case ShaderRevealDirection.bottomToTop:
        return Alignment.topCenter;
      case ShaderRevealDirection.topToBottom:
        return Alignment.bottomCenter;
      case ShaderRevealDirection.leftToRight:
        return Alignment.centerRight;
      case ShaderRevealDirection.rightToLeft:
        return Alignment.centerLeft;
      case ShaderRevealDirection.startToEnd:
        return textDirection == TextDirection.rtl
            ? Alignment.centerLeft
            : Alignment.centerRight;
      case ShaderRevealDirection.endToStart:
        return textDirection == TextDirection.rtl
            ? Alignment.centerRight
            : Alignment.centerLeft;
    }
  }

  List<double> _shaderStops(double progress) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final transitionEnd = (clampedProgress + widget.shaderSoftness).clamp(
      0.0,
      1.0,
    );

    if (transitionEnd <= 0) {
      return const [0.0, 0.0, 0.0];
    }

    if (clampedProgress <= 0.0) {
      return [0.0, 0.0, transitionEnd];
    }

    return [0.0, clampedProgress, transitionEnd];
  }

  /// Triggers the exit animation
  void exit() {
    if (widget.animateExit && !_isExiting) {
      setState(() {
        _isExiting = true;
      });
      _loopController?.stop();
      _animationController.duration = widget.exitDuration;
      _animationController.reverse();
    } else {
      widget.onExitComplete?.call();
    }
  }

  @override
  void didUpdateWidget(AnimatedOnAppear oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.exitDuration != oldWidget.exitDuration && _isExiting) {
      _animationController.duration = widget.exitDuration;
    }

    if (widget.animate && !oldWidget.animate && !_isExiting) {
      _animationController.duration =
          widget.animationDuration + Duration(milliseconds: widget.delay);
      _animationController.forward();
    } else if (!widget.animate && oldWidget.animate && !_isExiting) {
      _animationController.reverse();
    }

    // Loop mode toggled at runtime
    if (widget.loopMode != oldWidget.loopMode) {
      if (widget.loopMode == LoopMode.none) {
        _loopController?.stop();
      } else {
        _loopController ??= () {
          _initLoopController();
          return _loopController!;
        }();
        if (_animationController.status == AnimationStatus.completed) {
          _startLoopIfNeeded();
        }
      }
    }

    if (widget.loopDuration != oldWidget.loopDuration) {
      _loopController?.duration = widget.loopDuration;
    }
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(_animationStatusListener);
    _animationController.dispose();
    _loopController?.removeStatusListener(_loopStatusListener);
    _loopController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin

    if (_exitAnimationComplete) {
      return const SizedBox.shrink();
    }

    Widget animatedWidget = widget.child;

    // Innermost: pulse (existing) — fires once during enter.
    if (widget.animationTypes.contains(AnimationType.pulse)) {
      animatedWidget = ScaleTransition(
        scale: _pulseAnimation,
        child: animatedWidget,
      );
    }

    // Glow — wraps child early so subsequent transforms move the shadow with it.
    if (widget.animationTypes.contains(AnimationType.glow)) {
      animatedWidget = AnimatedBuilder(
        animation: Listenable.merge([_glowAnimation, _loopController]),
        child: animatedWidget,
        builder: (context, child) {
          final loopValue = _loopGlowAnimation?.value ?? 1.0;
          final intensity = _glowAnimation.value * loopValue;
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: widget.glowBorderRadius == BorderRadius.zero
                  ? null
                  : widget.glowBorderRadius,
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withOpacity(
                    (0.6 * intensity).clamp(0.0, 1.0),
                  ),
                  blurRadius: widget.glowBlurRadius * intensity,
                  spreadRadius: widget.glowSpreadRadius * intensity,
                ),
              ],
            ),
            child: child,
          );
        },
      );
    }

    if (widget.animationTypes.contains(AnimationType.scale)) {
      animatedWidget = ScaleTransition(
        scale: _scaleAnimation,
        child: animatedWidget,
      );
    }

    // Loop pulse — runs after enter animation completes.
    if (_loopPulseAnimation != null &&
        widget.animationTypes.contains(AnimationType.pulse)) {
      animatedWidget = ScaleTransition(
        scale: _loopPulseAnimation!,
        child: animatedWidget,
      );
    }

    // Tint overlay
    if (widget.animationTypes.contains(AnimationType.tint)) {
      animatedWidget = AnimatedBuilder(
        animation: _tintAnimation,
        child: animatedWidget,
        builder: (context, child) {
          final t = _tintAnimation.value.clamp(0.0, 1.0);
          if (t <= 0.001 || widget.tintColor.opacity == 0) {
            return child!;
          }
          return ColorFiltered(
            colorFilter: ColorFilter.mode(
              widget.tintColor.withOpacity(widget.tintColor.opacity * t),
              widget.tintBlendMode,
            ),
            child: child,
          );
        },
      );
    }

    if (widget.animationTypes.contains(AnimationType.rotation)) {
      animatedWidget = RotationTransition(
        turns: _rotationAnimation,
        child: animatedWidget,
      );
    }

    // 3D flip
    if (widget.animationTypes.contains(AnimationType.flip)) {
      animatedWidget = AnimatedBuilder(
        animation: _flipAnimation,
        child: animatedWidget,
        builder: (context, child) {
          final radians =
              widget.flipBeginAngle * _flipAnimation.value * math.pi / 180.0;
          final m = Matrix4.identity()..setEntry(3, 2, widget.flipPerspective);
          switch (widget.flipAxis) {
            case FlipAxis.horizontal:
              m.rotateX(radians);
              break;
            case FlipAxis.vertical:
              m.rotateY(radians);
              break;
            case FlipAxis.z:
              m.rotateZ(radians);
              break;
          }
          return Transform(
            alignment: Alignment.center,
            transform: m,
            child: child,
          );
        },
      );
    }

    // Skew / 3D tilt
    if (widget.animationTypes.contains(AnimationType.skew)) {
      animatedWidget = AnimatedBuilder(
        animation: _skewAnimation,
        child: animatedWidget,
        builder: (context, child) {
          final t = _skewAnimation.value;
          final m = Matrix4.identity()
            ..setEntry(3, 2, widget.skewPerspective)
            ..rotateX(widget.skewBeginX * t)
            ..rotateY(widget.skewBeginY * t);
          return Transform(
            alignment: Alignment.center,
            transform: m,
            child: child,
          );
        },
      );
    }

    if (widget.animationTypes.contains(AnimationType.shader)) {
      animatedWidget = AnimatedBuilder(
        animation: _shaderAnimation,
        builder: (context, child) {
          final progress = (widget.animate || _isExiting)
              ? _shaderAnimation.value
              : 1.0;
          final textDirection = Directionality.of(context);

          return ShaderMask(
            shaderCallback: (Rect bounds) {
              if (progress <= 0.0) {
                return LinearGradient(
                  begin: _shaderBeginAlignment(
                    widget.shaderDirection,
                    textDirection,
                  ),
                  end: _shaderEndAlignment(
                    widget.shaderDirection,
                    textDirection,
                  ),
                  colors: [
                    widget.shaderRevealColor.withOpacity(0.0),
                    widget.shaderRevealColor.withOpacity(0.0),
                  ],
                  stops: const [0.0, 1.0],
                ).createShader(bounds);
              }

              final stops = _shaderStops(progress);
              return LinearGradient(
                begin: _shaderBeginAlignment(
                  widget.shaderDirection,
                  textDirection,
                ),
                end: _shaderEndAlignment(widget.shaderDirection, textDirection),
                colors: [
                  widget.shaderRevealColor,
                  widget.shaderRevealColor,
                  widget.shaderRevealColor.withOpacity(0.0),
                ],
                stops: stops,
              ).createShader(bounds);
            },
            blendMode: widget.shaderBlendMode,
            child: child,
          );
        },
        child: animatedWidget,
      );
    }

    if (widget.animationTypes.contains(AnimationType.slide)) {
      animatedWidget = AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          double offset = widget.slideDistance * _slideAnimation.value;
          Offset translation;

          switch (widget.slideDirection) {
            case SlideDirection.up:
              translation = Offset(0, offset);
              break;
            case SlideDirection.down:
              translation = Offset(0, -offset);
              break;
            case SlideDirection.left:
              translation = Offset(offset, 0);
              break;
            case SlideDirection.right:
              translation = Offset(-offset, 0);
              break;
          }

          return Transform.translate(offset: translation, child: child);
        },
        child: animatedWidget,
      );
    }

    if (widget.animationTypes.contains(AnimationType.fade)) {
      animatedWidget = FadeTransition(
        opacity: _fadeAnimation,
        child: animatedWidget,
      );
    }

    if (widget.blurEnabled) {
      animatedWidget = AnimatedBuilder(
        animation: _blurAnimation,
        child: animatedWidget,
        builder: (context, child) {
          return ImageFiltered(
            imageFilter: switch (widget.blurDirection) {
              BlurAnimationDirection.x => ImageFilter.blur(
                sigmaX: widget.blurIntensity * _blurAnimation.value,
                sigmaY: 0,
              ),
              BlurAnimationDirection.y => ImageFilter.blur(
                sigmaX: 0,
                sigmaY: widget.blurIntensity * _blurAnimation.value,
              ),
              BlurAnimationDirection.both => ImageFilter.blur(
                sigmaX: widget.blurIntensity * _blurAnimation.value,
                sigmaY: widget.blurIntensity * _blurAnimation.value,
              ),
            },
            child: child,
          );
        },
      );
    }

    return animatedWidget;
  }

  @override
  bool get wantKeepAlive => widget.wantKeepAlive;
}

/// Extension to easily trigger exit animations
extension AnimatedOnAppearExtension on GlobalKey<_AnimatedOnAppearState> {
  /// Triggers the exit animation for this widget
  void exit() {
    currentState?.exit();
  }
}
