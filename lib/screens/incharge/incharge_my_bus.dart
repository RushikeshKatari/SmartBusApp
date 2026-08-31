import 'package:flutter/material.dart';
import '../../mock/mock_data.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/admin_widgets.dart';
import 'package:provider/provider.dart';

import '../../providers/smart_bus_provider.dart';

class InchargeMyBus extends StatefulWidget {
  const InchargeMyBus({super.key});

  @override
  State<InchargeMyBus> createState() => _InchargeMyBusState();
}

class _InchargeMyBusState extends State<InchargeMyBus> {
  @override
  Widget build(BuildContext context) {
    const bus = MockData.meeraBus;
    final provider = Provider.of<SmartBusProvider>(context, listen: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        const _BusHeroCard(bus: bus),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) {
                String? selected;
                final TextEditingController otherCtrl = TextEditingController();
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: const Text('Report Emergency'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RadioListTile<String>(
                                value: 'SOS',
                                groupValue: selected,
                                title: const Text('🆘 SOS'),
                                onChanged: (val) =>
                                    setState(() => selected = val),
                              ),
                              RadioListTile<String>(
                                value: 'Bus Accident',
                                groupValue: selected,
                                title: const Text('🚍 Bus Accident'),
                                onChanged: (val) =>
                                    setState(() => selected = val),
                              ),
                              RadioListTile<String>(
                                value: 'Bus Breakdown',
                                groupValue: selected,
                                title: const Text('🔧 Bus Breakdown'),
                                onChanged: (val) =>
                                    setState(() => selected = val),
                              ),
                              RadioListTile<String>(
                                value: 'Tyre Problem',
                                groupValue: selected,
                                title: const Text('🛞 Tyre Problem'),
                                onChanged: (val) =>
                                    setState(() => selected = val),
                              ),
                              RadioListTile<String>(
                                value: 'Fire Emergency',
                                groupValue: selected,
                                title: const Text('🔥 Fire Emergency'),
                                onChanged: (val) =>
                                    setState(() => selected = val),
                              ),
                              RadioListTile<String>(
                                value: 'Medical Emergency',
                                groupValue: selected,
                                title: const Text('❤️ Medical Emergency'),
                                onChanged: (val) =>
                                    setState(() => selected = val),
                              ),
                              RadioListTile<String>(
                                value: 'Road Block',
                                groupValue: selected,
                                title: const Text('🚧 Road Block'),
                                onChanged: (val) =>
                                    setState(() => selected = val),
                              ),
                              RadioListTile<String>(
                                value: 'Need Replacement Bus',
                                groupValue: selected,
                                title: const Text('🚌 Need Replacement Bus'),
                                onChanged: (val) =>
                                    setState(() => selected = val),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: otherCtrl,
                                decoration: const InputDecoration(
                                    labelText: 'Other (specify)'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {
                            final reason = otherCtrl.text.isNotEmpty
                                ? otherCtrl.text
                                : (selected ?? 'Unspecified');
                            provider.setBreakdownReason(reason.trim());
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Reason recorded.')));
                          },
                          child: const Text('Submit'),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
          child: const Text('Report Emergency'),
        ),
        const SizedBox(height: 24),
        const AdminSectionHeader(title: 'Bus Details'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0A0F172A),
                  blurRadius: 16,
                  offset: Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              _DetailRow('Bus Number', bus.busNumber, Icons.tag_rounded),
              _DetailRow(
                  'Bus Name', bus.busName, Icons.directions_bus_filled_rounded),
              _DetailRow('Registration', bus.registrationNumber,
                  Icons.confirmation_number_rounded),
              _DetailRow('Capacity', '${bus.capacity} seats',
                  Icons.airline_seat_recline_normal_rounded),
              _DetailRow(
                  'Occupancy',
                  '${bus.currentOccupancy} / ${bus.capacity} passengers',
                  Icons.people_alt_rounded),
              _DetailRow(
                  'Assigned Route', bus.assignedRoute, Icons.alt_route_rounded),
              _DetailRow('Last Service', bus.lastService, Icons.build_rounded),
              _DetailRow('Status', bus.status, Icons.verified_rounded,
                  isLast: true),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const AdminSectionHeader(title: 'Driver Information'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0A0F172A),
                  blurRadius: 16,
                  offset: Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.success.withValues(alpha: .12),
                child: const Text('RK',
                    style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bus.driverName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        )),
                    const SizedBox(height: 3),
                    Text(bus.driverPhone,
                        style: const TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 6),
                    const StatusBadge(label: 'Active'),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(14)),
                child: IconButton(
                  onPressed: () {},
                  icon:
                      const Icon(Icons.call_rounded, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const AdminSectionHeader(title: 'Current Occupancy'),
        const SizedBox(height: 12),
        _OccupancyBar(current: bus.currentOccupancy, total: bus.capacity),
        const SizedBox(height: 24),
        const AdminSectionHeader(title: 'Live Location'),
        const SizedBox(height: 12),
        const MapPlaceholder(height: 220),
      ],
    );
  }
}

class _BusHeroCard extends StatelessWidget {
  const _BusHeroCard({required this.bus});
  final AdminBus bus;

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
          boxShadow: const [
            BoxShadow(
                color: Color(0x332563EB), blurRadius: 24, offset: Offset(0, 8))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.directions_bus_filled_rounded,
                      color: Colors.white, size: 36),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(99)),
                  child: Row(
                    children: [
                      Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(bus.status,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(bus.busNumber,
                style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2)),
            const SizedBox(height: 4),
            Text(bus.busName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(
              children: [
                _HeroStat('Capacity', '${bus.capacity}'),
                const SizedBox(width: 24),
                _HeroStat('Occupancy', '${bus.currentOccupancy}'),
                const SizedBox(width: 24),
                const _HeroStat('Route', '18.6 km'),
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
          Text(label,
              style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
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
                Text(label,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 13)),
                const Spacer(),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
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
    final color = pct > .8
        ? AppColors.danger
        : pct > .6
            ? AppColors.warning
            : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$current passengers',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 22)),
              const Spacer(),
              Text('${(pct * 100).toInt()}%',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: color, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 4),
          Text('of $total seats occupied',
              style: const TextStyle(color: AppColors.muted, fontSize: 13)),
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
