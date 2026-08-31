import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/smart_bus_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class InchargeAttendance extends StatelessWidget {
  const InchargeAttendance({super.key});

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Live Trip Attendance Register',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${logs.length} Students boarded on Campus Express 04',
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Text('${logs.length} Boarded',
                  style: const TextStyle(
                      color: AppColors.success, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (logs.isEmpty)
          const SurfaceCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No students scanned in yet for this trip.',
                    style: TextStyle(color: AppColors.muted)),
              ),
            ),
          )
        else
          ...logs.map((log) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SurfaceCard(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.15),
                      child: Text(log['name']!.substring(0, 1),
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                    title: Text(log['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'Roll No: ${log['rollNumber']} • ${log['method']}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(log['time']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        const Text('VERIFIED',
                            style: TextStyle(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              )),
      ],
    );
  }
}
