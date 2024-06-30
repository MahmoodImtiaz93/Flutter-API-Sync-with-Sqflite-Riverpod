import 'dart:convert';
import 'package:path/path.dart';
import 'package:apiflow_sync_with_riverpod_and_localdb/models/product_data_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'product_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            id TEXT PRIMARY KEY,
            name TEXT,
            createdAt TEXT,
            data TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertProduct(ProductDataModel product) async {
    final db = await database;
    await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProductDataModel>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');

    // Convert the maps to a list of ProductDataModel and print each item
    List<ProductDataModel> products = List.generate(maps.length, (i) {
      return ProductDataModel(
        id: maps[i]['id'],
        name: maps[i]['name'],
        createdAt: maps[i]['createdAt'],
        data: jsonDecode(maps[i]['data']),
      );
    });

    // Print each product's data
    for (var product in products) {
      print('Product ID: ${product.id}');
      print('Product Name: ${product.name}');
      print('Created At: ${product.createdAt}');
      print('Data: ${product.data}');
      print('-------------'); // Separator for readability
    }

    return products;
  }

  Future<void> updateProduct(ProductDataModel product) async {
    final db = await database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    print('Deleted product with ID: $id from local database.');
  }

  Future<void> updateProductName(String id, String newName) async {
    final db = await database;
    await db.update(
      'products',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
