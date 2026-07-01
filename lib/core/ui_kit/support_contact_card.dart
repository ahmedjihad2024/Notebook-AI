import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u/app/extensions/extensions.dart';
import 'package:for_u/presentation/res/color_manager.dart';
import 'package:for_u/presentation/res/fonts_manager.dart';

class SupportContactCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;

  const SupportContactCard({
    super.key,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: ColorM.gray50,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: context.titleMedium.copyWith(
                      fontWeight: FontWeightM.bold,
                      color: ColorM.gray900,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.dg),
                  decoration: const BoxDecoration(
                    color: ColorM.primary50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone_rounded,
                    size: 20.w,
                    color: ColorM.primary500,
                  ),
                ),
              ],
            ),
            16.verticalSpace,
            Text(
              description,
              style: context.bodyMedium.copyWith(
                color: ColorM.gray600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
