import 'package:flutter/material.dart';

import 'product/init/app.dart';
import 'product/init/bootstrap.dart';

Future<void> main() async {
  await ProductBootstrapper.initialize();
  runApp(const ProductApp());
}
