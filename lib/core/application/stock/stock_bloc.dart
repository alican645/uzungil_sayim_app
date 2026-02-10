import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/stock_count.dart';
import '../../domain/repositories/i_stock_repository.dart';
import 'stock_event.dart';
import 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final IStockRepository repository;

  StockBloc({required this.repository}) : super(StockInitial()) {
    on<LoadStocks>(_onLoadStocks);
    on<AddStock>(_onAddStock);
    on<DeleteStock>(_onDeleteStock);
    on<FilterStocks>(_onFilterStocks);
    on<GetStockByBarcode>(_onGetStockByBarcode);
    on<GetDepos>(_onGetDepos);

    // Local Storage
    on<LoadLocalStocks>(_onLoadLocalStocks);
    on<AddLocalStock>(_onAddLocalStock);
    on<UpdateLocalStock>(_onUpdateLocalStock);
    on<DeleteLocalStock>(_onDeleteLocalStock);
    on<ClearLocalStocks>(_onClearLocalStocks);
    on<ProcessToVega>(_onProcessToVega);
  }

  Future<void> _onGetStockByBarcode(
    GetStockByBarcode event,
    Emitter<StockState> emit,
  ) async {
    // Keep current state if loaded, or show loading?
    // Ideally we want to prevent interaction while fetching, but for now let's just fetch.

    final result = await repository.getStockByBarcode(event.barcode);

    result.fold((failure) => emit(StockError(failure.message)), (item) {
      if (state is StockLoaded) {
        emit((state as StockLoaded).copyWith(scannedItem: item));
      } else {
        // If we were not loaded yet (e.g. initial), we should probably load stocks first or just emit with empty list?
        // For simplicity, let's assume we are mostly in Loaded state or we transition to it.
        // But actually ScanView can be opened directly.
        // Let's emit a StockLoaded with empty list if needed, OR just update if it IS loaded.
        emit(
          StockLoaded(
            stocks: const [],
            filteredStocks: const [],
            scannedItem: item,
          ),
        );
      }
    });
  }

  Future<void> _onLoadStocks(LoadStocks event, Emitter<StockState> emit) async {
    emit(StockLoading());
    final result = await repository.getStocks();
    result.fold(
      (failure) => emit(StockError(failure.message)),
      (stocks) => emit(StockLoaded(stocks: stocks, filteredStocks: stocks)),
    );
  }

  Future<void> _onAddStock(AddStock event, Emitter<StockState> emit) async {
    emit(StockLoading());
    final result = await repository.addStock(event.item);
    result.fold(
      (failure) => emit(StockError(failure.message)),
      (_) => add(LoadStocks()), // Reload after adding
    );
  }

  Future<void> _onDeleteStock(
    DeleteStock event,
    Emitter<StockState> emit,
  ) async {
    emit(StockLoading());
    final result = await repository.deleteStock(event.id);
    result.fold(
      (failure) => emit(StockError(failure.message)),
      (_) => add(LoadStocks()), // Reload after deleting
    );
  }

  void _onFilterStocks(FilterStocks event, Emitter<StockState> emit) {
    if (state is StockLoaded) {
      final currentState = state as StockLoaded;
      final query = event.query.toLowerCase();
      final filtered = currentState.stocks.where((item) {
        return item.code.toLowerCase().contains(query) ||
            item.name.toLowerCase().contains(query);
      }).toList();
    }
  }

  Future<void> _onGetDepos(GetDepos event, Emitter<StockState> emit) async {
    final result = await repository.getDepos();
    result.fold((failure) => emit(StockError(failure.message)), (depos) {
      if (state is StockLoaded) {
        emit((state as StockLoaded).copyWith(depos: depos));
      } else {
        emit(
          StockLoaded(stocks: const [], filteredStocks: const [], depos: depos),
        );
      }
    });
  }

  Future<void> _onLoadLocalStocks(
    LoadLocalStocks event,
    Emitter<StockState> emit,
  ) async {
    final result = await repository.getAllLocalStocks();
    result.fold((failure) => emit(StockError(failure.message)), (localStocks) {
      if (state is StockLoaded) {
        emit((state as StockLoaded).copyWith(localStocks: localStocks));
      } else {
        emit(
          StockLoaded(
            stocks: const [],
            filteredStocks: const [],
            localStocks: localStocks,
          ),
        );
      }
    });
  }

  Future<void> _onAddLocalStock(
    AddLocalStock event,
    Emitter<StockState> emit,
  ) async {
    final result = await repository.addLocalStock(event.item);
    result.fold(
      (failure) => emit(StockError(failure.message)),
      (_) => add(LoadLocalStocks()),
    );
  }

  Future<void> _onUpdateLocalStock(
    UpdateLocalStock event,
    Emitter<StockState> emit,
  ) async {
    final result = await repository.updateLocalStock(event.item);
    result.fold(
      (failure) => emit(StockError(failure.message)),
      (_) => add(LoadLocalStocks()),
    );
  }

  Future<void> _onDeleteLocalStock(
    DeleteLocalStock event,
    Emitter<StockState> emit,
  ) async {
    final result = await repository.deleteLocalStock(event.id);
    result.fold(
      (failure) => emit(StockError(failure.message)),
      (_) => add(LoadLocalStocks()),
    );
  }

  Future<void> _onClearLocalStocks(
    ClearLocalStocks event,
    Emitter<StockState> emit,
  ) async {
    final result = await repository.clearLocalStocks();
    result.fold(
      (failure) => emit(StockError(failure.message)),
      (_) => add(LoadLocalStocks()),
    );
  }

  Future<void> _onProcessToVega(
    ProcessToVega event,
    Emitter<StockState> emit,
  ) async {
    // 1. Fetch all local stocks
    final result = await repository.getAllLocalStocks();

    result.fold(
      (failure) {
        debugPrint('Error fetching local stocks for Vega: ${failure.message}');
      },
      (localStocks) {
        // 2. Group by stockCode AND warehouseName
        final Map<String, StockCount> grouped = {};

        for (var item in localStocks) {
          // Create a composite key to group by both stock code and warehouse
          final key = '${item.stockCode}_${item.warehouseName}';

          if (grouped.containsKey(key)) {
            // Aggregate quantity
            final current = grouped[key]!;
            final updated = StockCount(
              id: current.id,
              companyId: current.companyId,
              year: current.year,
              month: current.month,
              warehouseName: current.warehouseName,
              stockCode: current.stockCode,
              name: current.name,
              quantity: current.quantity + item.quantity,
              countDate: current.countDate,
              recordDate: current.recordDate,
              description: current.description,
              countType: current.countType,
              barcode: current.barcode,
            );
            grouped[key] = updated;
          } else {
            grouped[key] = item;
          }
        }

        // 3. Create List of Maps for JSON
        final List<Map<String, dynamic>> jsonList = grouped.values.map((e) {
          return {
            'stokKodu': e.stockCode,
            'stokAdı': e.name,
            'miktar': e.quantity,
            'depoAdi': e.warehouseName,
            'aciklama': e.description,
            'SayimTipi': e.countType,
          };
        }).toList();

        // 4. Print JSON
        debugPrint(jsonEncode(jsonList));
      },
    );
  }
}
