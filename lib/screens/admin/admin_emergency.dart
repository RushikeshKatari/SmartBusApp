import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/smart_bus_provider.dart';
import '../../theme/app_theme.dart';

class AdminEmergency extends StatelessWidget {
  const AdminEmergency({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Emergency Reports'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Consumer<SmartBusProvider>(
          builder: (context, provider, _) {
            final reports = provider.transportReports;
            if (reports.isEmpty) {
              return const Center(
                  child: Text(
                      'No attendance reports have been sent to transport.',
                      style: TextStyle(fontSize: 16)));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (_, index) {
                final report = reports[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.warning_rounded,
                                color: AppColors.danger),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(
                                    '${report.busNumber} · ${report.busName}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16))),
                            Chip(
                                label: Text(report.sentToHod
                                    ? 'Sent to HOD'
                                    : 'Transport review')),
                          ]),
                          const SizedBox(height: 10),
                          Text('Emergency: ${report.reason}'),
                          Text(
                              'Location: ${report.location} · ${report.createdAt}'),
                          Text('In-charge: ${report.inchargeName}'),
                          const SizedBox(height: 12),
                          Text(
                              'Attendance list (${report.students.length} students)',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          ...report.students.map((student) => Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text(
                                    '${student['name'] ?? 'Student'} · ${student['rollNumber'] ?? ''} · ${student['department'] ?? ''}'),
                              )),
                          const SizedBox(height: 14),
                          if (report.sentToHod)
                            const Row(children: [
                              Icon(Icons.check_circle_rounded,
                                  color: AppColors.success, size: 18),
                              SizedBox(width: 7),
                              Text('Attendance list delivered to HOD')
                            ])
                          else
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                onPressed: () {
                                  provider.sendEmergencyReportToHod(report.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Emergency attendance report sent to HOD.')));
                                },
                                icon:
                                    const Icon(Icons.forward_to_inbox_rounded),
                                label: const Text('Report to HOD'),
                              ),
                            ),
                        ]),
                  ),
                );
              },
            );
          },
        ),
      );
}
