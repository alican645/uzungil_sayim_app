import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/application/stock/stock_bloc.dart';
import '../../core/application/stock/stock_event.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StockBloc>()..add(LoadStocks()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5FAF7),
        body: SafeArea(
          child: Column(
            children: [
              const SayimAppBar(),
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
    );
  }
}
