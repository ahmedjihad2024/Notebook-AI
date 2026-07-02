import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notebook_ai/core/extensions/extensions.dart';

import 'package:notebook_ai/core/ui_kit/shapes/gradient_border_side.dart';

/// Available animation presets for [CustomInkButton].
///
/// Wrap one in [ButtonAnimationSettings] to control duration/curve/intensity,
/// then pass it to:
///  - [CustomInkButton.tap]         — fires after a tap is recognized
///  - [CustomInkButton.longPress]   — fires after a long press
///  - [CustomInkButton.pressEffect] — plays *while* the finger is down
///    (best used with [scaleHold])
///
/// Or trigger any of them from outside via [CustomInkButtonController.play].
enum ButtonAnimation {
  /// No animation. Default — preserves the original behavior.
  none,

  /// Quick scale dip: 1 → 0.92 → 1. Snappy tap feedback.
  scaleTap,

  /// Jumps up then elastic-bounces back. Same as the bottom-nav style.
  jump,

  /// Brief scale-up pulse (1 → 1.12 → 1). Good to draw attention.
  pulse,

  /// Strong squish + elastic rebound.
  bounce,

  /// Shrinks while the finger is down, returns on release.
  /// Use with [CustomInkButton.pressEffect].
  scaleHold,

  /// Horizontal shake. Great for error feedback.
  shake,

  /// Rotational wiggle (left-right tilt).
  wiggle,

  /// "Broken" feel — right edge skews down then elastically returns. Like the
  /// button briefly cracks under the press.
  tilt,
}

/// Configures how a [ButtonAnimation] plays.
///
/// Every field is optional:
///  - [duration]  overrides the preset's default time
///  - [curve]     reshapes the timeline (applied to `t` before the animation math)
///  - [intensity] scales the magnitude of the effect (1.0 = default, 2.0 = double, 0.5 = half)
///
/// Construct with `const`:
/// ```dart
/// const ButtonAnimationSettings(
///   ButtonAnimation.shake,
///   duration: Duration(milliseconds: 600),
///   intensity: 1.5,
/// );
/// ```
@immutable
class ButtonAnimationSettings {
  final ButtonAnimation animation;
  final Duration? duration;
  final Curve? curve;
  final double intensity;

  const ButtonAnimationSettings(
    this.animation, {
    this.duration,
    this.curve,
    this.intensity = 1.0,
  });

  /// Shortcut for "no animation".
  static const none = ButtonAnimationSettings(ButtonAnimation.none);

  ButtonAnimationSettings copyWith({
    ButtonAnimation? animation,
    Duration? duration,
    Curve? curve,
    double? intensity,
  }) {
    return ButtonAnimationSettings(
      animation ?? this.animation,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      intensity: intensity ?? this.intensity,
    );
  }

  bool get isNone => animation == ButtonAnimation.none;

  @override
  bool operator ==(Object other) {
    return other is ButtonAnimationSettings &&
        other.animation == animation &&
        other.duration == duration &&
        other.curve == curve &&
        other.intensity == intensity;
  }

  @override
  int get hashCode => Object.hash(animation, duration, curve, intensity);
}

/// Triggers [CustomInkButton] animations from outside the widget.
///
/// Two ways to use it:
///
/// **One-shot**: fire a single animation right now.
/// ```dart
/// btn.shake();
/// btn.play(const ButtonAnimationSettings(ButtonAnimation.pulse));
/// ```
///
/// **Active override**: replace what runs on tap / long-press / press-down
/// until cleared.
/// ```dart
/// btn.setTap(const ButtonAnimationSettings(ButtonAnimation.shake)); // every tap shakes
/// btn.setTap(null); // back to whatever the widget was constructed with
/// ```
class CustomInkButtonController extends ChangeNotifier {
  ButtonAnimationSettings _pending = ButtonAnimationSettings.none;
  int _tick = 0;

  ButtonAnimationSettings? _tapOverride;
  ButtonAnimationSettings? _longPressOverride;
  ButtonAnimationSettings? _pressEffectOverride;

  ButtonAnimationSettings get pending => _pending;

  int get tick => _tick;

  ButtonAnimationSettings? get tap => _tapOverride;

  ButtonAnimationSettings? get longPress => _longPressOverride;

  ButtonAnimationSettings? get pressEffect => _pressEffectOverride;

  /// Plays [settings] as a one-shot. Calling again replays from the start.
  void play(ButtonAnimationSettings settings) {
    if (settings.isNone) return;
    _pending = settings;
    _tick++;
    notifyListeners();
  }

