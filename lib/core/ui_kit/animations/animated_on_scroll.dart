import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'animated_on_appear.dart' show BlurAnimationDirection;
import 'animations_enum.dart';

/// Animates its child when it scrolls into view.
///
/// Backward-compatible defaults preserve the original behavior:
///   * Triggers once when ~30% of the widget enters the viewport.
///   * Does not reverse on exit.
///
/// New options enable replay-on-reenter, reverse-on-exit, parallax, and the
/// same advanced effects exposed by [AnimatedOnAppear].
class AnimatedOnScroll extends StatefulWidget {
  // ===== Original fields =====
  final Widget child;
  final ScrollController scrollController;
  final int delay;
  final SlideDirection slideDirection;
  final RotationDirection rotationDirection;
  final double slideDistance;
  final double rotationAngle;
  final Duration animationDuration;
  final Duration? animationDelay;
  final Curve animationCurve;
  final Set<AnimationType> animationTypes;

  // ===== New: scroll behavior =====
  /// Fraction of the widget's height that must be visible before the animation
  /// triggers. Range 0.0 – 1.0. Default 0.3 matches the original behavior.
  final double visibilityThreshold;

  /// If true (default), the animation runs only the first time the widget
  /// enters view. If false, it can replay each time the widget re-enters.
  final bool playOnce;

  /// If true, when [playOnce] is false and the widget scrolls out of view, the
  /// animation reverses back to its initial state. Ignored when [playOnce] is
  /// true.
  final bool reverseOnExit;

  /// Parallax translation applied to the child while scrolling. The child is
  /// translated by `(scrollOffset - initialOffset) * parallaxFactor`.
  /// 0.0 disables parallax. Typical values: 0.1 – 0.4.
  final double parallaxFactor;

  /// Axis along which [parallaxFactor] is applied.
  final Axis parallaxAxis;

  // ===== New: advanced effects (mirrors AnimatedOnAppear) =====
  final double scaleSize;
  final double pluseInterval;
  final double pluseScale;

  final FlipAxis flipAxis;
  final double flipBeginAngle;
  final double flipPerspective;

  final double skewBeginX;
  final double skewBeginY;
  final double skewPerspective;

  final Color tintColor;
  final BlendMode tintBlendMode;

  final Color glowColor;
  final double glowBlurRadius;
  final double glowSpreadRadius;
  final BorderRadius glowBorderRadius;

  final bool blurEnabled;
  final BlurAnimationDirection blurDirection;
  final double blurIntensity;

  final LoopMode loopMode;
  final Duration loopDuration;
  final int loopRepeatCount;

  const AnimatedOnScroll({
    super.key,
    required this.child,
    required this.scrollController,
    this.delay = 0,
    this.slideDirection = SlideDirection.up,
    this.rotationDirection = RotationDirection.left,
    this.slideDistance = 50.0,
    this.rotationAngle = 5.0,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationDelay,
    this.animationCurve = Curves.easeOutCubic,
    this.animationTypes = const {AnimationType.slide, AnimationType.fade},
    // Scroll behavior — defaults preserve the original behavior.
    this.visibilityThreshold = 0.3,
    this.playOnce = true,
    this.reverseOnExit = false,
    this.parallaxFactor = 0.0,
    this.parallaxAxis = Axis.vertical,
    // Advanced effects — defaults are no-ops unless [animationTypes] opts in.
    this.scaleSize = 0.8,
    this.pluseInterval = 0.6,
    this.pluseScale = 1.08,
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
    this.blurEnabled = false,
    this.blurDirection = BlurAnimationDirection.y,
    this.blurIntensity = 7.0,
    this.loopMode = LoopMode.none,
    this.loopDuration = const Duration(seconds: 2),
    this.loopRepeatCount = 0,
  }) : assert(
         visibilityThreshold >= 0.0 && visibilityThreshold <= 1.0,
         'visibilityThreshold must be between 0 and 1',
       );

  double get _rotationInTurns => rotationAngle / 360.0;

  @override
  State<AnimatedOnScroll> createState() => _AnimatedOnScrollState();
}

