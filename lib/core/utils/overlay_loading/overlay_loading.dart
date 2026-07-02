import 'dart:async';
import 'dart:ui';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notebook_ai/core/app.dart';
import 'package:notebook_ai/core/res/fonts_manager.dart';
import 'package:notebook_ai/core/res/translations_manager.dart';

enum LoadingType { spinner, dots, pulse, custom, widget }

enum BlurType { none, light, medium, heavy }

class OverlayLoading {
  // Singleton pattern
  static final OverlayLoading _instance = OverlayLoading._internal();
  factory OverlayLoading() => _instance;
  OverlayLoading._internal();

  static OverlayLoading get instance => _instance;

  // Instance variables
  OverlayEntry? _currentOverlay;
  bool _isLoading = false;
  bool _allowBackButton = false;
  late Future<void> Function() _hideFunction;

  // Enhanced configuration
  LoadingType _loadingType = LoadingType.spinner;
  String? _customMessage;
  Color _backgroundColor = Colors.black.withValues(alpha: .6);
  Color _spinnerColor = Colors.white.withValues(alpha: .85);
  bool _showMessage = false;
  Duration _animationDuration = const Duration(milliseconds: 200);
  Widget? _customWidget;

  // Getters
  bool get isLoadingActive => _isLoading;

  // Configuration methods
  OverlayLoading setLoadingType(LoadingType type) {
    _loadingType = type;
    return this;
  }

  OverlayLoading setCustomMessage(String message) {
    _customMessage = message;
    _showMessage = true;
    return this;
  }

  OverlayLoading setBackgroundColor(Color color) {
    _backgroundColor = color;
    return this;
  }

  OverlayLoading setSpinnerColor(Color color) {
    _spinnerColor = color;
    return this;
  }

  OverlayLoading showMessage(bool show) {
    _showMessage = show;
    return this;
  }

  OverlayLoading allowBackButton(bool allow) {
    _allowBackButton = allow;
    return this;
  }

  OverlayLoading setAnimationDuration(Duration duration) {
    _animationDuration = duration;
    return this;
  }

  OverlayLoading setCustomWidget(Widget widget) {
    _customWidget = widget;
    _loadingType = LoadingType.widget;
    return this;
  }

  // Show loading with context
  Future<void> _showOverlayLoading() async {
    // Add back button interceptor only if not allowed
    if (!_allowBackButton) {
      BackButtonInterceptor.add(_backButtonInterceptor);
    }

    _currentOverlay = OverlayEntry(
      builder: (con) => Theme(
        data: Theme.of(NAVIGATOR_KEY.currentContext!),
        child: EnhancedLoadingOverlay(
          overlayLoading: this,
          loadingType: _loadingType,
          customMessage: _customMessage,
          backgroundColor: _backgroundColor,
          spinnerColor: _spinnerColor,
          showMessage: _showMessage,
          animationDuration: _animationDuration,
          customWidget: _customWidget,
        ),
      ),
    );

    // Ensure we're using the navigator's overlay for best compatibility
    NAVIGATOR_KEY.currentState?.overlay?.insert(_currentOverlay!);

    // Provide haptic feedback to indicate loading
    await HapticFeedback.lightImpact();
  }

  // Show loading globally (context-free)
  void show({
    LoadingType? loadingType,
    BlurType? blurType,
    String? customMessage,
    Color? backgroundColor,
    Color? spinnerColor,
    double? blurIntensity,
    bool? showMessage,
    bool? allowBackButton,
    Duration? animationDuration,
    Widget? customWidget,
  }) {
    if (_isLoading) return;
    _isLoading = true;
    // Wait for the next frame to ensure the navigator is ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final context = NAVIGATOR_KEY.currentContext;
      if (context == null) {
        print('Warning: No global context available for overlay loading');
        _isLoading = false;
        return;
      }

      // Configure the singleton instance
      if (loadingType != null) {
        this.setLoadingType(loadingType);
      }
      if (showMessage != null) {
        this.showMessage(showMessage);
      }
      if (allowBackButton != null) {
        this.allowBackButton(allowBackButton);
      }
      if (customMessage != null) {
        setCustomMessage(customMessage);
      }
      if (backgroundColor != null) {
        setBackgroundColor(backgroundColor);
      }
      if (spinnerColor != null) {
        setSpinnerColor(spinnerColor);
      }
      if (animationDuration != null) {
        setAnimationDuration(animationDuration);
      }
      if (customWidget != null) {
        setCustomWidget(customWidget);
      }

      await _showOverlayLoading();
    });
  }

  // Hide loading
  Future<void> _hideOverlayLoading() async {
    if (_isLoading) {
      _isLoading = false;

      // Remove back button interceptor
      if (!_allowBackButton) {
        BackButtonInterceptor.remove(_backButtonInterceptor);
      }

      try {
        await _hideFunction();
      } catch (e) {
        Timer.periodic(const Duration(milliseconds: 100), (t) async {
          try {
            await _hideFunction();
            t.cancel();
          } catch (e) {
            print(e);
          }
        });
      }
    }
  }

  // Hide global loading
  Future<void> hide() async {
    await _hideOverlayLoading();
  }

  // Set hide function
  void _setHideFunction(Future<void> Function() fun) => _hideFunction = fun;

  // Intercept back button press
  bool _backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    // If loading is active and back button is not allowed, prevent back navigation
    if (_isLoading && !_allowBackButton) {
      // Provide feedback to indicate action is blocked
      HapticFeedback.vibrate();
      return true; // Intercept the back button
    }

    return false; // Allow back navigation when not loading or when allowed
  }

  // Reset configuration
  void reset() {
    _loadingType = LoadingType.spinner;
    _customMessage = null;
    _backgroundColor = Colors.black.withValues(alpha: .6);
    _spinnerColor = Colors.white.withValues(alpha: .85);
    _showMessage = false;
    _allowBackButton = false;
    _animationDuration = const Duration(milliseconds: 200);
    _customWidget = null;
  }
}

