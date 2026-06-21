import 'package:flutter/material.dart';

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
  DateTime? _date;
  String _serviceType = 'Komplettaufbereitung';

  void _save() {
    if (!_key.currentState!.validate() || _date == null) {
      if (_date == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte einen Wunschtermin auswählen.')),
        );
      }
      return;
    }
    AppointmentService.instance.create(
      ownerId: widget.ownerId,
      companyName: widget.fixedCompanyName ?? _company.text.trim(),
      make: _make.text.trim(),
      model: _model.text.trim(),
      plate: _plate.text.trim(),
      serviceType: _serviceType,
      desiredDate: _date!,
      notes: _notes.text.trim(),
    );
    Navigator.pop(context);
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
                      'Fahrzeug, Leistung und gewünschten Bearbeitungstermin eintragen.',
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: FncColors.gold.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: FncColors.line),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.business_outlined,
                              color: FncColors.gold,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.fixedCompanyName!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      initialValue: _serviceType,
                      decoration: const InputDecoration(labelText: 'Leistung'),
                      items:
                          const [
                                'Komplettaufbereitung',
                                'Innenraumaufbereitung',
                                'Außenaufbereitung',
                                'Verkaufsaufbereitung',
                                'Leasingrückläufer',
                                'Sonderleistung',
                              ]
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
                    OutlinedButton.icon(
                      onPressed: () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 1),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (selected != null) {
                          setState(() => _date = selected);
                        }
                      },
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(
                        _date == null
                            ? 'Wunschtermin auswählen'
                            : '${_date!.day.toString().padLeft(2, '0')}.${_date!.month.toString().padLeft(2, '0')}.${_date!.year}',
                      ),
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
                      onPressed: _save,
                      icon: const Icon(Icons.add_task_rounded),
                      label: const Text('Termin anlegen'),
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

  String? _required(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Pflichtfeld' : null;
}
