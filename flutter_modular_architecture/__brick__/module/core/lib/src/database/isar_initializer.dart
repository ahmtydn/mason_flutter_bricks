import 'package:flutter/foundation.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:module_core/src/cache/cache_directories.dart';

class IsarInitializer {
  IsarInitializer({CacheDirectories? cacheDirectories})
    : _cacheDirectories = cacheDirectories ?? const CacheDirectories();

  final CacheDirectories _cacheDirectories;
  Isar? _isar;

  Future<Isar> open({
    required List<IsarGeneratedSchema> schemas,
    String? name,
  }) async {
    if (_isar != null) {
      return _isar!;
    }

    if (kIsWeb) {
      await Isar.initialize();
    }

    final directory = await _cacheDirectories.resolvePersistentPath();
    _isar = Isar.open(
      schemas: schemas,
      directory: directory,
      name: name ?? Isar.defaultName,
      engine: kIsWeb ? IsarEngine.sqlite : IsarEngine.isar,
    );

    return _isar!;
  }

  Future<void> close() async {
    if (_isar != null) {
      _isar!.close();
      _isar = null;
    }
  }
}
