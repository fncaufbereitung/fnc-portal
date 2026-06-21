const appointmentStatuses = [
  'Angefragt',
  'Bestätigt',
  'In Arbeit',
  'Fertig',
  'Abgeholt',
  'Abgerechnet',
];

class Appointment {
  const Appointment({
    required this.id,
    required this.autohausId,
    required this.companyName,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.licensePlate,
    required this.serviceType,
    required this.desiredDate,
    required this.notes,
    required this.status,
  });

  final String id;
  final String autohausId;
  final String companyName;
  final String vehicleMake;
  final String vehicleModel;
  final String licensePlate;
  final String serviceType;
  final DateTime desiredDate;
  final String notes;
  final String status;

  Appointment copyWith({String? status}) => Appointment(
    id: id,
    autohausId: autohausId,
    companyName: companyName,
    vehicleMake: vehicleMake,
    vehicleModel: vehicleModel,
    licensePlate: licensePlate,
    serviceType: serviceType,
    desiredDate: desiredDate,
    notes: notes,
    status: status ?? this.status,
  );
}