  /// Active override for tap. While set, every tap plays this regardless of
  /// what was passed to [CustomInkButton.tap]. Pass `null` to clear.
  void setTap(ButtonAnimationSettings? settings) {
    if (_tapOverride == settings) return;
    _tapOverride = settings;
    notifyListeners();
  }

  /// Active override for long-press.
  void setLongPress(ButtonAnimationSettings? settings) {
    if (_longPressOverride == settings) return;
    _longPressOverride = settings;
    notifyListeners();
  }

  /// Active override for the press-down effect.
  void setPressEffect(ButtonAnimationSettings? settings) {
    if (_pressEffectOverride == settings) return;
    _pressEffectOverride = settings;
    notifyListeners();
  }

  /// Clear all active overrides.
  void clearOverrides() {
    if (_tapOverride == null &&
        _longPressOverride == null &&
        _pressEffectOverride == null) {
      return;
    }
    _tapOverride = null;
    _longPressOverride = null;
    _pressEffectOverride = null;
    notifyListeners();
  }

  // Convenience one-shots with sensible defaults.
  void shake({Duration? duration, double intensity = 1.0}) => play(
    ButtonAnimationSettings(
      ButtonAnimation.shake,
      duration: duration,
      intensity: intensity,
    ),
  );

  void pulse({Duration? duration, double intensity = 1.0}) => play(
    ButtonAnimationSettings(
      ButtonAnimation.pulse,
      duration: duration,
      intensity: intensity,
    ),
  );

  void jump({Duration? duration, double intensity = 1.0}) => play(
    ButtonAnimationSettings(
      ButtonAnimation.jump,
      duration: duration,
      intensity: intensity,
    ),
  );

  void bounce({Duration? duration, double intensity = 1.0}) => play(
    ButtonAnimationSettings(
      ButtonAnimation.bounce,
      duration: duration,
      intensity: intensity,
    ),
  );

  void wiggle({Duration? duration, double intensity = 1.0}) => play(
    ButtonAnimationSettings(
      ButtonAnimation.wiggle,
      duration: duration,
      intensity: intensity,
    ),
  );

  void tilt({Duration? duration, double intensity = 1.0}) => play(
    ButtonAnimationSettings(
      ButtonAnimation.tilt,
      duration: duration,
      intensity: intensity,
    ),
  );
}

class CustomInkButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Color? splashColor;
  final Color? highlightColor;
  final double? borderRadius;
  final BorderRadius? customBorderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? shadowColor;
  final double? width;
  final double? height;
  final double? maxWidth;
  final double? maxHeight;
  final bool enabled;
  final Duration? animationDuration;
  final AlignmentGeometry? alignment;
  final GradientBorderSide side;
  final double smoothness;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final bool enableHapticFeedback;
  final Clip clipBehavior;

  /// Sigma for the backdrop blur applied behind the button (frosted-glass
  /// effect). When `null`, no blur is applied. Typical Figma values are 10–30.
  /// Pair with a translucent [backgroundColor] / [gradient] and a subtle
  /// [side] for the classic glass look.
  final double? glassBlur;

  /// When true (default), [side] is painted *on top of* the [glassBlur] so the
  /// border stays sharp. When false, the border is painted with the rest of
  /// the box decoration and the backdrop filter samples through it, blurring
  /// the border. Only meaningful when both [glassBlur] and a non-none [side]
  /// are set.
  final bool keepBorderCrisp;

  /// Animation played when the button is tapped.
  final ButtonAnimationSettings tap;

  /// Animation played when the button is long-pressed.
  final ButtonAnimationSettings longPress;

  /// Animation that runs *while* the finger is held down. Best paired with
  /// [ButtonAnimation.scaleHold] (shrink on hold, return on release).
  final ButtonAnimationSettings pressEffect;

  /// Optional external controller to fire animations programmatically
  /// (e.g. shake on validation error) or to override [tap]/[longPress]/[pressEffect]
  /// at runtime.
  final CustomInkButtonController? controller;

  /// When true the [child] is swapped for a small progress spinner and taps
  /// are ignored — async CTAs show their busy state in place.
  final bool isLoading;

  /// Spinner color while [isLoading]; defaults to white (primary buttons).
  final Color? loadingColor;

  const CustomInkButton({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.splashColor,
    this.highlightColor,
    this.borderRadius,
    this.customBorderRadius,
    this.padding,
    this.margin,
    this.elevation = 0,
    this.shadowColor,
    this.width,
    this.height,
    this.maxWidth,
    this.maxHeight,
    this.enabled = true,
    this.animationDuration,
    this.alignment,
    this.side = GradientBorderSide.none,
    this.smoothness = 0,
    this.gradient,
    this.boxShadow,
    this.enableHapticFeedback = false,
    this.clipBehavior = Clip.hardEdge,
    this.glassBlur,
    this.keepBorderCrisp = true,
    this.tap = ButtonAnimationSettings.none,
    this.longPress = ButtonAnimationSettings.none,
    this.pressEffect = ButtonAnimationSettings.none,
    this.controller,
    this.isLoading = false,
    this.loadingColor,
  });

  @override
  State<CustomInkButton> createState() => _CustomInkButtonState();
}

