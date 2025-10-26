import 'package:module_gen/module_gen.dart';

class CounterSnapshot {
  const CounterSnapshot({required this.total, this.latest});

  final int total;
  final Count? latest;
}
