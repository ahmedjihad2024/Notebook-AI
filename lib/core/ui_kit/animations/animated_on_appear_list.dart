import 'package:flutter/material.dart';

import 'animated_on_appear.dart';
import 'animations_enum.dart';

/// Wraps a list of children, each with an [AnimatedOnAppear] whose [delay] is
/// auto-staggered by [staggerDelay] (multiplied by the child's index).
///
/// Use this when you want a cascading entrance for a list/grid without writing
/// the per-item delay math by hand.
///
/// All other animation parameters are forwarded to each [AnimatedOnAppear].
class AnimatedOnAppearList extends StatelessWidget {
  final List<Widget> children;

  /// Milliseconds added per index. e.g. [staggerDelay] = 80 means item 0 has
  /// 0ms delay, item 1 has 80ms, item 2 has 160ms, ...
  final int staggerDelay;

  /// Optional fixed delay applied to every child before the staggered delay.
  final int baseDelay;

  /// Maximum delay clamp (ms). 0 = no clamp. Useful when the list is long and
  /// you don't want the last items to take forever to appear.
  final int maxDelay;

  /// If true, the wrapping widget is a [Column]. Otherwise children are
  /// returned directly so callers can place them inside any layout.
  final bool wrapInColumn;

  // Forwarded AnimatedOnAppear parameters
  final SlideDirection slideDirection;
  final RotationDirection rotationDirection;
  final double slideDistance;
  final double rotationAngle;
  final Duration animationDuration;
  final Curve animationCurve;
  final Set<AnimationType> animationTypes;
  final bool animate;
  final double scaleSize;
  final ShaderRevealDirection shaderDirection;
  final Color shaderRevealColor;
  final double shaderSoftness;
  final BlendMode shaderBlendMode;
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
  final LoopMode loopMode;
  final Duration loopDuration;
  final int loopRepeatCount;
  final BlurAnimationDirection blurDirection;
  final bool blurEnabled;
  final double blurIntensity;
  final Curve blurAnimationCurve;

  const AnimatedOnAppearList({
    super.key,
    required this.children,
    this.staggerDelay = 80,
    this.baseDelay = 0,
    this.maxDelay = 0,
    this.wrapInColumn = false,
    this.slideDirection = SlideDirection.up,
    this.rotationDirection = RotationDirection.left,
    this.slideDistance = 50.0,
    this.rotationAngle = 5.0,
    this.animationDuration = const Duration(milliseconds: 600),
    this.animationCurve = Curves.easeOutCubic,
    this.animationTypes = const {AnimationType.slide, AnimationType.fade},
    this.animate = true,
    this.scaleSize = 0.9,
    this.shaderDirection = ShaderRevealDirection.bottomToTop,
    this.shaderRevealColor = Colors.white,
    this.shaderSoftness = 0.2,
    this.shaderBlendMode = BlendMode.dstIn,
    this.pluseInterval = 0.7,
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
    this.loopMode = LoopMode.none,
    this.loopDuration = const Duration(seconds: 2),
    this.loopRepeatCount = 0,
    this.blurDirection = BlurAnimationDirection.y,
    this.blurEnabled = false,
    this.blurIntensity = 7.0,
    this.blurAnimationCurve = Curves.fastEaseInToSlowEaseOut,
  });

  int _delayFor(int index) {
    int d = baseDelay + (index * staggerDelay);
    if (maxDelay > 0 && d > maxDelay) d = maxDelay;
    return d;
  }

  List<Widget> _buildItems() {
    return List<Widget>.generate(children.length, (i) {
      return AnimatedOnAppear(
        delay: _delayFor(i),
        slideDirection: slideDirection,
        rotationDirection: rotationDirection,
        slideDistance: slideDistance,
        rotationAngle: rotationAngle,
        animationDuration: animationDuration,
        animationCurve: animationCurve,
        animationTypes: animationTypes,
        animate: animate,
        scaleSize: scaleSize,
        shaderDirection: shaderDirection,
        shaderRevealColor: shaderRevealColor,
        shaderSoftness: shaderSoftness,
        shaderBlendMode: shaderBlendMode,
        pluseInterval: pluseInterval,
        pluseScale: pluseScale,
        flipAxis: flipAxis,
        flipBeginAngle: flipBeginAngle,
        flipPerspective: flipPerspective,
        skewBeginX: skewBeginX,
        skewBeginY: skewBeginY,
        skewPerspective: skewPerspective,
        tintColor: tintColor,
        tintBlendMode: tintBlendMode,
        glowColor: glowColor,
        glowBlurRadius: glowBlurRadius,
        glowSpreadRadius: glowSpreadRadius,
        glowBorderRadius: glowBorderRadius,
        loopMode: loopMode,
        loopDuration: loopDuration,
        loopRepeatCount: loopRepeatCount,
        blurDirection: blurDirection,
        blurEnabled: blurEnabled,
        blurIntensity: blurIntensity,
        blurAnimationCurve: blurAnimationCurve,
        child: children[i],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();
    if (wrapInColumn) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: items,
      );
    }
    return _StaggerChildrenInline(children: items);
  }
}

/// Used internally so callers can drop [AnimatedOnAppearList] inside e.g. a
/// `ListView` via `...AnimatedOnAppearList(...).expand()`. When not wrapping
/// in a Column, we return a Column anyway because returning a List<Widget>
/// from a Widget isn't possible. Use [wrapInColumn]=false + spread the
/// children manually if you need finer control:
///
/// ```dart
/// ListView(children: AnimatedOnAppearList.staggered(children: items))
/// ```
class _StaggerChildrenInline extends StatelessWidget {
  final List<Widget> children;
  const _StaggerChildrenInline({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

/// Convenience: return a `List<Widget>` of pre-staggered [AnimatedOnAppear]s
/// without any layout wrapper. Spread these into any list-based widget:
///
/// ```dart
/// ListView(children: staggeredAppearList(children: items, staggerDelay: 100))
/// ```
List<Widget> staggeredAppearList({
  required List<Widget> children,
  int staggerDelay = 80,
  int baseDelay = 0,
  int maxDelay = 0,
  SlideDirection slideDirection = SlideDirection.up,
  double slideDistance = 50.0,
  Duration animationDuration = const Duration(milliseconds: 600),
  Curve animationCurve = Curves.easeOutCubic,
  Set<AnimationType> animationTypes = const {
    AnimationType.slide,
    AnimationType.fade,
  },
  bool animate = true,
}) {
  return List<Widget>.generate(children.length, (i) {
    int delay = baseDelay + (i * staggerDelay);
    if (maxDelay > 0 && delay > maxDelay) delay = maxDelay;
    return AnimatedOnAppear(
      delay: delay,
      slideDirection: slideDirection,
      slideDistance: slideDistance,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      animationTypes: animationTypes,
      animate: animate,
      child: children[i],
    );
  });
}
