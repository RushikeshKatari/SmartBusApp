import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/smart_bus_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class QrScreen extends StatelessWidget {
  const QrScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final b = context.watch<SmartBusProvider>().assignedBus;
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Scan & board',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      const Text('Point your camera at the bus QR code.',
          style: TextStyle(color: AppColors.muted)),
      const SizedBox(height: 28),
      Container(
          height: 290,
          decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(28)),
          child: Stack(alignment: Alignment.center, children: [
            Container(
                height: 196,
                width: 196,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(20))),
            const Icon(Icons.qr_code_scanner_rounded,
                color: Colors.white, size: 90),
            const Positioned(
                bottom: 23,
                child: Text('Align QR code within the frame',
                    style: TextStyle(color: Colors.white70)))
          ])),
      const SizedBox(height: 24),
      const SectionHeader(title: 'Current bus'),
      const SizedBox(height: 11),
      BusCard(bus: b),
      const SizedBox(height: 13),
      const Row(children: [
        Expanded(
            child: _Info(
                icon: Icons.people_alt_rounded,
                title: 'Occupancy',
                value: '42% · Comfortable',
                color: AppColors.success)),
        SizedBox(width: 12),
        Expanded(
            child: _Info(
                icon: Icons.verified_rounded,
                title: 'Attendance',
                value: 'Marked today',
                color: AppColors.primary))
      ]),
      const SizedBox(height: 18),
      const ModernButton(
          label: 'Simulate scan success',
          icon: Icons.qr_code_rounded,
          onPressed: _noop)
    ]);
  }

  static void _noop() {}
}

class _Info extends StatelessWidget {
  const _Info(
      {required this.icon,
      required this.title,
      required this.value,
      required this.color});
  final IconData icon;
  final String title, value;
  final Color color;
  @override
  Widget build(BuildContext context) => SurfaceCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color),
        const SizedBox(height: 14),
        Text(title,
            style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))
      ]));
}
