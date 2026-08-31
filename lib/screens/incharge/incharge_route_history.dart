import 'package:flutter/material.dart';
import '../../mock/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_widgets.dart';
import 'incharge_route_detail.dart';

class InchargeRouteHistory extends StatelessWidget {
  const InchargeRouteHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final routes = MockData.meeraRoutes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route History',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: routes.isEmpty
          ? _EmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Row(
                  children: [
                    Expanded(
                        child: DashboardStatCard(
                      label: 'Total Routes',
                      value: '${routes.length}',
                      icon: Icons.alt_route_rounded,
                      color: AppColors.primary,
                    )),
                    const SizedBox(width: 12),
                    Expanded(
                        child: DashboardStatCard(
                            label: 'Approved',
                            value:
                                '${routes.where((r) => r.status == 'Approved').length}',
                            icon: Icons.check_circle_rounded,
                            color: AppColors.success)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: DashboardStatCard(
                            label: 'Pending',
                            value:
                                '${routes.where((r) => r.status == 'Pending').length}',
                            icon: Icons.pending_actions_rounded,
                            color: AppColors.warning)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: DashboardStatCard(
                            label: 'Total km',
                            value: routes
                                .fold(0.0, (s, r) => s + r.distanceKm)
                                .toStringAsFixed(1),
                            icon: Icons.straighten_rounded,
                            color: const Color(0xFF7C3AED))),
                  ],
                ),
                const SizedBox(height: 24),
                const AdminSectionHeader(title: 'All Routes'),
                const SizedBox(height: 12),
                ...routes.map((route) => InchargeRouteCard(
                      route: route,
                      onTap: () => Navigator.push(
                        context,
                        _slide(InchargeRouteDetail(
                          routeName: route.routeName,
                          distanceKm: route.distanceKm,
                          durationMinutes: route.durationMinutes,
                          stops: const [],
                          isPreview: false,
                          routeRecord: route,
                        )),
                      ),
                    )),
              ],
            ),
    );
  }

  PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
        pageBuilder: (_, a, __) => page,
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.route_rounded,
                size: 72, color: AppColors.primary.withValues(alpha: .3)),
            const SizedBox(height: 16),
            const Text('No routes yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Record a new route to see it here.',
                style: TextStyle(color: AppColors.muted)),
          ],
        ),
      );
}
