import 'package:flutter/material.dart';

/// Two flavors of window/layout getters — pick per call site:
///
/// * **Device snapshot (no suffix)** — backed by `View.of(context)`. Reads
///   the value once from the raw `FlutterView`. NO subscription, so no
///   rebuilds when the value changes (keyboard, rotation, etc.). Use when
///   you want a one-shot read at build time, or when something else is
///   already driving rebuilds.
///
/// * **Reactive (`Media` suffix)** — backed by `MediaQuery.xxxOf(context)`
///   aspect helpers. Registers the widget as a dependent of ONLY that one
///   slice (`InheritedModel`), so it rebuilds when *that specific* value
///   changes (e.g. keyboard for `viewInsets`, safe area for `viewPadding`).
///   This is NOT the legacy `MediaQuery.of(context)` rebuild-storm — each
///   helper is its own slice, not the whole `MediaQueryData`.
///
/// Rule of thumb: reach for the `Media` variant when you actually need the
/// widget to react to that change (e.g. a sheet lifting over the keyboard).
/// Stick with the plain getter for one-shot reads.
// dart format off
extension ViewExt on BuildContext{
  // ----- Device snapshot (View.of) — no rebuild on change -----
  double get devicePixelRatio       => View.of(this).devicePixelRatio;

  double get screenWidth            => View.of(this).display.size.width / devicePixelRatio;
  double get screenHeight           => View.of(this).display.size.height / devicePixelRatio;

  double get topPadding             => View.of(this).padding.top / devicePixelRatio;
  double get bottomPadding          => View.of(this).padding.bottom / devicePixelRatio;
  double get leftPadding            => View.of(this).padding.left / devicePixelRatio;
  double get rightPadding           => View.of(this).padding.right / devicePixelRatio;

  double get topSafeAreaPadding     => View.of(this).viewPadding.top / devicePixelRatio;
  double get bottomSafeAreaPadding  => View.of(this).viewPadding.bottom / devicePixelRatio;
  double get leftSafeAreaPadding    => View.of(this).viewPadding.left / devicePixelRatio;
  double get rightSafeAreaPadding   => View.of(this).viewPadding.right / devicePixelRatio;

  double get bottomViewInsets       => View.of(this).viewInsets.bottom / devicePixelRatio;
  double get topViewInsets          => View.of(this).viewInsets.top / devicePixelRatio;
  double get leftViewInsets         => View.of(this).viewInsets.left / devicePixelRatio;
  double get rightViewInsets        => View.of(this).viewInsets.right / devicePixelRatio;

  double get textScaleFactor        => View.of(this).platformDispatcher.textScaleFactor;
  TextScaler get textScaler         => TextScaler.linear(textScaleFactor);

  TextDirection get textDirection   => Directionality.of(this);
  bool get isRTL                    => textDirection == TextDirection.rtl;
  bool get isLTR                    => textDirection == TextDirection.ltr;

  // ----- Reactive (MediaQuery aspect helpers) — rebuilds on change -----
  double get devicePixelRatioMedia       => MediaQuery.devicePixelRatioOf(this);

  double get screenWidthMedia            => MediaQuery.sizeOf(this).width;
  double get screenHeightMedia           => MediaQuery.sizeOf(this).height;

  double get topPaddingMedia             => MediaQuery.paddingOf(this).top;
  double get bottomPaddingMedia          => MediaQuery.paddingOf(this).bottom;
  double get leftPaddingMedia            => MediaQuery.paddingOf(this).left;
  double get rightPaddingMedia           => MediaQuery.paddingOf(this).right;

  double get topSafeAreaPaddingMedia     => MediaQuery.viewPaddingOf(this).top;
  double get bottomSafeAreaPaddingMedia  => MediaQuery.viewPaddingOf(this).bottom;
  double get leftSafeAreaPaddingMedia    => MediaQuery.viewPaddingOf(this).left;
  double get rightSafeAreaPaddingMedia   => MediaQuery.viewPaddingOf(this).right;

  double get bottomViewInsetsMedia       => MediaQuery.viewInsetsOf(this).bottom;
  double get topViewInsetsMedia          => MediaQuery.viewInsetsOf(this).top;
  double get leftViewInsetsMedia         => MediaQuery.viewInsetsOf(this).left;
  double get rightViewInsetsMedia        => MediaQuery.viewInsetsOf(this).right;

  TextScaler get textScalerMedia         => MediaQuery.textScalerOf(this);
  double get textScaleFactorMedia        => textScalerMedia.scale(1);
}
// dart format on
