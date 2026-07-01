import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

// abstract class GetRenderBox{
//   RenderBox get(GlobalKey key){
//     final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
//     return renderBox;
//   }
// }

/// A custom RenderObject that allows tracking the size of its child widget.
class SizeTrackingRenderObject extends RenderProxyBox {
  final void Function(RenderBox renderBox)? onRenderObjectChange;
  final void Function(RenderBox renderBox)? onRenderedObject;

  SizeTrackingRenderObject({this.onRenderObjectChange, this.onRenderedObject});

  @override
  void performLayout() {
    super.performLayout();

    if (child != null) {
      final RenderBox renderBox = child!;
      if (onRenderedObject != null) {
        WidgetsBinding.instance.endOfFrame.then((_) {
          try {
            onRenderedObject!(renderBox);
          } catch (e) {
            _handleError(e);
          }
        });
      }

      if (onRenderObjectChange != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            onRenderObjectChange!(renderBox);
          } catch (e) {
            _handleError(e);
          }
        });
      }
    }
  }

  void _handleError(dynamic error) {
    if (kDebugMode) {
      print('Error in SizeTrackingRenderObject: $error');
    }
  }
}

class RenderBoxExchange extends SingleChildRenderObjectWidget {
  final void Function(RenderBox renderBox)? onRenderObjectChange;
  final void Function(RenderBox renderBox)? onRenderedObject;

  const RenderBoxExchange({
    super.key,
    required super.child,
    this.onRenderObjectChange,
    this.onRenderedObject,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return SizeTrackingRenderObject(
      onRenderObjectChange: onRenderObjectChange,
      onRenderedObject: onRenderedObject,
    );
  }
}
