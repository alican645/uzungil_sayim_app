---
name: dio-flutter-setup
description: >
  Professional-grade Dio HTTP client setup for Flutter/Dart projects. Use this skill whenever the user wants to:
  set up networking/HTTP in a Flutter app, configure Dio, create an API client, add interceptors (auth, logging, retry, cache),
  handle API errors, implement token refresh, upload/download files with progress, integrate with REST APIs,
  set up Retrofit with Dio, or structure their network layer. Also trigger when user mentions "Dio", "HTTP client",
  "API client", "REST API integration", "network layer", "interceptor", "token refresh", "api service",
  or any Flutter networking task. Even if they just say "I need to call an API" or "set up backend connection",
  use this skill. Covers Dio 5.x with all modern best practices.
---

# Dio Flutter Setup Skill

## Overview

This skill sets up a **production-ready Dio HTTP client** for Flutter projects following clean architecture principles. It generates a complete network layer with interceptors, error handling, token refresh, retry logic, and type-safe API calls.

## Quick Start

For a basic setup, run:
```bash
dart pub add dio pretty_dio_logger
```

For a full production setup, run:
```bash
dart pub add dio pretty_dio_logger dio_smart_retry connectivity_plus retrofit json_annotation
dart pub add --dev retrofit_generator build_runner json_serializable
```

---

## Before You Begin

1. **Read this file fully** before generating any code.
2. **Check the user's existing project structure** — adapt to their architecture (clean arch, MVVM, BLoC, Riverpod, etc.)
3. **Ask the user** which features they need if not specified:

| Feature | When to Include |
|---------|----------------|
| Base client + config | **Always** |
| Auth interceptor (token injection) | If app has authentication |
| Token refresh interceptor | If using JWT/OAuth with refresh tokens |
| Logging interceptor | **Always** (dev mode only) |
| Retry interceptor | Recommended for production apps |
| Error handling | **Always** |
| Connectivity check | Recommended |
| File upload/download | If app handles files |
| Caching | If app needs offline support |
| Retrofit integration | If user wants code-generated type-safe API |

---

## Architecture Decision

### Option A: Manual Dio (Default)
Best for: Small-medium projects, full control, learning
- Direct Dio calls with typed response parsing
- Manual endpoint management

### Option B: Dio + Retrofit (Recommended for large projects)
Best for: Large projects, teams, type-safety
- Code-generated API client from annotations
- Automatic serialization/deserialization
- Read `references/retrofit-setup.md` for details

---

## Core Implementation

### 1. API Client Singleton (`api_client.dart`)

```dart
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Interceptor sırası önemlidir!
    // 1. Auth (token ekleme)
    // 2. Retry (hata durumunda tekrar deneme)
    // 3. Logging (en son, tüm değişiklikleri görmek için)
    dio.interceptors.addAll([
      AuthInterceptor(),
      RetryInterceptor(dio: dio),
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
    ]);
  }

  factory ApiClient() {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  /// Test veya ortam değişikliği için instance sıfırlama
  @visibleForTesting
  static void reset() {
    _instance = null;
  }
}
```

### 2. App Configuration (`app_config.dart`)

```dart
enum Environment { dev, staging, prod }

class AppConfig {
  static late Environment _environment;

  static void init(Environment env) {
    _environment = env;
  }

  static String get baseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'https://dev-api.example.com/v1';
      case Environment.staging:
        return 'https://staging-api.example.com/v1';
      case Environment.prod:
        return 'https://api.example.com/v1';
    }
  }

  static bool get isDev => _environment == Environment.dev;
}
```

### 3. Auth Interceptor (`auth_interceptor.dart`)

```dart
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Public endpoint'leri atla
    final publicPaths = ['/auth/login', '/auth/register', '/public'];
    final isPublic = publicPaths.any((path) => options.path.contains(path));

    if (!isPublic) {
      final token = TokenStorage.accessToken; // kendi token storage'ınız
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final newToken = await _refreshToken();
        if (newToken != null) {
          // Token'ı güncelle ve isteği tekrar dene
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final response = await Dio().fetch(err.requestOptions);
          return handler.resolve(response);
        }
      } catch (e) {
        // Refresh başarısız — logout yap
        await TokenStorage.clear();
        // Navigate to login (use a global navigator key or event bus)
      }
    }
    handler.next(err);
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = TokenStorage.refreshToken;
      if (refreshToken == null) return null;

      final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data['access_token'] as String;
      final newRefreshToken = response.data['refresh_token'] as String;

      await TokenStorage.save(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      return newAccessToken;
    } catch (_) {
      return null;
    }
  }
}
```

### 4. Error Handling (`api_exceptions.dart`)

```dart
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

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

    // Sunucudan gelen hata mesajını parse et
    String message;
    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ??
          data['error'] as String? ??
          _defaultMessage(statusCode);
    } else {
      message = _defaultMessage(statusCode);
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }

  static String _defaultMessage(int? statusCode) {
    switch (statusCode) {
      case 400: return 'Geçersiz istek.';
      case 401: return 'Oturum süresi doldu. Lütfen tekrar giriş yapın.';
      case 403: return 'Bu işlem için yetkiniz yok.';
      case 404: return 'İstenen kaynak bulunamadı.';
      case 409: return 'Çakışma hatası.';
      case 422: return 'Gönderilen veriler geçersiz.';
      case 429: return 'Çok fazla istek. Lütfen biraz bekleyin.';
      case 500: return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
      case 502: return 'Sunucu geçici olarak erişilemiyor.';
      case 503: return 'Servis bakımda. Lütfen daha sonra tekrar deneyin.';
      default:  return 'Bir hata oluştu (Kod: $statusCode).';
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
```

