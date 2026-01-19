import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Explanation: Log request details for debugging
    // ignore: avoid_print
    print('--> [${options.method}] ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    // Explanation: Log response details for debugging
    // ignore: avoid_print
    print('<-- [${response.statusCode}] ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Explanation: Log error details for debugging
    // ignore: avoid_print
    print(
      '--x [${err.response?.statusCode}] '
      '${err.requestOptions.uri} ${err.message}',
    );
    handler.next(err);
  }
}
