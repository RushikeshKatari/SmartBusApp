import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_widgets.dart';
import '../../widgets/common_widgets.dart';

class InchargeRouteDetail extends StatelessWidget {
  const InchargeRouteDetail({
    super.key,
    required this.routeName,
    required this.distanceKm,
    required this.durationMinutes,
    required this.stops,
    required this.isPreview,
    this.routeRecord,
  });

  final String routeName;
  final double distanceKm;
  final int durationMinutes;
  final List stops; // List<Map> for preview, or use routeRecord.stops
  final bool isPreview;
  final RouteRecord? routeRecord;

  List<RecordedBoardingStop> get _stops =>
      routeRecord?.stops ?? stops.map<RecordedBoardingStop>((s) => RecordedBoardingStop(
            id: 'preview',
            name: s['name'] ?? '',
            landmark: s['landmark'] ?? '',
            type: s['type'] ?? 'Pickup',
            estimatedWaitMinutes: 3,
          )).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Map as SliverAppBar header
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            title: Text(routeName, style: const TextStyle(fontWeight: FontWeight.w800)),
            flexibleSpace: FlexibleSpaceBar(
              background: const MapPlaceholder(height: 260),
            ),
            actions: [
              if (!isPreview)
                IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route summary card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        _SummaryRow('Total Distance', '${distanceKm} km', Icons.straighten_rounded, AppColors.primary),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        _SummaryRow('Estimated Time', '${durationMinutes} min', Icons.timer_rounded, AppColors.success),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        _SummaryRow('Total Stops', '${_stops.length} stops', Icons.location_on_rounded, AppColors.warning),
                        if (routeRecord != null) ...[
                          const Divider(height: 24, color: Color(0xFFF1F5F9)),
                          _SummaryRow('Status', routeRecord!.status, Icons.info_outline_rounded, AppColors.muted),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stops timeline
                  const AdminSectionHeader(title: 'Boarding Stops'),
                  const SizedBox(height: 14),
                  if (_stops.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('No boarding stops added.', style: TextStyle(color: AppColors.muted)),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
                      ),
                      child: StopTimelineWidget(stops: _stops),
                    ),
                  const SizedBox(height: 24),

                  // Action buttons (preview or detail)
                  if (isPreview) ...[
                    FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Route submitted for approval ✓'), behavior: SnackBarBehavior.floating),
                        );
                        Navigator.popUntil(context, (r) => r.isFirst || r.settings.name == '/incharge');
                      },
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Submit Route', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Discard Route', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: BorderSide(color: AppColors.danger.withOpacity(.3)),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, this.icon, this.color);
  final String label, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        ],
      );
}
