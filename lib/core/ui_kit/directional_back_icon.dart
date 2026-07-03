import 'dart:math' as math;

import 'package:flutter/material.dart';

class DirectionalBackIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;

  const DirectionalBackIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Icon(this.icon, size: size, color: color);
    if (Directionality.of(context) != TextDirection.rtl) return icon;
    return Transform.rotate(angle: math.pi, child: icon);
  }
}
