import 'package:flutter/widgets.dart';

mixin AfterLayout<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) afterLayout(context);
    });
  }

  Future<void> afterLayout(BuildContext context);
}
