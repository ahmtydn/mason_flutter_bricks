import 'package:flutter/widgets.dart';
import 'package:module_common/module_common.dart';
import 'package:{{project_name.snakeCase()}}/product/service/container/product_container.dart';
import 'package:{{project_name.snakeCase()}}/product/service/counter/counter_service.dart';

class ProductBootstrapper {
  const ProductBootstrapper._();

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    await ProductContainer.setup();

    await Future.wait([
      ProductContainer.read<CounterService>().initialize(),
      ProductContainer.read<ConnectivityWatcher>().initialize(),
    ]);
  }
}
