import 'package:flutter/material.dart';

class ScannerHeader extends StatelessWidget {
  const ScannerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Barkod / QR Tarayıcı',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D5A3D),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ürün etiketini kameraya gösterin',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B8F7A)),
        ),
      ],
    );
  }
}
