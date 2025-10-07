import 'package:budgetbuddy_project/models/transaction_model.dart';
import 'package:budgetbuddy_project/services/balance_service.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';
import 'package:budgetbuddy_project/services/transaction_services.dart';
import 'package:budgetbuddy_project/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class DeductPage extends StatefulWidget {
  const DeductPage({super.key, required this.onConfirm});
  final Function(double) onConfirm;

  @override
  State<DeductPage> createState() => _DeductPageState();
}

class _DeductPageState extends State<DeductPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();

  final BalanceService _balanceService = locator<BalanceService>();
  final TransactionServices _transactionServices =
      locator<TransactionServices>();
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();

  double _currentBalance = 0;
  String? _selectedCategory;
  String? _balanceAfter;
  bool _showCategories = false;
  bool _showAddCategory = false;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    _currentBalance = await _balanceService.getBalance();
    final categories = _localStorageService.getCategories();
    if (categories != null) {
      setState(() => _categories = categories);
    }
  }

  Future<void> _saveCategories() async {
    await _localStorageService.setString('categories', jsonEncode(_categories));
  }

  void _addNewCategory() {
    if (_newCategoryController.text.isNotEmpty) {
      setState(() {
        _categories.add(_newCategoryController.text);
        _selectedCategory = _newCategoryController.text;
        _showAddCategory = false;
        _newCategoryController.clear();
      });
      _saveCategories();
    }
  }

  void _updateBalance() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _balanceAfter =
          'Balance after: ₱${(_currentBalance - amount).toStringAsFixed(2)}';
    });
  }

  Future<void> _confirmDeduction() async {
    final amount = double.tryParse(_amountController.text);

    // Validation
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    if (amount > _currentBalance) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Insufficient balance')));
      return;
    }

    // Create transaction
    final transaction = TransactionModel(
      amount: -amount, // Negative for outflow
      description:
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : 'Expense: $_selectedCategory',
      category: _selectedCategory!,
      date: DateTime.now(),
    );

    // Save transaction and update balance
    await _transactionServices.addTransaction(transaction);
    await _balanceService.deductBalance(amount);

    // Notify parent and close
    widget.onConfirm(-amount);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar Row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Deduct',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // Main Card
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Amount Input
                        Text(
                          'Enter Amount',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '₱',
                                style: GoogleFonts.inter(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _amountController,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0.00',
                                    hintStyle: GoogleFonts.inter(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey[400],
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  onChanged: (value) => _updateBalance(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Balance After
                        if (_balanceAfter != null)
                          Text(
                            _balanceAfter!,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.red[700],
                            ),
                          ),
                        const SizedBox(height: 32),

                        // Category Selection
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Select Category',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _showCategories = !_showCategories;
                              _showAddCategory = false;
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
                                _selectedCategory ?? 'Select Category',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color:
                                      _selectedCategory != null
                                          ? Colors.black
                                          : Colors.grey,
                                ),
                              ),
                              Icon(
                                _showCategories
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                              ),
                            ],
                          ),
                        ),
                        if (_showCategories)
                          Column(
                            children: [
                              ..._categories.map((category) {
                                return ListTile(
                                  title: Text(category),
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = category;
                                      _showCategories = false;
                                    });
                                  },
                                );
                              }),
                              ListTile(
                                title: Row(
                                  children: [
                                    const Icon(Icons.add, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Add New Category',
                                      style: GoogleFonts.inter(),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    _showCategories = false;
                                    _showAddCategory = true;
                                  });
                                },
                              ),
                            ],
                          ),
                        if (_showAddCategory)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _newCategoryController,
                                  decoration: InputDecoration(
                                    labelText: 'New Category Name',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _showAddCategory = false;
                                          });
                                        },
                                        child: Text('Cancel'),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _addNewCategory,
                                        child: Text('Add'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 32),

                        // Description Input
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description (optional)',
                            labelStyle: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                            alignLabelWithHint: true,
                            filled: true,
                            fillColor: const Color(0xFFF6F6F6),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 16,
                            ),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 5,
                          minLines: 3,
                        ),
                        const SizedBox(height: 32),

                        // Confirm Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _confirmDeduction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Confirm',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
