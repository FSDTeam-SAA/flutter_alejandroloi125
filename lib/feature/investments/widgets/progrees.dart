import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  const ProgressBar({super.key, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withOpacity(.12);
    return SizedBox(
      height: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: Stack(
          children: [
            Container(color: bg),
            FractionallySizedBox(
              widthFactor: value.clamp(0, 1),
              child: Container(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

//