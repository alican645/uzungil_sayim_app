import 'package:equatable/equatable.dart';
import '../../domain/entities/stock_item.dart';
import '../../domain/entities/stock_count.dart';

abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object> get props => [];
}

class LoadStocks extends StockEvent {}

class AddStock extends StockEvent {
  final StockItem item;
  const AddStock(this.item);

  @override
  List<Object> get props => [item];
}

class DeleteStock extends StockEvent {
  final String id;
  const DeleteStock(this.id);

  @override
  List<Object> get props => [id];
}

class FilterStocks extends StockEvent {
  final String query;
  const FilterStocks(this.query);

  @override
  List<Object> get props => [query];
}

class GetStockByBarcode extends StockEvent {
  final String barcode;
  const GetStockByBarcode(this.barcode);

  @override
  List<Object> get props => [barcode];
}

class GetDepos extends StockEvent {}

class LoadLocalStocks extends StockEvent {}

class AddLocalStock extends StockEvent {
  final StockCount item;
  const AddLocalStock(this.item);

  @override
  List<Object> get props => [item];
}

class UpdateLocalStock extends StockEvent {
  final StockCount item;
  const UpdateLocalStock(this.item);

  @override
  List<Object> get props => [item];
}

class DeleteLocalStock extends StockEvent {
  final int id;
  const DeleteLocalStock(this.id);

  @override
  List<Object> get props => [id];
}

class ClearLocalStocks extends StockEvent {}

class ProcessToVega extends StockEvent {}
