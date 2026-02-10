import 'package:flutter/material.dart';
import 'manual_input_section.dart';
import 'scanner_button.dart';
import 'scanner_header.dart';
import 'scanner_icon.dart';

class ScannerCard extends StatefulWidget {
  final VoidCallback onScanPressed;
  final ValueChanged<String> onManualSubmit;

  const ScannerCard({
    super.key,
    required this.onScanPressed,
    required this.onManualSubmit,
  });

  @override
  State<ScannerCard> createState() => _ScannerCardState();
}

class _ScannerCardState extends State<ScannerCard> {
  final TextEditingController _manualCodeController = TextEditingController();

  @override
  void dispose() {
    _manualCodeController.dispose();
    super.dispose();
  }

  void _handleManualSubmit() {
    if (_manualCodeController.text.isNotEmpty) {
      widget.onManualSubmit(_manualCodeController.text);
      _manualCodeController.clear();
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
      child: Column(
        children: [
          const ScannerIcon(),
          const ScannerHeader(),
          const SizedBox(height: 16),
          ScannerButton(onPressed: widget.onScanPressed),
          const SizedBox(height: 16),
          ManualInputSection(
            controller: _manualCodeController,
            onSubmit: _handleManualSubmit,
          ),
        ],
      ),
    );
  }
}
