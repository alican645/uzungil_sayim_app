import 'package:dartz/dartz.dart';
import 'package:uzungil_sayim_app/core/domain/entities/stock_item.dart';
import '../entities/depo.dart';
import '../entities/stock_count.dart';
import '../../error/failures.dart';

abstract class IStockRepository {
  Future<Either<Failure, List<StockItem>>> getStocks();
  Future<Either<Failure, StockItem?>> getStockByBarcode(String barcode);
  Future<Either<Failure, void>> addStock(StockItem item);
  Future<Either<Failure, void>> deleteStock(String id);
  Future<Either<Failure, void>> updateStock(StockItem item);
  Future<Either<Failure, List<Depo>>> getDepos();

  // Local Storage
  Future<Either<Failure, void>> addLocalStock(StockCount item);
  Future<Either<Failure, void>> updateLocalStock(StockCount item);
  Future<Either<Failure, void>> deleteLocalStock(int id);
  Future<Either<Failure, void>> clearLocalStocks();
  Future<Either<Failure, List<StockCount>>> getAllLocalStocks();
  Future<Either<Failure, double>> getLocalTotalQuantity(String stockCode);

  Future<Either<Failure, String>> sendToVega(List<Map<String, dynamic>> data);
}
