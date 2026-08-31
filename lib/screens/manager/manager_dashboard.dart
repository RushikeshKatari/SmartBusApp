import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'manager_my_bus.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  String _timeframe = 'today';

  Map<String, dynamic> _metrics = {
    'activeUsers': 1450,
    'billingEstimate': '\$12.50',
    'apiCalls': 4500,
    'status': 'HEALTHY'
  };

  void _updateTimeframe(String timeframe) {
    setState(() {
      _timeframe = timeframe;
      if (timeframe == 'today') {
        _metrics = {
          'activeUsers': 1450,
          'billingEstimate': '\$12.50',
          'apiCalls': 4500,
          'status': 'HEALTHY'
        };
      } else if (timeframe == 'weekly') {
        _metrics = {
          'activeUsers': 1600,
          'billingEstimate': '\$84.00',
          'apiCalls': 31500,
          'status': 'HEALTHY'
        };
      } else if (timeframe == 'monthly') {
        _metrics = {
          'activeUsers': 1800,
          'billingEstimate': '\$124.50',
          'apiCalls': 135000,
          'status': 'HEALTHY'
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('System Health & Billing Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'today', label: Text('Today')),
                ButtonSegment(value: 'weekly', label: Text('Weekly')),
                ButtonSegment(value: 'monthly', label: Text('Monthly')),
              ],
              selected: {_timeframe},
              onSelectionChanged: (Set<String> newSelection) {
                _updateTimeframe(newSelection.first);
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor:
                    const Color(0xFFEA580C).withOpacity(0.2),
                selectedForegroundColor: const Color(0xFFEA580C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth > 800
                ? (constraints.maxWidth - 32) / 3
                : constraints.maxWidth;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                    width: width,
                    child: _buildStatCard(
                        'Active Users',
                        '${_metrics['activeUsers']}',
                        Icons.people,
                        AppColors.primary)),
                SizedBox(
                    width: width,
                    child: _buildStatCard(
                        'Billing',
                        '${_metrics['billingEstimate']}',
                        Icons.attach_money,
                        AppColors.success)),
                SizedBox(
                    width: width,
                    child: _buildStatCard(
                        'API Calls',
                        '${_metrics['apiCalls']}',
                        Icons.api_rounded,
                        const Color(0xFFEA580C))),
              ],
            );
          },
        ),
        const SizedBox(height: 32),
        const Text('Recent System Alerts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SurfaceCard(
          child: ListTile(
            leading: const Icon(Icons.check_circle, color: AppColors.success),
            title: const Text('All systems operational'),
            subtitle: const Text(
                'Database and Redis are healthy. No billing anomalies detected.'),
          ),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.build_rounded),
            label: const Text('Bus Breakdown'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.dashboard_rounded),
                      title: const Text('Dashboard'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.gps_fixed_rounded),
                      title: const Text('Scan & GPS'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.directions_bus_rounded),
                      title: const Text('My Bus'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ManagerMyBus()));
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: AppColors.muted, fontWeight: FontWeight.w500)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(value,
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
