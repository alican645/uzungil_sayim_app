import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uzungil_sayim_app/core/application/stock/stock_bloc.dart';
import 'package:uzungil_sayim_app/core/application/stock/stock_event.dart';
import 'package:uzungil_sayim_app/core/application/stock/stock_state.dart';
import 'package:uzungil_sayim_app/core/domain/entities/stock_count.dart';
import 'package:uzungil_sayim_app/core/domain/entities/stock_item.dart';
import 'product_info_card.dart';
import 'product_label.dart';

class ProductForm extends StatefulWidget {
  final String scannedCode;
  final String? selectedDepoCode;
  final StockItem? initialItem;
  final StockCount? initialLocalCount;
  final VoidCallback onCancel;
  final Function(StockItem) onSave; // Keep generic save for now or unused
  final VoidCallback? onSuccess;

  const ProductForm({
    super.key,
    required this.scannedCode,
    this.selectedDepoCode,
    this.initialItem,
    this.initialLocalCount,
    required this.onCancel,
    required this.onSave,
    this.onSuccess,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;

  StockCount? _editingCount;

  @override
  void initState() {
    super.initState();
    _initControllers(firstTime: true);
  }

  void _initControllers({bool firstTime = false}) {
    if (!firstTime) {
      _nameController.dispose();
      _quantityController.dispose();
    }

    final item = widget.initialItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _quantityController = TextEditingController(
      text: item != null ? item.quantity.toString() : '',
    );
  }

  @override
  void didUpdateWidget(ProductForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialItem != oldWidget.initialItem) {
      _initControllers();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _quantityController.clear();
    setState(() {
      _editingCount = null;
    });
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final state = context.read<StockBloc>().state;
      String depoAdi = "";
      if (state is StockLoaded && state.depos.isNotEmpty) {
        if (widget.selectedDepoCode != null) {
          final selectedDepo = state.depos.firstWhere(
            (d) => d.code == widget.selectedDepoCode,
            orElse: () => state.depos.first,
          );
          depoAdi = selectedDepo.name;
        } else {
          // Fallback if no code usage
          depoAdi = state.depos.first.name;
        }
      }

      final count = StockCount(
        id: null, // Always new ID
        companyId: "1", // Mock/Config
        year: DateTime.now().year,
        month: DateTime.now().month,
        warehouseName: depoAdi, // Placeholder
        stockCode:
            widget.initialItem?.stockCode ??
            widget.scannedCode, // Use real stock code if available
        barcode: widget.scannedCode, // Scanned code is the barcode
        name: _nameController.text,
        quantity: double.parse(_quantityController.text),
        countDate: DateTime.now(),
        recordDate: DateTime.now(),
        description: 'Sayım Uygulaması',
        countType: "A",
      );

      context.read<StockBloc>().add(AddLocalStock(count));

      _clearForm();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kayıt Eklendi')));
      if (widget.onSuccess != null) widget.onSuccess!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD9B3), Color(0xFFFFCA99)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.inventory,
                        color: Color(0xFF8B5A2B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ürün Bilgisi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D5A3D),
                          ),
                        ),
                        Text(
                          widget.scannedCode,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Color(0xFF6B8F7A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.close, color: Color(0xFF6B8F7A)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (widget.initialItem != null)
              ProductInfoCard(stockItem: widget.initialItem!),

            const ProductLabel(text: 'Ürün Adı'),
            TextFormField(
              controller: _nameController,
              readOnly: true,
              decoration: _inputDecoration('Ürün adı...'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ProductLabel(text: 'Miktar'),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('0'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Miktar girin';
                          }
                          final quantity = double.tryParse(value);
                          if (quantity == null || quantity <= 0) {
                            return 'Geçersiz miktar';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ProductLabel(text: 'Birim'),
                      TextFormField(
                        initialValue: widget.initialItem?.unit ?? 'Adet',
                        readOnly: true,
                        decoration: _inputDecoration(''),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA8D5BA),
                      foregroundColor: const Color(0xFF2D5A3D),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Ekle'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAF9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8F4EC), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8F4EC), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFA8D5BA), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
