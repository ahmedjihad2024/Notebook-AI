import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCircularNotchedRectangle extends NotchedShape {
  const CustomCircularNotchedRectangle({
    this.inverted = false,
    this.notchTopRadius = 0.0,
  });

  final bool inverted;
  final double notchTopRadius;

  @override
  Path getOuterPath(Rect host, Rect? guest_) {
    Rect? guest = Rect.fromCircle(
      center: Offset(host.center.dx, 0),
      radius: 60.h / 2 + 5,
    );

    if (!host.overlaps(guest)) {
      return Path()..addRect(host);
    }

    final double r = guest.width / 2.0;
    final Radius notchRadius = Radius.circular(r);

    final double invertMultiplier = inverted ? -1.0 : 1.0;

    double s1 = 15.0 + notchTopRadius;
    double s2 = 1.0 + notchTopRadius;

    final double a = -r - s2;
    final double b = (inverted ? host.bottom : host.top) - guest.center.dy;

    final double n2 = sqrt(b * b * r * r * (a * a + b * b - r * r));
    final double p2xA = ((a * r * r) - n2) / (a * a + b * b);
    final double p2xB = ((a * r * r) + n2) / (a * a + b * b);
    final double p2yA = sqrt(r * r - p2xA * p2xA) * invertMultiplier;
    final double p2yB = sqrt(r * r - p2xB * p2xB) * invertMultiplier;

    final List<Offset> p = List<Offset>.filled(6, Offset.zero);

    // p0, p1, and p2 are the control points for segment A.
    p[0] = Offset(a - s1, b);
    p[1] = Offset(a, b);
    final double cmp = b < 0 ? -1.0 : 1.0;
    p[2] = cmp * p2yA > cmp * p2yB ? Offset(p2xA, p2yA) : Offset(p2xB, p2yB);

    // p3, p4, and p5 are the control points for segment B, which is a mirror
    // of segment A around the y axis.
    p[3] = Offset(-1.0 * p[2].dx, p[2].dy);
    p[4] = Offset(-1.0 * p[1].dx, p[1].dy);
    p[5] = Offset(-1.0 * p[0].dx, p[0].dy);

    // translate all points back to the absolute coordinate system.
    for (int i = 0; i < p.length; i += 1) {
      p[i] += guest.center;
    }

    // Use the calculated points to draw out a path object.
    final Path path = Path()..moveTo(host.left, host.top);
    if (!inverted) {
      path
        ..lineTo(p[0].dx, p[0].dy)
        ..quadraticBezierTo(p[1].dx, p[1].dy, p[2].dx, p[2].dy)
        ..arcToPoint(p[3], radius: notchRadius, clockwise: false)
        ..quadraticBezierTo(p[4].dx, p[4].dy, p[5].dx, p[5].dy)
        ..lineTo(host.right, host.top)
        ..lineTo(host.right, host.bottom)
        ..lineTo(host.left, host.bottom);
    } else {
      path
        ..lineTo(host.right, host.top)
        ..lineTo(host.right, host.bottom)
        ..lineTo(p[5].dx, p[5].dy)
        ..quadraticBezierTo(p[4].dx, p[4].dy, p[3].dx, p[3].dy)
        ..arcToPoint(p[2], radius: notchRadius, clockwise: false)
        ..quadraticBezierTo(p[1].dx, p[1].dy, p[0].dx, p[0].dy)
        ..lineTo(host.left, host.bottom);
    }

    return path..close();
  }
}

class NotchedClipper extends CustomClipper<Path> {
  final bool inverted;
  final double notchTopRadius;
  final double circleRadius;
  final double notchMargin;

  const NotchedClipper({
    required this.circleRadius,
    this.notchMargin = 0.0,
    this.inverted = false,
    this.notchTopRadius = 0.0,
  });

  @override
  Path getClip(Size size) {
    Rect? guest = Rect.fromCircle(
      center: Offset(size.width / 2, 0),
      radius: circleRadius + notchMargin,
    );
    Rect? host = Rect.fromLTRB(0, 0, size.width, size.height);

    // if (guest == null || !host.overlaps(guest)) {
    //   return Path()..addRect(host);
    // }

    final double r = guest.width / 2.0;
    final Radius notchRadius = Radius.circular(r);

    final double invertMultiplier = inverted ? -1.0 : 1.0;

    double s1 = 15.0 + notchTopRadius;
    double s2 = 1.0 + notchTopRadius;

    final double a = -r - s2;
    final double b = (inverted ? host.bottom : host.top) - guest.center.dy;

    final double n2 = sqrt(b * b * r * r * (a * a + b * b - r * r));
    final double p2xA = ((a * r * r) - n2) / (a * a + b * b);
    final double p2xB = ((a * r * r) + n2) / (a * a + b * b);
    final double p2yA = sqrt(r * r - p2xA * p2xA) * invertMultiplier;
    final double p2yB = sqrt(r * r - p2xB * p2xB) * invertMultiplier;

    final List<Offset> p = List<Offset>.filled(6, Offset.zero);

    // p0, p1, and p2 are the control points for segment A.
    p[0] = Offset(a - s1, b);
    p[1] = Offset(a, b);
    final double cmp = b < 0 ? -1.0 : 1.0;
    p[2] = cmp * p2yA > cmp * p2yB ? Offset(p2xA, p2yA) : Offset(p2xB, p2yB);

    // p3, p4, and p5 are the control points for segment B, which is a mirror
    // of segment A around the y axis.
    p[3] = Offset(-1.0 * p[2].dx, p[2].dy);
    p[4] = Offset(-1.0 * p[1].dx, p[1].dy);
    p[5] = Offset(-1.0 * p[0].dx, p[0].dy);

    // translate all points back to the absolute coordinate system.
    for (int i = 0; i < p.length; i += 1) {
      p[i] += guest.center;
    }

    // Use the calculated points to draw out a path object.
    final Path path = Path()..moveTo(host.left, host.top);
    if (!inverted) {
      path
        ..lineTo(p[0].dx, p[0].dy)
        ..quadraticBezierTo(p[1].dx, p[1].dy, p[2].dx, p[2].dy)
        ..arcToPoint(p[3], radius: notchRadius, clockwise: false)
        ..quadraticBezierTo(p[4].dx, p[4].dy, p[5].dx, p[5].dy)
        ..lineTo(host.right, host.top)
        ..lineTo(host.right, host.bottom)
        ..lineTo(host.left, host.bottom);
    } else {
      path
        ..lineTo(host.right, host.top)
        ..lineTo(host.right, host.bottom)
        ..lineTo(p[5].dx, p[5].dy)
        ..quadraticBezierTo(p[4].dx, p[4].dy, p[3].dx, p[3].dy)
        ..arcToPoint(p[2], radius: notchRadius, clockwise: false)
        ..quadraticBezierTo(p[1].dx, p[1].dy, p[0].dx, p[0].dy)
        ..lineTo(host.left, host.bottom);
    }

    return path..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
