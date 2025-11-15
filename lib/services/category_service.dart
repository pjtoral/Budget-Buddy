import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'local_storage_service.dart';
import 'service_locator.dart';

class CategoryService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw Exception('Not authenticated');
    return u.uid;
  }

  CollectionReference<Map<String, dynamic>> get _catCol =>
      _db.collection('users').doc(_uid).collection('categories');

  Future<List<String>> getCategoryNames() async {
    final qs = await _catCol.orderBy('name').get();
    return qs.docs.map((d) => (d.data()['name'] as String)).toList();
  }

  Future<void> addCategory(String name, {String type = 'expense'}) async {
    final id = _catCol.doc().id;
    await _catCol.doc(id).set({
      'name': name,
      'type': type, // 'income' or 'expense'
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Hydrate LocalStorage so UI that reads from LocalStorageService continues to work unchanged.
  Future<void> syncCategoriesToLocal() async {
    final list = await getCategoryNames();
    await locator<LocalStorageService>().setString(
      'categories',
      jsonEncode(list),
    );
  }
}
