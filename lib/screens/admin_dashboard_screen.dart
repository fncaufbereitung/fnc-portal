import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'new_appointment_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _appointments = AppointmentService.instance;
  String _filter = 'Alle';
  String _search = '';

  @override
  void initState() {
    super.initState();
    _appointments.addListener(_refresh);
  }

  @override
  void dispose() {
    _appointments.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final all = _appointments.appointments;
    final visible = all.where((item) {
      final query = _search.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          item.companyName.toLowerCase().contains(query) ||
          item.vehicleMake.toLowerCase().contains(query) ||
          item.vehicleModel.toLowerCase().contains(query) ||
          item.licensePlate.toLowerCase().contains(query);
      return matchesSearch && (_filter == 'Alle' || item.status == _filter);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        backgroundColor: FncColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FncMark(size: 42),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FNC PORTAL',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                Text(
                  'TERMINSTEUERUNG',
                  style: TextStyle(
                    fontSize: 9,
                    color: FncColors.muted,
                    letterSpacing: 1.3,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: const [
          Chip(
            avatar: Icon(Icons.admin_panel_settings_outlined, size: 18),
            label: Text('FNC Admin'),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 34, 24, 60),
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                runSpacing: 20,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terminsteuerung',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Fahrzeugtermine zentral planen und bearbeiten.',
                        style: TextStyle(color: FncColors.muted),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NewAppointmentScreen(
                          ownerId: 'fnc-admin',
                          title: 'Neuer Termin',
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Neuer Termin'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.swap_horiz_rounded),
                  label: const Text('Rolle wechseln'),
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _Metric(
                    label: 'Termine gesamt',
                    value: all.length,
                    icon: Icons.calendar_month_outlined,
                  ),
                  _Metric(
                    label: 'Offene Anfragen',
                    value: all
                        .where((item) => item.status == 'Angefragt')
                        .length,
                    icon: Icons.mark_email_unread_outlined,
                  ),
                  _Metric(
                    label: 'In Arbeit',
                    value: all
                        .where((item) => item.status == 'In Arbeit')
                        .length,
                    icon: Icons.handyman_outlined,
                  ),
                  _Metric(
                    label: 'Fertig',
                    value: all.where((item) => item.status == 'Fertig').length,
                    icon: Icons.check_circle_outline,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width: 360,
                        child: TextField(
                          onChanged: (value) => setState(() => _search = value),
                          decoration: const InputDecoration(
                            labelText: 'Autohaus, Fahrzeug oder Kennzeichen',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<String>(
                          initialValue: _filter,
                          decoration: const InputDecoration(
                            labelText: 'Status filtern',
                          ),
                          items: ['Alle', ...appointmentStatuses]
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _filter = value ?? 'Alle'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Termine',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  Text(
                    '${visible.length} Einträge',
                    style: const TextStyle(color: FncColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (visible.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text('Keine passenden Termine.')),
                  ),
                )
              else
                ...visible.map(
                  (item) => AppointmentCard(
                    item: item,
                    onStatus: (status) =>
                        _appointments.updateStatus(item.id, status),
                    onDelete: () => _confirmDelete(item),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Appointment item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Termin löschen?'),
        content: Text(
          '${item.vehicleMake} ${item.vehicleModel} (${item.licensePlate}) wird entfernt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed == true) _appointments.delete(item.id);
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 230,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: FncColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: FncColors.line),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: FncColors.gold.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: FncColors.gold),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            Text(label, style: const TextStyle(color: FncColors.muted)),
          ],
        ),
      ],
    ),
  );
}
