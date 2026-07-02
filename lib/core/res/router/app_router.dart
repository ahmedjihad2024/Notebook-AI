import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:notebook_ai/core/app.dart';
import 'package:notebook_ai/features/notes/view/notes_shell.dart';
import 'package:notebook_ai/features/splash/view/splash_view.dart';

/// Centralized path/name constants — pass these to `context.pushNamed` /
/// `context.go` so we never typo a route name and IDE rename works.
///
// dart format off
enum Routes {

  // Shared routes
  splash         ('splash'),
  notesShell     ('notes');

  final String name;
  const Routes(this.name);


  String get path => '/$name';


}

// dart format on

Widget _slideFadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final inCurve = CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOut,
    reverseCurve: Curves.easeInOut,
  );

  final outCurve = CurvedAnimation(
    parent: secondaryAnimation,
    curve: Curves.easeInOut,
    reverseCurve: Curves.easeInOut,
  );

  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(inCurve),
    child: SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.3, 0),
      ).animate(outCurve),
      child: child,
    ),
  );
}

GoRoute _r({
  required String name,
  required String path,
  required Widget Function(BuildContext context, GoRouterState state) builder,
}) => GoRoute(
  name: name,
  path: path,
  pageBuilder: (context, state) => CustomTransitionPage<void>(
    key: state.pageKey,
    name: name,
    child: builder(context, state),
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: _slideFadeTransition,
  ),
);

final GoRouter appRouter = GoRouter(
  navigatorKey: NAVIGATOR_KEY,
  initialLocation: Routes.splash.path,
  routes: [
    _r(
      name: Routes.splash.name,
      path: Routes.splash.path,
      builder: (_, _) => const SplashView(),
    ),
    _r(
      name: Routes.notesShell.name,
      path: Routes.notesShell.path,
      builder: (_, _) => const NotesShellView(),
    ),
  ],
);
