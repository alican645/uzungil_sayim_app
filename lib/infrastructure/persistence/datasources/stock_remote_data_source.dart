import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/stock_api_model.dart';
import '../models/depo_api_model.dart';

abstract class IStockRemoteDataSource {
  Future<StockApiModel?> getStockByBarcode(String barcode);
  Future<List<DepoApiModel>> getDepos();
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
}
