// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_count_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockCountModelAdapter extends TypeAdapter<StockCountModel> {
  @override
  final typeId = 0;

  @override
  StockCountModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockCountModel(
      id: (fields[0] as num?)?.toInt(),
      companyId: fields[1] as String,
      year: (fields[2] as num).toInt(),
      month: (fields[3] as num).toInt(),
      warehouseName: fields[4] as String,
      stockCode: fields[5] as String,
      quantity: (fields[6] as num).toDouble(),
      countDate: fields[7] as DateTime,
      recordDate: fields[8] as DateTime,
      description: fields[9] as String,
      countType: fields[10] as String,
      name: fields[11] as String?,
      barcode: fields[12] as String? ?? fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StockCountModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.companyId)
      ..writeByte(2)
      ..write(obj.year)
      ..writeByte(3)
      ..write(obj.month)
      ..writeByte(4)
      ..write(obj.warehouseName)
      ..writeByte(5)
      ..write(obj.stockCode)
      ..writeByte(6)
      ..write(obj.quantity)
      ..writeByte(7)
      ..write(obj.countDate)
      ..writeByte(8)
      ..write(obj.recordDate)
      ..writeByte(9)
      ..write(obj.description)
      ..writeByte(10)
      ..write(obj.countType)
      ..writeByte(11)
      ..write(obj.name)
      ..writeByte(12)
      ..write(obj.barcode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockCountModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
