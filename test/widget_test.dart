import 'package:flutter_test/flutter_test.dart';
import 'package:fnc_portal/models/appointment.dart';
import 'package:fnc_portal/services/autohaus_service.dart';

void main() {
  test('Autohaus names use a stable duplicate-safe Firestore identity', () {
    expect(normalizeAutohausName('  Autohaus   Müller  '), 'autohaus müller');
    expect(
      autohausDocumentId('Autohaus Müller'),
      autohausDocumentId('  AUTOHAUS   MÜLLER '),
    );
    expect(
      autohausDocumentId('Autohaus Müller'),
      isNot(autohausDocumentId('Autohaus Meier')),
    );
  });

  test('appointments sort by desired date and time', () {
    final later = _appointment('later', DateTime(2026, 7, 1, 14, 30));
    final earlier = _appointment('earlier', DateTime(2026, 7, 1, 8, 15));

    final sorted = sortAppointments([later, earlier]);

    expect(sorted.map((item) => item.id), ['earlier', 'later']);
  });

  test('weekly grouping uses Monday through Sunday', () {
    final reference = DateTime(2026, 6, 24);
    expect(startOfWeek(reference), DateTime(2026, 6, 22));
    expect(isInWeek(DateTime(2026, 6, 22, 8), reference), isTrue);
    expect(isInWeek(DateTime(2026, 6, 28, 18), reference), isTrue);
    expect(isInWeek(DateTime(2026, 6, 29), reference), isFalse);
  });
}

Appointment _appointment(String id, DateTime desiredAt) => Appointment(
  id: id,
  autohausId: 'session',
  companyName: 'Test Autohaus',
  vehicleMake: 'Volkswagen',
  vehicleModel: 'Passat',
  licensePlate: 'K-TEST 1',
  appointmentType: 'Aufbereitung',
  serviceType: 'Komplettaufbereitung',
  desiredAt: desiredAt,
  notes: '',
  status: 'Angefragt',
);
