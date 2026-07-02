import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:notebook_ai/core/utils/mixins/after_layout.dart';

class CaptureController {
  late Future<Uint8List> Function() _captureWidget;

  void _setCaptureFunction(Future<Uint8List> Function() fun) {
    _captureWidget = fun;
  }

  Future<Uint8List> captureWidgetAsBuffer() async {
    return _captureWidget();
  }

  Future<void> captureAndSaveAsImage({required String path}) async {
    Uint8List buffer = await captureWidgetAsBuffer();
    final file = File('$path/IMG-${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(buffer);
  }
}

class CaptureWidget extends StatefulWidget {
  final Widget child;
  final CaptureController controller;

  const CaptureWidget({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<CaptureWidget> createState() => _CaptureWidgetState();
}

class _CaptureWidgetState extends State<CaptureWidget> with AfterLayout {
  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(key: _globalKey, child: widget.child);
  }

  @override
  Future<void> afterLayout(BuildContext context) async {
    widget.controller._setCaptureFunction(() async {
      try {
        RenderRepaintBoundary boundary =
            _globalKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary;

        ui.Image originalSize = await boundary.toImage(pixelRatio: 1);
        double newPixelRatio = 1024 / originalSize.width;

        ui.Image image = await boundary.toImage(pixelRatio: newPixelRatio);
        ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        return byteData!.buffer.asUint8List();
      } catch (e) {
        throw Exception(e);
      }
    });
  }
}
