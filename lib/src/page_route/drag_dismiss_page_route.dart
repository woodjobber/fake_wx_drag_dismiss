// ignore_for_file: overridden_fields

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/drag_dismiss_manager.dart';
import '../widgets/drag_pop_widget.dart';

class DragDismissPageRoute<T> extends PageRoute<T>
    with CupertinoRouteTransitionMixin {
  DragDismissPageRoute({
    required this.builder,
    RouteSettings? settings,
    this.maintainState = true,
    this.needHero = true,
  }) : super(settings: settings, fullscreenDialog: true);

  final WidgetBuilder builder;

  @override
  final bool maintainState;

  final bool needHero;

  AnimationController? _animationController;
  AnimationController? _fadeAnimationController;

  @override
  Widget buildContent(BuildContext context) {
    return DragPopWidget(
      animationController: _animationController!,
      fadeAnimationController: _fadeAnimationController!,
      onClosing: () {
        DragDismissManager.sendClosing();
        if (needHero) {
          _animationController!.value = 1;
          _fadeAnimationController!.animateTo(0, duration: transitionDuration);
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
      child: builder(context),
    );
  }

  @override
  AnimationController createAnimationController() {
    if (_animationController == null) {
      _animationController = AnimationController(
        vsync: navigator!.overlay!,
        duration: transitionDuration,
        reverseDuration: transitionDuration,
      );
      _fadeAnimationController = AnimationController(
        vsync: navigator!.overlay!,
        duration: transitionDuration,
        reverseDuration: transitionDuration,
        value: 1,
      );
    }
    return _animationController!;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return Stack(
      children: [
        FadeTransition(
          opacity: !needHero || isActive
              ? _animationController!
              : _fadeAnimationController!,
          child: Container(
            color: Colors.black,
          ),
        ),
        child,
      ],
    );
  }

  @override
  String? get title => null;
}
