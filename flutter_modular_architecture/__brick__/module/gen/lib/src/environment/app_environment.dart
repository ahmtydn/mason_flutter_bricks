import 'package:envied/envied.dart';

part 'app_environment.g.dart';

@Envied(name: 'DevEnv', path: 'assets/env/dev.env')
abstract class AppDevEnvironment {
  @EnviedField(varName: 'APP_NAME')
  static const String appName = _DevEnv.appName;

  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _DevEnv.apiBaseUrl;
}

@Envied(name: 'ProdEnv', path: 'assets/env/prod.env')
abstract class AppProdEnvironment {
  @EnviedField(varName: 'APP_NAME')
  static const String appName = _ProdEnv.appName;

  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _ProdEnv.apiBaseUrl;
}
