import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class Result<T> extends Equatable {
  const Result();

  const factory Result.success(T data) = Success;
  const factory Result.failure(Object error, {StackTrace? stackTrace}) =
      Failure;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  R when<R>({
    required R Function(Success<T> success) success,
    required R Function(Failure<T> failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) {
      return success(self);
    }

    return failure(self as Failure<T>);
  }

  @override
  List<Object?> get props => [];
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}

final class Failure<T> extends Result<T> {
  const Failure(this.error, {this.stackTrace});

  final Object error;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [error, stackTrace];
}
