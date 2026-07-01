import 'dart:math' as math;
import 'dart:ui' as ui show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class GradientBorderSide with Diagnosticable {
  /// Creates the side of a border.
  ///
  /// By default, the border is 1.0 logical pixels wide and solid black.
  const GradientBorderSide({
    this.gradient,
    this.color = const Color(0xFF000000),
    this.width = 1.0,
    this.style = BorderStyle.solid,
    this.strokeAlign = strokeAlignInside,
  }) : assert(width >= 0.0);

  /// Creates a [GradientBorderSide] that represents the addition of the two given
  /// [GradientBorderSide]s.
  ///
  /// It is only valid to call this if [canMerge] returns true for the two
  /// sides.
  ///
  /// If one of the sides is zero-width with [BorderStyle.none], then the other
  /// side is return as-is. If both of the sides are zero-width with
  /// [BorderStyle.none], then [GradientBorderSide.none] is returned.
  static GradientBorderSide merge(GradientBorderSide a, GradientBorderSide b) {
    assert(canMerge(a, b));
    final bool aIsNone = a.style == BorderStyle.none && a.width == 0.0;
    final bool bIsNone = b.style == BorderStyle.none && b.width == 0.0;
    if (aIsNone && bIsNone) {
      return GradientBorderSide.none;
    }
    if (aIsNone) {
      return b;
    }
    if (bIsNone) {
      return a;
    }
    assert(a.color == b.color);
    assert(a.style == b.style);
    return GradientBorderSide(
      color: a.color, // == b.color
      width: a.width + b.width,
      strokeAlign: math.max(a.strokeAlign, b.strokeAlign),
      style: a.style, // == b.style
    );
  }

  final Gradient? gradient;

  /// The color of this side of the border.
  final Color color;

  /// The width of this side of the border, in logical pixels.
  ///
  /// Setting width to 0.0 will result in a hairline border. This means that
  /// the border will have the width of one physical pixel. Hairline
  /// rendering takes shortcuts when the path overlaps a pixel more than once.
  /// This means that it will render faster than otherwise, but it might
  /// double-hit pixels, giving it a slightly darker/lighter result.
  ///
  /// To omit the border entirely, set the [style] to [BorderStyle.none].
  final double width;

  /// The style of this side of the border.
  ///
  /// To omit a side, set [style] to [BorderStyle.none]. This skips
  /// painting the border, but the border still has a [width].
  final BorderStyle style;

  /// A hairline black border that is not rendered.
  static const GradientBorderSide none = GradientBorderSide(
    width: 0.0,
    style: BorderStyle.none,
  );

  /// The relative position of the stroke on a [GradientBorderSide] in an
  /// [OutlinedBorder] or [Border].
  ///
  /// Values typically range from -1.0 ([strokeAlignInside], inside border,
  /// default) to 1.0 ([strokeAlignOutside], outside border), without any
  /// bound constraints (e.g., a value of -2.0 is not typical, but allowed).
  /// A value of 0 ([strokeAlignCenter]) will center the border on the edge
  /// of the widget.
  ///
  /// When set to [strokeAlignInside], the stroke is drawn completely inside
  /// the widget. For [strokeAlignCenter] and [strokeAlignOutside], a property
  /// such as [Container.clipBehavior] can be used in an outside widget to clip
  /// it. If [Container.decoration] has a border, the container may incorporate
  /// [width] as additional padding:
  /// - [strokeAlignInside] provides padding with full [width].
  /// - [strokeAlignCenter] provides padding with half [width].
  /// - [strokeAlignOutside] provides zero padding, as stroke is drawn entirely outside.
  ///
  /// This property is not honored by [toPaint] (because the [Paint] object
  /// cannot represent it); it is intended that classes that use [GradientBorderSide]
  /// objects implement this property when painting borders by suitably
  /// inflating or deflating their regions.
  ///
  /// {@tool dartpad}
  /// This example shows an animation of how [strokeAlign] affects the drawing
  /// when applied to borders of various shapes.
  ///
  /// ** See code in examples/api/lib/painting/borders/border_side.stroke_align.0.dart **
  /// {@end-tool}
  final double strokeAlign;

  /// The border is drawn fully inside of the border path.
  ///
  /// This is a constant for use with [strokeAlign].
  ///
  /// This is the default value for [strokeAlign].
  static const double strokeAlignInside = -1.0;

  /// The border is drawn on the center of the border path, with half of the
  /// [GradientBorderSide.width] on the inside, and the other half on the outside of
  /// the path.
  ///
  /// This is a constant for use with [strokeAlign].
  static const double strokeAlignCenter = 0.0;

  /// The border is drawn on the outside of the border path.
  ///
  /// This is a constant for use with [strokeAlign].
  static const double strokeAlignOutside = 1.0;

  /// Creates a copy of this border but with the given fields replaced with the new values.
  GradientBorderSide copyWith({
    Color? color,
    double? width,
    BorderStyle? style,
    double? strokeAlign,
    Gradient? gradient,
  }) {
    return GradientBorderSide(
      color: color ?? this.color,
      width: width ?? this.width,
      style: style ?? this.style,
      strokeAlign: strokeAlign ?? this.strokeAlign,
      gradient: gradient ?? this.gradient,
    );
  }

  /// Creates a copy of this border side description but with the width scaled
  /// by the factor `t`.
  ///
  /// The `t` argument represents the multiplicand, or the position on the
  /// timeline for an interpolation from nothing to `this`, with 0.0 meaning
  /// that the object returned should be the nil variant of this object, 1.0
  /// meaning that no change should be applied, returning `this` (or something
  /// equivalent to `this`), and other values meaning that the object should be
  /// multiplied by `t`. Negative values are treated like zero.
  ///
  /// Since a zero width is normally painted as a hairline width rather than no
  /// border at all, the zero factor is special-cased to instead change the
  /// style to [BorderStyle.none].
  ///
  /// Values for `t` are usually obtained from an [Animation<double>], such as
  /// an [AnimationController].
  GradientBorderSide scale(double t) {
    return GradientBorderSide(
      color: color,
      gradient: gradient,
      width: math.max(0.0, width * t),
      style: t <= 0.0 ? BorderStyle.none : style,
      strokeAlign: strokeAlign,
    );
  }

  /// Create a [Paint] object that, if used to stroke a line, will draw the line
  /// in this border's style.
  ///
  /// The [strokeAlign] property is not reflected in the [Paint]; consumers must
  /// implement that directly by inflating or deflating their region appropriately.
  ///
  /// Not all borders use this method to paint their border sides. For example,
  /// non-uniform rectangular [Border]s have beveled edges and so paint their
  /// border sides as filled shapes rather than using a stroke.
  Paint toPaint([Rect? bounds]) {
    switch (style) {
      case BorderStyle.solid:
        final paint = Paint()
          ..color = color
          ..strokeWidth = width
          ..style = PaintingStyle.stroke;
        if (gradient != null && bounds != null) {
          paint.shader = gradient!.createShader(bounds);
        }
        return paint;
      case BorderStyle.none:
        final paint = Paint()
          ..color = const Color(0x00000000)
          ..strokeWidth = 0.0
          ..style = PaintingStyle.stroke;
        if (gradient != null && bounds != null) {
          paint.shader = gradient!.createShader(bounds);
        }
        return paint;
    }
  }

  /// Whether the two given [GradientBorderSide]s can be merged using
  /// [GradientBorderSide.merge].
  ///
  /// Two sides can be merged if one or both are zero-width with
  /// [BorderStyle.none], or if they both have the same color and style.
  static bool canMerge(GradientBorderSide a, GradientBorderSide b) {
    if ((a.style == BorderStyle.none && a.width == 0.0) ||
        (b.style == BorderStyle.none && b.width == 0.0)) {
      return true;
    }
    return a.style == b.style && a.color == b.color;
  }

  /// Linearly interpolate between two border sides.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static GradientBorderSide lerp(
    GradientBorderSide a,
    GradientBorderSide b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    if (t == 0.0) {
      return a;
    }
    if (t == 1.0) {
      return b;
    }
    final double width = ui.lerpDouble(a.width, b.width, t)!;
    if (width < 0.0) {
      return GradientBorderSide.none;
    }
    if (a.style == b.style && a.strokeAlign == b.strokeAlign) {
      return GradientBorderSide(
        color: Color.lerp(a.color, b.color, t)!,
        width: width,
        style: a.style, // == b.style
        strokeAlign: a.strokeAlign, // == b.strokeAlign
      );
    }
    final Color colorA = switch (a.style) {
      BorderStyle.solid => a.color,
      BorderStyle.none => a.color.withAlpha(0x00),
    };
    final Color colorB = switch (b.style) {
      BorderStyle.solid => b.color,
      BorderStyle.none => b.color.withAlpha(0x00),
    };
    if (a.strokeAlign != b.strokeAlign) {
      return GradientBorderSide(
        color: Color.lerp(colorA, colorB, t)!,
        width: width,
        strokeAlign: ui.lerpDouble(a.strokeAlign, b.strokeAlign, t)!,
      );
    }
    return GradientBorderSide(
      color: Color.lerp(colorA, colorB, t)!,
      width: width,
      strokeAlign: a.strokeAlign, // == b.strokeAlign
    );
  }

  static GradientBorderSide glassyOutline({double width = 1}) =>
      GradientBorderSide(
        width: width,
        gradient: SweepGradient(
          colors: [
            Colors.white.withValues(alpha: .5), // 0°    right edge mid
            Colors.white.withValues(alpha: .35), // 45°   BR — bright
            Colors.white.withValues(alpha: 0.25), // 90°   bottom edge mid
            Colors.white.withValues(alpha: 0.13), // 135°  BL — transparent
            Colors.white.withValues(alpha: 0.13), // 180°  left edge mid
            Colors.white.withValues(alpha: .5), // 225°  TL — bright
            Colors.white.withValues(alpha: .25), // 270°  top edge mid
            Colors.white.withValues(alpha: 0.13), // 315°  TR — transparent
            Colors.white.withValues(alpha: 0.13), // 360°  wrap
          ],
          stops: [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0],
        ),
      );

  /// Get the amount of the stroke width that lies inside of the [GradientBorderSide].
  ///
  /// For example, this will return the [width] for a [strokeAlign] of -1, half
  /// the [width] for a [strokeAlign] of 0, and 0 for a [strokeAlign] of 1.
  double get strokeInset => width * (1 - (1 + strokeAlign) / 2);

  /// Get the amount of the stroke width that lies outside of the [GradientBorderSide].
  ///
  /// For example, this will return 0 for a [strokeAlign] of -1, half the
  /// [width] for a [strokeAlign] of 0, and the [width] for a [strokeAlign]
  /// of 1.
  double get strokeOutset => width * (1 + strokeAlign) / 2;

  /// The offset of the stroke, taking into account the stroke alignment.
  ///
  /// For example, this will return the negative [width] of the stroke
  /// for a [strokeAlign] of -1, 0 for a [strokeAlign] of 0, and the
  /// [width] for a [strokeAlign] of -1.
  double get strokeOffset => width * strokeAlign;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is GradientBorderSide &&
        other.color == color &&
        other.width == width &&
        other.style == style &&
        other.strokeAlign == strokeAlign &&
        other.gradient == gradient;
  }

  @override
  int get hashCode => Object.hash(color, width, style, strokeAlign, gradient);

  @override
  String toStringShort() => 'GradientBorderSide';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<Color>(
        'color',
        color,
        defaultValue: const Color(0xFF000000),
      ),
    );
    properties.add(DoubleProperty('width', width, defaultValue: 1.0));
    properties.add(
      DoubleProperty(
        'strokeAlign',
        strokeAlign,
        defaultValue: strokeAlignInside,
      ),
    );
    properties.add(
      EnumProperty<BorderStyle>(
        'style',
        style,
        defaultValue: BorderStyle.solid,
      ),
    );
    if (gradient != null) {
      properties.add(DiagnosticsProperty<Gradient>('gradient', gradient));
    }
  }
}

