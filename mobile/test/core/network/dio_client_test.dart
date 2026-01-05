import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'dart:typed_data';

import 'dio_client_test.mocks.dart';

@GenerateMocks([HttpClientAdapter])
void main() {
  late DioClient dioClient;
  late Dio dio;
  late MockHttpClientAdapter mockAdapter;

  setUp(() {
    mockAdapter = MockHttpClientAdapter();
    dio = Dio();
    dio.httpClientAdapter = mockAdapter;
    
    // Stub default response
     when(mockAdapter.fetch(any, any, any)).thenAnswer((_) async => ResponseBody.fromString(
      '{}',
      200,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    ));

    dioClient = DioClient(dio: dio, baseUrl: 'https://test.api');
  });

  group('DioClient', () {
    test('should configure Dio options correctly on init', () {
      expect(dio.options.baseUrl, 'https://test.api');
      expect(dio.options.connectTimeout, const Duration(seconds: 15));
      expect(dio.interceptors.length, greaterThan(0)); // Should have RetryInterceptor
    });

    test('GET request calls adapter', () async {
      await dioClient.get('/test');
      
      verify(mockAdapter.fetch(
        argThat(predicate<RequestOptions>((x) => x.method == 'GET' && x.path == '/test')), 
        any, 
        any
      )).called(1);
    });
    
    test('POST request calls adapter', () async {
      await dioClient.post('/test', data: {'key': 'value'});

      verify(mockAdapter.fetch(
        argThat(predicate<RequestOptions>((x) => x.method == 'POST' && x.path == '/test')), 
        any, 
        any
      )).called(1);
    });
  });
}
