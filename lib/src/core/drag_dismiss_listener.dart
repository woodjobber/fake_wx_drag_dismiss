import 'package:flutter/material.dart';

abstract class DragDismissListener {
  void onDragStart();

  void onDragEnd(Offset endStatus);

  void onClosing();

  void onAnimationFinish();

  void onPanUpdate(Offset delta);
}
