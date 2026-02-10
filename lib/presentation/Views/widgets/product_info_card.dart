import 'package:flutter/material.dart';
import '../../../../core/domain/entities/stock_item.dart';

class ProductInfoCard extends StatelessWidget {
  final StockItem stockItem;

  const ProductInfoCard({super.key, required this.stockItem});

  @override
  Widget build(BuildContext context) {
    // Parse notes to extract Depo and Fiyat if available
    // Format in repository was: 'Depo: ${apiModel.depo}, Fiyat: ${apiModel.dalisFiyati}'
    String depo = '-';

    if (stockItem.notes != null) {
      final parts = stockItem.notes!.split(',');
      for (final part in parts) {
        if (part.trim().startsWith('Depo:')) {
          depo = part.trim().substring(5).trim();
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // Light green background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA8D5BA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stok Detayları',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5A3D),
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.warehouse, 'Depo', depo),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.category, 'Birim', stockItem.unit),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6B8F7A)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D5A3D),
          ),
        ),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(color: Color(0xFF1B4332))),
      ],
    );
  }
}
