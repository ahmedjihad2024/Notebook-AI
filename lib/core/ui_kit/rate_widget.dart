import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class RateWidget extends StatefulWidget {
  final Function(double rate) onRateChange;
  final double? initialRate;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;
  final double spacing;
  final bool allowHalfRating;
  final IconData filledIcon;
  final IconData halfFilledIcon;
  final IconData unfilledIcon;

  /// Optional SVG asset used to render each star instead of [filledIcon] /
  /// [unfilledIcon]. The asset is tinted with [activeColor] when selected and
  /// [inactiveColor] otherwise. Half ratings are not supported with an asset.
  final String? starAsset;
  final bool readonly;
  final MainAxisAlignment alignment;
  final EdgeInsets padding;

  const RateWidget({
    super.key,
    required this.onRateChange,
    this.initialRate,
    this.activeColor,
    this.inactiveColor,
    this.size = 24.0,
    this.spacing = 0.0,
    this.allowHalfRating = false,
    this.filledIcon = Icons.star,
    this.halfFilledIcon = Icons.star_half,
    this.unfilledIcon = Icons.star_border,
    this.starAsset,
    this.readonly = false,
    this.alignment = MainAxisAlignment.center,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<RateWidget> createState() => _RateWidgetState();
}

class _RateWidgetState extends State<RateWidget> {
  late double rate;

  @override
  void initState() {
    super.initState();
    rate = widget.initialRate ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final activeColor =
        widget.activeColor ?? const Color.fromARGB(255, 240, 205, 4);
    final inactiveColor =
        widget.inactiveColor ?? Colors.black.withValues(alpha: .1);

    return Padding(
      padding: widget.padding,
      child: Row(
        mainAxisAlignment: widget.alignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 5; i++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              child: GestureDetector(
                onTap: widget.readonly ? null : () => _updateRating(i + 1),
                onHorizontalDragUpdate:
                    widget.readonly || !widget.allowHalfRating
                    ? null
                    : (details) {
                        final box = context.findRenderObject() as RenderBox;
                        final localPosition = box.globalToLocal(
                          details.globalPosition,
                        );
                        final i =
                            localPosition.dx ~/ (widget.size + widget.spacing);
                        if (i < 0) {
                          _updateRating(0);
                        } else if (i >= 5) {
                          _updateRating(5);
                        } else {
                          final starPosition =
                              i * (widget.size + widget.spacing);
                          final position =
                              (localPosition.dx - starPosition) / widget.size;
                          _updateRating(i + (position > 0.5 ? 1.0 : 0.5));
                        }
                      },
                child: _buildStar(i + 1, activeColor, inactiveColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStar(int position, Color activeColor, Color inactiveColor) {
    IconData icon;
    Color color;

    if (position <= rate) {
      icon = widget.filledIcon;
      color = activeColor;
    } else if (widget.allowHalfRating && position - 0.5 <= rate) {
      icon = widget.halfFilledIcon;
      color = activeColor;
    } else {
      icon = widget.unfilledIcon;
      color = inactiveColor;
    }

    if (widget.starAsset != null) {
      return SvgPicture.asset(
        widget.starAsset!,
        width: widget.size,
        height: widget.size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }

    return Icon(icon, color: color, size: widget.size);
  }

  Future<void> _updateRating(double newRating) async {
    if (newRating != rate) {
      setState(() {
        rate = newRating;
      });
      widget.onRateChange(rate);
      await HapticFeedback.lightImpact();
    }
  }
}
