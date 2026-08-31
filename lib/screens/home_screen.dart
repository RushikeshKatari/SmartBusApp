import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/smart_bus_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/app_models.dart';
import 'smart_alarm_sheet.dart';
import 'location_scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.watch<SmartBusProvider>();
    final bus = p.assignedBus;
    return Stack(children: [
      ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 260), children: [
        Text('Good morning, ${p.student.name.split(' ').first}',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Your campus ride is on the move.',
            style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 14),
        SurfaceCard(
            color: const Color(0xFFEFF6FF),
            child: Row(children: [
              const Icon(Icons.share_location_rounded,
                  color: AppColors.primary),
              const SizedBox(width: 11),
              const Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Share bus location',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    Text('Help riders track this trip live.',
                        style: TextStyle(fontSize: 12, color: AppColors.muted))
                  ])),
              IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LocationScannerScreen())),
                  icon: const Icon(Icons.arrow_forward_rounded,
                      color: AppColors.primary))
            ])),
        const SizedBox(height: 20),
        SizedBox(
            height: 155,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: p.ads.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => AdvertisementCard(ad: p.ads[i]))),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Live route'),
        const SizedBox(height: 12),
        const MapPlaceholder(height: 350)
      ]),
      DraggableScrollableSheet(
          initialChildSize: .38,
          minChildSize: .30,
          maxChildSize: .83,
          builder: (_, controller) => SingleChildScrollView(
              controller: controller, child: _TripSheet(bus: bus)))
    ]);
  }
}

class _TripSheet extends StatelessWidget {
  const _TripSheet({required this.bus});
  final Bus bus;
  @override
  Widget build(BuildContext context) {
    final p = context.watch<SmartBusProvider>();
    return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(99))),
          ),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Assigned bus',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
            LiveStatusChip(label: bus.status)
          ]),
          const SizedBox(height: 15),
          SurfaceCard(
              padding: const EdgeInsets.all(15),
              color: const Color(0xFFF8FAFC),
              child: Row(children: [
                const Icon(Icons.directions_bus_filled_rounded,
                    color: AppColors.primary, size: 34),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('${bus.name} · ${bus.number}',
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text('Driver: ${bus.driver}',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 12))
                    ])),
                Text(bus.eta,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary))
              ])),
          const SizedBox(height: 17),
          Row(children: [
            _Metric(
                icon: Icons.location_on_rounded,
                label: 'NEXT STOP',
                value: bus.nextStop),
            _Metric(
                icon: Icons.people_alt_rounded,
                label: 'OCCUPANCY',
                value: bus.occupancy)
          ]),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
                child: ModernButton(
                    label: p.alarmEnabled
                        ? 'Alarm · ${p.alarmOption}'
                        : 'Set smart alarm',
                    icon: Icons.alarm_rounded,
                    onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const SmartAlarmSheet()))),
            const SizedBox(width: 10),
            ModernButton(
                label: 'Stops',
                icon: Icons.list_alt_rounded,
                secondary: true,
                onPressed: () => _showStops(context))
          ])
        ]));
  }

  void _showStops(BuildContext context) => showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Route stops',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 21)),
                const SizedBox(height: 12),
                ...context.read<SmartBusProvider>().stops.map((s) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                        s.isNext
                            ? Icons.location_on_rounded
                            : Icons.circle_outlined,
                        color: s.isNext ? AppColors.primary : AppColors.muted),
                    title: Text(s.name),
                    subtitle: Text(s.distance),
                    trailing: Text(s.time,
                        style: const TextStyle(fontWeight: FontWeight.w600))))
              ])));
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => Expanded(
          child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 7),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700)),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))
        ]))
      ]));
}
