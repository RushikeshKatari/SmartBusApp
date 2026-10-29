import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/smart_bus_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/app_models.dart';
import 'smart_alarm_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.watch<SmartBusProvider>();
    final bus = p.assignedBus;
    final breakdown = p.activeBreakdown;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 260),
          children: [
            if (breakdown != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF991B1B), Color(0xFF7F1D1D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33DC2626),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🚨 ${breakdown.brokenBusNumber} Reported Breakdown',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${breakdown.reason} near ${breakdown.location}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_bus_filled_rounded,
                                color: Color(0xFFFDE047),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rescue buses: ${breakdown.rescueBusNumbers.isEmpty ? "None available" : breakdown.rescueBusNumbers.join(" · ")}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      'Passenger coverage: ${breakdown.studentsCovered}/${breakdown.strandedStudentsCount} • ${breakdown.studentsUnassigned} need manual support',
                                      style: const TextStyle(
                                        color: Color(0xFFFDE047),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (breakdown.studentsUnassigned == 0
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF59E0B))
                                  .withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  breakdown.studentsUnassigned == 0
                                      ? Icons.verified_rounded
                                      : Icons.warning_amber_rounded,
                                  color: breakdown.studentsUnassigned == 0
                                      ? const Color(0xFF34D399)
                                      : const Color(0xFFFBBF24),
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${breakdown.coveredRemainingStops}/${breakdown.totalRemainingStops} pickup groups assigned • +${breakdown.detourDistanceKm.toStringAsFixed(1)} km estimated detour',
                                  style: const TextStyle(
                                    color: Color(0xFFFDE68A),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: breakdown.affectedStopNames
                                .map(
                                  (st) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '✓ $st',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 9.5,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          if (breakdown.stopAssignments.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Your revised pickup plan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            ...breakdown.stopAssignments.map(
                              (assignment) => Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  '${assignment.stopName} → ${assignment.assignedBusNumber} · ${assignment.studentCount} passengers',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Good morning, ${p.student.name.split(' ').first}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your campus ride is on the move.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Live route'),
            const SizedBox(height: 12),
            SizedBox(
              height: 350,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: MapPlaceholder(
                      key: ValueKey('home-map-${bus.number}'),
                      height: 350,
                      busNumber: bus.number,
                      assignedStops: p.assignedRouteStops,
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => _AssignedRouteMapPage(
                            bus: bus,
                            routeStops: p.assignedRouteStops,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_full, size: 17),
                      label: const Text('Open map'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        DraggableScrollableSheet(
          initialChildSize: .38,
          minChildSize: .30,
          maxChildSize: .83,
          builder: (_, controller) => SingleChildScrollView(
            controller: controller,
            child: _TripSheet(bus: bus),
          ),
        ),
      ],
    );
  }
}

class _AssignedRouteMapPage extends StatelessWidget {
  const _AssignedRouteMapPage({required this.bus, required this.routeStops});

  final Bus bus;
  final List<LiveRouteStop> routeStops;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${bus.number} · ${bus.name}'),
              const Text(
                'Drag to move · pinch or use + / − to zoom',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) => MapPlaceholder(
              key: ValueKey('fullscreen-map-${bus.number}'),
              height: constraints.maxHeight,
              busNumber: bus.number,
              assignedStops: routeStops,
            ),
          ),
        ),
      );
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Assigned bus',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
              ),
              LiveStatusChip(label: bus.status),
            ],
          ),
          const SizedBox(height: 15),
          SurfaceCard(
            padding: const EdgeInsets.all(15),
            color: const Color(0xFFF8FAFC),
            child: Row(
              children: [
                const Icon(
                  Icons.directions_bus_filled_rounded,
                  color: AppColors.primary,
                  size: 34,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${bus.name} · ${bus.number}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Driver: ${bus.driver}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  bus.eta,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              _Metric(
                icon: Icons.location_on_rounded,
                label: 'NEXT STOP',
                value: bus.nextStop,
              ),
              _Metric(
                icon: Icons.people_alt_rounded,
                label: 'OCCUPANCY',
                value: bus.occupancy,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
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
                    builder: (_) => const SmartAlarmSheet(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ModernButton(
                label: 'Stops',
                icon: Icons.list_alt_rounded,
                secondary: true,
                onPressed: () => _showStops(context),
              ),
            ],
          ),
        ],
      ),
    );
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
              const Text(
                'Route stops',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 21),
              ),
              const SizedBox(height: 12),
              ...context.read<SmartBusProvider>().stops.map(
                    (s) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        s.isNext
                            ? Icons.location_on_rounded
                            : Icons.circle_outlined,
                        color: s.isNext ? AppColors.primary : AppColors.muted,
                      ),
                      title: Text(s.name),
                      subtitle: Text(s.distance),
                      trailing: Text(
                        s.time,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
