import '../animation_controllers/drag_fade_animation_controller.dart';
import '../animation_controllers/drag_normal_animation_controller.dart';
import 'package:flutter/material.dart';

class DragTransitionBuilder {
  DragTransitionBuilder._();

  static Widget create(
    BuildContext context,
    Widget child,
    DragNormalAnimationController dragNormalAnimationController,
    DragFadeAnimationController dragFadeAnimationController, {
    bool hero = true,
  }) {
    return Stack(
      children: [
        FadeTransition(
          opacity: !hero
              ? dragNormalAnimationController
              : dragFadeAnimationController,
          child: Container(
            color: Colors.black,
          ),
        ),
        child,
      ],
    );
  }
}
