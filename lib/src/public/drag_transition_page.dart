import '../core/drag_pop_gesture.dart';
import '../animation_controllers/drag_fade_animation_controller.dart';
import '../animation_controllers/drag_normal_animation_controller.dart';
import 'package:flutter/material.dart';

import '../core/drag_dismiss_manager.dart';
import '../widgets/drag_pop_widget.dart';

class DragTransitionPage extends StatefulWidget {
  const DragTransitionPage({
    super.key,
    required this.builder,
    this.hero = true,
    this.dragDismissWithNoScaleAnimationAtTopEdge = false,
  });
  final WidgetBuilder builder;
  final bool hero;

  /// 针对 PageView,在顶部，直接关闭，没有缩放效果
  ///
  final bool dragDismissWithNoScaleAnimationAtTopEdge;
  @override
  State<DragTransitionPage> createState() => _DragTransitionPageState();
}

class _DragTransitionPageState extends State<DragTransitionPage>
    with TickerProviderStateMixin {
  late DragNormalAnimationController normalAnimationController;

  late DragFadeAnimationController fadeAnimationController;

  bool get hero => widget.hero;

  WidgetBuilder get builder => widget.builder;

  @override
  void initState() {
    super.initState();
    normalAnimationController = DragNormalAnimationController.create(context);
    fadeAnimationController = DragFadeAnimationController.create(context);
  }

  @override
  Widget build(BuildContext context) {
    return DragPopWidget(
      dragDismissWithNoScaleAnimationAtTopEdge:
          widget.dragDismissWithNoScaleAnimationAtTopEdge,
      animationController: normalAnimationController,
      fadeAnimationController: fadeAnimationController,
      onClosing: () {
        DragDismissManager.sendClosing();
        if (hero) {
          normalAnimationController.value = 1;
          fadeAnimationController.animateTo(0,
              duration: fadeAnimationController.transitionDuration);
        }
        Navigator.pop(context);
      },
      onDragStart: () {
        DragDismissManager.sendDragStart();
      },
      onDragEnd: (offset) {
        DragDismissManager.sendDragEnd(offset);
      },
      onAnimationFinish: () {
        DragDismissManager.sendAnimationFinish();
      },
      onPanUpdate: (delta) {
        DragDismissManager.sendDragUpdate(delta);
      },
      // child: builder(context),
      child: DragPopGesture(
        child: builder(context),
      ),
    );
  }
}