class _CustomInkButtonState extends State<CustomInkButton>
    with TickerProviderStateMixin {
  /// Drives one-shot animations (tap, long-press, controller.play).
  /// Timeline: t goes 0 → 1 over the animation's duration.
  late final AnimationController _oneShot;

  /// Drives the press effect. Timeline:
  ///  - press down  → animates t from current to 0.5 (the "loaded" peak)
  ///  - holding     → stays at 0.5
  ///  - press up    → animates t from 0.5 to 1.0 (the "release" half), then resets
  late final AnimationController _hold;

  ButtonAnimationSettings _oneShotSettings = ButtonAnimationSettings.none;
  ButtonAnimationSettings _holdSettings = ButtonAnimationSettings.none;
  int _lastControllerTick = 0;

  @override
  void initState() {
    super.initState();
    _oneShot = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _hold = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    final ctrl = widget.controller;
    if (ctrl != null) {
      _lastControllerTick = ctrl.tick;
      ctrl.addListener(_handleExternal);
    }
  }

  @override
  void didUpdateWidget(CustomInkButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleExternal);
      _lastControllerTick = widget.controller?.tick ?? 0;
      widget.controller?.addListener(_handleExternal);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleExternal);
    _oneShot.dispose();
    _hold.dispose();
    super.dispose();
  }

  void _handleExternal() {
    final ctrl = widget.controller;
    if (ctrl == null) return;
    if (ctrl.tick == _lastControllerTick) return;
    _lastControllerTick = ctrl.tick;
    _playOneShot(ctrl.pending);
  }

  Duration _defaultDurationFor(ButtonAnimation a) {
    switch (a) {
      case ButtonAnimation.scaleTap:
        return const Duration(milliseconds: 220);
      case ButtonAnimation.jump:
        return const Duration(milliseconds: 450);
      case ButtonAnimation.pulse:
        return const Duration(milliseconds: 320);
      case ButtonAnimation.bounce:
        return const Duration(milliseconds: 520);
      case ButtonAnimation.shake:
        return const Duration(milliseconds: 480);
      case ButtonAnimation.wiggle:
        return const Duration(milliseconds: 460);
      case ButtonAnimation.tilt:
        return const Duration(milliseconds: 520);
      case ButtonAnimation.scaleHold:
        return const Duration(milliseconds: 160);
      case ButtonAnimation.none:
        return const Duration(milliseconds: 200);
    }
  }

  void _playOneShot(ButtonAnimationSettings settings) {
    if (settings.isNone) return;
    _oneShotSettings = settings;
    _oneShot.duration =
        settings.duration ?? _defaultDurationFor(settings.animation);
    _oneShot.forward(from: 0);
  }

  ButtonAnimationSettings get _effectiveTap =>
      widget.controller?.tap ?? widget.tap;

  ButtonAnimationSettings get _effectiveLongPress =>
      widget.controller?.longPress ?? widget.longPress;

  ButtonAnimationSettings get _effectivePressEffect =>
      widget.controller?.pressEffect ?? widget.pressEffect;

  void _onPointerDown() {
    if (!widget.enabled) return;
    final effect = _effectivePressEffect;
    if (effect.isNone) return;
    _holdSettings = effect;

    // Total animation length splits in half: half on press, half on release.
    // Scale the press-down duration by how far we still have to travel so
    // re-presses mid-release feel snappy instead of slogging from 0.
    final totalMs = (effect.duration ?? _defaultDurationFor(effect.animation))
        .inMilliseconds;
    final pressMs = (totalMs / 2).round().clamp(40, 1200);
    final remaining = (0.5 - _hold.value).clamp(0.0, 0.5);
    final scaledMs = (pressMs * (remaining / 0.5)).round().clamp(40, pressMs);

    _hold.animateTo(
      0.5,
      duration: Duration(milliseconds: scaledMs),
      curve: Curves.easeOut,
    );
  }

  void _onPointerRelease() {
    if (_hold.value <= 0 && !_hold.isAnimating) return;

    final totalMs =
        (_holdSettings.duration ?? _defaultDurationFor(_holdSettings.animation))
            .inMilliseconds;
    final releaseMs = (totalMs / 2).round().clamp(40, 1500);
    final distance = (1.0 - _hold.value).clamp(0.0, 1.0);
    final scaledMs = (releaseMs * (distance / 0.5)).round().clamp(
      40,
      releaseMs,
    );

    _hold
        .animateTo(
          1.0,
          duration: Duration(milliseconds: scaledMs),
          curve: Curves.linear,
        )
        .whenComplete(() {
          if (!mounted) return;
          // Snap back to rest. At t = 1.0 every animation already renders rest
          // state (sin(π)=0, elastic returns to 0, etc.), so this is invisible.
          _hold.value = 0;
        });
  }

  void _handleTap() {
    if (widget.enableHapticFeedback) HapticFeedback.lightImpact();
    _playOneShot(_effectiveTap);
    widget.onTap?.call();
  }

  void _handleLongPress() {
    if (widget.enableHapticFeedback) HapticFeedback.mediumImpact();
    _playOneShot(_effectiveLongPress);
    widget.onLongPress?.call();
  }

  /// Applies the contribution of one animation at raw timeline position [rawT]
  /// (0 = rest, 0.5 = visual peak / "loaded", 1 = rest again) into [b].
  ///
  /// Used by both the one-shot driver and the press-hold driver — so every
  /// preset is reusable for tap, long-press, or press-and-hold.
  void _applyAnimation(
    double rawT,
    ButtonAnimationSettings s,
    _TransformBuilder b,
  ) {
    if (s.isNone) return;
    final t = (s.curve ?? Curves.linear).transform(rawT);
    final k = s.intensity;

    switch (s.animation) {
      case ButtonAnimation.scaleTap:
        // 1 → 0.92 → 1, peak shrink at t=0.5.
        b.scale *= 1.0 - 0.08 * k * math.sin(t * math.pi);
        break;

      case ButtonAnimation.scaleHold:
        // Slightly deeper shrink than scaleTap. Peak at t=0.5.
        b.scale *= 1.0 - 0.10 * k * math.sin(t * math.pi);
        break;

      case ButtonAnimation.pulse:
        // 1 → 1.12 → 1, peak at t=0.5.
        b.scale *= 1.0 + 0.12 * k * math.sin(t * math.pi);
        break;

      case ButtonAnimation.jump:
        // Rise in first half (smooth ease), elastic settle in second half.
        if (t < 0.5) {
          final p = Curves.fastEaseInToSlowEaseOut.transform(t / 0.5);
          b.ty -= 10.0 * k * p;
        } else {
          final p = Curves.elasticOut.transform((t - 0.5) / 0.5);
          b.ty -= 10.0 * k * (1 - p);
        }
        break;

      case ButtonAnimation.bounce:
        if (t < 0.5) {
          final p = Curves.easeOut.transform(t / 0.5);
          b.scale *= 1.0 - 0.10 * k * p;
        } else {
          final p = Curves.elasticOut.transform((t - 0.5) / 0.5);
          b.scale *= (1.0 - 0.10 * k) + 0.10 * k * p;
        }
        break;

      case ButtonAnimation.tilt:
        // Right edge skews down then elastically returns ("broken" feel).
        if (t < 0.5) {
          final p = Curves.easeOut.transform(t / 0.5);
          b.skew += 0.15 * k * p;
        } else {
          final p = Curves.elasticOut.transform((t - 0.5) / 0.5);
          b.skew += 0.15 * k * (1 - p);
        }
        break;

      case ButtonAnimation.shake:
        b.tx += math.sin(t * math.pi * 8) * 8.0 * k * (1 - t);
        break;

      case ButtonAnimation.wiggle:
        b.rot += math.sin(t * math.pi * 4) * 0.10 * k * (1 - t);
        break;

      case ButtonAnimation.none:
        break;
    }
  }

  _TransformBuilder _computeTransform() {
    final b = _TransformBuilder();

    // Press effect: _hold drives t directly (0 → 0.5 on press, holds, 0.5 → 1 on release).
    if (_hold.value > 0) {
      _applyAnimation(_hold.value, _holdSettings, b);
    }

    // One-shot effect: _oneShot drives t from 0 → 1 over its duration.
    if (_oneShot.isAnimating || (_oneShot.value > 0 && _oneShot.value < 1.0)) {
      _applyAnimation(_oneShot.value, _oneShotSettings, b);
    }

    return b;
  }

  bool get _hasAnyAnimation =>
      !widget.tap.isNone ||
      !widget.longPress.isNone ||
      !widget.pressEffect.isNone ||
      widget.controller != null;

  /// Shown in place of [CustomInkButton.child] while [CustomInkButton.isLoading].
  /// Fixed size so the button keeps its height during the busy state.
  Widget get _loadingIndicator => SizedBox(
    width: 22,
    height: 22,
    child: CircularProgressIndicator(
      strokeWidth: 2.2,
      valueColor: AlwaysStoppedAnimation<Color>(
        widget.loadingColor ?? Colors.white,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final Widget materialLayer = Material(
      color: Colors.transparent,
      elevation: widget.elevation ?? 0,
      shadowColor: widget.shadowColor,
      animationDuration:
          widget.animationDuration ?? const Duration(milliseconds: 200),
      child: InkWell(
        onTap: widget.enabled && !widget.isLoading && widget.onTap != null
            ? _handleTap
            : null,
        onLongPress:
            widget.enabled && !widget.isLoading && widget.onLongPress != null
            ? _handleLongPress
            : null,
        splashColor: widget.splashColor,
        highlightColor: widget.highlightColor,
        child: Container(
          constraints: BoxConstraints(
            minWidth: widget.width ?? 0,
            minHeight: widget.height ?? 0,
            maxWidth: widget.maxWidth ?? widget.width ?? double.infinity,
            maxHeight: widget.maxHeight ?? widget.height ?? double.infinity,
          ),
          padding: widget.padding,
          alignment: widget.isLoading ? Alignment.center : widget.alignment,
          child: widget.isLoading ? _loadingIndicator : widget.child,
        ),
      ),
    );

    final double? blur = widget.glassBlur;
    final Widget containerChild = blur == null
        ? materialLayer
        : Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: const SizedBox.expand(),
                ),
              ),
              materialLayer,
            ],
          );

    // When a glass blur is on and the caller wants a crisp border, paint the
    // border via `foregroundDecoration` so it lands on top of the blur layer
    // instead of being sampled through it.
    final bool liftBorder =
        blur != null &&
        widget.keepBorderCrisp &&
        widget.side != GradientBorderSide.none;

    final BorderRadius radius =
        widget.borderRadius == null && widget.customBorderRadius != null
        ? widget.customBorderRadius!
        : BorderRadius.circular(widget.borderRadius ?? 6);

    Widget inner = Container(
      clipBehavior: widget.clipBehavior == Clip.none && blur != null
          ? Clip.antiAlias
          : widget.clipBehavior,
      decoration: ShapeDecoration(
        color:
            widget.backgroundColor ??
            (widget.gradient == null
                ? context.theme.textButtonTheme.style?.backgroundColor?.resolve(
                    {},
                  )
                : null),
        gradient: widget.gradient,
        shadows: widget.boxShadow,
        shape: SmoothRectangleBorder(
          smoothness: widget.smoothness,
          borderRadius: radius,
          side: liftBorder ? GradientBorderSide.none : widget.side,
        ),
      ),
      foregroundDecoration: liftBorder
          ? ShapeDecoration(
              shape: SmoothRectangleBorder(
                smoothness: widget.smoothness,
                borderRadius: radius,
                side: widget.side,
              ),
            )
          : null,
      child: containerChild,
    );

    Widget result = inner;

    if (_hasAnyAnimation) {
      result = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _onPointerDown(),
        onPointerUp: (_) => _onPointerRelease(),
        onPointerCancel: (_) => _onPointerRelease(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_oneShot, _hold]),
          builder: (context, child) {
            final t = _computeTransform();
            final matrix = Matrix4.identity()
              ..translateByDouble(t.tx, t.ty, 0.0, 1.0)
              ..rotateZ(t.rot)
              ..scaleByDouble(t.scale, t.scale, 1.0, 1.0)
              ..multiply(Matrix4.skewY(t.skew));
            return Transform(
              alignment: Alignment.center,
              transform: matrix,
              child: child,
            );
          },
          child: inner,
        ),
      );
    }

    // A disabled button must look disabled — otherwise it reads as tappable
    // and a tap that does nothing feels broken. Loading keeps full opacity
    // (the spinner already communicates the busy state).
    if (!widget.enabled && !widget.isLoading) {
      result = AnimatedOpacity(
        opacity: 0.45,
        duration: const Duration(milliseconds: 150),
        child: result,
      );
    }

    if (widget.margin != null) {
      result = Padding(padding: widget.margin!, child: result);
    }

    return result;
  }
}

class _TransformBuilder {
  double scale = 1.0;
  double tx = 0.0;
  double ty = 0.0;
  double rot = 0.0;
  double skew = 0.0;
}