### 5. Generic API Response Wrapper (`api_response.dart`)

```dart
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final PaginationMeta? meta;

  const ApiResponse({
    this.data,
    this.message,
    required this.success,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      meta: json['meta'] != null
          ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
    );
  }

  bool get hasMore => currentPage < lastPage;
}
```

### 6. Base Repository with Error Handling

```dart
import 'package:dio/dio.dart';

abstract class BaseRepository {
  final Dio dio;

  BaseRepository({Dio? dio}) : dio = dio ?? ApiClient().dio;

  /// Güvenli API çağrısı wrapper'ı
  Future<T> safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } on FormatException {
      throw const ApiException(message: 'Veri formatı hatası.');
    } catch (e) {
      throw ApiException(message: 'Beklenmeyen hata: $e');
    }
  }
}
```

---

## Advanced Features

For advanced features, read the reference files:

| Feature | Reference File | When to Read |
|---------|---------------|--------------|
| Retry interceptor setup | `references/retry-and-cache.md` | Need retry/cache logic |
| Retrofit code generation | `references/retrofit-setup.md` | Need type-safe API client |
| File upload/download | `references/file-operations.md` | Need file handling |
| Testing the network layer | `references/testing.md` | Need unit/integration tests |

---

## File Structure to Generate

When setting up Dio for a project, create these files:

```
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart
│   └── network/
│       ├── api_client.dart           ← Dio singleton
│       ├── api_endpoints.dart        ← URL sabit tanımları
│       ├── api_exceptions.dart       ← Hata sınıfları
│       ├── api_response.dart         ← Generic response wrapper
│       ├── interceptors/
│       │   ├── auth_interceptor.dart ← Token ekleme + refresh
│       │   ├── retry_interceptor.dart← Tekrar deneme
│       │   └── cache_interceptor.dart← Önbellek (opsiyonel)
│       └── base_repository.dart      ← safeApiCall wrapper
```

---

## Implementation Checklist

When generating code, ensure:

- [ ] Dio singleton with proper BaseOptions
- [ ] Environment-based configuration (dev/staging/prod)
- [ ] Auth interceptor with token injection
- [ ] Token refresh logic (401 handling)
- [ ] Comprehensive error mapping (DioExceptionType → user message)
- [ ] Timeouts configured (connect, receive, send)
- [ ] Logging only in debug mode
- [ ] Generic response wrapper matching backend format
- [ ] Base repository with safeApiCall
- [ ] CancelToken support for search/infinite scroll
- [ ] Endpoints as constants (not magic strings)

---

## Common Patterns

### Cancel Token for Search

```dart
CancelToken? _searchCancelToken;

Future<List<Product>> search(String query) async {
  _searchCancelToken?.cancel();
  _searchCancelToken = CancelToken();

  final response = await dio.get(
    '/products/search',
    queryParameters: {'q': query},
    cancelToken: _searchCancelToken,
  );
  return (response.data['data'] as List)
      .map((e) => Product.fromJson(e))
      .toList();
}
```

### File Upload with Progress

```dart
Future<String> uploadFile(File file, {Function(int, int)? onProgress}) async {
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(
      file.path,
      filename: file.path.split('/').last,
    ),
  });

  final response = await dio.post(
    '/upload',
    data: formData,
    onSendProgress: onProgress,
  );

  return response.data['url'] as String;
}
```

### Pagination Helper

```dart
Future<ApiResponse<List<T>>> getPaginated<T>(
  String path, {
  required int page,
  int perPage = 20,
  required T Function(Map<String, dynamic>) fromJson,
  Map<String, dynamic>? queryParameters,
}) async {
  final response = await dio.get(
    path,
    queryParameters: {
      'page': page,
      'per_page': perPage,
      ...?queryParameters,
    },
  );

  final items = (response.data['data'] as List)
      .map((e) => fromJson(e as Map<String, dynamic>))
      .toList();

  return ApiResponse(
    success: true,
    data: items,
    meta: PaginationMeta.fromJson(response.data['meta']),
  );
}
```

---

## Dependency Versions (Dio 5.x)

Always check pub.dev for latest versions, but as reference:

```yaml
dependencies:
  dio: ^5.7.0
  pretty_dio_logger: ^1.4.0
  dio_smart_retry: ^7.0.1
  connectivity_plus: ^6.1.0
  # Retrofit (opsiyonel)
  retrofit: ^4.4.1
  json_annotation: ^4.9.0

dev_dependencies:
  # Retrofit (opsiyonel)
  retrofit_generator: ^9.1.5
  build_runner: ^2.4.13
  json_serializable: ^6.8.0
```

---

## Important Notes

1. **Interceptor sırası önemlidir**: Auth → Retry → Logger (logger en sonda olmalı ki tüm değişiklikleri görsün)
2. **Token refresh sırasında queue**: Birden fazla 401 gelirse, sadece bir refresh isteği atılmalı, diğerleri beklemeli
3. **Flutter Web**: `dart:io` web'de çalışmaz, `kIsWeb` kontrolü yapın
4. **Certificate Pinning**: Prodüksiyon uygulamalarında `badCertificate` handler ekleyin
5. **Dispose**: Uygulama kapanırken `dio.close()` çağrısı yapılmalı (opsiyonel ama önerilen)