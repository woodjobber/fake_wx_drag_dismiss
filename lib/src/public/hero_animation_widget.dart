import 'package:flutter/material.dart';

class HeroAnimationWidget extends StatelessWidget {
  const HeroAnimationWidget({
    super.key,
    required this.tag,
    required this.child,
  });
  final String tag;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Hero(tag: tag, child: child);
  }
}
