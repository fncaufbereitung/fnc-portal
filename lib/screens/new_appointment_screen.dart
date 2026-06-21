import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../theme.dart';

class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({
    super.key,
    required this.ownerId,
    required this.title,
    this.fixedCompanyName,
  });

  final String ownerId;
  final String title;
  final String? fixedCompanyName;

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  final _key = GlobalKey<FormState>();
  final _company = TextEditingController();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _plate = TextEditingController();
  final _notes = TextEditingController();
  final _appointments = AppointmentService();
  DateTime? _date;
  TimeOfDay? _time;
  String _appointmentType = appointmentTypes.first;
  String _serviceType = serviceTypes.first;
  bool _saving = false;

  Future<void> _save() async {
    if (!_key.currentState!.validate() || _date == null || _time == null) {
      final missing = [
        if (_date == null) 'Wunschdatum',
        if (_time == null) 'Wunschzeit',
      ].join(' und ');
      if (missing.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Bitte $missing auswählen.')));
      }
      return;
    }

    setState(() => _saving = true);
    try {
      final desiredAt = DateTime(
        _date!.year,
        _date!.month,
        _date!.day,
        _time!.hour,
        _time!.minute,
      );
      await _appointments.create(
        ownerId: widget.ownerId,
        companyName: widget.fixedCompanyName ?? _company.text.trim(),
        make: _make.text.trim(),
        model: _model.text.trim(),
        plate: _plate.text.trim(),
        appointmentType: _appointmentType,
        serviceType: _serviceType,
        desiredAt: desiredAt,
        notes: _notes.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Termin konnte nicht gespeichert werden: $error'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _company.dispose();
    _make.dispose();
    _model.dispose();
    _plate.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
      backgroundColor: FncColors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Termin erfassen',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Fahrzeug, Terminart, Leistung sowie Wunschdatum und Wunschzeit eintragen.',
                      style: TextStyle(color: FncColors.muted),
                    ),
                    const SizedBox(height: 28),
                    if (widget.fixedCompanyName == null) ...[
                      TextFormField(
                        controller: _company,
                        decoration: const InputDecoration(
                          labelText: 'Autohaus / Kunde',
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      _SelectedCompany(name: widget.fixedCompanyName!),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _make,
                            decoration: const InputDecoration(
                              labelText: 'Marke',
                            ),
                            validator: _required,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextFormField(
                            controller: _model,
                            decoration: const InputDecoration(
                              labelText: 'Modell',
                            ),
                            validator: _required,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _plate,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Kennzeichen',
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _appointmentType,
                      decoration: const InputDecoration(labelText: 'Terminart'),
                      items: appointmentTypes
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _appointmentType = value!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _serviceType,
                      decoration: const InputDecoration(labelText: 'Leistung'),
                      items: serviceTypes
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _serviceType = value!),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_month_outlined),
                            label: Text(
                              _date == null
                                  ? 'Wunschdatum'
                                  : '${_date!.day.toString().padLeft(2, '0')}.${_date!.month.toString().padLeft(2, '0')}.${_date!.year}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickTime,
                            icon: const Icon(Icons.schedule_outlined),
                            label: Text(
                              _time == null
                                  ? 'Wunschzeit'
                                  : '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')} Uhr',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notes,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Hinweise (optional)',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: const Icon(Icons.add_task_rounded),
                      label: Text(
                        _saving ? 'Wird gespeichert …' : 'Termin anlegen',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null) setState(() => _date = selected);
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (selected != null) setState(() => _time = selected);
  }

  String? _required(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Pflichtfeld' : null;
}

class _SelectedCompany extends StatelessWidget {
  const _SelectedCompany({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: FncColors.gold.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: FncColors.line),
    ),
    child: Row(
      children: [
        const Icon(Icons.business_outlined, color: FncColors.gold),
        const SizedBox(width: 12),
        Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}
