import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/app_theme.dart';
import '../../widgets/admin_widgets.dart';

class AdminReports extends StatefulWidget {
  const AdminReports({super.key});

  @override
  State<AdminReports> createState() => _AdminReportsState();
}

class _AdminReportsState extends State<AdminReports> {
  int _selectedTab = 0;

  final _tabs = [
    const _ReportTab('Attendance', Icons.people_rounded),
    const _ReportTab('Occupancy', Icons.airline_seat_recline_normal_rounded),
    const _ReportTab('Route Usage', Icons.alt_route_rounded),
    const _ReportTab('Popular Stops', Icons.location_on_rounded),
    const _ReportTab('Bus Performance', Icons.speed_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operational Analytics',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Visual charts and performance metrics for college bus operations',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                SecondaryButton(
                  label: 'Export PDF',
                  icon: Icons.download_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Report exported as PDF (Mock) ✓'),
                          behavior: SnackBarBehavior.floating),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tab Buttons Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final tab = _tabs[index];
                  final isSelected = _selectedTab == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(tab.icon,
                          size: 16,
                          color:
                              isSelected ? AppColors.primary : AppColors.muted),
                      label: Text(tab.label),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedTab = index);
                      },
                      selectedColor: AppColors.primary.withValues(alpha: .12),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.muted,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),

            // Chart Card Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0A0F172A),
                      blurRadius: 20,
                      offset: Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _tabs[_selectedTab].label,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      const Icon(Icons.show_chart_rounded,
                          color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDescriptionForTab(_selectedTab),
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 240,
                    width: double.infinity,
                    child: _buildChartForTab(_selectedTab),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDescriptionForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'Weekly comparison of student boarding vs total registered count';
      case 1:
        return 'Average seating fill rate statistics across standard running buses';
      case 2:
        return 'Total trips completed successfully per route during the current semester';
      case 3:
        return 'Boarding density level by stop location based on scanner logs';
      case 4:
        return 'On-time arrival success rate percentage of operating drivers';
      default:
        return '';
    }
  }

  Widget _buildChartForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return const CustomPaint(
            painter: _LineChartPainter(data: [42, 68, 59, 88, 72, 92]));
      case 1:
        return const CustomPaint(
            painter: _BarChartPainter(data: [0.74, 0.88, 0.52, 0.41, 0.68]));
      case 2:
        return const CustomPaint(
            painter: _HorizontalBarPainter(data: [120, 85, 96, 64]));
      case 3:
        return CustomPaint(painter: _RadarChartPainter());
      case 4:
        return const CustomPaint(painter: _GaugeChartPainter(percentage: 0.92));
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ReportTab {
  const _ReportTab(this.label, this.icon);
  final String label;
  final IconData icon;
}

// ─────────────────────────────────────────────
// CUSTOM PAINTERS FOR CHARTS
// ─────────────────────────────────────────────

// LINE CHART
class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({required this.data});
  final List<double> data;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: .3),
          AppColors.primary.withValues(alpha: 0)
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = stepX * i;
      final y = size.height - (data[i] / 100) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Draw dots
      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(x, y), 6, dotPaint);
      canvas.drawCircle(Offset(x, y), 6, borderPaint);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// VERTICAL BAR CHART
class _BarChartPainter extends CustomPainter {
  const _BarChartPainter({required this.data});
  final List<double> data;

  @override
  void paint(Canvas canvas, Size size) {
    final spacing = size.width / data.length;
    final width = spacing * 0.5;

    for (int i = 0; i < data.length; i++) {
      final x = spacing * i + (spacing - width) / 2;
      final h = data[i] * size.height;
      final y = size.height - h;

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: .4)],
        ).createShader(Rect.fromLTWH(x, y, width, h));

      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x, y, width, h), const Radius.circular(8)),
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// HORIZONTAL BAR CHART
class _HorizontalBarPainter extends CustomPainter {
  const _HorizontalBarPainter({required this.data});
  final List<double> data;

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = data.reduce(math.max);
    final spacing = size.height / data.length;
    final height = spacing * 0.5;

    for (int i = 0; i < data.length; i++) {
      final y = spacing * i + (spacing - height) / 2;
      final w = (data[i] / maxVal) * size.width;

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF7C3AED),
            const Color(0xFF7C3AED).withValues(alpha: .4)
          ],
        ).createShader(Rect.fromLTWH(0, y, w, height));

      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(0, y, w, height), const Radius.circular(8)),
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// RADAR CHART
class _RadarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 20;

    final linePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: .2)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Outer grid rings
    for (int ring = 1; ring <= 4; ring++) {
      final ringR = r * (ring / 4);
      final ringPath = Path();
      for (int i = 0; i < 5; i++) {
        final angle = (i * 2 * math.pi / 5) - math.pi / 2;
        final x = cx + ringR * math.cos(angle);
        final y = cy + ringR * math.sin(angle);
        if (i == 0) {
          ringPath.moveTo(x, y);
        } else {
          ringPath.lineTo(x, y);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, linePaint);
    }

    // Draw Radar web spokes
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      canvas.drawLine(
          Offset(cx, cy),
          Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
          linePaint);
    }

    // Actual Data polygon
    final dataScale = [0.8, 0.9, 0.6, 0.75, 0.85];
    final radarPath = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final x = cx + r * dataScale[i] * math.cos(angle);
      final y = cy + r * dataScale[i] * math.sin(angle);
      if (i == 0) {
        radarPath.moveTo(x, y);
      } else {
        radarPath.lineTo(x, y);
      }
    }
    radarPath.close();

    canvas.drawPath(radarPath, fillPaint);
    canvas.drawPath(radarPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// GAUGE CHART
class _GaugeChartPainter extends CustomPainter {
  const _GaugeChartPainter({required this.percentage});
  final double percentage;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 20;
    final r = math.min(cx, size.height - 20) - 20;

    final bgPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.success, AppColors.primary],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw base semi-circle
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), math.pi,
        math.pi, false, bgPaint);

    // Draw gauge fill percentage
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), math.pi,
        math.pi * percentage, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
