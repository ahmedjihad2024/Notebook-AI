import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notebook_ai/core/res/router/app_router.dart';

// ---------------------------------------------------------------------------
// Navigation Extensions (go_router)
// Use inside widgets where you have a BuildContext.
// Outside the widget tree (services, DI, notification callbacks), use
// `appRouter` directly from `lib/core/res/router/app_router.dart`.
// ---------------------------------------------------------------------------
extension NavigationExtension on BuildContext {
  // ── Push ──────────────────────────────────────────────────────────────────

  /// Push a named route on top of the current stack.
  Future<T?> pushNamed<T>(Routes route, {Object? arguments}) =>
      GoRouter.of(this).pushNamed<T>(route.name, extra: arguments);

  /// Replace the entire stack with [name]. Equivalent of the old
  /// `pushNamedAndRemoveUntil(name, (_) => false)`.
  void goNamed(Routes route, {Object? arguments}) =>
      GoRouter.of(this).goNamed(route.name, extra: arguments);

  /// Push [name]; on back press, the user lands on the route named
  /// [keepUntilName] (the surviving route at the bottom of the stack).
  /// Use this when you want to clear intermediate routes but preserve
  /// a specific destination below the new screen.
  Future<T?> pushNamedAndKeepUntil<T>(
    Routes route, {
    required Routes keepUntilName,
    Object? arguments,
  }) {
    final router = GoRouter.of(this);
    router.goNamed(keepUntilName.name);
    return router.pushNamed<T>(route.name, extra: arguments);
  }

  /// Replace the current route with [name].
  Future<T?> pushReplacementNamed<T>(Routes route, {Object? arguments}) =>
      GoRouter.of(this).pushReplacementNamed<T>(route.name, extra: arguments);

  // ── Pop ───────────────────────────────────────────────────────────────────

  /// Pop the current route.
  void pop<T>([T? result]) => GoRouter.of(this).pop<T>(result);

  /// Pop if the navigator can.
  void maybePop<T>([T? result]) {
    final router = GoRouter.of(this);
    if (router.canPop()) router.pop<T>(result);
  }

  /// Go back to a specific named route (clears anything above it).
  void popUntilNamed(Routes route) => GoRouter.of(this).goNamed(route.name);

  /// Whether the navigator can pop.
  bool get canPop => GoRouter.of(this).canPop();
}
