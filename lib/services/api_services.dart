import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apiflow_sync_with_riverpod_and_localdb/models/product_data_model.dart';

class ApiService {
  // Base URL for the API
  final String baseUrl = 'https://api.restful-api.dev/objects';

  // Function to post product data
  Future<ProductDataModel> postProductData(Map<String, dynamic> data) async {
    final url = '$baseUrl';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      print('Response: $responseBody');

      return ProductDataModel.fromJson(responseBody);
    } else {
      print('Failed to post product data. Status code: ${response.statusCode}');
      throw Exception(
          'Failed to post product data. Status code: ${response.statusCode}');
    }
  }

  // Function to fetch objects based on IDs
  Future<List<ProductDataModel>> fetchObjects(List<String> ids) async {
    final queryParams = {'id': ids.join(',')};
    final url = Uri.parse('$baseUrl').replace(queryParameters: queryParams);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => ProductDataModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  // Function to delete a product based on ID
  Future<void> deleteProduct(String id) async {
    final url = '$baseUrl/$id';
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200 || response.statusCode == 204) {
    } else {
      throw Exception(
          'Failed to delete product. Status code: ${response.statusCode}');
    }
  }

  // Function to update the name of a product based on ID
  Future<ProductDataModel> updateProductName(String id, String newName) async {
    final url = '$baseUrl/$id';
    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': newName}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      return ProductDataModel.fromJson(responseBody);
    } else {
      throw Exception(
          'Failed to update product name. Status code: ${response.statusCode}');
    }
  }
}
