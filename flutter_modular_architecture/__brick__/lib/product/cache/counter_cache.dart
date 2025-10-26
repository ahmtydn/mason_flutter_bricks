import 'package:module_gen/module_gen.dart';

class CounterCache {
  int _total = 0;
  Count? _latest;

  int get total => _total;
  Count? get latest => _latest;

  void write({required int total, Count? latest}) {
    _total = total;
    _latest = latest;
  }

  void clear() {
    _total = 0;
    _latest = null;
  }
}
