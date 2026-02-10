import 'package:flutter/material.dart';
import '../../../../core/domain/entities/stock_count.dart';
import '../../../../core/domain/entities/stock_item.dart';
import 'stock_list_item.dart';

class StockGroupItem extends StatefulWidget {
  final String stockCode;
  final String warehouseName;
  final List<StockCount> items;
  final Function(int) onDelete;
  final Function(StockCount) onEdit;

  const StockGroupItem({
    super.key,
    required this.stockCode,
    required this.warehouseName,
    required this.items,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<StockGroupItem> createState() => _StockGroupItemState();
}

class _StockGroupItemState extends State<StockGroupItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final firstItem = widget.items.first;
    final totalQuantity = widget.items.fold(
      0.0,
      (sum, item) => sum + item.quantity,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8F4EC), Color(0xFFD4EDDA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory, color: Color(0xFF2D5A3D)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F7F3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.stockCode,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: Color(0xFF6B8F7A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F7F3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            firstItem.barcode,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: Color(0xFF6B8F7A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      firstItem.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5A3D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.warehouseName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF856404),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toplam: $totalQuantity',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D5A3D),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                icon: Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF6B8F7A),
                ),
              ),
            ],
          ),

          // Expanded Body
          if (_isExpanded) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return StockListItem(
                  item: StockItem(
                    id: item.id?.toString() ?? '',
                    code: item.barcode,
                    stockCode: item.stockCode,
                    name: item.name, // Name is already shown in header
                    quantity: item.quantity,
                    unit: 'Adet',
                    notes: item.description,
                    date: item.countDate,
                  ),
                  onDelete: () => widget.onDelete(item.id ?? -1),
                  onEdit: () => widget.onEdit(item),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
