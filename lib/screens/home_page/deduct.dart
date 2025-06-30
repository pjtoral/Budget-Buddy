import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deduct',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DeductPage(),
    );
  }
}

class DeductPage extends StatefulWidget {
  const DeductPage({super.key});

  @override
  State<DeductPage> createState() => _DeductPageState();
}

class _DeductPageState extends State<DeductPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  bool _showCategories = false;
  final List<String> _categories = ['School', 'Motorcycle', 'Shabu'];
  double balance = 40000.00;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deduct'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter amount to deduct:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Enter Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Balance after: ₽${(balance - (double.tryParse(_amountController.text) ?? 0)).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select a category:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Category dropdown button
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _showCategories = !_showCategories;
                });
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.grey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategory ?? 'Categories',
                    style: TextStyle(
                      color: _selectedCategory != null ? Colors.black : Colors.grey,
                    ),
                  ),
                  Icon(
                    _showCategories ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  ),
                ],
              ),
            ),
            // Category dropdown menu
            if (_showCategories) ...[
              Column(
                children: _categories.map((category) {
                  return ListTile(
                    title: Text(category),
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                        _showCategories = false;
                      });
                    },
                  );
                }).toList(),
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 8),
                    Text('Add Category'),
                  ],
                ),
                onTap: () {
                  // Add category functionality
                },
              ),
            ],
            // Description field (only shown when category is selected)
            if (_selectedCategory != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Description:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Enter Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
            const SizedBox(height: 16),
            const Divider(thickness: 1),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Confirm action
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}