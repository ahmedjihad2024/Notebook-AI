import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformSafeArea extends StatelessWidget {
  final Widget child;
  final bool? top;
  final bool? bottom;
  final bool? left;
  final bool? right;
  final EdgeInsets minimum;

  const PlatformSafeArea({
    Key? key,
    required this.child,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.minimum = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the platform is iOS
    final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    return SafeArea(
      top: top ?? true,
      // For iOS, set bottom to false, for other platforms keep it as provided or true
      bottom: isIOS ? false : (bottom ?? true),
      left: left ?? true,
      right: right ?? true,
      minimum: minimum,
      child: child,
    );
  }
}
