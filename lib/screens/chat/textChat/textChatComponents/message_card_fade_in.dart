import 'package:flutter/material.dart';

class FadeInListItem extends StatefulWidget {
  final Widget child;
  final int durationMilliseconds;

  const FadeInListItem(
      {super.key, required this.child, this.durationMilliseconds = 600});

  @override
  _FadeInListItemState createState() => _FadeInListItemState();
}

class _FadeInListItemState extends State<FadeInListItem>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.durationMilliseconds),
      vsync: this,
    );
    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller!);

    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation!,
      child: widget.child,
    );
  }
}
