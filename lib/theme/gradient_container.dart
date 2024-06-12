import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final double width;

  const GradientContainer({Key? key, required this.child, this.width = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width == 0 ? MediaQuery.of(context).size.width : width,
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
