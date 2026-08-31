import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/smart_bus_provider.dart';
import '../../theme/app_theme.dart';

class AdminEmergency extends StatelessWidget {
  const AdminEmergency({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Reports'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SmartBusProvider>(
        builder: (context, provider, _) {
          final alerts = provider.breakdownAlerts;
          if (alerts.isEmpty) {
            return const Center(
              child:
                  Text('No emergency reports.', style: TextStyle(fontSize: 16)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (_, index) {
              final alert = alerts[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.warning_rounded,
                      color: AppColors.danger),
                  title: Text(
                      'Bus ${alert['busNumber'] ?? 'N/A'} - ${alert['busName'] ?? ''}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reason: ${alert['reason'] ?? 'N/A'}'),
                      Text('Location: ${alert['location'] ?? 'N/A'}'),
                      Text('Time: ${alert['time'] ?? ''}'),
                      Text('Incharge: ${alert['inchargeName'] ?? ''}'),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
