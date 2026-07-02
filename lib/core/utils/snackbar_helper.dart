import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

// import 'package:fluttertoast/fluttertoast.dart';
import 'package:notebook_ai/core/app.dart';
import 'package:notebook_ai/core/extensions/extensions.dart';
import 'package:notebook_ai/core/ui_kit/overlays/zesty_snack.dart';
import 'package:notebook_ai/core/res/color_manager.dart';
import 'package:notebook_ai/core/ui_kit/shapes/gradient_border_side.dart';
import 'package:notebook_ai/core/res/sizes_manager.dart';

// error message
enum ErrorMessage {
  snackBar,
  toast;

  bool get isSnackBar => this == ErrorMessage.snackBar;

  bool get isToast => this == ErrorMessage.toast;
}

class SnackbarHelper {
  void showMessage(
    String message,
    ErrorMessage type, {
    int snackbarSeconds = 4,
    bool isError = false,
    List<Widget> actions = const [],
  }) {
    if (type.isSnackBar) {
      _showSnackbar(message, snackbarSeconds, isError, actions);
    } else {
      _showToast(message);
    }
  }

  static void _showSnackbar(
    String message, [
    int snackbarSeconds = 3,
    bool isError = false,
    List<Widget> actions = const [],
  ]) {
    ZestySnack.instance.show(
      Padding(
        padding: EdgeInsets.all(SizeM.pagePadding.dg),
        child: Row(
          children: [
            ...actions,
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.w),
                width: double.infinity,
                decoration: ShapeDecoration(
                  color: ColorM.white,
                  shape: SmoothRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    smoothness: 1,
                    side: GradientBorderSide(color: ColorM.primary, width: 1.w),
                  ),
                ),
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  message,
                  softWrap: true,
                  style: NAVIGATOR_KEY.currentState!.context.labelMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showToast(String message) {
    // Fluttertoast.showToast(
    //   msg: message,
    //   toastLength: Toast.LENGTH_SHORT,
    //   gravity: ToastGravity.BOTTOM,
    //   timeInSecForIosWeb: 3,
    //   backgroundColor: ColorM.primary,
    //   textColor: Colors.white,
    //   fontSize:
    //       SCAFFOLD_MESSENGER_KEY.currentContext?.labelMedium.fontSize ?? 14,
    // );
  }
}
