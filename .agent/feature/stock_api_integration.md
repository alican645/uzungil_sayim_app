# Stock API Integration Plan

This document outlines the steps to integrate the `SayimAktarmaApi` into the application. This API allows fetching stock details using a barcode.

## 1. JSON Structure & Models

The API returns the following JSON structure:

```json
{
  "success": true,
  "data": [
    {
      "Barcode": "HAM0036227",
      "Ind": 235,
      "MalInCinsi": "GÜL AROMASI",
      "StokKodu": "HML023",
      "AnaBirim": "227",
      "Depo": "108",
      "Kod1": "HAMMADDE",
      "Kod2": "AROMA",
      "Kod3": "LOKUM",
      "DalisFiyati": 486.06200000
    }
  ]
}
```

### Proposed Data Models

Create a new file `lib/infrastructure/persistence/models/stock_api_model.dart`:

```dart
class StockApiModel {
  final String barcode;
  final int ind;
  final String malInCinsi;
  final String stokKodu;
  final String anaBirim;
  final String depo;
  final double dalisFiyati;

  StockApiModel({
    required this.barcode,
    required this.ind,
    required this.malInCinsi,
    required this.stokKodu,
    required this.anaBirim,
    required this.depo,
    required this.dalisFiyati,
  });

  factory StockApiModel.fromJson(Map<String, dynamic> json) {
    return StockApiModel(
      barcode: json['Barcode'] as String,
      ind: json['Ind'] as int,
      malInCinsi: json['MalInCinsi'] as String,
      stokKodu: json['StokKodu'] as String,
      anaBirim: json['AnaBirim'] as String,
      depo: json['Depo'] as String,
      dalisFiyati: (json['DalisFiyati'] as num).toDouble(),
    );
  }
}

class StockApiResponse {
  final bool success;
  final List<StockApiModel> data;

  StockApiResponse({required this.success, required this.data});

  factory StockApiResponse.fromJson(Map<String, dynamic> json) {
    return StockApiResponse(
      success: json['success'] as bool,
      data: (json['data'] as List)
          .map((e) => StockApiModel.fromJson(e))
          .toList(),
    );
  }
}
```

## 2. Remote Data Source

Create `lib/infrastructure/persistence/datasources/stock_remote_data_source.dart`. This layer handles the immediate API call using `Dio`.

```dart
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../models/stock_api_model.dart';

abstract class IStockRemoteDataSource {
  Future<StockApiModel?> getStockByBarcode(String barcode);
}

class StockRemoteDataSourceImpl implements IStockRemoteDataSource {
  final Dio dio;
  final String baseUrl = 'http://localhost:5149'; // Adjust for emulator/device (e.g., 10.0.2.2 for Android)

  StockRemoteDataSourceImpl({required this.dio});

  @override
  Future<StockApiModel?> getStockByBarcode(String barcode) async {
    try {
      final response = await dio.get(
        '$baseUrl/SayimAktarmaApi',
        queryParameters: {'barcode': barcode},
      );

      if (response.statusCode == 200) {
        final apiResponse = StockApiResponse.fromJson(response.data);
        if (apiResponse.success && apiResponse.data.isNotEmpty) {
          return apiResponse.data.first;
        }
        return null; // Not found or success is false
      } else {
        throw ServerFailure('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
```

## 3. Repository Integration

Update `lib/infrastructure/persistence/repositories/stock_repository_impl.dart` to use the remote data source.

You will need to map `StockApiModel` to your domain `StockItem`.

**Mapping Strategy:**
- `StockApiModel.barcode` -> `StockItem.code`
- `StockApiModel.malInCinsi` -> `StockItem.name`
- `StockApiModel.anaBirim` -> `StockItem.unit`
- `StockApiModel.ind` -> `StockItem.id` (or generate a new UUID if strictly local)

```dart
// In StockRepositoryImpl

final IStockRemoteDataSource remoteDataSource;

// ... constructor ...

Future<Either<Failure, StockItem?>> fetchStockFromApi(String barcode) async {
  try {
    final apiModel = await remoteDataSource.getStockByBarcode(barcode);
    if (apiModel != null) {
      // Map API model to Domain entity
      final stockItem = StockItem(
        id: apiModel.ind.toString(),
        code: apiModel.barcode,
        name: apiModel.malInCinsi,
        quantity: 1, // Default to 1 on scan
        unit: apiModel.anaBirim, // You might need a Unit mapper (227 -> Adet)
        date: DateTime.now(),
        notes: 'Price: ${apiModel.dalisFiyati}',
      );
      return Right(stockItem);
    }
    return const Right(null); // Found nothing, but no error
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

## 4. Usage in Logic (BLoC)

In `ScanView` or `StockBloc`, when a barcode is scanned:
1. Call `repository.fetchStockFromApi(barcode)`.
2. If a result is found, pre-fill the `ProductForm` fields (`name`, `unit`, `notes`).
3. If not found, allow manual entry as usual.

## 5. Dependency Injection

Update `lib/core/injection_container.dart`:

```dart
// Register Dio
sl.registerLazySingleton(() => Dio());

// Register Data Source
sl.registerLazySingleton<IStockRemoteDataSource>(
  () => StockRemoteDataSourceImpl(dio: sl()),
);

// Update Repository Registration to inject Data Source
sl.registerLazySingleton<IStockRepository>(
  () => StockRepositoryImpl(remoteDataSource: sl()),
);
```
