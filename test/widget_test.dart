import 'package:flutter_test/flutter_test.dart';
import 'package:fnc_portal/services/appointment_service.dart';
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

  test('Autohaus requests are isolated by local session', () {
    final service = AppointmentService.instance;
    const sessionA = 'test-session-a';
    const sessionB = 'test-session-b';

    service.create(
      ownerId: sessionA,
      companyName: 'Test Autohaus A',
      make: 'Volkswagen',
      model: 'Passat',
      plate: 'k test 1',
      serviceType: 'Komplettaufbereitung',
      desiredDate: DateTime(2026, 7, 1),
      notes: 'Testtermin',
    );

    final request = service.appointmentsForSession(sessionA).single;
    expect(request.status, 'Angefragt');
    expect(request.licensePlate, 'K TEST 1');
    expect(service.appointmentsForSession(sessionB), isEmpty);

    service.updateStatus(request.id, 'Bestätigt');
    expect(service.appointmentsForSession(sessionA).single.status, 'Bestätigt');

    service.delete(request.id);
    expect(service.appointmentsForSession(sessionA), isEmpty);
  });
}
