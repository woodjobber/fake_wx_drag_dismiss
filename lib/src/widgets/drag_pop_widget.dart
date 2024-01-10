// ignore_for_file: prefer_typing_uninitialized_variables

import '../../fake_wx_drag_dismiss.dart';
import '../animation_controllers/drag_fade_animation_controller.dart';
import '../animation_controllers/drag_normal_animation_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/drag_notification.dart';

class DragPopWidget extends StatefulWidget {
  const DragPopWidget({
    Key? key,
    this.onClosing,
    required this.child,
    this.onDragStart,
    this.onDragEnd,
    this.onAnimationFinish,
    required this.animationController,
    required this.fadeAnimationController,
  }) : super(key: key);
  final Function? onClosing;
  final Widget child;
  final Function? onDragStart;
  final ValueChanged<Offset>? onDragEnd;
  final Function? onAnimationFinish;
  final AnimationController animationController;
  final AnimationController fadeAnimationController;
  // final ChangeNotifier manualClosingNotifier;
  @override
  DragPopWidgetState createState() => DragPopWidgetState();

  static const double minScale = 0.6;
}

class DragPopWidgetState extends State<DragPopWidget>
    with SingleTickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print("DragPopWidget dispose...");
    }
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

  void onPanUpdate(DragUpdateDetails details) {
    _offsetNotifier.value += details.delta;

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

    if (details.delta.dy > 0) {
      _isBottomDir = true;
    } else {
      _isBottomDir = false;
    }
  }

  void onPanEnd(DragEndDetails details) {
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

  void onPanCancel() {}

  bool isChildBelowMid(double dy) {
    return _offsetNotifier.value.dy > 0;
  }

  void closing() {
    widget.animationController.removeListener(valueListener);
    widget.onClosing?.call();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (notification) {
        if (notification is DragStartNotification) {
          onPanStart(notification.details);
        } else if (notification is DragUpdateNotification) {
          onPanUpdate(notification.details);
        } else if (notification is DragEndNotification) {
          onPanEnd(notification.details);
        } else if (notification is DragCancelNotification) {
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
    );
  }
}
