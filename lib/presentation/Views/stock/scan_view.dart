import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:uzungil_sayim_app/core/application/stock/stock_state.dart';
import 'package:uzungil_sayim_app/core/domain/entities/stock_item.dart';
import '../../../../core/domain/entities/stock_count.dart';
import '../../../../core/application/stock/stock_bloc.dart';
import '../../../../core/application/stock/stock_event.dart';
import '../widgets/product_form.dart';
import '../widgets/scanner_card.dart';

class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  final MobileScannerController _scannerController = MobileScannerController();

  String? _scannedCode;
  bool _isScanning = false;
  String? _selectedDepoId;
  StockCount? _selectedLocalCount;

  @override
  void initState() {
    super.initState();
    context.read<StockBloc>().add(GetDepos());
    context.read<StockBloc>().add(LoadLocalStocks());
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _scannedCode = barcode.rawValue;
          _isScanning = false;
        });
        context.read<StockBloc>().add(GetStockByBarcode(barcode.rawValue!));
        _scannerController.stop();
      }
    }
  }

  void _startScanning() {
    if (_selectedDepoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen önce bir depo seçiniz!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _isScanning = true;
      _scannedCode = null;
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    _scannerController.stop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isScanning) {
      return Stack(
        children: [
          MobileScanner(controller: _scannerController, onDetect: _onDetect),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              onPressed: _stopScanning,
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
            ),
          ),
          const Center(
            child: Text(
              'Barkodu çerçeve içine alınız',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          BlocBuilder<StockBloc, StockState>(
            builder: (context, state) {
              List<DropdownMenuItem<String>> items = [];
              if (state is StockLoaded) {
                items = state.depos
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.code, child: Text(e.name)),
                    )
                    .toList();
              }

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
                child: DropdownButtonFormField2<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  hint: const Text(
                    'Depo Seçiniz',
                    style: TextStyle(fontSize: 14),
                  ),
                  items: items,
                  onChanged: (value) {
                    setState(() {
                      _selectedDepoId = value;
                    });
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.only(right: 8),
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(Icons.arrow_drop_down, color: Colors.black45),
                    iconSize: 24,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ScannerCard(
            onScanPressed: _startScanning,
            onManualSubmit: (code) {
              if (_selectedDepoId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen önce bir depo seçiniz!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              setState(() {
                _scannedCode = code;
              });
              context.read<StockBloc>().add(GetStockByBarcode(code));
            },
          ),
          if (_scannedCode != null) ...[
            const SizedBox(height: 16),
            BlocBuilder<StockBloc, StockState>(
              builder: (context, state) {
                StockItem? initialItem;
                StockCount? initialLocalCount;

                // Check if we are editing a local item (logic to find it?)
                // Or if we clicked a list item, _scannedCode is set.
                // We should check if _scannedCode matches any local item?
                // But multiple local items can have same code.
                // We need to track selected local item explicitly.

                if (state is StockLoaded) {
                  if (state.scannedItem?.code == _scannedCode) {
                    initialItem = state.scannedItem;
                  }
                  if (_selectedLocalCount != null &&
                      _selectedLocalCount!.stockCode == _scannedCode) {
                    initialLocalCount = _selectedLocalCount;
                  }
                }

                return ProductForm(
                  scannedCode: _scannedCode!,
                  selectedDepoCode: _selectedDepoId,
                  initialItem: initialItem,
                  initialLocalCount: initialLocalCount,
                  onCancel: () {
                    setState(() {
                      _scannedCode = null;
                      _selectedLocalCount = null;
                    });
                  },
                  onSave: (item) {
                    // Legacy save, handled internally now
                    setState(() {
                      _scannedCode = null;
                      _selectedLocalCount = null;
                    });
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
