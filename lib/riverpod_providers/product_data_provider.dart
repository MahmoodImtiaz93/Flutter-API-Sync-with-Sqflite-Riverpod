// Providers
import 'package:apiflow_sync_with_riverpod_and_localdb/localdb/database_helper.dart';
import 'package:apiflow_sync_with_riverpod_and_localdb/models/product_data_model.dart';
import 'package:apiflow_sync_with_riverpod_and_localdb/services/api_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDataNotifier
    extends StateNotifier<AsyncValue<List<ProductDataModel>>> {
  final ApiService _apiService;
  final DatabaseHelper _databaseHelper;

  ProductDataNotifier(this._apiService, this._databaseHelper)
      : super(AsyncValue.data([]));

  Future<void> createProduct(Map<String, dynamic> formData) async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiService.postProductData(formData);
      await _databaseHelper.insertProduct(response);
      final updatedProducts = await _databaseHelper.getProducts();
      state = AsyncValue.data(updatedProducts);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> fetchProductObjects(List<String> ids) async {
    state = const AsyncValue.loading();
    try {
      final fetchedProducts = await _apiService.fetchObjects(ids);
      // Update state with fetched remote data
      state = AsyncValue.data(fetchedProducts);
      // Update local database in the background
      for (var product in fetchedProducts) {
        await _databaseHelper.updateProduct(product);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteProduct(String id) async {
    state = const AsyncValue.loading();
    try {
      // Attempt to delete product from remote API
      await _apiService.deleteProduct(id);
      // Delete product from local database
      await _databaseHelper.deleteProduct(id);
      // Update the state with remaining products
      final updatedProducts = await _databaseHelper.getProducts();
      state = AsyncValue.data(updatedProducts);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProductName(String id, String newName) async {
    state = const AsyncValue.loading();
    try {
      final updatedProduct = await _apiService.updateProductName(id, newName);
      await _databaseHelper.updateProductName(id, newName);
      final updatedProducts = await _databaseHelper.getProducts();
      state = AsyncValue.data(updatedProducts);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
