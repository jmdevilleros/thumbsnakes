import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        minimumSize: const Size(160, 52),
        side: const BorderSide(color: AppColors.snakeA, width: 2),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      child: Text(label),
    ),
  );
}
