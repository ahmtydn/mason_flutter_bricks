import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/material.dart';

class DevicePreviewTools {
  static List<Widget> tools = const [DeviceSection()];

  static List<DeviceInfo> quickDevices = [
    Devices.ios.iPhoneSE,
    Devices.ios.iPhone13ProMax,
    Devices.ios.iPadPro11Inches,
  ];
}
