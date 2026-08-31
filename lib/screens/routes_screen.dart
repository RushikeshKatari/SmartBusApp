import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/smart_bus_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.watch<SmartBusProvider>();
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Other routes',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      const Text('Discover buses around your campus.',
          style: TextStyle(color: AppColors.muted)),
      const SizedBox(height: 20),
      const MapPlaceholder(height: 205),
      const SizedBox(height: 22),
      const SectionHeader(title: 'Nearby buses', action: '3 available'),
      const SizedBox(height: 12),
      ...p.nearbyBuses.map((b) => Padding(
          padding: const EdgeInsets.only(bottom: 12), child: BusCard(bus: b))),
      const SizedBox(height: 8),
      const SectionHeader(title: 'Nearest boarding stop'),
      const SizedBox(height: 12),
      SurfaceCard(
          child: Row(children: [
        Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.location_on_rounded,
                color: AppColors.warning)),
        const SizedBox(width: 12),
        const Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Central Library',
              style: TextStyle(fontWeight: FontWeight.w800)),
          Text('250 m · 3 min walk',
              style: TextStyle(color: AppColors.muted, fontSize: 12))
        ])),
        const Icon(Icons.chevron_right_rounded)
      ]))
    ]);
  }
}
