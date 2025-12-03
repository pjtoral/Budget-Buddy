import 'dart:convert';

import 'package:budgetbuddy_project/models/transaction_model.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final _securestorage = const FlutterSecureStorage();
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setLoggedIn(bool value) => setBool('is_logged_in', value);
  Future<bool> isLoggedIn() => getBool('is_logged_in');

  Future<void> setString(String key, String value) async =>
      _prefs?.setString(key, value);
  Future<void> setBool(String key, bool value) async =>
      _prefs?.setBool(key, value);
  Future<void> setInt(String key, int value) async =>
      _prefs?.setInt(key, value);
  Future<void> setDouble(String key, double value) async =>
      _prefs?.setDouble(key, value);
  Future<void> setStringList(String key, List<String> value) async =>
      _prefs?.setStringList(key, value);

  String? getString(String key) => _prefs?.getString(key);
  int? getInt(String key) => _prefs?.getInt(key);
  double? getDouble(String key) => _prefs?.getDouble(key);
  List<String>? getStringList(String key) => _prefs?.getStringList(key);
  
  Future<bool> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  Future<void> remove(String key) async => _prefs?.remove(key);

  Future<void> clear() async => _prefs?.clear();

  // Added function to save transaction list
  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final jsonList = transactions.map((t) => t.toJson()).toList();
    await _prefs?.setString('transactions', jsonEncode(jsonList));
  }

  // Synchronous version - can be called without await
  List<TransactionModel>? getTransactions() {
    final jsonString = _prefs?.getString('transactions');
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => TransactionModel.fromJson(json)).toList();
    }
    return null;
  }

  // Async version if you need to ensure _prefs is initialized
  Future<List<TransactionModel>?> getTransactionsAsync() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonString = prefs.getString('transactions');
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => TransactionModel.fromJson(json)).toList();
    }
    return null;
  }

  // Fixed: Made synchronous to avoid Future arithmetic operations
  double getBalanceSync() {
    return _prefs?.getDouble('balance') ?? 0.0;
  }

  // Keep async version for cases where _prefs might not be initialized
  Future<double> getBalance() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getDouble('balance') ?? 0.0;
  }

  Future<void> setBalance(double value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setDouble('balance', value);
  }

  Future<void> _saveCategories(List<String> categories) async {
    await _prefs?.setString('categories', jsonEncode(categories));
  }

  List<String>? getCategories() {
    final jsonString = _prefs?.getString('categories');
    if (jsonString != null) {
      return List<String>.from(jsonDecode(jsonString));
    }
    return null;
  }

  //hashing saved passwords when logged in once online
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  //Saves usercredentials when logged in once online
  Future<void> saveUserCredentials(String email, String password, String username) async {
    final hashedpassword = hashPassword(password);
    final trimmedEmail = email.trim();
    await _securestorage.write(key: 'username', value: username);
    await _securestorage.write(key: 'email', value: trimmedEmail);
    await _securestorage.write(key: 'password_hash', value: hashedpassword);
    
    print('DEBUG: Saving credentials:');
    print('  Email: "$email" (trimmed: "$trimmedEmail")');
    print('  Username: "$username"');
    print('  Password Hash: "$hashedpassword"');
  }

  //To verify credentials offline
  Future<bool> verifyOfflineLogin(String email, String password) async {
    final storedEmail = await _securestorage.read(key: 'email');
    final storedHash = await _securestorage.read(key: 'password_hash');

    if(storedEmail == null || storedHash == null) {
      print('DEBUG: Stored email is null: ${storedEmail == null}, Stored hash is null: ${storedHash == null}');
      return false;
    }

    final trimmedInput = email.trim();
    final inputHash = hashPassword(password);
    final emailMatch = storedEmail == trimmedInput;
    final passwordMatch = storedHash == inputHash;
    
    print('DEBUG Login verification:');
    print('  Stored Email: "$storedEmail" vs Input: "$email" (trimmed: "$trimmedInput") => Match: $emailMatch');
    print('  Stored Hash: "$storedHash"');
    print('  Input Hash: "$inputHash"');
    print('  Password Match: $passwordMatch');
    
    return emailMatch && passwordMatch;
  }
  
  // Helper method to get stored credentials (for debugging)
  Future<Map<String, String?>> getStoredCredentials() async {
    return {
      'email': await _securestorage.read(key: 'email'),
      'username': await _securestorage.read(key: 'username'),
      'password_hash': await _securestorage.read(key: 'password_hash'),
    };
  }

 
  Future<void> clearAll() async => _prefs?.clear();
}