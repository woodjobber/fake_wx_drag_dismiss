import 'package:flutter/material.dart';

import 'drag_dismiss_listener.dart';

class DragDismissManager {
  static final List<DragDismissListener> _listeners = [];

  static void addListener(DragDismissListener listener) {
    _listeners.add(listener);
  }

  static void removeListener(DragDismissListener listener) {
    _listeners.remove(listener);
  }

  static void sendDragStart() {
    for (var listener in _listeners) {
      listener.onDragStart();
    }
  }

  static void sendDragEnd(Offset endStatus) {
    for (var listener in _listeners) {
      listener.onDragEnd(endStatus);
    }
  }

  static void sendClosing() {
    for (var listener in _listeners) {
      listener.onClosing();
    }
  }

  static void sendAnimationFinish() {
    for (var listener in _listeners) {
      listener.onAnimationFinish();
    }
  }

  static void sendDragUpdate(Offset delta) {
    for (var listener in _listeners) {
      listener.onPanUpdate(delta);
    }
  }
}
