import 'dart:async';
import 'package:flutter/material.dart';

class WidgetAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration timeAnimation;

  WidgetAnimation({@required this.child, this.delay, this.timeAnimation});

  @override
  _WidgetAnimation createState() => _WidgetAnimation();
}

class _WidgetAnimation extends State<WidgetAnimation>
    with TickerProviderStateMixin {
  AnimationController _animController;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
        vsync: this,
        duration: widget.timeAnimation ?? Duration(milliseconds: 500));

    if (widget.delay == null) {
      _animController.forward();
    } else {
      Timer(widget.delay ?? Duration.zero, () {
        _animController.forward();
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      child: widget.child,
      opacity: _animController,
    );
  }
}
