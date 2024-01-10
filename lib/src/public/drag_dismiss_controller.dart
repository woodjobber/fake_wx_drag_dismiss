// ignore_for_file: non_constant_identifier_names

import 'package:flutter/foundation.dart';

import '../notifier/drag_dismiss_value_notifier.dart';

class DragDismissController {
  final DragDismissValueNotifier<bool> _notifier =
      DragDismissValueNotifier<bool>(false);

  DragDismissController._();

  static DragDismissController? _controller;

  void close() {
    _notifier.value = !_notifier.value;
  }

  factory DragDismissController.create() {
    _controller ??= DragDismissController._();
    return _controller!;
  }

  static DragDismissController get instance => DragDismissController.create();

  void addListener(VoidCallback listener) {
    _notifier.addListener(listener);
  }

  void removeListener(VoidCallback listener) {
    _notifier.removeListener(listener);
  }

  static void dispose() {
    _controller = null;
  }
}
