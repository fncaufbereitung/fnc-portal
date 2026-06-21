import 'package:cloud_firestore/cloud_firestore.dart';

class AutohausCompany {
  const AutohausCompany({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.lastUsedAt,
  });

  final String id;
  final String name;
  final DateTime? createdAt;
  final DateTime? lastUsedAt;

  factory AutohausCompany.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return AutohausCompany(
      id: doc.id,
      name: data['name'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastUsedAt: (data['lastUsedAt'] as Timestamp?)?.toDate(),
    );
  }
}
