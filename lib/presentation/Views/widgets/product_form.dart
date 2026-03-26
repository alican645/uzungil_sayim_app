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
  late TextEditingController _stockCodeController;
  late TextEditingController _nameController;
  late TextEditingController _quantityController;

  bool get _isManualEntry => widget.scannedCode.isEmpty && widget.initialLocalCount == null;

  StockCount? _editingCount;
  late FocusNode _quantityFocusNode;

  @override
  void initState() {
    super.initState();
    _quantityFocusNode = FocusNode();
    _initControllers(firstTime: true);
    _requestQuantityFocus();
  }

  void _requestQuantityFocus() {
    // Skip auto-focus for manual entry - user starts with stock code field
    if (_isManualEntry) return;
    // Small delay to ensure widget is built and ready
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _quantityFocusNode.requestFocus();
      }
    });
  }

  void _initControllers({bool firstTime = false}) {
    if (!firstTime) {
      _stockCodeController.dispose();
      _nameController.dispose();
      _quantityController.dispose();
    }

    final item = widget.initialItem;
    _stockCodeController = TextEditingController(
      text: widget.scannedCode.isNotEmpty ? widget.scannedCode : '',
    );
    _nameController = TextEditingController(text: item?.name ?? '');
    _quantityController = TextEditingController(
      text: item != null ? item.quantity.toString() : '',
    );
  }

  @override
  void didUpdateWidget(ProductForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialItem != oldWidget.initialItem ||
        widget.scannedCode != oldWidget.scannedCode) {
      _initControllers();
      _requestQuantityFocus();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _stockCodeController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  void _clearForm() {
    _stockCodeController.clear();
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
      String countType = "A";
      if (state is StockLoaded) {
        countType = state.countType;
        if (state.depos.isNotEmpty) {
          if (widget.selectedDepoCode != null) {
            final selectedDepo = state.depos.firstWhere(
              (d) => d.code == widget.selectedDepoCode,
              orElse: () => state.depos.first,
            );
            depoAdi = selectedDepo.name;
          } else {
            depoAdi = state.depos.first.name;
          }
        }
      }

      final stockCode = _isManualEntry
          ? _stockCodeController.text.trim()
          : (widget.initialItem?.stockCode ?? widget.scannedCode);
      final barcode = _isManualEntry
          ? _stockCodeController.text.trim()
          : widget.scannedCode;

      final count = StockCount(
        id: null, // Always new ID
        companyId: "1", // Mock/Config
        year: DateTime.now().year,
        month: DateTime.now().month,
        warehouseName: depoAdi,
        stockCode: stockCode,
        barcode: barcode,
        name: _nameController.text,
        quantity: double.parse(_quantityController.text),
        countDate: DateTime.now(),
        recordDate: DateTime.now(),
        description: 'Sayım Uygulaması',
        countType: countType,
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
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isManualEntry
                                ? [const Color(0xFFB3D9FF), const Color(0xFF99CAFF)]
                                : [const Color(0xFFFFD9B3), const Color(0xFFFFCA99)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isManualEntry ? Icons.edit_note : Icons.inventory,
                          color: _isManualEntry
                              ? const Color(0xFF2B5A8B)
                              : const Color(0xFF8B5A2B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isManualEntry ? 'Manuel Giriş' : 'Ürün Bilgisi',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D5A3D),
                              ),
                            ),
                            if (!_isManualEntry)
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
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.close, color: Color(0xFF6B8F7A)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isManualEntry) ...[
              const ProductLabel(text: 'Stok Kodu'),
              TextFormField(
                controller: _stockCodeController,
                decoration: _inputDecoration('Stok kodu girin...'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Stok kodu girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
            ],
            if (widget.initialItem != null)
              ProductInfoCard(stockItem: widget.initialItem!),

            const ProductLabel(text: 'Ürün Adı'),
            TextFormField(
              controller: _nameController,
              readOnly: !_isManualEntry,
              decoration: _inputDecoration(_isManualEntry ? 'Ürün adı girin...' : 'Ürün adı...'),
              validator: _isManualEntry
                  ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ürün adı girin';
                      }
                      return null;
                    }
                  : null,
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
                        focusNode: _quantityFocusNode,
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
