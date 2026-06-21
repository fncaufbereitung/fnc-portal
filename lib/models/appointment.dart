import 'package:cloud_firestore/cloud_firestore.dart';

const appointmentStatuses = [
  'Angefragt',
  'Bestätigt',
  'In Arbeit',
  'Fertig',
  'Abgeholt',
  'Abgerechnet',
];

const appointmentTypes = [
  'Auslieferung',
  'Aufbereitung',
  'Smart Repair',
  'Sonstiges',
];

const serviceTypes = [
  'Innenreinigung',
  'Komplettaufbereitung',
  'Lackpolitur',
  'Scheinwerferaufbereitung',
  'Ozonbehandlung',
  'Sonstiges',
];

class Appointment {
  const Appointment({
    required this.id,
    required this.autohausId,
    required this.companyName,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.licensePlate,
    required this.appointmentType,
    required this.serviceType,
    required this.desiredAt,
    required this.notes,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String autohausId;
  final String companyName;
  final String vehicleMake;
  final String vehicleModel;
  final String licensePlate;
  final String appointmentType;
  final String serviceType;
  final DateTime desiredAt;
  final String notes;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Appointment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    DateTime? timestamp(String key) => (data[key] as Timestamp?)?.toDate();
    return Appointment(
      id: doc.id,
      autohausId: data['autohausId'] as String? ?? '',
      companyName: data['companyName'] as String? ?? '',
      vehicleMake: data['vehicleMake'] as String? ?? '',
      vehicleModel: data['vehicleModel'] as String? ?? '',
      licensePlate: data['licensePlate'] as String? ?? '',
      appointmentType: data['appointmentType'] as String? ?? 'Aufbereitung',
      serviceType: data['serviceType'] as String? ?? 'Komplettaufbereitung',
      desiredAt: timestamp('desiredAt') ?? DateTime.now(),
      notes: data['notes'] as String? ?? '',
      status: data['status'] as String? ?? 'Angefragt',
      createdAt: timestamp('createdAt'),
      updatedAt: timestamp('updatedAt'),
    );
  }
}

List<Appointment> sortAppointments(Iterable<Appointment> appointments) {
  final result = List<Appointment>.of(appointments);
  result.sort((a, b) => a.desiredAt.compareTo(b.desiredAt));
  return result;
}

DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime startOfWeek(DateTime date) {
  final day = startOfDay(date);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool isInWeek(DateTime value, DateTime reference) {
  final start = startOfWeek(reference);
  final end = start.add(const Duration(days: 7));
  return !value.isBefore(start) && value.isBefore(end);
}
