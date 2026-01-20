import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/product/init/app.dart';
import 'package:{{project_name.snakeCase()}}/product/init/bootstrap.dart';
import 'package:{{project_name.snakeCase()}}/product/utility/extensions/device_preview_tools.dart';

Future<void> main() async {
  await ProductBootstrapper.initialize();
  runApp(
    DevicePreview(
      enableQuickDevicesTools: true,
      tools: DevicePreviewTools.tools,
      quickDevices: DevicePreviewTools.quickDevices,
      builder: (context) => const ProductApp(),
    ),
  );
}
