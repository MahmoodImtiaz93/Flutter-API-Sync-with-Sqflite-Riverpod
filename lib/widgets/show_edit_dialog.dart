import 'package:apiflow_sync_with_riverpod_and_localdb/models/product_data_model.dart';
import 'package:apiflow_sync_with_riverpod_and_localdb/riverpod_providers/global_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showEditDialog(
    BuildContext context, WidgetRef ref, ProductDataModel product) {
  final TextEditingController nameController =
      TextEditingController(text: product.name);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Product Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Update'),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                ref
                    .read(productDataProvider.notifier)
                    .updateProductName(product.id!, nameController.text);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}
