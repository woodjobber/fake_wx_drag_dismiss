import 'package:flutter/material.dart';

import '../animation_controllers/default_duration.dart';
import '../animation_controllers/drag_fade_animation_controller.dart';
import '../animation_controllers/drag_normal_animation_controller.dart';
import '../core/drag_transition_builder.dart';

const Duration dragDefaultTransitionDuration = defaultDuration;

Widget defaultTransitionsBuilder(BuildContext context, Widget child,
    {bool hero = true}) {
  return DragTransitionBuilder.create(
    context,
    child,
    hero: hero,
    DragNormalAnimationController.create(context),
    DragFadeAnimationController.create(context),
  );
}
