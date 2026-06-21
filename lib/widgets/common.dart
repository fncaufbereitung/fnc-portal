import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../theme.dart';

class FncMark extends StatelessWidget {
  const FncMark({super.key, this.size = 46});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: FncColors.ink,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Text(
      'FNC',
      style: TextStyle(
        color: Colors.white,
        fontSize: size * .25,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

String germanDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.item,
    this.onStatus,
    this.onDelete,
  });

  final Appointment item;
  final ValueChanged<String>? onStatus;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.vehicleMake} ${item.vehicleModel}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.companyName} · ${item.licensePlate} · ${item.serviceType}',
                    style: const TextStyle(color: FncColors.muted),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    germanDate(item.desiredDate),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    item.status,
                    style: const TextStyle(
                      color: FncColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (item.notes.isNotEmpty) ...[
            const Divider(height: 28),
            Text(item.notes),
          ],
          if (onStatus != null || onDelete != null) ...[
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onStatus != null)
                  SizedBox(
                    width: 190,
                    child: DropdownButtonFormField<String>(
                      initialValue: item.status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: appointmentStatuses
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) onStatus!(value);
                      },
                    ),
                  ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}
