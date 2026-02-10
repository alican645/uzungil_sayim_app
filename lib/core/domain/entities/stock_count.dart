import 'package:equatable/equatable.dart';

class StockCount extends Equatable {
  final int? id; // Hive key
  final String companyId; // SIRKETNO
  final int year; // YIL
  final int month; // AY
  final String warehouseName; // DEPOADI
  final String stockCode; // STOKKODU
  final String barcode; // BARKOD
  final String name; // STOKADI
  final double quantity; // MIKTAR
  final DateTime countDate; // SAYTARIH
  final DateTime recordDate; // KAYTARIH
  final String description; // ACIKLAMA
  final String countType; // SAYIMTIPI

  const StockCount({
    this.id,
    required this.companyId,
    required this.year,
    required this.month,
    required this.warehouseName,
    required this.stockCode,
    required this.barcode,
    required this.name,
    required this.quantity,
    required this.countDate,
    required this.recordDate,
    required this.description,
    required this.countType,
  });

  @override
  List<Object?> get props => [
    id,
    companyId,
    year,
    month,
    warehouseName,
    stockCode,
    barcode,
    name,
    quantity,
    countDate,
    recordDate,
    description,
    countType,
  ];
}
