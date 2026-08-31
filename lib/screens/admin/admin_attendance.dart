import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/smart_bus_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminAttendance extends StatelessWidget {
  const AdminAttendance({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SmartBusProvider>(context);
    final logs = provider.attendanceLogs;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('System-wide Attendance Logs',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Real-time QR scan logs across all active bus routes',
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Exporting attendance report (CSV)...')));
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Export Report'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...logs.map((log) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SurfaceCard(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(log['name']!.substring(0, 1),
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                  ),
                  title: Text(log['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Roll No: ${log['rollNumber']} • Bus: ${log['busName']}'),
                  trailing: Text(log['time']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: AppColors.muted)),
                ),
              ),
            )),
      ],
    );
  }
}
