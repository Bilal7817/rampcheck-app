import 'package:flutter/material.dart';
import '../models/inspection_item.dart';
import '../services/database_helper.dart';

class AddInspectionItemScreen extends StatefulWidget {
  final int jobId;

  const AddInspectionItemScreen({super.key, required this.jobId});

  @override
  State<AddInspectionItemScreen> createState() =>
      _AddInspectionItemScreenState();
}

class _AddInspectionItemScreenState extends State<AddInspectionItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      try {
        final item = InspectionItem(
          jobId: widget.jobId,
          title: _titleController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          needsSync: 1,
        );

        await _dbHelper.createInspectionItem(item);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inspection item added')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error adding item: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Inspection Item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Item Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.checklist),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an item title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Add Item', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