/// A border with rounded corners that supports gradient borders.
///
/// This border is similar to [RoundedRectangleBorder] but supports gradient
/// borders through the custom [GradientBorderSide] class.
class GradientRoundedRectangleBorder extends ShapeBorder {
  /// Creates a rounded rectangle border.
  ///
  /// The [side] argument must not be null. It defaults to [GradientBorderSide.none].
  ///
  /// The [borderRadius] argument must not be null. It defaults to [BorderRadius.zero].
  const GradientRoundedRectangleBorder({
    this.side = GradientBorderSide.none,
    this.borderRadius = BorderRadius.zero,
  });

  /// The border side to paint.
  final GradientBorderSide side;

  /// The border radius.
  final BorderRadius borderRadius;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  ShapeBorder scale(double t) {
    return GradientRoundedRectangleBorder(
      side: side.scale(t),
      borderRadius: BorderRadius.lerp(BorderRadius.zero, borderRadius, t)!,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is GradientRoundedRectangleBorder) {
      return GradientRoundedRectangleBorder(
        side: GradientBorderSide.lerp(a.side, side, t),
        borderRadius: BorderRadius.lerp(a.borderRadius, borderRadius, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is GradientRoundedRectangleBorder) {
      return GradientRoundedRectangleBorder(
        side: GradientBorderSide.lerp(side, b.side, t),
        borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t)!,
      );
    }
    return super.lerpTo(b, t);
  }

  /// Creates a copy of this border with the given fields replaced.
  GradientRoundedRectangleBorder copyWith({
    GradientBorderSide? side,
    BorderRadius? borderRadius,
  }) {
    return GradientRoundedRectangleBorder(
      side: side ?? this.side,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final RRect borderRect = borderRadius.resolve(textDirection).toRRect(rect);
    final RRect innerRect = borderRect.deflate(side.width);
    return Path()..addRRect(innerRect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final RRect borderRect = borderRadius.resolve(textDirection).toRRect(rect);
    return Path()..addRRect(borderRect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) {
      return;
    }

    final RRect borderRect = borderRadius.resolve(textDirection).toRRect(rect);

    // If the border has a gradient, we need to paint it specially
    if (side.gradient != null) {
      // Create a path for the border stroke
      final Path borderPath = Path()..addRRect(borderRect);

      // Create a path for the inner rect to create the border effect
      final RRect innerRect = borderRect.deflate(side.width);
      final Path innerPath = Path()..addRRect(innerRect);

      // Use PathOperation.difference to create the border area
      final Path borderArea = Path.combine(
        PathOperation.difference,
        borderPath,
        innerPath,
      );

      // Create paint with gradient shader
      final Paint paint = Paint()
        ..shader = side.gradient!.createShader(rect)
        ..style = PaintingStyle.fill;

      canvas.drawPath(borderArea, paint);
    } else {
      // Standard border painting for non-gradient borders
      final Paint paint = side.toPaint(rect);
      canvas.drawRRect(borderRect, paint);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is GradientRoundedRectangleBorder &&
        other.side == side &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => Object.hash(side, borderRadius);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'GradientRoundedRectangleBorder')}($side, $borderRadius)';
  }
}

enum CornerLocation { tl, tr, bl, br }

/// A rectangular border with variable smoothness transitions between
/// the straight sides and the rounded corners.
///
/// Supports gradient borders through the custom [GradientBorderSide] class.
class SmoothRectangleBorder extends ShapeBorder {
  const SmoothRectangleBorder({
    this.smoothness = 0.0,
    this.borderRadius = BorderRadius.zero,
    this.side = GradientBorderSide.none,
  });

  /// The radius for each corner.
  ///
  /// Negative radius values are clamped to 0.0 by [getInnerPath] and
  /// [getOuterPath].
  ///
  /// If radiuses of X and Y from one corner are not equal, the smallest one will be used.
  final BorderRadiusGeometry borderRadius;

  /// The smoothness of corners.
  ///
  /// The concept comes from a feature called "corner smoothing" of Figma.
  ///
  /// 0.0 - 1.0
  final double smoothness;

  /// The border side to paint.
  final GradientBorderSide side;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getPath(
      borderRadius.resolve(textDirection).toRRect(rect).deflate(side.width),
    );
  }

  Path getPath(RRect rrect) {
    var path = Path();
    if (smoothness == 0 || borderRadius == BorderRadius.zero) {
      path.addRRect(rrect);
    } else {
      final width = rrect.width;
      final height = rrect.height;
      final top = rrect.top;
      final left = rrect.left;
      final bottom = rrect.bottom;
      final right = rrect.right;

      var centerX = width / 2 + left;

      var tl = Corner(rrect, CornerLocation.tl, smoothness);
      var tr = Corner(rrect, CornerLocation.tr, smoothness);
      var br = Corner(rrect, CornerLocation.br, smoothness);
      var bl = Corner(rrect, CornerLocation.bl, smoothness);

      path.moveTo(centerX, top);

      // top right
      path
        ..lineTo(left + math.max(width / 2, width - tr.p), top)
        ..cubicTo(
          right - (tr.p - tr.a),
          top,
          right - (tr.p - tr.a - tr.b),
          top,
          right - (tr.p - tr.a - tr.b - tr.c),
          top + tr.d,
        )
        ..arcTo(
          Rect.fromCircle(
            center: Offset(right - tr.radius, top + tr.radius),
            radius: tr.radius,
          ),
          (270 + tr.angleBezier).toRadian(),
          (90 - 2 * tr.angleBezier).toRadian(),
          false,
        )
        ..cubicTo(
          right,
          top + (tr.p - tr.a - tr.b),
          right,
          top + (tr.p - tr.a),
          right,
          top + math.min(height / 2, tr.p),
        );

      //bottom right
      path
        ..lineTo(right, top + math.max(height / 2, height - br.p))
        ..cubicTo(
          right,
          bottom - (br.p - br.a),
          right,
          bottom - (br.p - br.a - br.b),
          right - br.d,
          bottom - (br.p - br.a - br.b - br.c),
        )
        ..arcTo(
          Rect.fromCircle(
            center: Offset(right - br.radius, bottom - br.radius),
            radius: br.radius,
          ),
          br.angleBezier.toRadian(),
          (90 - br.angleBezier * 2).toRadian(),
          false,
        )
        ..cubicTo(
          right - (br.p - br.a - br.b),
          bottom,
          right - (br.p - br.a),
          bottom,
          left + math.max(width / 2, width - br.p),
          bottom,
        );

      //bottom left
      path
        ..lineTo(left + math.min(width / 2, bl.p), bottom)
        ..cubicTo(
          left + (bl.p - bl.a),
          bottom,
          left + (bl.p - bl.a - bl.b),
          bottom,
          left + (bl.p - bl.a - bl.b - bl.c),
          bottom - bl.d,
        )
        ..arcTo(
          Rect.fromCircle(
            center: Offset(left + bl.radius, bottom - bl.radius),
            radius: bl.radius,
          ),
          (90 + bl.angleBezier).toRadian(),
          (90 - bl.angleBezier * 2).toRadian(),
          false,
        )
        ..cubicTo(
          left,
          bottom - (bl.p - bl.a - bl.b),
          left,
          bottom - (bl.p - bl.a),
          left,
          top + math.max(height / 2, height - bl.p),
        );

      //top left
      path
        ..lineTo(left, top + math.min(height / 2, tl.p))
        ..cubicTo(
          left,
          top + (tl.p - tl.a),
          left,
          top + (tl.p - tl.a - tl.b),
          left + tl.d,
          top + (tl.p - tl.a - tl.b - tl.c),
        )
        ..arcTo(
          Rect.fromCircle(
            center: Offset(left + tl.radius, top + tl.radius),
            radius: tl.radius,
          ),
          (180 + tl.angleBezier).toRadian(),
          (90 - tl.angleBezier * 2).toRadian(),
          false,
        )
        ..cubicTo(
          left + (tl.p - tl.a - tl.b),
          top,
          left + (tl.p - tl.a),
          top,
          left + math.min(width / 2, tl.p),
          top,
        );

      path.close();
    }
    return path;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return getPath(borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (rect.isEmpty || side.style == BorderStyle.none) return;

    final RRect borderRRect = borderRadius.resolve(textDirection).toRRect(rect);

    // If the border has a gradient, we need to paint it specially
    if (side.gradient != null) {
      // Create paths for outer and inner boundaries
      final Path outerPath = getPath(borderRRect);
      final RRect innerRRect = borderRRect.deflate(side.width);
      final Path innerPath = getPath(innerRRect);

      // Use PathOperation.difference to create the border area
      final Path borderArea = Path.combine(
        PathOperation.difference,
        outerPath,
        innerPath,
      );

      // Create paint with gradient shader
      final Paint paint = Paint()
        ..shader = side.gradient!.createShader(rect)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      canvas.drawPath(borderArea, paint);
    } else {
      // Standard border painting for non-gradient borders
      final Path path = getPath(borderRRect.deflate(side.width / 2));
      final Paint paint = side.toPaint(rect)..isAntiAlias = true;
      canvas.drawPath(path, paint);
    }
  }

  @override
  ShapeBorder scale(double t) {
    return SmoothRectangleBorder(
      borderRadius: borderRadius * t,
      side: side.scale(t),
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is SmoothRectangleBorder) {
      return SmoothRectangleBorder(
        side: GradientBorderSide.lerp(a.side, side, t),
        borderRadius: BorderRadiusGeometry.lerp(
          a.borderRadius,
          borderRadius,
          t,
        )!,
        smoothness: a.smoothness + (smoothness - a.smoothness) * t,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is SmoothRectangleBorder) {
      return SmoothRectangleBorder(
        side: GradientBorderSide.lerp(side, b.side, t),
        borderRadius: BorderRadiusGeometry.lerp(
          borderRadius,
          b.borderRadius,
          t,
        )!,
        smoothness: smoothness + (b.smoothness - smoothness) * t,
      );
    }
    return super.lerpTo(b, t);
  }

  /// Creates a copy of this border with the given fields replaced.
  SmoothRectangleBorder copyWith({
    GradientBorderSide? side,
    BorderRadiusGeometry? borderRadius,
    double? smoothness,
  }) {
    return SmoothRectangleBorder(
      borderRadius: borderRadius ?? this.borderRadius,
      side: side ?? this.side,
      smoothness: smoothness ?? this.smoothness,
    );
  }

  @override
  int get hashCode {
    return Object.hash(smoothness, borderRadius, side);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is SmoothRectangleBorder &&
        other.smoothness == smoothness &&
        other.borderRadius == borderRadius &&
        other.side == side;
  }
}

extension _Math on double {
  double toRadian() => this * math.pi / 180;
}

class Corner {
  late double angleBezier;
  late double angleCircle;
  late double a;
  late double b;
  late double c;
  late double d;
  late double p;
  late double radius;
  late double shortestSide;

  Corner(RRect rrect, CornerLocation location, double smoothness) {
    if (smoothness > 1) smoothness = 1;
    shortestSide = rrect.shortestSide;

    radius = _getRadius(rrect, location);

    p = math.min(shortestSide / 2, (1 + smoothness) * radius);

    if (radius > shortestSide / 4) {
      var changePercentage = (radius - shortestSide / 4) / (shortestSide / 4);
      angleCircle = 90 * (1 - smoothness * (1 - changePercentage));
      angleBezier = 45 * smoothness * (1 - changePercentage);
    } else {
      angleCircle = 90 * (1 - smoothness);
      angleBezier = 45 * smoothness;
    }

    var dToC = math.tan(angleBezier.toRadian());
    var longest = radius * math.tan(angleBezier.toRadian() / 2);
    var l =
        math.sin(angleCircle.toRadian() / 2) *
        radius *
        math.pow(2, 0.5).toDouble();
    c = longest * math.cos(angleBezier.toRadian());
    d = c * dToC;
    b = ((p - l) - (1 + dToC) * c) / 3;
    a = 2 * b;
  }

  double _getRadius(RRect rrect, CornerLocation location) {
    double radiusX, radiusY;
    switch (location) {
      case CornerLocation.tl:
        radiusX = rrect.tlRadiusX;
        radiusY = rrect.tlRadiusY;
        break;
      case CornerLocation.tr:
        radiusX = rrect.trRadiusX;
        radiusY = rrect.trRadiusY;
        break;
      case CornerLocation.bl:
        radiusX = rrect.blRadiusX;
        radiusY = rrect.blRadiusY;
        break;
      case CornerLocation.br:
        radiusX = rrect.brRadiusX;
        radiusY = rrect.brRadiusY;
        break;
    }
    var radius = math.max(0.0, math.min(radiusX, radiusY));
    return math.min(radius, shortestSide / 2);
  }
}
