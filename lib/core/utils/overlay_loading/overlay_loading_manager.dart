import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u/app/utils/overlay_loading/overlay_loading.dart';
import 'package:for_u/presentation/res/gen/assets.gen.dart';
import 'package:lottie/lottie.dart';

import '../../../presentation/res/color_manager.dart';

abstract class LoadingManager {
  void show({
    LoadingType loadingType,
    BlurType blurType,
    String? customMessage,
    Color? backgroundColor,
    Color? spinnerColor,
    double? blurIntensity,
    bool showMessage,
    bool allowBackButton,
    Duration? animationDuration,
    Widget? customWidget,
  });

  Future<void> hide();
}

class OverlayLoadingManager implements LoadingManager {
  final OverlayLoading _overlayLoading;

  OverlayLoadingManager({OverlayLoading? overlayLoading})
    : _overlayLoading = overlayLoading ?? OverlayLoading.instance;

  @override
  void show({
    LoadingType loadingType = LoadingType.spinner,
    BlurType blurType = BlurType.medium,
    String? customMessage,
    Color? backgroundColor,
    Color? spinnerColor,
    double? blurIntensity,
    bool showMessage = false,
    bool allowBackButton = false,
    Duration? animationDuration,
    Widget? customWidget,
  }) {
    _overlayLoading.show(
      loadingType: loadingType,
      blurType: blurType,
      customMessage: customMessage,
      backgroundColor: backgroundColor,
      spinnerColor: spinnerColor,
      blurIntensity: blurIntensity,
      showMessage: showMessage,
      allowBackButton: allowBackButton,
      animationDuration: animationDuration,
      customWidget:
          customWidget ??
          Lottie.asset(
            Assets.lottieAnimations.sandyLoading.path,
            key: Key("loading-lottie"),
            width: 100.w,
            height: 100.w,
            repeat: true,
            fit: BoxFit.contain,
          ),
    );
  }

  @override
  Future<void> hide() async {
    await _overlayLoading.hide();
  }
}