class _AnimatedOnScrollState extends State<AnimatedOnScroll>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  AnimationController? _loopController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _flipAnimation;
  late Animation<double> _skewAnimation;
  late Animation<double> _tintAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _blurAnimation;

  Animation<double>? _loopPulseAnimation;
  Animation<double>? _loopGlowAnimation;

  bool _isVisible = false;
  bool _hasPlayed = false;
  int _completedLoopCycles = 0;
  double _initialScrollOffset = 0.0;
  bool _hasRecordedInitialOffset = false;
  double _parallaxOffset = 0.0;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();

    final totalDuration =
        widget.animationDuration +
        (widget.animationDelay ?? Duration(milliseconds: widget.delay));

    _animationController = AnimationController(
      vsync: this,
      duration: totalDuration,
    );

    final double delayFraction =
        (widget.animationDelay?.inMilliseconds ?? widget.delay) /
        totalDuration.inMilliseconds;
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

    final double startAngle = widget.rotationDirection == RotationDirection.left
        ? widget._rotationInTurns
        : -widget._rotationInTurns;
    _rotationAnimation = Tween<double>(begin: startAngle, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: delayedCurve),
    );

    final pulseStart =
        delayFraction + ((1.0 - delayFraction) * widget.pluseInterval);
    _pulseAnimation =
        TweenSequence<double>([
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
        ]).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(pulseStart, 1.0),
          ),
        );

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
    _blurAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: delayedCurve),
    );

    if (widget.loopMode != LoopMode.none) {
      _initLoopController();
    }

    _animationController.addStatusListener(_onEnterStatus);

    widget.scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
    });
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
    if (widget.loopRepeatCount <= 0) return;
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
    if (_loopController == null) return;
    if (widget.loopRepeatCount > 0 &&
        _completedLoopCycles >= widget.loopRepeatCount) {
      return;
    }
    _loopController!.repeat(reverse: widget.loopMode == LoopMode.pingPong);
  }

  void _onEnterStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _isVisible) {
      _startLoopIfNeeded();
    }
  }

  void _onScroll() {
    if (!mounted) return;

    final RenderBox? renderBox =
        _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    final visibleHeight =
        math.min(position.dy + size.height, screenSize.height) -
        math.max(position.dy, 0);
    final fractionVisible = size.height <= 0
        ? 0.0
        : (visibleHeight / size.height).clamp(0.0, 1.0);

    final isVisible = fractionVisible >= widget.visibilityThreshold;

    if (isVisible != _isVisible) {
      _isVisible = isVisible;

      if (isVisible) {
        if (widget.playOnce && _hasPlayed) {
          // Already played; just resume the ambient loop if it was paused.
          if (_animationController.status == AnimationStatus.completed) {
            _startLoopIfNeeded();
          }
        } else {
          _hasPlayed = true;
          _animationController.forward(from: 0.0);
        }
      } else {
        // Out of view
        _loopController?.stop();
        if (!widget.playOnce && widget.reverseOnExit) {
          _animationController.reverse();
        }
      }

      if (mounted) setState(() {});
    }

    // Parallax offset
    if (widget.parallaxFactor != 0.0) {
      final currentOffset = widget.scrollController.hasClients
          ? widget.scrollController.offset
          : 0.0;
      if (!_hasRecordedInitialOffset) {
        _initialScrollOffset = currentOffset;
        _hasRecordedInitialOffset = true;
      }
      final newParallax =
          (currentOffset - _initialScrollOffset) * widget.parallaxFactor;
      if ((newParallax - _parallaxOffset).abs() > 0.5) {
        _parallaxOffset = newParallax;
        if (mounted) setState(() {});
      }
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedOnScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController != oldWidget.scrollController) {
      oldWidget.scrollController.removeListener(_onScroll);
      widget.scrollController.addListener(_onScroll);
    }
    if (widget.loopDuration != oldWidget.loopDuration) {
      _loopController?.duration = widget.loopDuration;
    }
    if (widget.loopMode != oldWidget.loopMode) {
      if (widget.loopMode == LoopMode.none) {
        _loopController?.stop();
      } else {
        _loopController ??= () {
          _initLoopController();
          return _loopController!;
        }();
        if (_animationController.status == AnimationStatus.completed &&
            _isVisible) {
          _startLoopIfNeeded();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget animatedWidget = widget.child;

    if (widget.animationTypes.contains(AnimationType.pulse)) {
      animatedWidget = ScaleTransition(
        scale: _pulseAnimation,
        child: animatedWidget,
      );
    }

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

    if (_loopPulseAnimation != null &&
        widget.animationTypes.contains(AnimationType.pulse)) {
      animatedWidget = ScaleTransition(
        scale: _loopPulseAnimation!,
        child: animatedWidget,
      );
    }

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

    // Parallax — applied last so it doesn't get cancelled by inner transforms.
    if (widget.parallaxFactor != 0.0) {
      final dx = widget.parallaxAxis == Axis.horizontal ? _parallaxOffset : 0.0;
      final dy = widget.parallaxAxis == Axis.vertical ? _parallaxOffset : 0.0;
      animatedWidget = Transform.translate(
        offset: Offset(dx, dy),
        child: animatedWidget,
      );
    }

    return Container(key: _key, child: animatedWidget);
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(_onEnterStatus);
    _animationController.dispose();
    _loopController?.removeStatusListener(_loopStatusListener);
    _loopController?.dispose();
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }
}
