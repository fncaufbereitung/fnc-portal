import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/appointment.dart';

class AppointmentService {
  AppointmentService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('appointments');

  Stream<List<Appointment>> watchAll() => _collection
      .orderBy('desiredAt')
      .snapshots()
      .map((snapshot) => snapshot.docs.map(Appointment.fromDoc).toList());

  Stream<List<Appointment>> watchForSession(String sessionId) => _collection
      .where('autohausId', isEqualTo: sessionId)
      .orderBy('desiredAt')
      .snapshots()
      .map((snapshot) => snapshot.docs.map(Appointment.fromDoc).toList());

  Future<void> create({
    required String ownerId,
    required String companyName,
    required String make,
    required String model,
    required String plate,
    required String appointmentType,
    required String serviceType,
    required DateTime desiredAt,
    required String notes,
  }) async {
    final ref = _collection.doc();
    await ref.set({
      'id': ref.id,
      'autohausId': ownerId,
      'companyName': companyName,
      'vehicleMake': make,
      'vehicleModel': model,
      'licensePlate': plate.toUpperCase(),
      'appointmentType': appointmentType,
      'serviceType': serviceType,
      'desiredAt': Timestamp.fromDate(desiredAt),
      'notes': notes,
      'status': 'Angefragt',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus(String id, String status) => _collection
      .doc(id)
      .update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});

  Future<void> delete(String id) => _collection.doc(id).delete();
}
