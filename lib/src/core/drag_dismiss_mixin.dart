import 'package:flutter/animation.dart';

mixin DragDismissMixin {
  late final AnimationController moveController;
  int activePointerCount = 0;
  bool dragUnderway = false;
  bool get isActive => dragUnderway || moveController.isAnimating;
}
