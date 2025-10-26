import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class CacheDirectories {
  const CacheDirectories();

  Future<String> resolvePersistentPath() async {
    if (kIsWeb) {
      return 'isar_data';
    }

    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
