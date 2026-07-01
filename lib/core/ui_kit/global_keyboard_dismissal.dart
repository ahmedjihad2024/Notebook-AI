import 'package:flutter/material.dart';

/// A global solution for keyboard dismissal that can be applied at the app level.
/// This widget wraps your entire app and provides keyboard dismissal functionality.
class GlobalKeyboardDismissal extends StatelessWidget {
  final Widget child;
  final bool enableKeyboardDismissal;

  const GlobalKeyboardDismissal({
    super.key,
    required this.child,
    this.enableKeyboardDismissal = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enableKeyboardDismissal) {
      return child;
    }

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping anywhere
        FocusScope.of(context).unfocus();
      },
      child: child,
    );
  }
}
