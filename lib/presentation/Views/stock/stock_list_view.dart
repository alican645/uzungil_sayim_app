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

  void _showManualAddDialog(BuildContext context) {
    final stockBloc = context.read<StockBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: BlocProvider.value(
            value: stockBloc,
            child: ProductForm(
              onCancel: () => Navigator.pop(dialogContext),
              onSave: (_) {}, // Handled internally by ProductForm logic
              onSuccess: () => Navigator.pop(dialogContext),
              scannedCode: '',
            ),
          ),
        ),
      ),
    );
  }

  void _showWarehouseChangeDialog(
    BuildContext context,
    List<StockCount> items,
    String currentWarehouse,
  ) {
    final stockBloc = context.read<StockBloc>();
    final state = stockBloc.state;

    if (state is! StockLoaded || state.depos.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Depo listesi yüklenemedi')));
      return;
    }

    final depos = state.depos;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF3CD), Color(0xFFFFE69C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.warehouse,
                  color: Color(0xFF856404),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Depo Değiştir',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5A3D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mevcut: $currentWarehouse',
                style: const TextStyle(color: Color(0xFF6B8F7A), fontSize: 14),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: depos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final depo = depos[index];
                    final isCurrentDepo = depo.name == currentWarehouse;
                    return InkWell(
                      onTap: isCurrentDepo
                          ? null
                          : () {
                              final ids = items
                                  .where((i) => i.id != null)
                                  .map((i) => i.id!)
                                  .toList();
                              stockBloc.add(
                                ChangeStockGroupWarehouse(
                                  ids: ids,
                                  newWarehouseName: depo.name,
                                ),
                              );
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Depo "${depo.name}" olarak değiştirildi',
                                  ),
                                ),
                              );
                            },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrentDepo
                              ? const Color(0xFFE8F4EC)
                              : const Color(0xFFF8FAF9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrentDepo
                                ? const Color(0xFFA8D5BA)
                                : const Color(0xFFE8F4EC),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isCurrentDepo
                                  ? Icons.check_circle
                                  : Icons.warehouse_outlined,
                              color: isCurrentDepo
                                  ? const Color(0xFF2D5A3D)
                                  : const Color(0xFF6B8F7A),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                depo.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isCurrentDepo
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: const Color(0xFF2D5A3D),
                                ),
                              ),
                            ),
                            if (isCurrentDepo)
                              const Text(
                                'Mevcut',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B8F7A),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
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
            ],
          ),
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    final stockBloc = context.read<StockBloc>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Listeyi Temizle'),
        content: const Text(
          'Tüm listeyi silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              stockBloc.add(ClearLocalStocks());
              Navigator.pop(context);
            },
            child: const Text('Temizle', style: TextStyle(color: Colors.red)),
          ),
        ],
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
          onManualInput: () => _showManualAddDialog(context),
          onClear: () => _showClearConfirmation(context),
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
                for (var item in state.filteredLocalStocks) {
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

                    final stockItems = items.cast<StockCount>();
                    return StockGroupItem(
                      stockCode: firstItem.stockCode,
                      warehouseName: firstItem.warehouseName,
                      items: stockItems,
                      onDelete: (id) => _confirmDelete(context, id),
                      onEdit: (item) => _showEditDialog(context, item),
                      onWarehouseEdit: () => _showWarehouseChangeDialog(
                        context,
                        stockItems,
                        firstItem.warehouseName,
                      ),
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
