import 'package:flutter/material.dart';

class CustomWrapWidget extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final Axis direction;
  final WrapAlignment alignment;
  final WrapAlignment runAlignment;

  const CustomWrapWidget({
    super.key,
    required this.children,
    this.spacing = 4.0,
    this.runSpacing = 4.0,
    this.direction = Axis.horizontal,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
    /*  alignment: WrapAlignment.spaceEvenly,
      runAlignment: WrapAlignment.spaceEvenly,*/
      spacing: spacing,
      runSpacing: runSpacing,
      direction: direction,
      alignment: alignment,
      runAlignment: runAlignment,
      children: children,
    );
  }
}
