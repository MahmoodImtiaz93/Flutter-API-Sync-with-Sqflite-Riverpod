import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetConnectionChecker =
      InternetConnectionChecker();

  Stream<bool> get connectivityStream async* {
    await for (final connectivityResult
        in _connectivity.onConnectivityChanged) {
      if (connectivityResult == ConnectivityResult.none) {
        yield false;
      } else {
        final isConnected = await _internetConnectionChecker.hasConnection;
        yield isConnected;
      }
    }
  }

  Future<bool> checkInitialConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      return await _internetConnectionChecker.hasConnection;
    }
  }
}
