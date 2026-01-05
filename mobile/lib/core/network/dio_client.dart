import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/service_locator/app_config.dart';

final dioProvider = Provider<Dio>((ref) {
  // We assume AppConfig is provided globally, but for now we'll rely on it being passed or accessed.
  // In a real app we'd lookup the config provider.
  // For the testability, we might pass the baseUrl.
  return Dio(); 
});

class DioClient {
  final Dio _dio;
  final String baseUrl;

  DioClient({
    required Dio dio, 
    required this.baseUrl,
  }) : _dio = dio {
    _dio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = const Duration(seconds: 15)
      ..options.receiveTimeout = const Duration(seconds: 15)
      ..options.responseType = ResponseType.json;

    // Retry Policy
    _dio.interceptors.add(RetryInterceptor(
      dio: _dio,
      logPrint: print, // ignore: avoid_print
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 5),
      ],
    ));
    
    // TODO: Add AuthInterceptor
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }
}

// Provider for DioClient
final dioClientProvider = Provider<DioClient>((ref) {
  final dio = ref.watch(dioProvider);
  // Ideally get config from a provider
  return DioClient(dio: dio, baseUrl: 'https://api.usavpc.app'); // Defaulting for now
});
