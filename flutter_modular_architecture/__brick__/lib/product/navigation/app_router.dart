import 'package:auto_route/auto_route.dart';
import 'package:{{project_name.snakeCase()}}/feature/counter/view/counter_view.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'View,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    CustomRoute<CounterView>(page: CounterRoute.page, initial: true),
  ];
}
