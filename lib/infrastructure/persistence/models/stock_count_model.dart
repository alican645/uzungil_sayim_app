import 'package:hive_ce/hive.dart';
import '../../../../core/domain/entities/stock_count.dart';

part 'stock_count_model.g.dart';

@HiveType(typeId: 0)
class StockCountModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String companyId; // SIRKETNO

  @HiveField(2)
  int year; // YIL

  @HiveField(3)
  int month; // AY

  @HiveField(4)
  String warehouseName; // DEPOADI

  @HiveField(5)
  String stockCode; // STOKKODU

  @HiveField(6)
  double quantity; // MIKTAR

  @HiveField(7)
  DateTime countDate; // SAYTARIH

  @HiveField(8)
  DateTime recordDate; // KAYTARIH

  @HiveField(9)
  String description; // ACIKLAMA

  @HiveField(10)
  String countType; // SAYIMTIPI

  @HiveField(11)
  String? name; // STOKADI

  @HiveField(12)
  String barcode; // BARKOD

  StockCountModel({
    this.id,
    required this.companyId,
    required this.year,
    required this.month,
    required this.warehouseName,
    required this.stockCode,
    required this.barcode,
    required this.quantity,
    required this.countDate,
    required this.recordDate,
    required this.description,
    required this.countType,
    this.name,
  });

  StockCount toEntity() {
    return StockCount(
      id: id,
      companyId: companyId,
      year: year,
      month: month,
      warehouseName: warehouseName,
      stockCode: stockCode,
      barcode: barcode,
      name: name ?? '', // Handle migration
      quantity: quantity,
      countDate: countDate,
      recordDate: recordDate,
      description: description,
      countType: countType,
    );
  }

  factory StockCountModel.fromEntity(StockCount entity) {
    return StockCountModel(
      id: entity.id,
      companyId: entity.companyId,
      year: entity.year,
      month: entity.month,
      warehouseName: entity.warehouseName,
      stockCode: entity.stockCode,
      barcode: entity.barcode,
      name: entity.name,
      quantity: entity.quantity,
      countDate: entity.countDate,
      recordDate: entity.recordDate,
      description: entity.description,
      countType: entity.countType,
    );
  }
}
