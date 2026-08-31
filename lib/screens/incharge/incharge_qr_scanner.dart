import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/smart_bus_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/manager_api_service.dart';
import '../../screens/admin/admin_emergency.dart';

class InchargeQrScanner extends StatefulWidget {
  const InchargeQrScanner({super.key});

  @override
  State<InchargeQrScanner> createState() => _InchargeQrScannerState();
}

class _InchargeQrScannerState extends State<InchargeQrScanner> {
  Future<void> _showEmergencyDialog() async {
    final provider = Provider.of<SmartBusProvider>(context, listen: false);
    final reasons = [
      '🆘 SOS',
      '🚍 Bus Accident',
      '🔧 Bus Breakdown',
      '🛞 Tyre Problem',
      '🔥 Fire Emergency',
      '❤️ Medical Emergency',
      '🚧 Road Block',
      '🚌 Need Replacement Bus',
      'Other',
    ];
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Report Emergency'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: reasons.length,
              itemBuilder: (_, i) {
                final reason = reasons[i];
                return ListTile(
                  title: Text(reason),
                  onTap: () {
                    provider.setBreakdownReason(reason);
                    ManagerApiService.sendEmergencyReport({
                      'reason': reason,
                      'busNumber': 'SB-04',
                      'busName': 'Campus Express 04',
                      'inchargeName': 'Incharge',
                      'location': 'Campus',
                    });
                    Navigator.of(ctx).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showManualAttendanceDialog() async {
    final provider = Provider.of<SmartBusProvider>(context, listen: false);
    final nameCtrl = TextEditingController();
    final rollCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manual Attendance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: rollCtrl,
                decoration: const InputDecoration(labelText: 'Roll No')),
            TextField(
                controller: deptCtrl,
                decoration: const InputDecoration(labelText: 'Department')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              provider.addAttendanceRecord(
                  rollCtrl.text, nameCtrl.text, 'Campus Express 04');
              Navigator.pop(ctx);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SmartBusProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scan'),
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: provider.breakdownReason != null
                ? AppColors.danger
                : Colors.transparent,
            width: 4,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('QR Scan',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Scan student QR codes to log attendance',
                        style: TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_rounded),
                  tooltip: 'Manual Attendance',
                  onPressed: _showManualAttendanceDialog,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (provider.breakdownReason == null) ...[
              FilledButton.icon(
                icon: const Icon(Icons.warning_rounded),
                label: const Text('Report Emergency'),
                onPressed: () async {
                  await _showEmergencyDialog();
                },
              ),
              const SizedBox(height: 12),
            ],
            SurfaceCard(
              child: Column(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_scanner_rounded,
                                color: AppColors.primary, size: 80),
                            SizedBox(height: 12),
                            Text('Point camera at Student QR Pass',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                        Positioned(
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              provider.sharingActive
                                  ? 'GPS Broadcast ACTIVE • Live'
                                  : 'GPS Broadcast Standby',
                              style: TextStyle(
                                  color: provider.sharingActive
                                      ? AppColors.success
                                      : Colors.white60,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            if (provider.breakdownReason != null) ...[
              FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminEmergency()),
                  );
                },
                child: const Text('Report attendance to transport department'),
              ),
              const SizedBox(height: 24),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
