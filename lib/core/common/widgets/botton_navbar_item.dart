import 'package:flutter/material.dart';

class CustomNavItem extends StatelessWidget {
  final IconData iconData;
  final String label;
  final bool isSelected;

  const CustomNavItem({
    super.key,
    required this.iconData,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      decoration: isSelected ? BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20),) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          //mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, color: Colors.white),
            if (isSelected) const SizedBox(width: 10),
            if (isSelected)Text(label, style: const TextStyle(color: Colors.white),),
          ],
        ),
      ),
    );
  }
}
