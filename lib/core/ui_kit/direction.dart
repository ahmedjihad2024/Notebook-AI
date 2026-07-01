import 'package:flutter/material.dart';

enum Dir { ltr, rtl }

class Direction extends StatelessWidget {
  final Dir init;
  final Widget child;
  const Direction({super.key, required this.init, required this.child});

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: init == .ltr
          ? (Directionality.of(context) == TextDirection.ltr ? 2 : 0)
          : (Directionality.of(context) == TextDirection.ltr ? 0 : 2),
      child: child,
    );
  }
}
