// ignore_for_file: prefer_typing_uninitialized_variables

import '../../fake_wx_drag_dismiss.dart';
import '../core/drag_dismiss_mixin.dart';
import 'package:flutter/rendering.dart';

import '../animation_controllers/drag_fade_animation_controller.dart';
import '../animation_controllers/drag_normal_animation_controller.dart';
import 'package:flutter/material.dart';

import '../core/drag_notification.dart';

class DragPopWidget extends StatefulWidget {
  const DragPopWidget({
    Key? key,
    this.onClosing,
    required this.child,
    this.onDragStart,
    this.onDragEnd,
    this.onPanUpdate,
    this.onAnimationFinish,
    this.dragDismissWithNoScaleAnimationAtTopEdge = false,
    required this.animationController,
    required this.fadeAnimationController,
  }) : super(key: key);
  final Function()? onClosing;
  final Widget child;
  final Function()? onDragStart;
  final ValueChanged<Offset>? onPanUpdate;
  final ValueChanged<Offset>? onDragEnd;
  final Function()? onAnimationFinish;
  final AnimationController animationController;
  final AnimationController fadeAnimationController;
  final bool dragDismissWithNoScaleAnimationAtTopEdge;
  @override
  DragPopWidgetState createState() => DragPopWidgetState();

  static const double minScale = 0.6;
}

class DragPopWidgetState extends State<DragPopWidget>
    with SingleTickerProviderStateMixin, DragDismissMixin {
  final ValueNotifier<double> _scaleNotifier = ValueNotifier<double>(1.0);
  final ValueNotifier<Offset> _offsetNotifier =
      ValueNotifier<Offset>(Offset.zero);
  late double midDy;
  bool _isBottomDir = false;

  late AnimationController _resetController;
  late Animation _resetAnimation;

  double _lastScale = 0;
  Offset _lastOffset = Offset.zero;
  double _lastFade = 0;

  late var statusListener;
  late var valueListener;

  bool isClosing = false;

  bool atTopEdge = false;
  ScrollDirection direction = ScrollDirection.idle;
  Offset moveDelta = Offset.zero;

  @override
  void initState() {
    final MediaQueryData data = MediaQueryData.fromView(
        WidgetsBinding.instance.platformDispatcher.views.first);
    midDy = data.size.height / 2;
    super.initState();
    _resetController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _resetAnimation = CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOut,
    )..addListener(() {
        _scaleNotifier.value =
            _resetAnimation.value * (1 - _lastScale) + _lastScale;
        widget.animationController.value =
            _resetAnimation.value * (1 - _lastFade) + _lastFade;
        double dx =
            _resetAnimation.value * (1 - _lastOffset.dx) + _lastOffset.dx;
        double dy =
            _resetAnimation.value * (1 - _lastOffset.dy) + _lastOffset.dy;
        _offsetNotifier.value = Offset(dx, dy);
        widget.onDragEnd?.call(_lastOffset);
      });

    statusListener = (status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationFinish?.call();
      }
    };
    valueListener = () {
      widget.fadeAnimationController.value = widget.animationController.value;
    };
    widget.animationController.addStatusListener(statusListener);
    widget.animationController.addListener(valueListener);
    DragDismissController.instance.addListener(closing);
    moveController = widget.animationController;
  }

  @override
  void dispose() {
    _resetController.dispose();
    widget.animationController.removeStatusListener(statusListener);
    widget.animationController.removeListener(valueListener);
    DragDismissController.instance.removeListener(closing);
    super.dispose();
    DragDismissController.dispose();
    DragFadeAnimationController.destroy();
    DragNormalAnimationController.destroy();
  }

  void onPanStart(DragStartDetails details) {
    widget.onDragStart?.call();
  }

  void onPanUpdate(Offset delta) {
    // if (isActive) return;
    _offsetNotifier.value += delta;
    widget.onPanUpdate?.call(delta);
    if (isChildBelowMid(_offsetNotifier.value.dy)) {
      // dy : sy = x : 1 - min
      _scaleNotifier.value =
          1 - (_offsetNotifier.value.dy / midDy * (1 - DragPopWidget.minScale));
      widget.animationController.value = 1 - (_offsetNotifier.value.dy / midDy);
    } else {
      if (_scaleNotifier.value != 1) {
        _scaleNotifier.value = 1;
        widget.animationController.value = 1;
      }
    }
    if (delta.dy > 0.15) {
      _isBottomDir = true;
    } else {
      _isBottomDir = false;
    }
  }

  void onPanEnd() {
    if (isChildBelowMid(_offsetNotifier.value.dy - 100)) {
      if (_isBottomDir) {
        closing();
        return;
      }
    }
    _lastScale = _scaleNotifier.value;
    _lastOffset = _offsetNotifier.value;
    _lastFade = widget.animationController.value;
    _resetController.forward(from: 0);
  }

  void reset() {
    _lastScale = 0;
    _lastOffset = Offset.zero;
    _lastFade = 0;
    _resetController.forward(from: 1);
  }

  void onPanCancel() {}

  bool isChildBelowMid(double dy) {
    return _offsetNotifier.value.dy > 0;
  }

  void closing() {
    if (isClosing) {
      return;
    }
    isClosing = true;
    widget.animationController.removeListener(valueListener);
    widget.onClosing?.call();
  }

  void _onPointerDown(PointerDownEvent event) {
    activePointerCount++;
  }

  void _onPointerUp(_) {
    activePointerCount--;
    if (dragUnderway && activePointerCount == 0) {
      onPanEnd();
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    moveDelta = event.delta;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerCancel: _onPointerUp,
      onPointerUp: _onPointerUp,
      onPointerMove: _onPointerMove,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is UserScrollNotification && atTopEdge) {
            direction = notification.direction;
          }
          if (notification is ScrollStartNotification) {
            atTopEdge = notification.metrics.pixels ==
                notification.metrics.minScrollExtent;
          }
          if (notification is ScrollUpdateNotification &&
              atTopEdge &&
              direction == ScrollDirection.forward) {
            if (direction == ScrollDirection.forward) {
              if (atTopEdge &&
                  widget.dragDismissWithNoScaleAnimationAtTopEdge &&
                  moveDelta.dx.abs() < 0.3 &&
                  moveDelta.dy.abs() > 0.7) {
                closing();
              }
            }
            if (notification.dragDetails != null) {
              dragUnderway = true;
              DragUpdateDetails details = notification.dragDetails!;
              onPanUpdate(Offset(moveDelta.dx, details.delta.dy));
            } else {
              dragUnderway = false;
              onPanEnd();
            }
          }

          return false;
        },
        child: NotificationListener(
          onNotification: (notification) {
            if (notification is DragStartNotification) {
              dragUnderway = true;
              onPanStart(notification.details);
            } else if (notification is DragUpdateNotification) {
              onPanUpdate(notification.details.delta);
            } else if (notification is DragEndNotification) {
              dragUnderway = false;
              onPanEnd();
            } else if (notification is DragCancelNotification) {
              dragUnderway = false;
              onPanCancel();
            }
            return false;
          },
          child: ValueListenableBuilder<Offset>(
            valueListenable: _offsetNotifier,
            builder: (context, offset, child) {
              return Transform.translate(
                offset: offset,
                child: ValueListenableBuilder<double>(
                  valueListenable: _scaleNotifier,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: RepaintBoundary(
                        child: widget.child,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
