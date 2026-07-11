import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 84,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF24D17E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.show_chart_rounded,
        color: Colors.black,
        size: 42,
      ),
    );
  }
}