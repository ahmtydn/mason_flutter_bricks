import 'package:isar_plus/isar_plus.dart';

part 'count.g.dart';

/// Metadata for a counter step, stored as an embedded object.
@embedded
class StepMetadata {
  const StepMetadata({required this.recordedAt, this.note = ''});

  final DateTime recordedAt;
  final String note;
}

/// Represents a single counter increment with metadata.
@collection
class Count {
  Count({required this.id, required this.step, required this.metadata});

  @Id()
  final int id;
  final int step;
  final StepMetadata metadata;
}
