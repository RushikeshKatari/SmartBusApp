import 'package:flutter/material.dart';
import '../../mock/mock_data.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_widgets.dart';
import '../incharge/incharge_route_detail.dart';

class AdminRoutes extends StatefulWidget {
  const AdminRoutes({super.key});

  @override
  State<AdminRoutes> createState() => _AdminRoutesState();
}

class _AdminRoutesState extends State<AdminRoutes> {
  String _selectedStatus = 'Pending';

  @override
  Widget build(BuildContext context) {
    final routes = MockData.routeRecords.where((r) {
      if (_selectedStatus == 'All') return true;
      return r.status == _selectedStatus;
    }).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Route Approvals',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Review, preview, and approve boarding routes submitted by Bus In-charges',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tab bar for filtering route status
            Row(
              children:
                  ['Pending', 'Approved', 'Rejected', 'All'].map((status) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedStatus = status);
                    },
                    selectedColor: AppColors.primary.withValues(alpha: .15),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            if (routes.isEmpty)
              Container(
                height: 300,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 64,
                        color: AppColors.success.withValues(alpha: .5)),
                    const SizedBox(height: 16),
                    Text(
                      'No $_selectedStatus routes found',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    const Text('Everything looks clean!',
                        style: TextStyle(color: AppColors.muted)),
                  ],
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount =
                      (constraints.maxWidth / 340).floor().clamp(1, 3);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.88,
                    ),
                    itemCount: routes.length,
                    itemBuilder: (context, index) {
                      final route = routes[index];
                      return ApprovalRouteCard(
                        route: route,
                        onApprove: () => _approveRoute(route),
                        onReject: () => _rejectRoute(route),
                        onView: () => _viewRouteDetails(route),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _approveRoute(RouteRecord route) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Approve Route',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
            'Are you sure you want to approve "${route.routeName}" for ${route.busNumber}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Route "${route.routeName}" approved successfully ✓'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectRoute(RouteRecord route) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject Route',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Provide a reason for rejecting "${route.routeName}":'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Route "${route.routeName}" rejected. Reason: ${reasonCtrl.text}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _viewRouteDetails(RouteRecord route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InchargeRouteDetail(
          routeName: route.routeName,
          distanceKm: route.distanceKm,
          durationMinutes: route.durationMinutes,
          stops: const [],
          isPreview: false,
          routeRecord: route,
        ),
      ),
    );
  }
}
