import 'package:flutter/material.dart';

class EmptyStockState extends StatelessWidget {
  const EmptyStockState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 15,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: Color(0xFFA8D5BA),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz stok kaydı yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5A3D),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Barkod tarayarak veya manuel giriş yaparak stok ekleyin',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF6B8F7A)),
          ),
        ],
      ),
    );
  }
}
