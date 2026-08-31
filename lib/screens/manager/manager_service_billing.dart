import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ManagerServiceBilling extends StatelessWidget {
  const ManagerServiceBilling({super.key});

  final List<Map<String, dynamic>> _mockServices = const [
    {
      'service': 'Google Maps API',
      'cost': 45.20,
      'calls': 12500,
      'status': 'active'
    },
    {
      'service': 'PostgreSQL Database',
      'cost': 20.00,
      'calls': 450000,
      'status': 'active'
    },
    {
      'service': 'Firebase Notifications',
      'cost': 5.50,
      'calls': 3200,
      'status': 'active'
    },
    {'service': 'Stripe Fees', 'cost': 12.00, 'calls': 150, 'status': 'active'},
    {
      'service': 'Redis Cache',
      'cost': 10.00,
      'calls': 850000,
      'status': 'active'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Service Billing Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ..._mockServices.map((srv) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SurfaceCard(
                child: ListTile(
                  leading: const Icon(Icons.cloud_done_rounded,
                      color: AppColors.primary, size: 30),
                  title: Text(srv['service'],
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${srv['calls']} API calls processed'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${srv['cost'].toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success)),
                      Text(srv['status'],
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
