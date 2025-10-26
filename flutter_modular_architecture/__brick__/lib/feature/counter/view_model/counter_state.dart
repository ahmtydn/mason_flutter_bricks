import 'package:equatable/equatable.dart';

enum CounterStatus { initial, loading, ready, failure }

class CounterState extends Equatable {
  const CounterState({
    this.total = 0,
    this.status = CounterStatus.initial,
    this.lastRecordedAt,
    this.lastNote,
    this.errorMessage,
  });

  final int total;
  final CounterStatus status;
  final String? lastRecordedAt;
  final String? lastNote;
  final String? errorMessage;

  bool get isLoading => status == CounterStatus.loading;
  bool get hasError => errorMessage != null;

  CounterState copyWith({
    int? total,
    CounterStatus? status,
    String? lastRecordedAt,
    String? lastNote,
    Object? errorMessage = _unset,
  }) {
    return CounterState(
      total: total ?? this.total,
      status: status ?? this.status,
      lastRecordedAt: lastRecordedAt ?? this.lastRecordedAt,
      lastNote: lastNote ?? this.lastNote,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  CounterState clearError() {
    return copyWith(status: CounterStatus.ready, errorMessage: null);
  }

  @override
  List<Object?> get props => [
    total,
    status,
    lastRecordedAt,
    lastNote,
    errorMessage,
  ];
}

const _unset = Object();
