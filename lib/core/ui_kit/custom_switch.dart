import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class CustomSwitch extends StatefulWidget {
  /// Whether this switch is on or off.
  final bool value;

  /// Called when the user toggles the switch.
  final ValueChanged<bool> onChanged;

  /// The width of the switch.
  final double width;

  /// The height of the switch.
  final double height;

  /// The padding between the thumb and the track.
  final double padding;

  /// The duration of the animation.
  final Duration duration;

  /// The curve of the animation.
  final Curve curve;

  /// The background of the track when the switch is on.
  /// This can be a color, gradient, image, or any widget.
  final Widget? activeTrackWidget;

  /// The background color of the track when the switch is on.
  /// This is used when [activeTrackWidget] is null.
  final Color activeTrackColor;

  /// The background of the track when the switch is off.
  /// This can be a color, gradient, image, or any widget.
  final Widget? inactiveTrackWidget;

  /// The background color of the track when the switch is off.
  /// This is used when [inactiveTrackWidget] is null.
  final Color inactiveTrackColor;

  /// The background of the thumb.
  /// This can be a color, gradient, image, or any widget.
  final Widget? thumbWidget;

  /// The color of the thumb.
  /// This is used when [thumbWidget] is null.
  final Color thumbColor;

  /// The border radius of the track.
  final BorderRadius? trackBorderRadius;

  /// The border radius of the thumb.
  final BorderRadius? thumbBorderRadius;

  /// The border of the track.
  final BoxBorder? trackBorder;

  /// The border of the thumb.
  final BoxBorder? thumbBorder;

  /// The shadow of the thumb.
  final List<BoxShadow>? thumbShadow;

  /// The shadow of the track.
  final List<BoxShadow>? trackShadow;

  /// The size of the thumb relative to the height of the track.
  /// A value of 1.0 means the thumb has the same height as the track.
  final double thumbSizeRatio;

  /// Whether to show a ripple effect when the switch is tapped.
  final bool enableFeedback;

  /// Whether to enable the glow effect around the thumb when active.
  final bool enableGlow;

  /// The color of the glow effect.
  final Color? glowColor;

  /// The intensity of the glow effect (0.0 to 1.0).
  final double glowIntensity;

  /// Whether to rotate the thumb when toggling.
  final bool rotateThumb;

  /// Whether to scale the thumb when toggling.
  final bool scaleThumb;

  /// The scale factor for the thumb when active.
  final double activeThumbScale;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 60.0,
    this.height = 30.0,
    this.padding = 2.0,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.activeTrackWidget,
    this.activeTrackColor = Colors.blue,
    this.inactiveTrackWidget,
    this.inactiveTrackColor = Colors.grey,
    this.thumbWidget,
    this.thumbColor = Colors.white,
    this.trackBorderRadius,
    this.thumbBorderRadius,
    this.trackBorder,
    this.thumbBorder,
    this.thumbShadow,
    this.trackShadow,
    this.thumbSizeRatio = 0.9,
    this.enableFeedback = true,
    this.enableGlow = false,
    this.glowColor,
    this.glowIntensity = 0.5,
    this.rotateThumb = false,
    this.scaleThumb = false,
    this.activeThumbScale = 1.1,
  });

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.value ? 1.0 : 0.0,
    );

    _updateAnimations();
  }

  void _updateAnimations() {
    final double thumbWidth = _calculateThumbWidth();
    final double trackWidth = widget.width;
    final double maxSlide = trackWidth - thumbWidth - (widget.padding * 2);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: Offset(maxSlide, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: widget.rotateThumb ? 2 * 3.14159 : 0.0, // Full rotation if enabled
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleThumb ? widget.activeThumbScale : 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: widget.enableGlow ? widget.glowIntensity : 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void didUpdateWidget(CustomSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }

    if (oldWidget.width != widget.width ||
        oldWidget.height != widget.height ||
        oldWidget.padding != widget.padding ||
        oldWidget.rotateThumb != widget.rotateThumb ||
        oldWidget.scaleThumb != widget.scaleThumb ||
        oldWidget.activeThumbScale != widget.activeThumbScale ||
        oldWidget.enableGlow != widget.enableGlow ||
        oldWidget.glowIntensity != widget.glowIntensity) {
      _updateAnimations();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _calculateThumbWidth() {
    // Make the thumb width proportional to the height
    return widget.height * widget.thumbSizeRatio;
  }

  @override
  Widget build(BuildContext context) {
    final double thumbHeight = widget.height * widget.thumbSizeRatio;
    final double thumbWidth = _calculateThumbWidth();

    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
        if (widget.enableFeedback) {
          switch (Theme.of(context).platform) {
            case TargetPlatform.android:
            case TargetPlatform.fuchsia:
            case TargetPlatform.linux:
            case TargetPlatform.windows:
              HapticFeedback.lightImpact();
              break;
            case TargetPlatform.iOS:
            case TargetPlatform.macOS:
              HapticFeedback.mediumImpact();
              break;
          }
        }
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius:
              widget.trackBorderRadius ??
              BorderRadius.circular(widget.height / 2),
          border: widget.trackBorder,
          boxShadow: widget.trackShadow,
        ),
        child: Stack(
          children: [
            // Track Background
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    borderRadius:
                        widget.trackBorderRadius ??
                        BorderRadius.circular(widget.height / 2),
                  ),
                  child: _controller.value > 0.5
                      ? widget.activeTrackWidget ??
                            Container(color: widget.activeTrackColor)
                      : widget.inactiveTrackWidget ??
                            Container(color: widget.inactiveTrackColor),
                );
              },
            ),

            // Thumb with animations
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned(
                  left: widget.padding + _slideAnimation.value.dx,
                  top: (widget.height - thumbHeight) / 2,
                  child: widget.enableGlow && _glowAnimation.value > 0
                      ? _buildGlowEffect(thumbWidth, thumbHeight)
                      : _buildThumb(thumbWidth, thumbHeight),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowEffect(double width, double height) {
    final Color glowColor = widget.glowColor ?? widget.activeTrackColor;

    return Container(
      width: width * (1 + _glowAnimation.value * 0.5),
      height: height * (1 + _glowAnimation.value * 0.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(_glowAnimation.value * 0.5),
            blurRadius: 10 * _glowAnimation.value,
            spreadRadius: 4 * _glowAnimation.value,
          ),
        ],
      ),
      child: Center(child: _buildThumb(width, height)),
    );
  }

  Widget _buildThumb(double width, double height) {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: Transform.rotate(
        angle: _rotationAnimation.value,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: widget.thumbColor,
            borderRadius:
                widget.thumbBorderRadius ?? BorderRadius.circular(height / 2),
            border: widget.thumbBorder,
            boxShadow:
                widget.thumbShadow ??
                [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
          ),
          child: widget.thumbWidget != null
              ? ClipRRect(
                  borderRadius:
                      widget.thumbBorderRadius ??
                      BorderRadius.circular(height / 2),
                  child: widget.thumbWidget,
                )
              : null,
        ),
      ),
    );
  }
}
