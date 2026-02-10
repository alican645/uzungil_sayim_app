import 'package:dartz/dartz.dart';
import 'package:uzungil_sayim_app/infrastructure/persistence/datasources/stock_remote_data_source.dart';
import 'package:uzungil_sayim_app/infrastructure/persistence/datasources/stock_local_data_source.dart';
import '../../../../core/domain/entities/stock_item.dart';
import '../../../../core/domain/entities/depo.dart';
import '../../../../core/domain/entities/stock_count.dart';
import '../../../../core/domain/repositories/i_stock_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/stock_count_model.dart';

class StockRepositoryImpl implements IStockRepository {
  final IStockRemoteDataSource remoteDataSource;
  final IStockLocalDataSource localDataSource;
  final List<StockItem> _stocks = [];

  StockRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, StockItem?>> getStockByBarcode(String barcode) async {
    try {
      final apiModel = await remoteDataSource.getStockByBarcode(barcode);
      if (apiModel != null) {
        print(
          'DEBUG: fetched barcode=${apiModel.barcode}, stokKodu=${apiModel.stokKodu}',
        );
        return Right(
          StockItem(
            id: apiModel.ind.toString(),
            code: apiModel.barcode,
            stockCode: apiModel.stokKodu,
            name: apiModel.malInCinsi,
            quantity: 1, // Default to 1
            unit: apiModel.anaBirim.toString(),
            notes: 'Depo: ${apiModel.depo}',
            date: DateTime.now(),
          ),
        );
      }
      return const Right(null);
    } catch (e) {
      // Handle specific ApiException if needed, for now general ServerFailure
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StockItem>>> getStocks() async {
    return Right(_stocks);
  }

  @override
  Future<Either<Failure, void>> addStock(StockItem item) async {
    try {
      final index = _stocks.indexWhere((element) => element.code == item.code);
      if (index != -1) {
        _stocks[index] = item;
      } else {
        _stocks.add(item);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStock(String id) async {
    try {
      _stocks.removeWhere((element) => element.id == id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStock(StockItem item) async {
    try {
      final index = _stocks.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        _stocks[index] = item;
        return const Right(null);
      } else {
        return const Left(CacheFailure('Item not found'));
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Depo>>> getDepos() async {
    try {
      final apiModels = await remoteDataSource.getDepos();
      final depos = apiModels.map((e) => e.toEntity()).toList();
      return Right(depos);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addLocalStock(StockCount item) async {
    try {
      final model = StockCountModel.fromEntity(item);
      await localDataSource.addStockCount(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateLocalStock(StockCount item) async {
    try {
      final model = StockCountModel.fromEntity(item);
      await localDataSource.updateStockCount(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLocalStock(int id) async {
    try {
      await localDataSource.deleteStockCount(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearLocalStocks() async {
    try {
      await localDataSource.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StockCount>>> getAllLocalStocks() async {
    try {
      final models = localDataSource.getAllStockCounts();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getLocalTotalQuantity(
    String stockCode,
  ) async {
    try {
      final total = localDataSource.getTotalQuantityByStockCode(stockCode);
      return Right(total);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> sendToVega(
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final message = await remoteDataSource.sendToVega(data);
      return Right(message);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
