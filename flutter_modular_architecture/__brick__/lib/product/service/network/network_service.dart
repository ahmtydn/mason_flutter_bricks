import 'package:dio/dio.dart';
import 'package:module_common/module_common.dart';

class NetworkService {
  NetworkService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Result<Response<dynamic>>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _apiClient.get(path, queryParameters: queryParameters);
  }
}
