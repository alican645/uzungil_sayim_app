import 'package:flutter/material.dart';

class ProductSaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const ProductSaveButton({
    super.key,
    required this.onPressed,
    this.text = 'Stok Kaydet',
  });

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
        icon: const Icon(Icons.check, color: Color(0xFF2D5A3D)),
        label: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF2D5A3D),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
