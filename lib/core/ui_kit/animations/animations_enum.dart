enum SlideDirection { up, down, left, right }

enum RotationDirection { left, right }

enum AnimationType {
  slide,
  fade,
  scale,
  pulse,
  rotation,
  shader,
  flip,
  skew,
  tint,
  glow,
}

enum ShaderRevealDirection {
  bottomToTop,
  topToBottom,
  leftToRight,
  rightToLeft,
  startToEnd,
  endToStart,
}

/// Axis around which a flip animation rotates.
/// - [horizontal] rotates around the X-axis (top flips toward/away from camera)
/// - [vertical] rotates around the Y-axis (left/right flip — typical card flip)
/// - [z] rotates around the Z-axis (2D rotation in plane)
enum FlipAxis { horizontal, vertical, z }

/// Controls whether ambient effects (pulse / glow) keep cycling after the
/// initial enter animation completes.
enum LoopMode { none, forever, pingPong }
