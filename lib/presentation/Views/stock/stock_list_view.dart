import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/application/stock/stock_bloc.dart';
import '../../../../core/application/stock/stock_event.dart';
import '../../../../core/application/stock/stock_state.dart';
import '../widgets/empty_stock_state.dart';
import '../widgets/stock_list_item.dart';
import 'package:uzungil_sayim_app/core/domain/entities/stock_count.dart';
import '../widgets/stock_group_item.dart';
import '../widgets/product_form.dart';
import '../widgets/stock_search_bar.dart';
import '../widgets/send_to_vega_button.dart';

class StockListView extends StatelessWidget {
  const StockListView({super.key});

  void _showEditDialog(BuildContext context, StockCount item) {
    final stockBloc = context.read<StockBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: BlocProvider.value(
            value: stockBloc,
            child: ProductForm(
              scannedCode: item.stockCode,
              initialLocalCount: item,
              onCancel: () => Navigator.pop(dialogContext),
              onSave: (_) {}, // Handled internally by ProductForm logic
              onSuccess: () => Navigator.pop(dialogContext),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    final stockBloc = context.read<StockBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF8D7DA), Color(0xFFF5C6CB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.delete_forever,
                color: Color(0xFF721C24),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kaydı Sil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A3D),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bu stok kaydını silmek istediğinize emin misiniz?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B8F7A), fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xFFF0F7F3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'İptal',
                      style: TextStyle(
                        color: Color(0xFF6B8F7A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      stockBloc.add(DeleteLocalStock(id));
                      Navigator.pop(dialogContext);
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(content: Text('Kayıt silindi')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xFFF8D7DA),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sil',
                      style: TextStyle(
                        color: Color(0xFF721C24),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StockSearchBar(
          onChanged: (query) {
            context.read<StockBloc>().add(FilterStocks(query));
          },
        ),
        Expanded(
          child: BlocConsumer<StockBloc, StockState>(
            listener: (context, state) {
              if (state is StockActionSuccess) {
                final stockBloc = context.read<StockBloc>();
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Başarılı'),
                    content: Text(state.message),
                    actions: [
                      TextButton(
                        onPressed: () {
                          stockBloc.add(ClearLocalStocks());
                          Navigator.pop(dialogContext);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Listeyi Temizle'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tamam'),
                      ),
                    ],
                  ),
                );
              }
            },
            buildWhen: (previous, current) => current is! StockActionSuccess,
            builder: (context, state) {
              if (state is StockLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is StockLoaded) {
                // Determine which list to show.
                // If there is a filter query, we might want to filter localStocks too.
                // For now, let's show localStocks as priority since user asked for "Added records".
                // If filteredStocks is populated (from remote search), we might want to show that?
                // But the user said "Eklenen kayıtlar" (Added records).
                // So let's show localStocks.

                // Group local stocks by stockCode AND warehouseName
                final Map<String, List<dynamic>> groupedStocks = {};
                for (var item in state.localStocks) {
                  // Use composite key or nested map. Composite key is easier for sorting/linear list.
                  // Key format: "StockCode_WarehouseName"
                  // But we need to be able to extract them back or store metadata.
                  // Let's use a unique key but pass data to widget.
                  final key = '${item.stockCode}_${item.warehouseName}';
                  if (!groupedStocks.containsKey(key)) {
                    groupedStocks[key] = [];
                  }
                  groupedStocks[key]!.add(item);
                }

                final List<String> sortedKeys = groupedStocks.keys.toList()
                  ..sort();

                if (sortedKeys.isEmpty) {
                  return const EmptyStockState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedKeys.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final key = sortedKeys[index];
                    final items = groupedStocks[key]!;
                    final firstItem = items.first as StockCount;

                    return StockGroupItem(
                      stockCode: firstItem.stockCode,
                      warehouseName: firstItem.warehouseName,
                      items: items.cast<StockCount>(),
                      onDelete: (id) => _confirmDelete(context, id),
                      onEdit: (item) => _showEditDialog(context, item),
                    );
                  },
                );
              } else if (state is StockError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        SendToVegaButton(),
      ],
    );
  }
}
