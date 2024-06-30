import 'package:apiflow_sync_with_riverpod_and_localdb/riverpod_providers/global_providers.dart';
import 'package:apiflow_sync_with_riverpod_and_localdb/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateProduct extends ConsumerStatefulWidget {
  @override
  _CreateProductState createState() => _CreateProductState();
}

class _CreateProductState extends ConsumerState<CreateProduct> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _cpuModelController = TextEditingController();
  final TextEditingController _hardDiskSizeController = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _cpuModelController.dispose();
    _hardDiskSizeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final formData = {
          'name': _nameController.text,
          'data': {
            'year': int.parse(_yearController.text),
            'price': double.parse(_priceController.text),
            'CPU model': _cpuModelController.text,
            'Hard disk size': _hardDiskSizeController.text,
          }
        };
        await ref.read(productDataProvider.notifier).createProduct(formData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Product ${formData['name']} created successfully!')),
        );
        Navigator.of(context).pop();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating product: $error')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              buildTextFormField(
                controller: _nameController,
                labelText: 'Name',
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              buildTextFormField(
                controller: _yearController,
                labelText: 'Year',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the year';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              buildTextFormField(
                controller: _priceController,
                labelText: 'Price (\$)',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              buildTextFormField(
                controller: _cpuModelController,
                labelText: 'CPU Model',
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the CPU model';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              buildTextFormField(
                controller: _hardDiskSizeController,
                labelText: 'Hard Disk Size',
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the hard disk size';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
