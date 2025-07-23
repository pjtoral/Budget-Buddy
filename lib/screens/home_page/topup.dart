import 'package:budgetbuddy_project/models/transaction_model.dart';
import 'package:budgetbuddy_project/services/balance_service.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';
import 'package:budgetbuddy_project/services/transaction_services.dart';
import 'package:budgetbuddy_project/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key, required this.onConfirm});
  final Function onConfirm;
  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();
  
  final BalanceService _balanceService = locator<BalanceService>();
  final TransactionServices _transactionServices = locator<TransactionServices>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();


  String? _balanceAfter;
  String? _selectedCategory;
  bool _showCategories = false;
  bool _showAddCategory = false;
  List<String> _categories = ['School', 'Motorcycle', 'Computer', 'Shabu'];
  double _currentBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }


  Future<void> _loadInitialData() async {
    _currentBalance = await _balanceService.getBalance();
    final categories = locator<LocalStorageService>().getCategories();
    if (categories != null) {
      setState(() => _categories = categories);  
    }
  }

  Future<void> _updateBalance() async {
    final amount = double.tryParse(_amountController.text);
    if(amount != null) {
      setState(() {
        _balanceAfter = 'Balance after: ₱${(_currentBalance + amount).toStringAsFixed(2)}';
      });
    } else {
      setState(() {
        _balanceAfter = null;
      });
    }
  }

  Future<void> _confirmTopUp() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final transaction = TransactionModel(
      amount: amount,
      description: 'Top Up',
      category: _selectedCategory!,
      date: DateTime.now(),
    );

    await _transactionServices.addTransaction(transaction);
    await _balanceService.updateBalance(amount);
    
    widget.onConfirm();
    Navigator.of(context).pop();
  }


  Future<void> _saveCategories() async {
    await locator<LocalStorageService>().setString(
      'categories', 
      jsonEncode(_categories)
    );
  }

  void _addNewCategory() {
    if(_newCategoryController.text.isNotEmpty) {
      setState(() {
        _categories.add(_newCategoryController.text);
        _selectedCategory = _newCategoryController.text;
        _showAddCategory = false;
        _newCategoryController.clear();
      });
      _saveCategories();
    }
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
                        'Top Up',
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
                        TextFormField(
                          controller: _amountController,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            prefixText: '₱ ',
                            prefixStyle: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            hintText: '0.00',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[400],
                            ),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.zero,
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (value) => _updateBalance(),
                        ),
                        const SizedBox(height: 8),
                        // Balance After
                        if (_balanceAfter != null)
                          Text(
                            _balanceAfter!,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.green[700],
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
                                  color: _selectedCategory != null
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

                        // Confirm Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _confirmTopUp,
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