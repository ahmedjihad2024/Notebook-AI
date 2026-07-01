import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u/app/extensions/extensions.dart';
import 'package:for_u/app/ui_kit/buttons/custom_ink_button.dart';
import 'package:for_u/presentation/common/general_padding.dart';
import 'package:for_u/presentation/res/color_manager.dart';
import 'package:for_u/presentation/res/fonts_manager.dart';
import 'package:for_u/presentation/res/gen/assets.gen.dart';
import 'package:for_u/presentation/res/translations_manager.dart';
import 'package:lottie/lottie.dart';

enum ErrorType { noInternet, noResults, noNotification, notFound, noEsim, none }

class MyErrorWidget extends StatelessWidget {
  final void Function()? onRetry;
  final String? retryText;
  final String? svgPath;
  final String titleMessage;
  final String? subtitleMessage;
  final ErrorType? errorType;
  final double? svgSize;

  const MyErrorWidget({
    super.key,
    this.onRetry,
    this.retryText,
    this.svgPath,
    required this.titleMessage,
    this.subtitleMessage,
    this.errorType,
    this.svgSize,
  });

  @override
  Widget build(BuildContext context) {
    // if (errorType != null) {
    //   switch (errorType!) {
    //     case ErrorType.noInternet:
    //       return NoInternetWidget(onRetry: onRetry, svgSize: svgSize);
    //     case ErrorType.noResults:
    //       return NoResultsFoundWidget(onRetry: onRetry, svgSize: svgSize);
    //     case ErrorType.noNotification:
    //       return NoNotificationWidget(onRetry: onRetry, svgSize: svgSize);
    //     case ErrorType.notFound:
    //       return NotFoundWidget(onRetry: onRetry, svgSize: svgSize);
    //     case ErrorType.noEsim:
    //       return NoEsimWidget(onRetry: onRetry, svgSize: svgSize);
    //     case ErrorType.none:
    //       break;
    //   }
    // }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (svgPath != null) ...[
          SvgPicture.asset(
            svgPath!,
            height: svgSize ?? 270.w,
            width: svgSize ?? 270.w,
          ),
          14.verticalSpace,
        ] else
          Lottie.asset(
            Assets.lottieAnimations.error.path,
            key: const Key("empty-lottie-error-render"),
            width: 200.w,
            height: 200.w,
            repeat: true,
            fit: BoxFit.contain,
          ),
        Text(
          titleMessage,
          textAlign: TextAlign.center,
          style: context.headlineMedium.copyWith(
            fontWeight: FontWeightM.medium,
            fontSize: 24.sp,
          ),
        ),
        if (subtitleMessage != null) ...[
          15.verticalSpace,
          Text(
            subtitleMessage!,
            textAlign: TextAlign.center,
            style: context.titleMedium.copyWith(
              color: context.colorScheme.surface.withValues(alpha: .5),
            ),
          ),
        ],
        if (onRetry != null) ...[
          32.verticalSpace,
          RetryButton(onRetry: onRetry, retryText: retryText),
        ],
      ],
    );
  }
}

class RetryButton extends StatelessWidget {
  final String? retryText;
  final void Function()? onRetry;

  const RetryButton({super.key, this.retryText, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return CustomInkButton(
      onTap: onRetry,
      backgroundColor: ColorM.primary,
      borderRadius: 10.r,
      padding: EdgeInsets.symmetric(horizontal: 46.w, vertical: 11.5.w),
      smoothness: 1,
      boxShadow: [
        BoxShadow(
          color: ColorM.primary.withValues(alpha: 0.2),
          blurRadius: 0,
          offset: Offset(9.w, 9.w),
        ),
      ],
      child: Text(
        retryText ?? Translation.retry_button.tr,
        style: context.labelMedium.copyWith(
          fontWeight: FontWeightM.medium,
          color: Colors.white,
        ),
      ),
    );
  }
}

// class NoInternetWidget extends StatelessWidget {
//   const NoInternetWidget({super.key, this.onRetry, this.svgSize});

//   final void Function()? onRetry;
//   final double? svgSize;

//   @override
//   Widget build(BuildContext context) {
//     return MyErrorWidget(
//       svgSize: svgSize,
//       onRetry: onRetry,
//       titleMessage: Translation.no_connection.tr,
//       subtitleMessage: Translation.oops_offline.tr,
//       svgPath: context.isDark
//           ? SvgM.noInternetIconDark
//           : SvgM.noInternetIconLight,
//     );
//   }
// }

// class NoResultsFoundWidget extends StatelessWidget {
//   const NoResultsFoundWidget({super.key, this.onRetry, this.svgSize});

//   final void Function()? onRetry;
//   final double? svgSize;

//   @override
//   Widget build(BuildContext context) {
//     return MyErrorWidget(
//       svgSize: svgSize,
//       onRetry: onRetry,
//       titleMessage: Translation.no_results_found.tr,
//       subtitleMessage: Translation.no_results_try_again.tr,
//       svgPath: context.isDark ? SvgM.searchIconDark : SvgM.searchIconLight,
//     );
//   }
// }

// class NoNotificationWidget extends StatelessWidget {
//   const NoNotificationWidget({super.key, this.onRetry, this.svgSize});

//   final void Function()? onRetry;
//   final double? svgSize;

//   @override
//   Widget build(BuildContext context) {
//     return MyErrorWidget(
//       svgSize: svgSize,
//       onRetry: onRetry,
//       titleMessage: Translation.no_notifications.tr,
//       subtitleMessage: Translation.no_notifications_yet.tr,
//       svgPath: context.isDark
//           ? SvgM.notificationIconDark
//           : SvgM.notificationIconLight,
//     );
//   }
// }

// class NotFoundWidget extends StatelessWidget {
//   const NotFoundWidget({super.key, this.onRetry, this.svgSize});

//   final void Function()? onRetry;
//   final double? svgSize;

//   @override
//   Widget build(BuildContext context) {
//     return MyErrorWidget(
//       svgSize: svgSize,
//       onRetry: onRetry,
//       titleMessage: Translation.oops_page_not_found.tr,
//       subtitleMessage: Translation.oops_page_not_found.tr,
//       svgPath: context.isDark ? SvgM.notFoundIconDark : SvgM.notFoundIconLight,
//     );
//   }
// }

// class NoEsimWidget extends StatelessWidget {
//   const NoEsimWidget({super.key, this.onRetry, this.svgSize});

//   final void Function()? onRetry;
//   final double? svgSize;

//   @override
//   Widget build(BuildContext context) {
//     return MyErrorWidget(
//       svgSize: svgSize,
//       onRetry: onRetry,
//       retryText: Translation.explore_esims.tr,
//       titleMessage: Translation.no_esims_yet.tr,
//       subtitleMessage: Translation.buy_first_esim.tr,
//       svgPath: context.isDark
//           ? SvgM.paperPlaneIconDark
//           : SvgM.paperPlaneIconLight,
//     );
//   }
// }
