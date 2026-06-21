import 'package:flutter/foundation.dart';

import '../models/appointment.dart';

class AppointmentService extends ChangeNotifier {
  AppointmentService._();

  static final AppointmentService instance = AppointmentService._();

  final List<Appointment> _appointments = [
    Appointment(
      id: 'fnc-1001',
      autohausId: 'demo-rheinblick',
      companyName: 'Autohaus Rheinblick',
      vehicleMake: 'Mercedes-Benz',
      vehicleModel: 'E-Klasse',
      licensePlate: 'K-FNC 241',
      serviceType: 'Komplettaufbereitung',
      desiredDate: DateTime.now().add(const Duration(days: 1)),
      notes: 'Verkaufsfahrzeug, bitte Innenraum besonders gründlich.',
      status: 'Bestätigt',
    ),
    Appointment(
      id: 'fnc-1002',
      autohausId: 'demo-nordstern',
      companyName: 'Nordstern Automobile',
      vehicleMake: 'BMW',
      vehicleModel: 'X5',
      licensePlate: 'D-NA 508',
      serviceType: 'Leasingrückläufer',
      desiredDate: DateTime.now().add(const Duration(days: 2)),
      notes: 'Kleine Kratzer an der Ladekante prüfen.',
      status: 'In Arbeit',
    ),
    Appointment(
      id: 'fnc-1003',
      autohausId: 'demo-direkt',
      companyName: 'FNC Direktkunde',
      vehicleMake: 'Audi',
      vehicleModel: 'A6 Avant',
      licensePlate: 'NE-FC 77',
      serviceType: 'Innenraumaufbereitung',
      desiredDate: DateTime.now().add(const Duration(days: 3)),
      notes: '',
      status: 'Angefragt',
    ),
  ];

  List<Appointment> get appointments => _sorted(_appointments);

  List<Appointment> appointmentsForSession(String sessionId) =>
      _sorted(_appointments.where((item) => item.autohausId == sessionId));

  List<Appointment> _sorted(Iterable<Appointment> source) {
    final result = List<Appointment>.of(source);
    result.sort((a, b) => a.desiredDate.compareTo(b.desiredDate));
    return List.unmodifiable(result);
  }

  void create({
    required String ownerId,
    required String companyName,
    required String make,
    required String model,
    required String plate,
    required String serviceType,
    required DateTime desiredDate,
    required String notes,
  }) {
    _appointments.add(
      Appointment(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        autohausId: ownerId,
        companyName: companyName,
        vehicleMake: make,
        vehicleModel: model,
        licensePlate: plate.toUpperCase(),
        serviceType: serviceType,
        desiredDate: desiredDate,
        notes: notes,
        status: 'Angefragt',
      ),
    );
    notifyListeners();
  }

  void updateStatus(String id, String status) {
    final index = _appointments.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _appointments[index] = _appointments[index].copyWith(status: status);
    notifyListeners();
  }

  void delete(String id) {
    _appointments.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
