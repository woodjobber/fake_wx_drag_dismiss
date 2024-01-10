import 'package:flutter/cupertino.dart';

import 'default_duration.dart';

class DragNormalAnimationController extends AnimationController {
  Duration get transitionDuration => defaultDuration;

  DragNormalAnimationController._({required super.vsync}) {
    duration = transitionDuration;
    reverseDuration = transitionDuration;
  }

  static DragNormalAnimationController? _controller;

  factory DragNormalAnimationController.create(BuildContext context) {
    TickerProvider vsync = Navigator.of(context).overlay!;
    _controller ??= DragNormalAnimationController._(vsync: vsync);
    return _controller!;
  }

  static void destroy() {
    _controller = null;
  }
}
