import 'package:budgetbuddy_project/models/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
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
  //  Future<void> setTransactionList(String key, List<TransactionModel> value) async =>
  //     _prefs?.setString(key,jsonEncode(value.map((e) => e.toJson()).toList()));

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
}