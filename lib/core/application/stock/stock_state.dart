import 'package:equatable/equatable.dart';
import '../../domain/entities/stock_item.dart';
import '../../domain/entities/depo.dart';
import '../../domain/entities/stock_count.dart';

sealed class StockState extends Equatable {
  const StockState();

  @override
  List<Object?> get props => [];
}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final List<StockItem> stocks;
  final List<StockItem> filteredStocks;
  final StockItem? scannedItem; // Added scanned item
  final List<Depo> depos;
  final List<StockCount> localStocks;

  const StockLoaded({
    required this.stocks,
    required this.filteredStocks,
    this.scannedItem,
    this.depos = const [],
    this.localStocks = const [],
  });

  @override
  List<Object?> get props => [
    stocks,
    filteredStocks,
    scannedItem,
    depos,
    localStocks,
  ];

  StockLoaded copyWith({
    List<StockItem>? stocks,
    List<StockItem>? filteredStocks,
    StockItem? scannedItem,
    List<Depo>? depos,
    List<StockCount>? localStocks,
  }) {
    return StockLoaded(
      stocks: stocks ?? this.stocks,
      filteredStocks: filteredStocks ?? this.filteredStocks,
      scannedItem: scannedItem, // Can be null
      depos: depos ?? this.depos,
      localStocks: localStocks ?? this.localStocks,
    );
  }
}

class StockError extends StockState {
  final String message;
  const StockError(this.message);

  @override
  List<Object?> get props => [message];
}
