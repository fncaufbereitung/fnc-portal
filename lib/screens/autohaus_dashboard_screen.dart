import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../models/autohaus_company.dart';
import '../services/appointment_service.dart';
import '../services/autohaus_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'new_appointment_screen.dart';

class AutohausDashboardScreen extends StatefulWidget {
  const AutohausDashboardScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  State<AutohausDashboardScreen> createState() =>
      _AutohausDashboardScreenState();
}

class _AutohausDashboardScreenState extends State<AutohausDashboardScreen> {
  final _appointments = AppointmentService();
  final _autohaeuser = AutohausService();
  final _companyController = TextEditingController();
  AutohausCompany? _selectedCompany;
  bool _savingCompany = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _companyController.dispose();
    super.dispose();
  }

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
                'AUTOHAUS',
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
      actions: [
        IconButton(
          tooltip: 'Rolle wechseln',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.swap_horiz_rounded),
        ),
        const SizedBox(width: 16),
      ],
    ),
    body: StreamBuilder<List<Appointment>>(
      stream: _appointments.watchForSession(widget.sessionId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Anfragen konnten nicht geladen werden.\n${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: FncColors.gold),
          );
        }
        final requests = snapshot.data!;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
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
                          'Terminanfragen',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedCompany == null
                              ? 'Wählen Sie ein Autohaus oder legen Sie einen neuen Eintrag an.'
                              : 'Anfragen von ${_selectedCompany!.name} in dieser Sitzung.',
                          style: const TextStyle(color: FncColors.muted),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _selectedCompany == null
                          ? null
                          : _openNewRequest,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Termin anfragen'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _companySelectionCard(),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Text(
                      'Eigene Anfragen',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Spacer(),
                    Text(
                      '${requests.length} Einträge',
                      style: const TextStyle(color: FncColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (requests.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(42),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.event_note_outlined,
                            size: 44,
                            color: FncColors.gold,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Noch keine Anfragen',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ihre in dieser Sitzung erstellten Terminanfragen erscheinen hier.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: FncColors.muted),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...requests.map((item) => AppointmentCard(item: item)),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.swap_horiz_rounded),
                    label: const Text('Rolle wechseln'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _companySelectionCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Autohaus auswählen',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text(
            'Gespeicherte Unternehmen stehen bei jedem neuen Besuch wieder zur Verfügung.',
            style: TextStyle(color: FncColors.muted),
          ),
          const SizedBox(height: 20),
          StreamBuilder<List<AutohausCompany>>(
            stream: _autohaeuser.watchCompanies(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _FirestoreError(message: snapshot.error.toString());
              }
              if (!snapshot.hasData) {
                return const LinearProgressIndicator(color: FncColors.gold);
              }
              final companies = snapshot.data!;
              if (companies.isEmpty) {
                return const Text(
                  'Noch keine Autohaus-Unternehmen gespeichert.',
                  style: TextStyle(color: FncColors.muted),
                );
              }
              return DropdownButtonFormField<String>(
                initialValue:
                    companies.any(
                      (company) => company.id == _selectedCompany?.id,
                    )
                    ? _selectedCompany?.id
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Gespeichertes Autohaus',
                  prefixIcon: Icon(Icons.apartment_rounded),
                ),
                items: companies
                    .map(
                      (company) => DropdownMenuItem(
                        value: company.id,
                        child: Text(company.name),
                      ),
                    )
                    .toList(),
                onChanged: (id) {
                  if (id == null) return;
                  final company = companies.firstWhere((item) => item.id == id);
                  _selectCompany(company);
                },
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'ODER NEU ANLEGEN',
                    style: TextStyle(
                      color: FncColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
          ),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 420,
                child: TextField(
                  controller: _companyController,
                  decoration: const InputDecoration(
                    labelText: 'Name des Autohauses',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                  onSubmitted: (_) => _saveCompany(),
                ),
              ),
              ElevatedButton(
                onPressed: _savingCompany ? null : _saveCompany,
                child: Text(
                  _savingCompany ? 'Wird gespeichert …' : 'Autohaus übernehmen',
                ),
              ),
            ],
          ),
          if (_selectedCompany != null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FncColors.gold.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: FncColors.line),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: FncColors.gold),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ausgewählt: ${_selectedCompany!.name}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );

  Future<void> _selectCompany(AutohausCompany company) async {
    setState(() => _selectedCompany = company);
    try {
      await _autohaeuser.markUsed(company);
    } catch (error) {
      if (mounted) {
        _showError('Nutzung konnte nicht gespeichert werden: $error');
      }
    }
  }

  Future<void> _saveCompany() async {
    final name = _companyController.text.trim();
    if (name.isEmpty) {
      _showError('Bitte den Namen des Autohauses eingeben.');
      return;
    }

    setState(() => _savingCompany = true);
    try {
      final company = await _autohaeuser.saveOrUse(name);
      if (!mounted) return;
      setState(() {
        _selectedCompany = company;
        _companyController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${company.name} wurde übernommen.')),
      );
    } catch (error) {
      if (mounted) {
        _showError('Autohaus konnte nicht gespeichert werden: $error');
      }
    } finally {
      if (mounted) setState(() => _savingCompany = false);
    }
  }

  Future<void> _openNewRequest() async {
    final company = _selectedCompany;
    if (company == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewAppointmentScreen(
          ownerId: widget.sessionId,
          title: 'Neue Terminanfrage',
          fixedCompanyName: company.name,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _FirestoreError extends StatelessWidget {
  const _FirestoreError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.red.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.red.withValues(alpha: .2)),
    ),
    child: Text(
      'Gespeicherte Autohaus-Unternehmen konnten nicht geladen werden.\n'
      '$message',
      style: const TextStyle(color: Colors.redAccent),
    ),
  );
}
