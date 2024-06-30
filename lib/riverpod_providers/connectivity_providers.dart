import 'package:apiflow_sync_with_riverpod_and_localdb/services/connectivity_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.connectivityStream;
});

final initialConnectivityProvider = FutureProvider<bool>((ref) async {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return await connectivityService.checkInitialConnectivity();
});
