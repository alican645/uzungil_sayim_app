import 'package:flutter/material.dart';

class ScannerIcon extends StatelessWidget {
  const ScannerIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4EDDA), Color(0xFFC3E6CB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.qr_code_scanner,
        size: 32,
        color: Color(0xFF2D5A3D),
      ),
    );
  }
}
