import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:for_u/app/extensions/extensions.dart';
import 'package:for_u/presentation/res/gen/assets.gen.dart';
import 'package:smooth_corner/smooth_corner.dart';

class CustomCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? errorBackgroundColor;
  final Widget? errorWidget;
  final Widget? placeholder;
  final BorderRadius? borderRadius;
  final bool isCircle;
  final BorderSide side;

  const CustomCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBackgroundColor,
    this.errorWidget,
    this.placeholder,
    this.borderRadius,
    this.isCircle = false,
    this.side = BorderSide.none,
  });

  @override
  Widget build(BuildContext context) {
    final double finalWidth = width ?? 20.w;
    final double finalHeight = height ?? 20.w;

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: finalWidth,
      height: finalHeight,
      fit: fit,
      placeholder: placeholder != null ? (context, url) => placeholder! : null,
      errorWidget: errorWidget != null
          ? (context, url, error) => errorWidget!
          : (context, url, error) => Container(
              width: finalWidth,
              height: finalHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    errorBackgroundColor ??
                    context.colorScheme.surface.withValues(alpha: 0.1),
              ),
              child: SvgPicture.asset(
                Assets.svg.appLogo.path,
                width: finalWidth * 0.8,
                height: finalHeight * 0.8,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: .1),
                  BlendMode.srcIn,
                ),
              ),
            ),
    );

    return SmoothClipRRect(
      smoothness: 1,
      borderRadius: isCircle
          ? BorderRadius.circular(999999)
          : (borderRadius ?? BorderRadius.circular(5.r)),
      side: side,
      child: imageWidget,
    );
  }
}

// Specialized circular image widget
class CircularCachedImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Color? errorBackgroundColor;
  final Widget? errorWidget;
  final Widget? placeholder;
  final bool isCircle;

  const CircularCachedImage({
    Key? key,
    required this.imageUrl,
    this.size = 40,
    this.errorBackgroundColor,
    this.errorWidget,
    this.placeholder,
    this.isCircle = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCachedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      isCircle: true,
      errorBackgroundColor: errorBackgroundColor,
      errorWidget: errorWidget,
      placeholder: placeholder,
    );
  }
}
