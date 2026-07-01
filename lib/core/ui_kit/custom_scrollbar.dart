import 'package:flutter/material.dart';

import 'dart:async';

import 'package:flutter/services.dart';

/// An advanced custom scrollbar with multiple features
class CustomScrollbar extends StatefulWidget {
  /// The child widget to display
  final Widget? child;

  /// The scroll controller to use
  final ScrollController? controller;

  /// Whether to wrap the child in a SingleChildScrollView
  final bool wrapWithScrollView;

  /// The scroll physics to use when wrapping with a SingleChildScrollView
  final ScrollPhysics? physics;

  /// The padding to apply to the SingleChildScrollView
  final EdgeInsetsGeometry? padding;

  /// The width of the scrollbar track
  final double trackWidth;

  /// The width of the scrollbar thumb
  final double thumbWidth;

  /// The radius of the scrollbar thumb
  final double thumbRadius;

  /// The color of the scrollbar thumb
  final Color thumbColor;

  /// The color of the scrollbar track
  final Color trackColor;

  /// Whether to always show the scrollbar
  final bool alwaysVisible;

  /// The duration for which the scrollbar is visible after scrolling
  final Duration visibilityDuration;

  /// The duration of the fade in/out animation
  final Duration fadeAnimationDuration;

  /// The curve of the fade in/out animation
  final Curve fadeAnimationCurve;

  /// The minimum height of the scrollbar thumb
  final double minThumbHeight;

  /// The position of the scrollbar (left or right)
  final ScrollbarPosition position;

  /// The margin around the scrollbar
  final EdgeInsets margin;

  /// Whether to show the scrollbar track
  final bool showTrack;

  /// Whether to enable haptic feedback when dragging the scrollbar
  final bool enableHapticFeedback;

  /// Whether to enable the scrollbar to be dragged
  final bool enableDrag;

  /// The callback when the scrollbar is dragged
  final void Function(double)? onDragThumb;

  /// Whether to show scroll indicators at the top and bottom when more content is available
  final bool showScrollIndicators;

  /// The color of the scroll indicators
  final Color scrollIndicatorColor;

  /// Whether to show a glow effect when reaching the edges
  final bool showEdgeGlow;

  /// The color of the glow effect
  final Color? edgeGlowColor;

  /// The axis direction of the scrollbar
  final Axis axis;

  const CustomScrollbar({
    super.key,
    this.child,
    this.controller,
    this.wrapWithScrollView = true,
    this.physics,
    this.padding,
    this.trackWidth = 6.0,
    this.thumbWidth = 6.0,
    this.thumbRadius = 3.0,
    this.thumbColor = const Color(0xFF888888),
    this.trackColor = const Color(0x1F000000),
    this.alwaysVisible = false,
    this.visibilityDuration = const Duration(seconds: 1),
    this.fadeAnimationDuration = const Duration(milliseconds: 300),
    this.fadeAnimationCurve = Curves.easeInOut,
    this.minThumbHeight = 40.0,
    this.position = ScrollbarPosition.right,
    this.margin = const EdgeInsets.all(2.0),
    this.showTrack = true,
    this.enableHapticFeedback = true,
    this.enableDrag = true,
    this.onDragThumb,
    this.showScrollIndicators = false,
    this.scrollIndicatorColor = const Color(0x80000000),
    this.showEdgeGlow = false,
    this.edgeGlowColor,
    this.axis = Axis.vertical,
  });

  @override
  State<CustomScrollbar> createState() => _CustomScrollbarState();
}

