import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/autohaus_company.dart';

String normalizeAutohausName(String value) =>
    value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

String autohausDocumentId(String name) {
  final normalized = normalizeAutohausName(name);
  return base64Url.encode(utf8.encode(normalized)).replaceAll('=', '');
}

class AutohausService {
  AutohausService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('autohaeuser');

  Stream<List<AutohausCompany>> watchCompanies() => _collection
      .orderBy('name')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(AutohausCompany.fromDoc)
            .where((company) => company.name.isNotEmpty)
            .toList(),
      );

  Future<AutohausCompany> saveOrUse(String rawName) async {
    final name = rawName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty) {
      throw ArgumentError.value(
        rawName,
        'rawName',
        'Name darf nicht leer sein',
      );
    }

    final ref = _collection.doc(autohausDocumentId(name));
    await _firestore.runTransaction((transaction) async {
      final existing = await transaction.get(ref);
      if (existing.exists) {
        transaction.update(ref, {'lastUsedAt': FieldValue.serverTimestamp()});
      } else {
        transaction.set(ref, {
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUsedAt': FieldValue.serverTimestamp(),
        });
      }
    });

    return AutohausCompany.fromDoc(await ref.get());
  }

  Future<void> markUsed(AutohausCompany company) => _collection
      .doc(company.id)
      .update({'lastUsedAt': FieldValue.serverTimestamp()});
}
