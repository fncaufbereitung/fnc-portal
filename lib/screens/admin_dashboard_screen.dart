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
  final _appointments = AppointmentService();
  String _filter = 'Alle';
  String _search = '';
  bool _weeklyView = false;

  @override
  Widget build(BuildContext context) => Scaffold(
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
        SizedBox(width: 12),
      ],
    ),
    body: StreamBuilder<List<Appointment>>(
      stream: _appointments.watchAll(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ErrorState(error: snapshot.error);
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: FncColors.gold),
          );
        }
        return _dashboard(snapshot.data!);
      },
    ),
  );

  Widget _dashboard(List<Appointment> all) {
    final now = DateTime.now();
    final today = all.where((item) => isSameDay(item.desiredAt, now)).toList();
    final thisWeek = all
        .where((item) => isInWeek(item.desiredAt, now))
        .toList();
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1380),
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
                      'Fahrzeuge, Kapazitäten und Auftragsstatus im Überblick.',
                      style: TextStyle(color: FncColors.muted),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.swap_horiz_rounded),
                      label: const Text('Rolle wechseln'),
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
              ],
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Metric(
                  label: 'Heute',
                  value: today.length,
                  icon: Icons.today_outlined,
                ),
                _Metric(
                  label: 'Diese Woche',
                  value: thisWeek.length,
                  icon: Icons.date_range_outlined,
                ),
                _Metric(
                  label: 'Offene Anfragen',
                  value: all.where((item) => item.status == 'Angefragt').length,
                  icon: Icons.mark_email_unread_outlined,
                ),
                _Metric(
                  label: 'In Arbeit',
                  value: all.where((item) => item.status == 'In Arbeit').length,
                  icon: Icons.handyman_outlined,
                ),
                _Metric(
                  label: 'Fertig',
                  value: all.where((item) => item.status == 'Fertig').length,
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Heutige Fahrzeuge',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 14),
            if (today.isEmpty)
              const _EmptyCard(
                text: 'Für heute sind keine Fahrzeuge eingeplant.',
              )
            else
              _TodayVehicles(items: today),
            const SizedBox(height: 30),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 350,
                      child: TextField(
                        onChanged: (value) => setState(() => _search = value),
                        decoration: const InputDecoration(
                          labelText: 'Autohaus, Fahrzeug oder Kennzeichen',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 210,
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
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.view_list_outlined),
                          label: Text('Liste'),
                        ),
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.calendar_view_week_outlined),
                          label: Text('Wochenansicht'),
                        ),
                      ],
                      selected: {_weeklyView},
                      onSelectionChanged: (selection) =>
                          setState(() => _weeklyView = selection.first),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  _weeklyView ? 'Wochenansicht' : 'Alle Termine',
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
              const _EmptyCard(text: 'Keine passenden Termine.')
            else if (_weeklyView)
              _WeekView(
                appointments: visible,
                onStatus: _appointments.updateStatus,
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
    if (confirmed == true) await _appointments.delete(item.id);
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 205,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: FncColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: FncColors.line),
    ),
    child: Row(
      children: [
        Icon(icon, color: FncColors.gold, size: 26),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            Text(
              label,
              style: const TextStyle(color: FncColors.muted, fontSize: 13),
            ),
          ],
        ),
      ],
    ),
  );
}

class _TodayVehicles extends StatelessWidget {
  const _TodayVehicles({required this.items});
  final List<Appointment> items;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: items
            .map(
              (item) => Container(
                width: 280,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: FncColors.ivory,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: FncColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      germanTime(item.desiredAt),
                      style: const TextStyle(
                        color: FncColors.gold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.vehicleMake} ${item.vehicleModel}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      item.companyName,
                      style: const TextStyle(color: FncColors.muted),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${item.serviceType} · ${item.status}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    ),
  );
}

class _WeekView extends StatelessWidget {
  const _WeekView({required this.appointments, required this.onStatus});
  final List<Appointment> appointments;
  final Future<void> Function(String id, String status) onStatus;

  @override
  Widget build(BuildContext context) {
    final weekStart = startOfWeek(DateTime.now());
    final weekAppointments = appointments
        .where((item) => isInWeek(item.desiredAt, weekStart))
        .toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 1100
            ? (constraints.maxWidth - 72) / 5
            : constraints.maxWidth >= 700
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(7, (index) {
            final day = weekStart.add(Duration(days: index));
            final dayItems = weekAppointments
                .where((item) => isSameDay(item.desiredAt, day))
                .toList();
            return SizedBox(
              width: cardWidth,
              child: _DayColumn(
                date: day,
                appointments: dayItems,
                onStatus: onStatus,
              ),
            );
          }),
        );
      },
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.date,
    required this.appointments,
    required this.onStatus,
  });
  final DateTime date;
  final List<Appointment> appointments;
  final Future<void> Function(String id, String status) onStatus;

  static const weekdays = [
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
    'Samstag',
    'Sonntag',
  ];

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            weekdays[date.weekday - 1],
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          Text(
            germanDate(date),
            style: const TextStyle(color: FncColors.muted, fontSize: 12),
          ),
          const Divider(height: 24),
          if (appointments.isEmpty)
            const Text(
              'Keine Termine',
              style: TextStyle(color: FncColors.muted, fontSize: 12),
            )
          else
            ...appointments.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: FncColors.ivory,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: FncColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        germanTime(item.desiredAt),
                        style: const TextStyle(
                          color: FncColors.gold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${item.vehicleMake} ${item.vehicleModel}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        item.companyName,
                        style: const TextStyle(
                          color: FncColors.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.serviceType,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: item.status,
                        isDense: true,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                        ),
                        items: appointmentStatuses
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                        onChanged: (status) {
                          if (status != null) onStatus(item.id, status);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(34),
      child: Center(
        child: Text(text, style: const TextStyle(color: FncColors.muted)),
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});
  final Object? error;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Text(
        'Termine konnten nicht geladen werden.\n$error',
        textAlign: TextAlign.center,
      ),
    ),
  );
}
