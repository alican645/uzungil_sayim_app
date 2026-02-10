import 'package:equatable/equatable.dart';

class StockItem extends Equatable {
  final String id;
  final String code;
  final String stockCode;
  final String name;
  final double quantity;
  final String unit;
  final String? notes;
  final DateTime date;

  const StockItem({
    required this.id,
    required this.code,
    required this.stockCode,
    required this.name,
    required this.quantity,
    required this.unit,
    this.notes,
    required this.date,
  });

  @override
  List<Object?> get props => [
    id,
    code,
    stockCode,
    name,
    quantity,
    unit,
    notes,
    date,
  ];

  StockItem copyWith({
    String? id,
    String? code,
    String? stockCode,
    String? name,
    double? quantity,
    String? unit,
    String? notes,
    DateTime? date,
  }) {
    return StockItem(
      id: id ?? this.id,
      code: code ?? this.code,
      stockCode: stockCode ?? this.stockCode,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      date: date ?? this.date,
    );
  }
}
