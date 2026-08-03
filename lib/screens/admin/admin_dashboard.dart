import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/app_models.dart';
import '../../mock/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_widgets.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final buses = MockData.buses;
    final students = MockData.students;
    final routes = MockData.routeRecords;
    final pendingRoutes = routes.where((r) => r.status == 'Pending').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome back, Admin 👋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                    Text('20 July 2026 · ${routes.length} pending approvals', style: const TextStyle(color: AppColors.muted, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Top stats cards — responsive wrap
          LayoutBuilder(builder: (_, c) {
            final cols = (c.maxWidth / 200).floor().clamp(2, 6);
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                SizedBox(width: (c.maxWidth - (cols - 1) * 14) / cols, child: DashboardStatCard(label: 'Total Students', value: '${students.length}', icon: Icons.people_alt_rounded, color: AppColors.primary, trend: '+4.2%')),
                SizedBox(width: (c.maxWidth - (cols - 1) * 14) / cols, child: DashboardStatCard(label: 'Total Buses', value: '${buses.length}', icon: Icons.directions_bus_rounded, color: AppColors.success, trend: '+1')),
                SizedBox(width: (c.maxWidth - (cols - 1) * 14) / cols, child: DashboardStatCard(label: 'Routes', value: '${routes.length}', icon: Icons.alt_route_rounded, color: const Color(0xFF7C3AED), trend: '+2')),
                SizedBox(width: (c.maxWidth - (cols - 1) * 14) / cols, child: DashboardStatCard(label: 'Boarding Stops', value: '${routes.fold(0, (s, r) => s + r.stops.length)}', icon: Icons.location_on_rounded, color: AppColors.warning)),
                SizedBox(width: (c.maxWidth - (cols - 1) * 14) / cols, child: DashboardStatCard(label: 'Today\'s Trips', value: '112', icon: Icons.timelapse_rounded, color: const Color(0xFFEC4899), trend: '+8')),
                SizedBox(width: (c.maxWidth - (cols - 1) * 14) / cols, child: DashboardStatCard(label: 'Advertisements', value: '${MockData.advertisements.length}', icon: Icons.campaign_rounded, color: const Color(0xFF0891B2))),
              ],
            );
          }),
          const SizedBox(height: 28),

          // Charts row
          LayoutBuilder(builder: (_, c) {
            final wide = c.maxWidth > 600;
            return wide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: _AttendanceChart()),
                    const SizedBox(width: 16),
                    SizedBox(width: 260, child: _OccupancyChart()),
                  ])
                : Column(children: [
                    _AttendanceChart(),
                    const SizedBox(height: 16),
                    _OccupancyChart(),
                  ]);
          }),
          const SizedBox(height: 28),

          // Bottom row: recent activities + pending approvals + live bus status
          LayoutBuilder(builder: (_, c) {
            final wide = c.maxWidth > 700;
            return wide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: _RecentActivities()),
                    const SizedBox(width: 16),
                    Expanded(child: Column(children: [
                      _PendingApprovals(routes: pendingRoutes),
                      const SizedBox(height: 16),
                      _LiveBusStatus(buses: MockData.buses),
                    ])),
                  ])
                : Column(children: [
                    _RecentActivities(),
                    const SizedBox(height: 16),
                    _PendingApprovals(routes: pendingRoutes),
                    const SizedBox(height: 16),
                    _LiveBusStatus(buses: MockData.buses),
                  ]);
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ATTENDANCE CHART
// ─────────────────────────────────────────────
class _AttendanceChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = MockData.weeklyAttendance;
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
              const Text('Attendance', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(99)),
                child: const Text('This Week', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Daily student boarding count', style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _AttendanceBarPainter(data: data),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: data.map((d) => Text(d.label, style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600))).toList(),
          ),
        ],
      ),
    );
  }
}

class _AttendanceBarPainter extends CustomPainter {
  const _AttendanceBarPainter({required this.data});
  final List<AttendancePoint> data;

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = data.fold(0, (m, d) => math.max(m, d.total));
    final barW = (size.width / data.length) * 0.5;
    final spacing = size.width / data.length;

    for (int i = 0; i < data.length; i++) {
      final x = spacing * i + spacing / 2;
      final bgH = size.height;
      final fgH = (data[i].value / maxVal) * size.height;

      // Background bar
      final bgPaint = Paint()..color = const Color(0xFFF1F5F9);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - barW / 2, 0, barW, bgH), const Radius.circular(6)), bgPaint);

      // Foreground bar (gradient)
      final fgPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primary.withOpacity(.5)],
        ).createShader(Rect.fromLTWH(x - barW / 2, bgH - fgH, barW, fgH));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - barW / 2, bgH - fgH, barW, fgH), const Radius.circular(6)), fgPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────
