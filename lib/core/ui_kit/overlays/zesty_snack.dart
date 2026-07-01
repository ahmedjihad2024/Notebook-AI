import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:for_u/app/app.dart';

class ZestySnack {
  static ZestySnack? _instance;
  static ZestySnack get instance => _instance ??= ZestySnack._internal();
  ZestySnack._internal();

  OverlayEntry? _overlayEntry;
  void Function()? _hideFunction;

  void show(
    Widget widget, {
    Duration duration = const Duration(seconds: 3),
    bool blurEnabled = true,
    Duration displayAnimationDuration = const Duration(milliseconds: 800),
    Curve displayAnimationCurve = Curves.elasticOut,
    Duration hideAnimationDuration = const Duration(milliseconds: 800),
    Curve hideAnimationCurve = Curves.fastLinearToSlowEaseIn,
    Duration blurAnimationDuration = const Duration(milliseconds: 800),
    Curve displayBlurAnimationCurve = Curves.fastEaseInToSlowEaseOut,
    Curve hideBlurAnimationCurve = Curves.fastEaseInToSlowEaseOut,
    double blurYIntensity = 6,
  }) {
    _overlayEntry?.remove();
    _hideFunction = null;

    _overlayEntry = OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 0,
        right: 0,
        child: _ZestySnackWidget(
          zestySnack: this,
          widget: widget,
          duration: duration,
          blurEnabled: blurEnabled,
          displayAnimationDuration: displayAnimationDuration,
          displayAnimationCurve: displayAnimationCurve,
          hideAnimationDuration: hideAnimationDuration,
          hideAnimationCurve: hideAnimationCurve,
          blurAnimationDuration: blurAnimationDuration,
          displayBlurAnimationCurve: displayBlurAnimationCurve,
          hideBlurAnimationCurve: hideBlurAnimationCurve,
          blurYIntensity: blurYIntensity,
        ),
      ),
    );
    NAVIGATOR_KEY.currentState?.overlay?.insert(_overlayEntry!);
  }

  void hide() {
    _hideFunction?.call();
  }

  void _setHideFunction(void Function() fun) {
    _hideFunction = fun;
  }
}

class _ZestySnackWidget extends StatefulWidget {
  final Widget widget;
  final Duration duration;
  final bool blurEnabled;
  final Duration displayAnimationDuration;
  final Curve displayAnimationCurve;
  final Duration hideAnimationDuration;
  final Curve hideAnimationCurve;
  final Duration blurAnimationDuration;
  final Curve displayBlurAnimationCurve;
  final Curve hideBlurAnimationCurve;
  final double blurYIntensity;

  const _ZestySnackWidget({
    required this.zestySnack,
    required this.widget,
    required this.duration,
    required this.blurEnabled,
    required this.displayAnimationDuration,
    required this.displayAnimationCurve,
    required this.hideAnimationDuration,
    required this.hideAnimationCurve,
    required this.blurAnimationDuration,
    required this.displayBlurAnimationCurve,
    required this.hideBlurAnimationCurve,
    required this.blurYIntensity,
  });
  final ZestySnack zestySnack;

  @override
  State<_ZestySnackWidget> createState() => _ZestySnackWidgetState();
}

class _ZestySnackWidgetState extends State<_ZestySnackWidget>
    with TickerProviderStateMixin {
  ZestySnack get zestySnack => widget.zestySnack;
  double opacity = 0;
  Size size = Size.zero;

  late AnimationController displayAnimationController;
  late Animation<double> displayAnimation;

  late Timer animationTimer;

  late OverlayEntry currentOverlayEntry;

  late AnimationController blurAnimationController;
  late Animation<double> blurAnimation;

  @override
  void initState() {
    super.initState();

    currentOverlayEntry = zestySnack._overlayEntry!;

    blurAnimationController = AnimationController(
      vsync: this,
      duration: widget.blurAnimationDuration,
    );
    blurAnimation = blurAnimationController
        .drive(CurveTween(curve: widget.displayBlurAnimationCurve))
        .drive(Tween(begin: 1, end: 0));

    displayAnimationController = AnimationController(
      vsync: this,
      duration: widget.displayAnimationDuration,
    );

    displayAnimation = displayAnimationController
        .drive(CurveTween(curve: widget.displayAnimationCurve))
        .drive(Tween(begin: 1, end: 0));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.size != null) {
        size = context.size!;
        opacity = 1;
        setState(() {});
        displayAnimationController.forward();
        if (widget.blurEnabled) blurAnimationController.forward();
      }
    });

    zestySnack._setHideFunction(() {
      displayAnimationController.dispose();
      displayAnimationController = AnimationController(
        vsync: this,
        duration: widget.hideAnimationDuration,
      );

      displayAnimation = displayAnimationController
          .drive(CurveTween(curve: widget.hideAnimationCurve))
          .drive(Tween(begin: 0, end: 1));

      blurAnimation = blurAnimationController
          .drive(CurveTween(curve: widget.hideBlurAnimationCurve))
          .drive(Tween(begin: 0, end: .5));
      if (mounted) setState(() {});
      displayAnimationController.forward();
      if (widget.blurEnabled) blurAnimationController.forward();
      Future.delayed(widget.hideAnimationDuration, () {
        if (currentOverlayEntry == zestySnack._overlayEntry) {
          zestySnack._overlayEntry!.remove();
          zestySnack._overlayEntry = null;
        }
      });
    });

    animationTimer = Timer(widget.duration, () {
      zestySnack.hide();
    });
  }

  @override
  void dispose() {
    displayAnimationController.dispose();
    blurAnimationController.dispose();
    if (animationTimer.isActive) animationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: displayAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, displayAnimation.value * size.height),
          child: child!,
        );
      },
      child: Opacity(
        opacity: opacity,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              if (animationTimer.isActive) animationTimer.cancel();
              zestySnack.hide();
            },
            child: AnimatedBuilder(
              animation: blurAnimation,
              builder: (context, _) {
                return ImageFiltered(
                  enabled: widget.blurEnabled,
                  imageFilter: ImageFilter.blur(
                    sigmaX: 0,
                    sigmaY: widget.blurYIntensity * blurAnimation.value,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewPadding.bottom,
                    ),
                    child: widget.widget,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
