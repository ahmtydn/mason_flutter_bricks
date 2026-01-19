import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:module_common/module_common.dart';
import 'package:module_core/module_core.dart';
import 'package:{{project_name.snakeCase()}}/product/cache/counter_cache.dart';
import 'package:{{project_name.snakeCase()}}/product/navigation/app_router.dart';
import 'package:{{project_name.snakeCase()}}/product/service/counter/counter_service.dart';
import 'package:{{project_name.snakeCase()}}/product/service/network/network_service.dart';
import 'package:{{project_name.snakeCase()}}/product/state/product_view_model.dart';
import 'package:{{project_name.snakeCase()}}/product/utility/date_time_formatter.dart';

class ProductContainer {
  ProductContainer._();

  static final GetIt _getIt = GetIt.instance;
  static bool _configured = false;

  static Future<void> setup() async {
    if (_configured) {
      return;
    }

    _getIt
      ..registerLazySingleton<CacheDirectories>(CacheDirectories.new)
      ..registerLazySingleton<IsarInitializer>(
        () => IsarInitializer(cacheDirectories: _getIt<CacheDirectories>()),
      )
      ..registerLazySingleton<CounterCache>(CounterCache.new)
      ..registerLazySingleton<DateTimeFormatter>(DateTimeFormatter.new)
      ..registerLazySingleton<LoggingInterceptor>(
        () => const LoggingInterceptor(),
      )
      ..registerLazySingleton<Dio>(() {
        final dio = Dio();
        dio.interceptors.add(_getIt<LoggingInterceptor>());
        return dio;
      })
      ..registerLazySingleton<ApiClient>(() => ApiClient(dio: _getIt<Dio>()))
      ..registerLazySingleton<ConnectivityWatcher>(ConnectivityWatcher.new)
      ..registerLazySingleton<NetworkService>(
        () => NetworkService(apiClient: _getIt<ApiClient>()),
      )
      ..registerLazySingleton<CounterService>(
        () => CounterService(
          isarInitializer: _getIt<IsarInitializer>(),
          cache: _getIt<CounterCache>(),
        ),
      )
      ..registerSingleton<ProductViewModel>(ProductViewModel())
      ..registerSingleton<AppRouter>(AppRouter());

    _configured = true;
  }

  static T read<T extends Object>() => _getIt<T>();
}