class _CustomScrollbarState extends State<CustomScrollbar>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _fadeTimer;
  bool _isDragging = false;
  double _dragPosition = 0.0;
  bool _showTopIndicator = false;
  bool _showBottomIndicator = false;
  Timer? _rebuildTimer;

  // Store the scroll listener as a field to properly remove it later
  late void Function() _scrollListener;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _fadeController = AnimationController(
      vsync: this,
      duration: widget.fadeAnimationDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: widget.fadeAnimationCurve,
    );

    if (widget.alwaysVisible) {
      _fadeController.value = 1.0;
    }

    // Define the scroll listener function and store it
    _scrollListener = () {
      // This will update the scrollbar position in real-time
      setState(() {});
      _handleScroll();
    };

    // Add the listener
    _scrollController.addListener(_scrollListener);

    // Initial check for scroll indicators
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollIndicators();
    });
  }

  @override
  void didUpdateWidget(CustomScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      // Remove the old listener
      // _scrollController.removeListener(_scrollListener);

      // Update the controller
      // _scrollController = widget.controller ?? ScrollController();

      // Add the listener to the new controller
      // _scrollController.addListener(_scrollListener);
    }

    if (widget.alwaysVisible != oldWidget.alwaysVisible) {
      if (widget.alwaysVisible) {
        _fadeController.value = 1.0;
      } else if (!_isDragging) {
        _fadeController.value = 0.0;
      }
    }
  }

  void _handleScroll() {
    _updateScrollIndicators();

    if (!widget.alwaysVisible) {
      _fadeController.forward();
      _resetFadeTimer();
    }
  }

  void _scheduleRebuild() {
    _rebuildTimer?.cancel();
    _rebuildTimer = Timer(const Duration(milliseconds: 16), () {
      if (mounted) {
        setState(() {
          // This empty setState forces the UI to update during scrolling
        });
      }
    });
  }

  void _updateScrollIndicators() {
    if (!widget.showScrollIndicators) return;

    final position = _scrollController.position;
    final showTop = position.pixels > position.minScrollExtent + 20;
    final showBottom = position.pixels < position.maxScrollExtent - 20;

    if (showTop != _showTopIndicator || showBottom != _showBottomIndicator) {
      setState(() {
        _showTopIndicator = showTop;
        _showBottomIndicator = showBottom;
      });
    }
  }

  void _resetFadeTimer() {
    _fadeTimer?.cancel();
    _fadeTimer = Timer(widget.visibilityDuration, () {
      if (mounted && !_isDragging) {
        _fadeController.reverse();
      }
    });
  }

  void _onVerticalDragStart(DragStartDetails details) {
    if (!widget.enableDrag) return;

    setState(() {
      _isDragging = true;
    });

    final trackHeight = context.size!.height - 2 * widget.margin.vertical;
    final thumbHeight = _calculateThumbHeight(trackHeight);
    final trackStart = widget.margin.top;
    final trackEnd = trackStart + trackHeight;

    _dragPosition = (details.localPosition.dy - trackStart).clamp(
      0.0,
      trackHeight - thumbHeight,
    );

    final scrollPosition =
        _dragPosition /
        (trackHeight - thumbHeight) *
        _scrollController.position.maxScrollExtent;

    _scrollController.jumpTo(scrollPosition);

    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    if (widget.onDragThumb != null) {
      widget.onDragThumb!(
        scrollPosition / _scrollController.position.maxScrollExtent,
      );
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!widget.enableDrag || !_isDragging) return;

    final trackHeight = context.size!.height - 2 * widget.margin.vertical;
    final thumbHeight = _calculateThumbHeight(trackHeight);

    _dragPosition = (_dragPosition + details.delta.dy).clamp(
      0.0,
      trackHeight - thumbHeight,
    );

    final scrollPosition =
        _dragPosition /
        (trackHeight - thumbHeight) *
        _scrollController.position.maxScrollExtent;

    _scrollController.jumpTo(scrollPosition);

    if (widget.onDragThumb != null) {
      widget.onDragThumb!(
        scrollPosition / _scrollController.position.maxScrollExtent,
      );
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    if (!widget.alwaysVisible) {
      _resetFadeTimer();
    }
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (!widget.enableDrag) return;

    setState(() {
      _isDragging = true;
    });

    final trackWidth = context.size!.width - 2 * widget.margin.horizontal;
    final thumbWidth = _calculateThumbWidth(trackWidth);
    final trackStart = widget.margin.left;
    final trackEnd = trackStart + trackWidth;

    _dragPosition = (details.localPosition.dx - trackStart).clamp(
      0.0,
      trackWidth - thumbWidth,
    );

    final scrollPosition =
        _dragPosition /
        (trackWidth - thumbWidth) *
        _scrollController.position.maxScrollExtent;

    _scrollController.jumpTo(scrollPosition);

    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    if (widget.onDragThumb != null) {
      widget.onDragThumb!(
        scrollPosition / _scrollController.position.maxScrollExtent,
      );
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!widget.enableDrag || !_isDragging) return;

    final trackWidth = context.size!.width - 2 * widget.margin.horizontal;
    final thumbWidth = _calculateThumbWidth(trackWidth);

    _dragPosition = (_dragPosition + details.delta.dx).clamp(
      0.0,
      trackWidth - thumbWidth,
    );

    final scrollPosition =
        _dragPosition /
        (trackWidth - thumbWidth) *
        _scrollController.position.maxScrollExtent;

    _scrollController.jumpTo(scrollPosition);

    if (widget.onDragThumb != null) {
      widget.onDragThumb!(
        scrollPosition / _scrollController.position.maxScrollExtent,
      );
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    if (!widget.alwaysVisible) {
      _resetFadeTimer();
    }
  }

  double _calculateThumbHeight(double trackHeight) {
    if (!_scrollController.hasClients) return widget.minThumbHeight;

    final viewportHeight = _scrollController.position.viewportDimension;
    final contentHeight =
        _scrollController.position.maxScrollExtent + viewportHeight;

    final thumbHeight = (viewportHeight / contentHeight) * trackHeight;
    return thumbHeight.clamp(widget.minThumbHeight, trackHeight);
  }

  double _calculateThumbWidth(double trackWidth) {
    if (!_scrollController.hasClients) return widget.minThumbHeight;

    final viewportWidth = _scrollController.position.viewportDimension;
    final contentWidth =
        _scrollController.position.maxScrollExtent + viewportWidth;

    final thumbWidth = (viewportWidth / contentWidth) * trackWidth;
    return thumbWidth.clamp(widget.minThumbHeight, trackWidth);
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    _rebuildTimer?.cancel();
    _fadeController.dispose();

    // Remove the listener before disposing
    _scrollController.removeListener(_scrollListener);

    // Only dispose the controller if we created it
    if (widget.controller == null) {
      _scrollController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (widget.wrapWithScrollView && widget.child != null) {
      content = SingleChildScrollView(
        controller: _scrollController,
        physics: widget.physics,
        padding: widget.padding,
        child: widget.child!,
      );
    } else {
      content = widget.child ?? const SizedBox.shrink();
    }

    // Apply edge glow effect if enabled
    if (widget.showEdgeGlow) {
      content = ScrollConfiguration(
        behavior: _CustomScrollBehavior(
          glowColor: widget.edgeGlowColor ?? widget.thumbColor.withOpacity(0.3),
        ),
        child: content,
      );
    } else {
      content = ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: content,
      );
    }

    // Add scroll indicators if enabled
    if (widget.showScrollIndicators) {
      content = Stack(
        children: [
          content,
          if (_showTopIndicator && widget.axis == Axis.vertical)
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.scrollIndicatorColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          if (_showBottomIndicator && widget.axis == Axis.vertical)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.scrollIndicatorColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return Stack(
      children: [
        content,
        if (widget.axis == Axis.vertical)
          Positioned(
            right: widget.position == ScrollbarPosition.right ? 0 : null,
            left: widget.position == ScrollbarPosition.left ? 0 : null,
            top: 0,
            bottom: 0,
            width: widget.trackWidth + widget.margin.horizontal,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onVerticalDragStart: _onVerticalDragStart,
                onVerticalDragUpdate: _onVerticalDragUpdate,
                onVerticalDragEnd: _onVerticalDragEnd,
                child: Container(
                  margin: widget.margin,
                  decoration: BoxDecoration(
                    color: widget.showTrack
                        ? widget.trackColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(widget.trackWidth / 2),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (!_scrollController.hasClients ||
                          _scrollController.position.maxScrollExtent == 0) {
                        return const SizedBox.shrink();
                      }

                      final viewportHeight =
                          _scrollController.position.viewportDimension;
                      final contentHeight =
                          _scrollController.position.maxScrollExtent +
                          viewportHeight;

                      if (contentHeight <= viewportHeight) {
                        return const SizedBox.shrink();
                      }

                      final trackHeight = constraints.maxHeight;
                      final thumbHeight = _calculateThumbHeight(trackHeight);

                      final scrollFraction = _scrollController.hasClients
                          ? (_scrollController.offset /
                                    _scrollController.position.maxScrollExtent)
                                .clamp(0.0, 1.0)
                          : 0.0;

                      final thumbTop =
                          scrollFraction * (trackHeight - thumbHeight);

                      return Stack(
                        children: [
                          Positioned(
                            top: thumbTop,
                            left: (widget.trackWidth - widget.thumbWidth) / 2,
                            height: thumbHeight,
                            width: widget.thumbWidth,
                            child: Container(
                              decoration: BoxDecoration(
                                color: widget.thumbColor,
                                borderRadius: BorderRadius.circular(
                                  widget.thumbRadius,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          )
        else
          Positioned(
            left: 0,
            right: 0,
            bottom: widget.position == ScrollbarPosition.right ? 0 : null,
            top: widget.position == ScrollbarPosition.left ? 0 : null,
            height: widget.trackWidth + widget.margin.vertical,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onHorizontalDragStart: _onHorizontalDragStart,
                onHorizontalDragUpdate: _onHorizontalDragUpdate,
                onHorizontalDragEnd: _onHorizontalDragEnd,
                child: Container(
                  margin: widget.margin,
                  decoration: BoxDecoration(
                    color: widget.showTrack
                        ? widget.trackColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(widget.trackWidth / 2),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (!_scrollController.hasClients ||
                          _scrollController.position.maxScrollExtent == 0) {
                        return const SizedBox.shrink();
                      }

                      final viewportWidth =
                          _scrollController.position.viewportDimension;
                      final contentWidth =
                          _scrollController.position.maxScrollExtent +
                          viewportWidth;

                      if (contentWidth <= viewportWidth) {
                        return const SizedBox.shrink();
                      }

                      final trackWidth = constraints.maxWidth;
                      final thumbWidth = _calculateThumbWidth(trackWidth);

                      final scrollFraction = _scrollController.hasClients
                          ? (_scrollController.offset /
                                    _scrollController.position.maxScrollExtent)
                                .clamp(0.0, 1.0)
                          : 0.0;

                      final thumbLeft =
                          scrollFraction * (trackWidth - thumbWidth);

                      return Stack(
                        children: [
                          Positioned(
                            left: thumbLeft,
                            top: (widget.trackWidth - widget.thumbWidth) / 2,
                            width: thumbWidth,
                            height: widget.thumbWidth,
                            child: Container(
                              decoration: BoxDecoration(
                                color: widget.thumbColor,
                                borderRadius: BorderRadius.circular(
                                  widget.thumbRadius,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The position of the scrollbar
enum ScrollbarPosition {
  /// The scrollbar is on the left side
  left,

  /// The scrollbar is on the right side
  right,
}

/// Custom scroll behavior for edge glow effect
class _CustomScrollBehavior extends ScrollBehavior {
  final Color glowColor;

  const _CustomScrollBehavior({required this.glowColor});

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: glowColor,
      child: child,
    );
  }
}

/// Extension to create a CustomScrollbar from a SingleChildScrollView
extension SingleChildScrollViewExtension on SingleChildScrollView {
  /// Wraps this SingleChildScrollView with a CustomScrollbar
  Widget withCustomScrollbar({
    double trackWidth = 6.0,
    double thumbWidth = 6.0,
    double thumbRadius = 3.0,
    Color thumbColor = const Color(0xFF888888),
    Color trackColor = const Color(0x1F000000),
    bool alwaysVisible = false,
    Duration visibilityDuration = const Duration(seconds: 1),
    Duration fadeAnimationDuration = const Duration(milliseconds: 300),
    Curve fadeAnimationCurve = Curves.easeInOut,
    double minThumbHeight = 40.0,
    ScrollbarPosition position = ScrollbarPosition.right,
    EdgeInsets margin = const EdgeInsets.all(2.0),
    bool showTrack = true,
    bool enableHapticFeedback = true,
    bool enableDrag = true,
    void Function(double)? onDragThumb,
    bool showScrollIndicators = false,
    Color scrollIndicatorColor = const Color(0x80000000),
    bool showEdgeGlow = false,
    Color? edgeGlowColor,
    Axis axis = Axis.vertical,
  }) {
    return CustomScrollbar(
      controller: controller,
      wrapWithScrollView: false,
      trackWidth: trackWidth,
      thumbWidth: thumbWidth,
      thumbRadius: thumbRadius,
      thumbColor: thumbColor,
      trackColor: trackColor,
      alwaysVisible: alwaysVisible,
      visibilityDuration: visibilityDuration,
      fadeAnimationDuration: fadeAnimationDuration,
      fadeAnimationCurve: fadeAnimationCurve,
      minThumbHeight: minThumbHeight,
      position: position,
      margin: margin,
      showTrack: showTrack,
      enableHapticFeedback: enableHapticFeedback,
      enableDrag: enableDrag,
      onDragThumb: onDragThumb,
      showScrollIndicators: showScrollIndicators,
      scrollIndicatorColor: scrollIndicatorColor,
      showEdgeGlow: showEdgeGlow,
      edgeGlowColor: edgeGlowColor,
      axis: axis,
      child: this,
    );
  }
}
