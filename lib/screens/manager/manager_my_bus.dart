import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/smart_bus_provider.dart';
import '../../theme/app_theme.dart';

class ManagerMyBus extends StatelessWidget {
  const ManagerMyBus({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SmartBusProvider>(context);
    final logs = provider.attendanceLogs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bus'),
        backgroundColor: AppColors.primary,
      ),
      body: logs.isEmpty
          ? const Center(child: Text('No attendance records'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final log = logs[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text("Roll No: ${log['rollNumber']}"),
                  subtitle: Text("Scanned at: ${log['time']}"),
                );
              },
            ),
    );
  }
}
