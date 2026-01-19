import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/product/init/app.dart';
import 'package:{{project_name.snakeCase()}}/product/init/bootstrap.dart';

Future<void> main() async {
  await ProductBootstrapper.initialize();
  runApp(const ProductApp());
}
