import 'package:isar_plus/isar_plus.dart';
import 'package:module_core/module_core.dart';
import 'package:module_gen/module_gen.dart';
import 'package:{{project_name.snakeCase()}}/product/cache/counter_cache.dart';
import 'package:{{project_name.snakeCase()}}/product/service/counter/counter_snapshot.dart';

class CounterService {
  CounterService({
    required IsarInitializer isarInitializer,
    CounterCache? cache,
  }) : _isarInitializer = isarInitializer,
       _cache = cache ?? CounterCache();

  final IsarInitializer _isarInitializer;
  final CounterCache _cache;
  Isar? _isar;

  Future<void> initialize() async {
    await _ensureIsar();
    await _refreshCache();
  }

  CounterSnapshot currentSnapshot() {
    return CounterSnapshot(total: _cache.total, latest: _cache.latest);
  }

  Stream<CounterSnapshot> observe() async* {
    final isar = await _ensureIsar();
    yield currentSnapshot();
    yield* isar.counts.watchLazy().asyncMap((_) async {
      await _refreshCache();
      return currentSnapshot();
    });
  }

  Future<void> increment({String note = ''}) async {
    final isar = await _ensureIsar();
    await isar.write((isarInstance) {
      final nextId = (isarInstance.counts.where().idProperty().max() ?? 0) + 1;
      final metadata = StepMetadata(recordedAt: DateTime.now(), note: note);
      isarInstance.counts.put(Count(id: nextId, step: 1, metadata: metadata));
    });
    await _refreshCache();
  }

  Future<void> dispose() async {
    _isar?.close();
    _isar = null;
    _cache.clear();
  }

  Future<void> _refreshCache() async {
    final isar = await _ensureIsar();
    final total = isar.counts.where().stepProperty().sum();
    final latest = isar.counts.where().sortByIdDesc().findFirst();
    _cache.write(total: total, latest: latest);
  }

  Future<Isar> _ensureIsar() async {
    _isar ??= await _isarInitializer.open(schemas: [CountSchema]);
    return _isar!;
  }
}
