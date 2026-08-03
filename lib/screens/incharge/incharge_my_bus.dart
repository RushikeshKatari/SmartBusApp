import 'package:flutter/material.dart';
import '../../mock/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_widgets.dart';
import '../../widgets/common_widgets.dart';

class InchargeMyBus extends StatelessWidget {
  const InchargeMyBus({super.key});

  @override
  Widget build(BuildContext context) {
    final bus = MockData.meeraBus;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        // Bus hero card
        _BusHeroCard(bus: bus),
        const SizedBox(height: 24),

        // Bus Details
        const AdminSectionHeader(title: 'Bus Details'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
          ),
          child: Column(
            children: [
              _DetailRow('Bus Number', bus.busNumber, Icons.tag_rounded),
              _DetailRow('Bus Name', bus.busName, Icons.directions_bus_filled_rounded),
              _DetailRow('Registration', bus.registrationNumber, Icons.confirmation_number_rounded),
              _DetailRow('Capacity', '${bus.capacity} seats', Icons.airline_seat_recline_normal_rounded),
              _DetailRow('Occupancy', '${bus.currentOccupancy} / ${bus.capacity} passengers', Icons.people_alt_rounded),
              _DetailRow('Assigned Route', bus.assignedRoute, Icons.alt_route_rounded),
              _DetailRow('Last Service', bus.lastService, Icons.build_rounded),
              _DetailRow('Status', bus.status, Icons.verified_rounded, isLast: true),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Driver Info
        const AdminSectionHeader(title: 'Driver Information'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.success.withOpacity(.12),
                child: const Text('RK', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bus.driverName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                    const SizedBox(height: 3),
                    Text(bus.driverPhone, style: const TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 6),
                    const StatusBadge(label: 'Active'),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(.08), borderRadius: BorderRadius.circular(14)),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.call_rounded, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Occupancy bar
        const AdminSectionHeader(title: 'Current Occupancy'),
        const SizedBox(height: 12),
        _OccupancyBar(current: bus.currentOccupancy, total: bus.capacity),
        const SizedBox(height: 24),

        // Map placeholder
        const AdminSectionHeader(title: 'Live Location'),
        const SizedBox(height: 12),
        const MapPlaceholder(height: 220),
      ],
    );
  }
}

class _BusHeroCard extends StatelessWidget {
  const _BusHeroCard({required this.bus});
  final dynamic bus;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x332563EB), blurRadius: 24, offset: Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.15), borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.directions_bus_filled_rounded, color: Colors.white, size: 36),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(99)),
                  child: Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF4ADE80), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(bus.status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(bus.busNumber, style: const TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
            const SizedBox(height: 4),
            Text(bus.busName, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(
              children: [
                _HeroStat('Capacity', '${bus.capacity}'),
                const SizedBox(width: 24),
                _HeroStat('Occupancy', '${bus.currentOccupancy}'),
                const SizedBox(width: 24),
                _HeroStat('Route', '18.6 km'),
              ],
            ),
          ],
        ),
      );
}

class _HeroStat extends StatelessWidget {
  const _HeroStat(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
        ],
      );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value, this.icon, {this.isLast = false});
  final String label, value;
  final IconData icon;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                const Spacer(),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ),
          if (!isLast) const Divider(height: 1, color: Color(0xFFF1F5F9)),
        ],
      );
}

class _OccupancyBar extends StatelessWidget {
  const _OccupancyBar({required this.current, required this.total});
  final int current, total;

  @override
  Widget build(BuildContext context) {
    final pct = current / total;
    final color = pct > .8 ? AppColors.danger : pct > .6 ? AppColors.warning : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$current passengers', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
              const Spacer(),
              Text('${(pct * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 4),
          Text('of $total seats occupied', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
