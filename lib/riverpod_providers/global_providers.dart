import 'package:apiflow_sync_with_riverpod_and_localdb/localdb/database_helper.dart';
import 'package:apiflow_sync_with_riverpod_and_localdb/models/product_data_model.dart';
import 'package:apiflow_sync_with_riverpod_and_localdb/riverpod_providers/product_data_provider.dart';
import 'package:apiflow_sync_with_riverpod_and_localdb/services/api_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseHelperProvider =
    Provider<DatabaseHelper>((ref) => DatabaseHelper());

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final productDataProvider = StateNotifierProvider<ProductDataNotifier,
    AsyncValue<List<ProductDataModel>>>(
  (ref) {
    final apiService = ref.watch(apiServiceProvider);
    final databaseHelper = ref.watch(databaseHelperProvider);
    return ProductDataNotifier(apiService, databaseHelper);
  },
);

final productsIDProvider = FutureProvider<List<String>>((ref) async {
  final databaseHelper = ref.watch(databaseHelperProvider);
  final products = await databaseHelper.getProducts();
  return products.map((product) => product.id!).toList();
});

final productsListProvider =
    FutureProvider<List<ProductDataModel>>((ref) async {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return await databaseHelper.getProducts();
});
