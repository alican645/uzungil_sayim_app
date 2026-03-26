import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/application/stock/stock_bloc.dart';
import '../../core/application/stock/stock_event.dart';
import '../../core/application/stock/stock_state.dart';
import '../../core/injection_container.dart';
import 'stock/scan_view.dart';
import 'stock/stock_list_view.dart';
import 'widgets/sayim_app_bar.dart';
import 'widgets/sayim_tab_navigation.dart';

class SayimScreen extends StatefulWidget {
  const SayimScreen({super.key});

  @override
  State<SayimScreen> createState() => _SayimScreenState();
}

class _SayimScreenState extends State<SayimScreen> {
  int _currentIndex = 0;
  bool _isSayimStart = false;

  void _showCountTypeDialog(BuildContext context) {
    final stockBloc = context.read<StockBloc>();
    final currentType = (stockBloc.state is StockLoaded)
        ? (stockBloc.state as StockLoaded).countType
        : 'A';

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
                    colors: [Color(0xFFE8F4EC), Color(0xFFD4EDDA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.assignment,
                  color: Color(0xFF2D5A3D),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sayım Tipi Seçin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5A3D),
                ),
              ),
              const SizedBox(height: 20),
              _buildCountTypeOption(
                context: context,
                dialogContext: dialogContext,
                stockBloc: stockBloc,
                label: 'Aylık',
                value: 'A',
                icon: Icons.calendar_month,
                isSelected: currentType == 'A',
              ),
              const SizedBox(height: 12),
              _buildCountTypeOption(
                context: context,
                dialogContext: dialogContext,
                stockBloc: stockBloc,
                label: 'Günlük',
                value: 'T',
                icon: Icons.today,
                isSelected: currentType == 'T',
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

  void _applyCountType(BuildContext context, StockBloc stockBloc, String value, String label) {
    stockBloc.add(SetCountType(value));
    setState(() {
      _isSayimStart = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sayım tipi: $label')),
    );
  }

  void _showClearDataWarning({
    required BuildContext context,
    required StockBloc stockBloc,
    required String newValue,
    required String newLabel,
    required String currentLabel,
  }) {
    showDialog(
      context: context,
      builder: (warningContext) => AlertDialog(
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
                  colors: [Color(0xFFFFF3CD), Color(0xFFFFE69C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFF856404),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sayım Tipi Değişikliği',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A3D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mevcut "$currentLabel" sayım verileri bulunuyor. '
              '"$newLabel" tipine geçmek için önce mevcut verileri temizlemeniz gerekiyor.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B8F7A), fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(warningContext),
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
                      stockBloc.add(ClearLocalStocks());
                      _applyCountType(context, stockBloc, newValue, newLabel);
                      Navigator.pop(warningContext);
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
                      'Temizle ve Geç',
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

  Widget _buildCountTypeOption({
    required BuildContext context,
    required BuildContext dialogContext,
    required StockBloc stockBloc,
    required String label,
    required String value,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        final state = stockBloc.state;
        final hasLocalStocks = state is StockLoaded && state.localStocks.isNotEmpty;
        final isChangingType = !isSelected;

        Navigator.pop(dialogContext);

        if (hasLocalStocks && isChangingType) {
          final currentLabel = state.countType == 'A' ? 'Aylık' : 'Günlük';
          _showClearDataWarning(
            context: context,
            stockBloc: stockBloc,
            newValue: value,
            newLabel: label,
            currentLabel: currentLabel,
          );
        } else {
          _applyCountType(context, stockBloc, value, label);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F4EC) : const Color(0xFFF8FAF9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFA8D5BA)
                : const Color(0xFFE8F4EC),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF2D5A3D)
                  : const Color(0xFF6B8F7A),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: const Color(0xFF2D5A3D),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2D5A3D),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StockBloc>()..add(LoadStocks()),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFFF5FAF7),
          body: SafeArea(
            child: Column(
              children: [
                BlocSelector<StockBloc, StockState, String>(
                  selector: (state) =>
                      state is StockLoaded ? state.countType : 'A',
                  builder: (context, countType) => SayimAppBar(
                    onSayimBaslat: () => _showCountTypeDialog(context),
                    isSayimStart: _isSayimStart,
                    countType: countType,
                  ),
                ),
                SayimTabNavigation(
                  currentIndex: _currentIndex,
                  onTabSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: const [ScanView(), StockListView()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
