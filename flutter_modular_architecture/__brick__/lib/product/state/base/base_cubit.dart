import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

abstract class BaseCubit<State> extends Cubit<State> {
  BaseCubit(super.initialState);

  @protected
  void emitSafe(State newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  @protected
  void emitSafeUpdate(State Function(State current) update) {
    if (isClosed) {
      return;
    }

    emit(update(state));
  }
}
