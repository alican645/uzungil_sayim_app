import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/stock_api_model.dart';
import '../models/depo_api_model.dart';

abstract class IStockRemoteDataSource {
  Future<StockApiModel?> getStockByBarcode(String barcode);
  Future<List<DepoApiModel>> getDepos();
  Future<String> sendToVega(List<Map<String, dynamic>> data);
}

class StockRemoteDataSourceImpl implements IStockRemoteDataSource {
  final Dio dio;

  StockRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient().dio;

  @override
  Future<StockApiModel?> getStockByBarcode(String barcode) async {
    try {
      final response = await dio.get(
        '/SayimAktarmaApi',
        queryParameters: {'barcode': barcode},
      );

      final apiResponse = StockApiResponse.fromJson(response.data);
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data;
      }
      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<DepoApiModel>> getDepos() async {
    try {
      final response = await dio.get('/SayimAktarmaApi/Depo');
      final apiResponse = DepoApiResponse.fromJson(response.data);
      if (apiResponse.success) {
        return apiResponse.data;
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<String> sendToVega(List<Map<String, dynamic>> data) async {
    try {
      // The user specified: base url de /SendToVega end pointli url e jsonList'i göndereceğiz
      // Assuming it's a POST request
      final response = await dio.post(
        '/SayimAktarmaApi/SendToVega',
        data: data, // dio handles list serialization
      );

      // Expected response: { success = True, data = 2, message = 2 kayıt başarıyla aktarıldı. }
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        // Check success
        final bool success = body['success'] == true;
        final String message =
            body['message']?.toString() ?? 'İşlem tamamlandı';

        if (success) {
          return message;
        } else {
          throw ServerFailure(message);
        }
      }
      throw ServerFailure('İşlem başarısız: HTML ${response.statusCode}');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is Failure) rethrow; // If we threw ServerFailure above
      throw ServerFailure(e.toString());
    }
  }
}
