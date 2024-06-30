import 'package:apiflow_sync_with_riverpod_and_localdb/models/product_data_model.dart';
import 'package:apiflow_sync_with_riverpod_and_localdb/riverpod_providers/product_data_provider.dart';
import 'package:flutter/material.dart';

Future<dynamic> deleteDialog(BuildContext context, ProductDataModel product,
    ProductDataNotifier productDataNotifier) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Delete',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Do you want to delete ${product.name!}?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Row(
            children: [
              ElevatedButton.icon(
                  onPressed: () async {
                    await productDataNotifier.deleteProduct(product.id!);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.done_rounded),
                  label: const Text("Yes")),
              const Spacer(),
              ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close_rounded),
                  label: const Text("No"))
            ],
          )
        ],
      );
    },
  );
}
