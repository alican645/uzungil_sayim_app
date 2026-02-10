import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({required this.message, this.statusCode, this.data});

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const ApiException(
          message: 'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.',
          statusCode: null,
        );
      case DioExceptionType.sendTimeout:
        return const ApiException(
          message: 'İstek gönderme zaman aşımına uğradı.',
          statusCode: null,
        );
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Sunucu yanıt vermedi. Lütfen tekrar deneyin.',
          statusCode: null,
        );
      case DioExceptionType.badCertificate:
        return const ApiException(
          message: 'Güvenlik sertifikası hatası.',
          statusCode: null,
        );
      case DioExceptionType.badResponse:
        return ApiException._fromResponse(error.response);
      case DioExceptionType.cancel:
        return const ApiException(
          message: 'İstek iptal edildi.',
          statusCode: null,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'İnternet bağlantınızı kontrol edin.',
          statusCode: null,
        );
      case DioExceptionType.unknown:
        return ApiException(
          message: error.message ?? 'Beklenmeyen bir hata oluştu.',
          statusCode: null,
        );
    }
  }

  factory ApiException._fromResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    // Parse error message from server response
    String message;
    if (data is Map<String, dynamic>) {
      message =
          data['message'] as String? ??
          data['error'] as String? ??
          _defaultMessage(statusCode);
    } else {
      message = _defaultMessage(statusCode);
    }

    return ApiException(message: message, statusCode: statusCode, data: data);
  }

  static String _defaultMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Geçersiz istek.';
      case 401:
        return 'Oturum süresi doldu. Lütfen tekrar giriş yapın.';
      case 403:
        return 'Bu işlem için yetkiniz yok.';
      case 404:
        return 'İstenen kaynak bulunamadı.';
      case 409:
        return 'Çakışma hatası.';
      case 422:
        return 'Gönderilen veriler geçersiz.';
      case 429:
        return 'Çok fazla istek. Lütfen biraz bekleyin.';
      case 500:
        return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
      case 502:
        return 'Sunucu geçici olarak erişilemiyor.';
      case 503:
        return 'Servis bakımda. Lütfen daha sonra tekrar deneyin.';
      default:
        return 'Bir hata oluştu (Kod: $statusCode).';
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
