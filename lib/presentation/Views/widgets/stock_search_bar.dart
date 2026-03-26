import 'package:flutter/material.dart';

class StockSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onManualInput;
  final VoidCallback onClear;

  const StockSearchBar({
    super.key,
    required this.onChanged,
    required this.onManualInput,
    required this.onClear,
  });

  @override
  State<StockSearchBar> createState() => _StockSearchBarState();
}

class _StockSearchBarState extends State<StockSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width:
                    MediaQuery.of(context).size.width * 0.5 -
                    32, // Adjusting for padding roughly or just using relative constraint
                child: ElevatedButton(
                  onPressed: widget.onClear,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0x40000000),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Listeyi Temizle',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(
                child: TextField(
                  controller: _controller,
                  onChanged: widget.onChanged,
                  decoration: InputDecoration(
                    hintText: 'Stok kodu veya ürün ara...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF6B8F7A),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAF9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE8F4EC),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE8F4EC),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFA8D5BA),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: widget.onManualInput,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFA8D5BA), Color(0xFF7EC8A3)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Color(0xFF2D5A3D)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
