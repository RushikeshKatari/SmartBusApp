import 'package:flutter/material.dart';
import '../../mock/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_widgets.dart';
import 'incharge_record_route.dart';
import 'incharge_route_history.dart';
import 'incharge_my_bus.dart';

class InchargeDashboard extends StatelessWidget {
  const InchargeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final bus = MockData.meeraBus;
    final routes = MockData.meeraRoutes;
    final todayRoute = routes.isNotEmpty ? routes.first : null;
    final pendingRoutes = routes.where((r) => r.status == 'Pending').length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        // Welcome card
        _WelcomeCard(busNumber: bus.busNumber),
        const SizedBox(height: 20),

        // Today's Route Card
        const AdminSectionHeader(title: 'Today\'s Route'),
        const SizedBox(height: 10),
        _TodayRouteCard(
          routeName: todayRoute?.routeName ?? 'North Campus Morning Run',
          stops: todayRoute?.stops.length ?? 8,
          distance: todayRoute?.distanceKm ?? 18.6,
          status: 'Active',
        ),
        const SizedBox(height: 20),

        // Stats Row
        const AdminSectionHeader(title: 'Overview'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: DashboardStatCard(label: 'Total Stops', value: '${todayRoute?.stops.length ?? 8}', icon: Icons.location_on_rounded, color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: DashboardStatCard(label: 'Pending', value: '$pendingRoutes', icon: Icons.pending_actions_rounded, color: AppColors.warning)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: DashboardStatCard(label: 'Routes', value: '${routes.length}', icon: Icons.alt_route_rounded, color: AppColors.success)),
            const SizedBox(width: 12),
            Expanded(child: DashboardStatCard(label: 'Distance', value: '${todayRoute?.distanceKm ?? 18.6} km', icon: Icons.straighten_rounded, color: const Color(0xFF7C3AED))),
          ],
        ),
        const SizedBox(height: 24),

        // Quick Actions
        const AdminSectionHeader(title: 'Quick Actions'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.35,
          children: [
            QuickActionCard(
              label: 'Record New Route',
              icon: Icons.add_road_rounded,
              color: AppColors.primary,
              onTap: () => Navigator.push(context, _slide(const InchargeRecordRoute())),
            ),
            QuickActionCard(
              label: 'My Routes',
              icon: Icons.route_rounded,
              color: AppColors.success,
              onTap: () => Navigator.push(context, _slide(const InchargeRouteHistory())),
            ),
            QuickActionCard(
              label: 'Boarding Stops',
              icon: Icons.location_on_rounded,
              color: const Color(0xFF7C3AED),
              onTap: () => _showBoardingStopsSheet(context, todayRoute?.stops ?? []),
            ),
            QuickActionCard(
              label: 'Route History',
              icon: Icons.history_rounded,
              color: AppColors.warning,
              onTap: () => Navigator.push(context, _slide(const InchargeRouteHistory())),
            ),
          ],
        ),
      ],
    );
  }

  void _showBoardingStopsSheet(BuildContext context, List stops) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            const Text('Boarding Stops', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Today\'s route · ${stops.length} stops', style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 20),
            if (stops.isEmpty)
              const Center(child: Text('No stops recorded yet.', style: TextStyle(color: AppColors.muted)))
            else
              StopTimelineWidget(stops: stops.cast()),
          ],
        ),
      ),
    );
  }

  PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
        pageBuilder: (_, a, __) => page,
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
}

// ─────────────────────────────────────────────
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.busNumber});
  final String busNumber;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x332563EB), blurRadius: 20, offset: Offset(0, 8))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('GOOD MORNING', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  const SizedBox(height: 6),
                  const Text('Meera Singh 👋', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Managing Bus $busNumber today', style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.directions_bus_filled_rounded, color: Colors.white, size: 32),
            ),
          ],
        ),
      );
}

class _TodayRouteCard extends StatelessWidget {
  const _TodayRouteCard({required this.routeName, required this.stops, required this.distance, required this.status});
  final String routeName, status;
  final int stops;
  final double distance;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.success.withOpacity(.1), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.alt_route_rounded, color: AppColors.success, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(routeName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('$stops boarding stops · $distance km', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
            StatusBadge(label: status),
          ],
        ),
      );
}
