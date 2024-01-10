import 'package:flutter/cupertino.dart';

import 'default_duration.dart';

class DragFadeAnimationController extends AnimationController {
  Duration get transitionDuration => defaultDuration;

  DragFadeAnimationController._({required super.vsync}) {
    duration = transitionDuration;
    reverseDuration = transitionDuration;
    value = 1;
  }

  static DragFadeAnimationController? _controller;

  factory DragFadeAnimationController.create(BuildContext context) {
    TickerProvider vsync = Navigator.of(context).overlay!;
    _controller ??= DragFadeAnimationController._(vsync: vsync);
    return _controller!;
  }

  static void destroy() {
    _controller = null;
  }
}
