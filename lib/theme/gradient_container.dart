import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;

  const GradientContainer(
      {super.key, required this.child, this.width = 0, this.height = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width == 0 ? MediaQuery.of(context).size.width : width,
      height: height == 0 ? MediaQuery.of(context).size.height : height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomLeft,
          colors: [
            Theme.of(context).colorScheme.surfaceContainer,
            Theme.of(context).colorScheme.surfaceContainerHigh,
          ],
        ),
      ),
      child: child,
    );
  }
}