// OCCUPANCY PIE CHART
// ─────────────────────────────────────────────
class _OccupancyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = MockData.busOccupancy;
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
          const Text('Bus Occupancy', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          const Text('Average fill rate per bus', style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: CustomPaint(painter: _OccupancyPiePainter(data: data), child: const SizedBox.expand()),
          ),
          const SizedBox(height: 12),
          ...data.map((d) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: _busColor(d.busNumber), borderRadius: BorderRadius.circular(3)),
                    ),
                    const SizedBox(width: 8),
                    Text(d.busNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('${d.percentage.toInt()}%', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  static Color _busColor(String bus) {
    const colors = [AppColors.primary, Color(0xFF7C3AED), AppColors.success, AppColors.warning, Color(0xFFEC4899)];
    final idx = ['SB-04', 'SB-12', 'SB-09', 'SB-02', 'SB-17'].indexOf(bus);
    return idx >= 0 ? colors[idx] : AppColors.muted;
  }
}

class _OccupancyPiePainter extends CustomPainter {
  const _OccupancyPiePainter({required this.data});
  final List<OccupancyPoint> data;

  static const _colors = [AppColors.primary, Color(0xFF7C3AED), AppColors.success, AppColors.warning, Color(0xFFEC4899)];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 10;
    double startAngle = -math.pi / 2;
    final total = data.fold(0.0, (s, d) => s + d.percentage.clamp(1, 100));

    for (int i = 0; i < data.length; i++) {
      final sweep = (data[i].percentage.clamp(1, 100) / total) * 2 * math.pi;
      final paint = Paint()
        ..color = _colors[i % _colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), startAngle, sweep - 0.05, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────
// RECENT ACTIVITIES
// ─────────────────────────────────────────────
class _RecentActivities extends StatelessWidget {
  static const _activities = [
    _ActivityItem(Icons.add_road_rounded, AppColors.primary, 'New route submitted', 'Meera Singh · SB-04', '2h ago'),
    _ActivityItem(Icons.check_circle_rounded, AppColors.success, 'Route approved', 'West Gate Evening Loop', '5h ago'),
    _ActivityItem(Icons.person_add_alt_rounded, Color(0xFF7C3AED), 'Student added', 'Divya Kumar · CS2024', 'Yesterday'),
    _ActivityItem(Icons.campaign_rounded, Color(0xFF0891B2), 'Ad published', 'Smart Travel Campaign', 'Yesterday'),
    _ActivityItem(Icons.build_rounded, AppColors.warning, 'Bus maintenance', 'SB-02 scheduled service', '2 days ago'),
  ];

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminSectionHeader(title: 'Recent Activities'),
            const SizedBox(height: 16),
            ..._activities.map((a) => _ActivityTile(item: a)),
          ],
        ),
      );
}

class _ActivityItem {
  const _ActivityItem(this.icon, this.color, this.title, this.subtitle, this.time);
  final IconData icon;
  final Color color;
  final String title, subtitle, time;
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item});
  final _ActivityItem item;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: item.color.withOpacity(.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(item.icon, color: item.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(item.subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
            Text(item.time, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────
// PENDING APPROVALS SUMMARY
// ─────────────────────────────────────────────
class _PendingApprovals extends StatelessWidget {
  const _PendingApprovals({required this.routes});
  final List routes;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminSectionHeader(
              title: 'Pending Approvals',
              subtitle: '${routes.length} routes waiting',
              action: 'View all',
            ),
            const SizedBox(height: 14),
            if (routes.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('All caught up! ✓', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
              ))
            else
              ...routes.take(3).map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.warning.withOpacity(.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pending_actions_rounded, color: AppColors.warning, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.routeName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            Text('${r.inchargeName} · ${r.busNumber}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                          ],
                        ),
                      ),
                      const StatusBadge(label: 'Pending'),
                    ],
                  ),
                ),
              )),
          ],
        ),
      );
}

// ─────────────────────────────────────────────
// LIVE BUS STATUS
// ─────────────────────────────────────────────
class _LiveBusStatus extends StatelessWidget {
  const _LiveBusStatus({required this.buses});
  final List buses;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminSectionHeader(title: 'Live Bus Status', subtitle: 'Real-time fleet overview'),
            const SizedBox(height: 14),
            ...buses.map((b) => LiveBusStatusRow(bus: b)),
          ],
        ),
      );
}
