import 'package:flutter/material.dart';
import 'package:for_u/presentation/res/color_manager.dart';

class MyCircularProgressIndicator extends StatelessWidget {
  const MyCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          color: ColorM.primary,
          backgroundColor: ColorM.gray500.withValues(alpha: .1),
          strokeCap: StrokeCap.round,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
