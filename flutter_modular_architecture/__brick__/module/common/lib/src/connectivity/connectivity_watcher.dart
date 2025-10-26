import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityWatcher {
  ConnectivityWatcher({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Stream<bool> get onStatusChange => _controller.stream;

  Future<void> initialize() async {
    final status = await _connectivity.checkConnectivity();
    _controller.add(!_isOffline(status));

    await _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((event) {
      _controller.add(!_isOffline(event));
    });
  }

  bool _isOffline(List<ConnectivityResult> results) {
    return results.every((result) => result == ConnectivityResult.none);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
