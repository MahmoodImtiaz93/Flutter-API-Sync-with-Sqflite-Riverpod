import 'dart:convert';

class ProductDataModel {
  final String? id;
  final String? name;
  final String? createdAt;
  final Map<String, dynamic>? data;

  ProductDataModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.data,
  });

  factory ProductDataModel.fromJson(Map<String, dynamic> json) {
    return ProductDataModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      createdAt: json['createdAt'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt,
      'data': jsonEncode(data),
    };
  }
}
