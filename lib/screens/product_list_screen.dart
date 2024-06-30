import 'package:apiflow_sync_with_riverpod_and_localdb/riverpod_providers/connectivity_providers.dart';
import 'package:apiflow_sync_with_riverpod_and_localdb/riverpod_providers/global_providers.dart';
import 'package:apiflow_sync_with_riverpod_and_localdb/screens/create_product.dart';
import 'package:apiflow_sync_with_riverpod_and_localdb/widgets/show_delete_dialog.dart';
import 'package:apiflow_sync_with_riverpod_and_localdb/widgets/show_edit_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ProductListScreen extends HookConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("Build");
    final initialConnectivity = ref.watch(initialConnectivityProvider);
    final connectivityStream = ref.watch(connectivityStreamProvider);
    final productsID = ref.watch(productsIDProvider);
    final productsDataLocalcValue = ref.watch(productsListProvider);
    final productDataNotifier = ref.read(productDataProvider.notifier);
    final productDataRemoteValue = ref.watch(productDataProvider);

    useEffect(() {
      Future.microtask(() {
        connectivityStream.whenData((isConnected) {
          if (isConnected) {
            productsID.whenData((productIds) {
              if (productIds.isNotEmpty) {
                if (kDebugMode) {
                  print("Fetching product objects for IDs: $productIds");
                }

                productDataNotifier.fetchProductObjects(productIds);
              } else {
                if (kDebugMode) {
                  print("No product IDs found in local database");
                }
              }
            });
          }
        });
      });
      return null;
    }, [connectivityStream, productsID]);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SyncMaster",
          style: TextStyle(
            color: Color.fromARGB(255, 91, 6, 104),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Text(
                  "All Products",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  child: initialConnectivity.when(
                    data: (initiallyConnected) {
                      return connectivityStream.when(
                        data: (isConnected) {
                          return Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            color: isConnected ? Colors.green : Colors.red,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                isConnected ? 'Connected' : 'Disconnected!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) =>
                            const Text('Error checking connectivity'),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) =>
                        const Text('Error checking initial connectivity'),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: initialConnectivity.when(
              data: (initiallyConnected) {
                return connectivityStream.when(
                  data: (isConnected) {
                    if (isConnected) {
                      return productDataRemoteValue.when(
                        data: (products) {
                          return RefreshIndicator(
                              onRefresh: () async {
                                await ref.refresh(productsListProvider.future);
                                await ref
                                    .read(productDataProvider.notifier)
                                    .fetchProductObjects(
                                      products.map((p) => p.id!).toList(),
                                    );
                              },
                              child: products.isEmpty
                                  ? ListView(
                                      children: [
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                3),
                                        const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text("No products available."),
                                              SizedBox(height: 20),
                                              Text("Pull down to refresh",
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : ListView.builder(
                                      itemCount: products.length,
                                      itemBuilder: (context, index) {
                                        final product = products[index];
                                        return Card(
                                          child: ListTile(
                                            title: Text(
                                              product.name!,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            subtitle: Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Price: \$${product.data!['price']}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                        'Year: ${product.data!['year']}'),
                                                    Text(
                                                        'CPU: ${product.data!['CPU model']}'),
                                                    Text(
                                                        'HDD: ${product.data!['Hard disk size']}'),
                                                    Text(
                                                      'ID: ${product.id}',
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                                const Spacer(),
                                                Column(children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      deleteDialog(
                                                          context,
                                                          product,
                                                          productDataNotifier);
                                                    },
                                                    icon: const Icon(
                                                        Icons.delete),
                                                    color: Colors.red,
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      showEditDialog(context,
                                                          ref, product);
                                                    },
                                                    icon:
                                                        const Icon(Icons.edit),
                                                    color: Colors.purple,
                                                  ),
                                                ]),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ));
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, stackTrace) {
                          return Center(
                            child: Text('Error: $error'),
                          );
                        },
                      );
                    } else {
                      return RefreshIndicator(
                        onRefresh: () async {
                          // Refresh the local data
                          await ref.refresh(productsListProvider.future);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data Synced'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Color.fromARGB(255, 73, 45, 148),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: productsDataLocalcValue.when(
                          data: (products) {
                            return ListView.builder(
                              itemCount: products.isEmpty ? 1 : products.length,
                              itemBuilder: (context, index) {
                                if (products.isEmpty) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 250.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'No products available.',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 20),
                                          Text(
                                            "Pull down to Sync",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                final product = products[index];
                                return Card(
                                  child: ListTile(
                                    title: Text(
                                      product.name ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                                'Year: ${product.data?['year'] ?? 'N/A'}'),
                                            const Spacer(),
                                            Text(
                                                'Price: \$${product.data?['price'] ?? 'N/A'}'),
                                          ],
                                        ),
                                        Text(
                                            'CPU: ${product.data?['CPU model'] ?? 'N/A'}'),
                                        Text(
                                            'HDD: ${product.data?['Hard disk size'] ?? 'N/A'}'),
                                        const SizedBox(height: 5),
                                        const Text(
                                          "Cached Data",
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, stackTrace) =>
                              Center(child: Text('Error: $error')),
                        ),
                      );
                    }
                  },
                  loading: () => productsDataLocalcValue.when(
                    data: (products) {
                      if (products.isEmpty) {
                        return const Center(
                            child: Text('No products available.'));
                      }
                      return ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];

                          return Card(
                            child: ListTile(
                              title: Text(
                                product.name!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('Year: ${product.data!['year']}'),
                                      const Spacer(),
                                      Text(
                                          'Price: \$${product.data!['price']}'),
                                    ],
                                  ),
                                  Text('CPU: ${product.data!['CPU model']}'),
                                  Text(
                                      'HDD: ${product.data!['Hard disk size']}'),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Cached Data",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
                  ),
                  error: (_, __) => const Text('Error checking connectivity'),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const Text('Error checking initial connectivity'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateProduct(),
            ),
          ).then((_) => ref.refresh(productsIDProvider));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
