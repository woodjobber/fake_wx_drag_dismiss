import 'package:flutter/material.dart';

class DragStartNotification extends Notification {
  final DragStartDetails details;

  DragStartNotification(this.details);
}

class DragUpdateNotification extends Notification {
  final DragUpdateDetails details;

  DragUpdateNotification(this.details);
}

class DragEndNotification extends Notification {
  final DragEndDetails details;

  DragEndNotification(this.details);
}

class DragCancelNotification extends Notification {
  DragCancelNotification();
}
