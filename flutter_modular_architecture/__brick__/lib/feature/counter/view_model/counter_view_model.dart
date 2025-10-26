import 'dart:async';

import 'package:{{project_name.snakeCase()}}/feature/counter/view_model/counter_state.dart';
import 'package:{{project_name.snakeCase()}}/product/service/counter/counter_service.dart';
import 'package:{{project_name.snakeCase()}}/product/service/counter/counter_snapshot.dart';
import 'package:{{project_name.snakeCase()}}/product/state/base/base_cubit.dart';
import 'package:{{project_name.snakeCase()}}/product/utility/date_time_formatter.dart';

class CounterViewModel extends BaseCubit<CounterState> {
  CounterViewModel({
    required CounterService counterService,
    required DateTimeFormatter dateTimeFormatter,
  }) : _counterService = counterService,
       _dateTimeFormatter = dateTimeFormatter,
       super(const CounterState());

  final CounterService _counterService;
  final DateTimeFormatter _dateTimeFormatter;
  StreamSubscription<CounterSnapshot>? _subscription;

  Future<void> initialize() async {
    emitSafe(state.copyWith(status: CounterStatus.loading, errorMessage: null));

    await _counterService.initialize();
    _emitSnapshot(_counterService.currentSnapshot());

    await _subscription?.cancel();
    _subscription = _counterService.observe().listen(
      _emitSnapshot,
      onError: (Object error, StackTrace stackTrace) {
        emitSafe(
          state.copyWith(
            status: CounterStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> increment({String note = ''}) async {
    try {
      await _counterService.increment(note: note);
    } on Exception catch (error) {
      emitSafe(
        state.copyWith(
          status: CounterStatus.ready,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }
    emitSafe(state.clearError());
  }

  void _emitSnapshot(CounterSnapshot snapshot) {
    final latest = snapshot.latest;
    emitSafe(
      state.copyWith(
        status: CounterStatus.ready,
        total: snapshot.total,
        lastRecordedAt: latest == null
            ? null
            : _dateTimeFormatter.formatWithSeconds(latest.metadata.recordedAt),
        lastNote: latest == null || latest.metadata.note.trim().isEmpty
            ? null
            : latest.metadata.note,
        errorMessage: null,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
