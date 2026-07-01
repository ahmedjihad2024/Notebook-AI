import 'package:flutter/material.dart';
import 'package:for_u/app/ui_kit/animations/animated_on_appear.dart';
import 'package:for_u/app/ui_kit/animations/animations_enum.dart';

extension PulseAnimation on Widget {
  Widget pluseAnimation(int index, [bool enablePluse = true]) {
    return AnimatedOnAppear(
      delay: 300 + (50 * index),
      animationTypes: enablePluse
          ? {AnimationType.fade, AnimationType.pulse}
          : {AnimationType.fade},
      animationDuration: Duration(milliseconds: 700),
      pluseInterval: .65,
      pluseScale: 1.015,
      child: this,
    );
  }
}

extension PremiumAppearAnimation on Widget {
  /// Premium entrance animation.
  ///
  /// Set [wantKeepAlive] to `true` if you want the animated widget to survive
  /// being scrolled off-screen inside a lazy list. Defaults to `false` so the
  /// child is disposed like any other lazy list item.
  Widget premiumAppear({
    int index = 0,
    int baseDelay = 100,
    bool wantKeepAlive = false,
  }) {
    return AnimatedOnAppear(
      delay: baseDelay + (index * 80),
      slideDistance: 30.0,
      slideDirection: SlideDirection.up,
      animationDuration: const Duration(milliseconds: 500),
      animationCurve:
          Curves.fastEaseInToSlowEaseOut, //Curves.easeOutCirc, // easeInOutCirc
      exitCurve: Curves.fastEaseInToSlowEaseOut,
      animationTypes: const {
        AnimationType.slide,
        AnimationType.fade,
        AnimationType.scale,
      },
      scaleSize: 0.98,
      wantKeepAlive: wantKeepAlive,
      child: this,
    );
  }
}

extension ContainerSlideAnimation on Widget {
  Widget containerSlideUp({int delay = 0, double slideDistance = 60.0}) {
    return AnimatedOnAppear(
      delay: delay,
      slideDistance: slideDistance,
      slideDirection: SlideDirection.up,
      animationDuration: const Duration(milliseconds: 700),
      animationCurve: Curves.easeOutQuart,
      animationTypes: const {AnimationType.slide, AnimationType.fade},
      child: this,
    );
  }
}