// Enhanced Loading Overlay Widget
class EnhancedLoadingOverlay extends StatefulWidget {
  final OverlayLoading overlayLoading;
  final LoadingType loadingType;
  final String? customMessage;
  final Color backgroundColor;
  final Color spinnerColor;
  final bool showMessage;
  final Duration animationDuration;
  final Widget? customWidget;

  const EnhancedLoadingOverlay({
    super.key,
    required this.overlayLoading,
    required this.loadingType,
    this.customMessage,
    required this.backgroundColor,
    required this.spinnerColor,
    required this.showMessage,
    required this.animationDuration,
    this.customWidget,
  });

  @override
  State<EnhancedLoadingOverlay> createState() => _EnhancedLoadingOverlayState();
}

class _EnhancedLoadingOverlayState extends State<EnhancedLoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  late AnimationController loopAnimationController;
  late Animation<double> loopAnimation;
  late AnimationController pulseAnimationController;
  late Animation<double> pulseAnimation;
  late AnimationController dotsAnimationController;
  late Animation<double> dotsAnimation;

  @override
  void initState() {
    super.initState();

    // Main fade animation
    animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      reverseDuration: widget.animationDuration,
    );

    // Loop animation for spinner
    loopAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      reverseDuration: const Duration(milliseconds: 700),
    );

    // Pulse animation for pulse loading type
    pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Dots animation for dots loading type
    dotsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Setup animations
    animation = animationController
        .drive(CurveTween(curve: Curves.fastEaseInToSlowEaseOut))
        .drive(Tween(begin: 0.0, end: 1.0));

    loopAnimation = loopAnimationController
        .drive(CurveTween(curve: Curves.fastEaseInToSlowEaseOut))
        .drive(Tween(begin: 0, end: .15));

    pulseAnimation = pulseAnimationController
        .drive(CurveTween(curve: Curves.fastEaseInToSlowEaseOut))
        .drive(Tween(begin: 0.5, end: 1.0));

    dotsAnimation = dotsAnimationController
        .drive(CurveTween(curve: Curves.fastEaseInToSlowEaseOut))
        .drive(Tween(begin: 0.0, end: 1.0));

    // Set hide function
    widget.overlayLoading._setHideFunction(() async {
      animationController.stop(canceled: true);
      await animationController.reverse();
      loopAnimationController.stop(canceled: true);
      pulseAnimationController.stop(canceled: true);
      dotsAnimationController.stop(canceled: true);
      widget.overlayLoading._currentOverlay!.remove();
    });

    // Start animations
    animationController.forward();
    loopAnimationController.repeat(reverse: true);
    pulseAnimationController.repeat(reverse: true);
    dotsAnimationController.repeat();
  }

  @override
  void dispose() {
    try {
      animationController.dispose();
      loopAnimationController.dispose();
      pulseAnimationController.dispose();
      dotsAnimationController.dispose();
    } catch (e) {}
    super.dispose();
  }

  Widget _buildLoadingIndicator() {
    switch (widget.loadingType) {
      case LoadingType.spinner:
        return AnimatedBuilder(
          animation: loopAnimationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: loopAnimation.value * 2 * 3.14159,
              child: CircularProgressIndicator(
                color: widget.spinnerColor,
                strokeCap: StrokeCap.round,
                strokeWidth: 3.w,
              ),
            );
          },
        );

      case LoadingType.dots:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: dotsAnimationController,
              builder: (context, child) {
                final delay = index * 0.2;
                final animationValue = (dotsAnimation.value + delay) % 1.0;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: widget.spinnerColor.withValues(
                      alpha: animationValue,
                    ),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        );

      case LoadingType.pulse:
        return AnimatedBuilder(
          animation: pulseAnimationController,
          builder: (context, child) {
            return Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: widget.spinnerColor.withValues(
                  alpha: pulseAnimation.value,
                ),
                shape: BoxShape.circle,
              ),
            );
          },
        );

      case LoadingType.custom:
        return Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: widget.spinnerColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.hourglass_empty,
            color: widget.backgroundColor,
            size: 24.w,
          ),
        );
      case LoadingType.widget:
        return widget.customWidget ??
            CircularProgressIndicator(
              color: widget.spinnerColor,
              strokeCap: StrokeCap.round,
              strokeWidth: 3.w,
            );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, _) {
          return Opacity(
            opacity: animation.value,
            child: Container(
              color: widget.backgroundColor,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Loading indicator
                    _buildLoadingIndicator(),

                    // Custom message
                    if (widget.showMessage && widget.customMessage != null) ...[
                      16.verticalSpace,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.w,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          widget.customMessage!,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14.sp,
                            fontWeight: FontWeightM.medium,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    // Default loading message
                    if (widget.showMessage && widget.customMessage == null) ...[
                      16.verticalSpace,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.w,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          Translation.loading.tr,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14.sp,
                            fontWeight: FontWeightM.medium,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
