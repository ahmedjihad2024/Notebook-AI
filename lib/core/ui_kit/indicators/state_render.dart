import 'package:flutter/material.dart';

enum ReqState {
  loading,
  empty,
  error,
  success,
  idle;

  bool get isLoading => this == ReqState.loading;
  bool get isEmpty => this == ReqState.empty;
  bool get isError => this == ReqState.error;
  bool get isSuccess => this == ReqState.success;
  bool get isIdle => this == ReqState.idle;
}

/// A widget that conditionally renders different widgets based on [ReqState]
/// Use this widget to wrap content and show different states (loading, error, empty, success, idle)
class StateRender extends StatelessWidget {
  /// The request state to determine which widget to show
  final ReqState reqState;

  /// The widget to show when state is success (required)
  final WidgetBuilder success;

  /// The widget to show when state is loading (optional, defaults to empty SizedBox)
  final WidgetBuilder? loading;

  /// The widget to show when state is error (optional, defaults to empty SizedBox)
  final WidgetBuilder? error;

  /// The widget to show when state is empty (optional, defaults to empty SizedBox)
  final WidgetBuilder? empty;

  /// The widget to show when state is idle (optional, defaults to empty SizedBox)
  final WidgetBuilder? idle;

  const StateRender({
    super.key,
    required this.reqState,
    required this.success,
    this.loading,
    this.error,
    this.empty,
    this.idle,
  });

  @override
  Widget build(BuildContext context) {
    return switch (reqState) {
      ReqState.success => success(context),
      ReqState.loading => loading?.call(context) ?? const SizedBox.shrink(),
      ReqState.error => error?.call(context) ?? const SizedBox.shrink(),
      ReqState.empty => empty?.call(context) ?? const SizedBox.shrink(),
      ReqState.idle => idle?.call(context) ?? const SizedBox.shrink(),
    };
  }
}
