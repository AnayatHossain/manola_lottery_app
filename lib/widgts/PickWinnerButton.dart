import 'package:flutter/material.dart';

class PickWinnerButton extends StatelessWidget {
  final VoidCallback onPickWinners;
  final Color themeColor;

  const PickWinnerButton({
    super.key,
    required this.onPickWinners,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPickWinners,
      icon: const Icon(Icons.star),
      label: const Text('Pick Winners'),
      style: ElevatedButton.styleFrom(
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}