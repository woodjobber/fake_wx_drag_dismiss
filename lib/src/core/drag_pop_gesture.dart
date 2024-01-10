import 'package:flutter/material.dart';

import 'drag_notification.dart';

/// 指定用于拖拽的区域
/// 包裹 [child], 则只有[child]会被响应拖拽事件
///
class DragPopGesture extends StatelessWidget {
  final Widget child;

  const DragPopGesture({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        DragStartNotification(details).dispatch(context);
      },
      onPanUpdate: (details) {
        DragUpdateNotification(details).dispatch(context);
      },
      onPanEnd: (details) {
        DragEndNotification(details).dispatch(context);
      },
      onPanCancel: () {
        DragCancelNotification().dispatch(context);
      },
      child: child,
    );
  }
}
