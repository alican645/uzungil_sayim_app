import 'package:flutter/material.dart';

class ScannerButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ScannerButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA8D5BA),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.camera_alt, color: Color(0xFF2D5A3D)),
        label: const Text(
          'Barkod Tara',
          style: TextStyle(
            color: Color(0xFF2D5A3D),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
