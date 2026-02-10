import 'package:hive_ce/hive.dart';
import '../models/stock_count_model.dart';

abstract class IStockLocalDataSource {
  Future<void> init();
  Future<void> addStockCount(StockCountModel item);
  Future<void> updateStockCount(StockCountModel item);
  Future<void> deleteStockCount(int key);
  Future<void> clearAll();
  List<StockCountModel> getAllStockCounts();
  double getTotalQuantityByStockCode(String stockCode);
}

class StockLocalDataSource implements IStockLocalDataSource {
  static const String boxName = 'stock_counts';

  @override
  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<StockCountModel>(boxName);
    }
  }

  Box<StockCountModel> get _box => Hive.box<StockCountModel>(boxName);

  @override
  Future<void> addStockCount(StockCountModel item) async {
    await _box.add(item);
    item.id = item.key as int?; // Set ID to Hive key
    await item.save(); // Save the updated ID if needed, or just rely on key
  }

  @override
  Future<void> updateStockCount(StockCountModel item) async {
    if (item.isInBox) {
      await item.save();
    }
  }

  @override
  Future<void> deleteStockCount(int key) async {
    await _box.delete(key);
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
  }

  @override
  List<StockCountModel> getAllStockCounts() {
    return _box.values.toList();
  }

  @override
  double getTotalQuantityByStockCode(String stockCode) {
    return _box.values
        .where((element) => element.stockCode == stockCode)
        .fold(
          0.0,
          (previousValue, element) => previousValue + element.quantity,
        );
  }
}
