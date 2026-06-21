import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import 'admin_dashboard_screen.dart';
import 'autohaus_dashboard_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: FncColors.ink,
    body: LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        return Stack(
          fit: StackFit.expand,
          children: [
            if (wide)
              Image.asset(
                'assets/images/fnc_detailing_hero.png',
                fit: BoxFit.cover,
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: wide
                      ? const [
                          Color(0xF2171816),
                          Color(0xC9171816),
                          Color(0x55171816),
                        ]
                      : const [FncColors.ink, Color(0xFF242622)],
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            FncMark(size: 54),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FNC PORTAL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  'AUTOAUFBEREITUNG',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 10,
                                    letterSpacing: 1.8,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 72),
                        const Text(
                          'Wie möchten Sie\nfortfahren?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            height: 1.05,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Wählen Sie den passenden Portalbereich.',
                          style: TextStyle(color: Colors.white70, fontSize: 17),
                        ),
                        const SizedBox(height: 38),
                        Wrap(
                          spacing: 18,
                          runSpacing: 18,
                          children: [
                            _RoleCard(
                              icon: Icons.admin_panel_settings_outlined,
                              eyebrow: 'INTERN',
                              title: 'FNC Admin',
                              description:
                                  'Alle Termine steuern, Status bearbeiten und Aufträge überblicken.',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminDashboardScreen(),
                                ),
                              ),
                            ),
                            _RoleCard(
                              icon: Icons.business_outlined,
                              eyebrow: 'GESCHÄFTSKUNDE',
                              title: 'Autohaus',
                              description:
                                  'Neue Terminanfragen senden und eigene Anfragen dieser Sitzung ansehen.',
                              onTap: () {
                                final sessionId =
                                    'session-${DateTime.now().microsecondsSinceEpoch}';
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AutohausDashboardScreen(
                                      sessionId: sessionId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 42),
                        const Text(
                          'Lokale Vorschau · Kein Login erforderlich',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 340,
    child: Material(
      color: const Color(0xFFFDFBF6),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: FncColors.gold.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: FncColors.gold, size: 28),
              ),
              const SizedBox(height: 28),
              Text(
                eyebrow,
                style: const TextStyle(
                  color: FncColors.gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 7),
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(color: FncColors.muted, height: 1.45),
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Text(
                    'Portal öffnen',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 19),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
