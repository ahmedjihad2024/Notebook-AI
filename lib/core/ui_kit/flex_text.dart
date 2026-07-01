import 'package:flutter/material.dart';

class FlexText extends StatelessWidget {
  final Widget child;

  const FlexText({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: child,
      ),
    );
  }
}
