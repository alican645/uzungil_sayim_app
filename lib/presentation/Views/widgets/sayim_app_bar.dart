import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/application/stock/stock_bloc.dart';
import '../../../core/application/stock/stock_state.dart';

class SayimAppBar extends StatelessWidget {
  final VoidCallback onSayimBaslat;
  final bool isSayimStart;
  final String countType;
  const SayimAppBar({
    super.key,
    required this.onSayimBaslat,
    required this.isSayimStart,
    this.countType = 'A',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA8D5BA), Color(0xFF7EC8A3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stok Sayım',
                    style: TextStyle(
                      color: Color(0xFF2D5A3D),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ERP Stok Yönetimi',
                    style: TextStyle(color: Color(0xFF6B8F7A), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          if (isSayimStart)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: countType == 'A'
                    ? const Color(0xFFE8F4EC)
                    : const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                countType == 'A' ? 'Aylık' : 'Günlük',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: countType == 'A'
                      ? const Color(0xFF2D5A3D)
                      : const Color(0xFF856404),
                ),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF2D5A3D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: onSayimBaslat,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  isSayimStart ? "Sayım Tipi" : "Sayım Başlat",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
