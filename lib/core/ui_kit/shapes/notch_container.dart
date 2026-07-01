import 'package:flutter/material.dart';

class NotchContainer extends StatefulWidget {
  const NotchContainer({
    super.key,
    this.child,
    this.notchWidth = 100.0,
    this.notchHeight = 15.0,
    this.notchRadius = 10.0,
    this.enable = true,
  });

  final Widget? child;
  final double notchWidth;
  final double notchHeight;
  final double notchRadius;
  final bool enable;

  @override
  State<NotchContainer> createState() => _NotchContainerState();
}

class _NotchContainerState extends State<NotchContainer> {
  @override
  Widget build(BuildContext context) {
    return widget.enable
        ? ClipPath(
            clipper: _NotchClipper(
              notchWidth: widget.notchWidth,
              notchHeight: widget.notchHeight,
              notchRadius: widget.notchRadius,
            ),
            child: widget.child,
          )
        : (widget.child ?? const SizedBox.shrink());
  }
}

class _NotchClipper extends CustomClipper<Path> {
  final double notchWidth;
  final double notchHeight;
  final double notchRadius;

  _NotchClipper({
    required this.notchWidth,
    required this.notchHeight,
    required this.notchRadius,
  });

  @override
  Path getClip(Size size) {
    Path path = Path();
    double w = size.width;
    double h = size.height;
    double centerX = w / 2;
    double halfWidth = notchWidth / 2;
    double r = notchRadius;

    path.moveTo(0, 0);
    path.lineTo(w, 0);
    path.lineTo(w, h);

    // Right side transition into notch
    path.lineTo(centerX + halfWidth + r, h);
    path.quadraticBezierTo(centerX + halfWidth, h, centerX + halfWidth, h - r);

    // Notch right vertical down to depth
    path.lineTo(centerX + halfWidth, h - notchHeight + r);
    path.quadraticBezierTo(
      centerX + halfWidth,
      h - notchHeight,
      centerX + halfWidth - r,
      h - notchHeight,
    );

    // Notch flat top (drawing right to left)
    path.lineTo(centerX - halfWidth + r, h - notchHeight);

    // Notch left vertical up
    path.quadraticBezierTo(
      centerX - halfWidth,
      h - notchHeight,
      centerX - halfWidth,
      h - notchHeight + r,
    );
    path.lineTo(centerX - halfWidth, h - r);

    // Left side transition out of notch
    path.quadraticBezierTo(centerX - halfWidth, h, centerX - halfWidth - r, h);

    path.lineTo(0, h);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant _NotchClipper oldClipper) {
    return true;
  }
}
