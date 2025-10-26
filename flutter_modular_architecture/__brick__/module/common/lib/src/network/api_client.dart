import 'package:dio/dio.dart';

import '../result/result.dart';

class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<Result<Response<dynamic>>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return Result.success(response);
    } on DioException catch (error, stackTrace) {
      return Result.failure(error, stackTrace: stackTrace);
    }
  }
}
