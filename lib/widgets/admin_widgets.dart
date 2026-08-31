import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────
class AdminSectionHeader extends StatelessWidget {
  const AdminSectionHeader(
      {super.key,
      required this.title,
      this.subtitle,
      this.action,
      this.onAction});
  final String title;
  final String? subtitle, action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 13)),
                ],
              ],
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              child: Text(action!,
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
        ],
      );
}

// ─────────────────────────────────────────────
// DASHBOARD STAT CARD
// ─────────────────────────────────────────────
class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.trendUp = true,
  });
  final String label, value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool trendUp;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A0F172A), blurRadius: 20, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
                if (trend != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (trendUp ? AppColors.success : AppColors.danger)
                          .withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                            trendUp
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 12,
                            color:
                                trendUp ? AppColors.success : AppColors.danger),
                        const SizedBox(width: 3),
                        Text(trend!,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: trendUp
                                    ? AppColors.success
                                    : AppColors.danger)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(value,
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800, height: 1)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label});
  final String label;

  static Color _color(String s) {
    switch (s.toLowerCase()) {
      case 'active':
      case 'approved':
      case 'on time':
      case 'on duty':
        return AppColors.success;
      case 'inactive':
      case 'rejected':
      case 'deactivated':
        return AppColors.danger;
      case 'pending':
      case 'maintenance':
      case 'scheduled':
        return AppColors.warning;
      case 'arriving':
        return AppColors.primary;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: c.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: c, size: 7),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: c, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ADMIN AVATAR
// ─────────────────────────────────────────────
class AdminAvatar extends StatelessWidget {
  const AdminAvatar(
      {super.key,
      required this.initials,
      required this.color,
      this.radius = 20});
  final String initials;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: radius,
        backgroundColor: color.withValues(alpha: .15),
        child: Text(
          initials,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: radius * 0.7),
        ),
      );
}

// ─────────────────────────────────────────────
// PRIMARY BUTTON
// ─────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.icon,
      this.small = false});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool small;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
        onPressed: onPressed,
        icon: icon != null
            ? Icon(icon, size: small ? 15 : 18)
            : const SizedBox.shrink(),
        label: Text(label,
            style: TextStyle(
                fontSize: small ? 13 : 14, fontWeight: FontWeight.w700)),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
              vertical: small ? 10 : 13, horizontal: small ? 14 : 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}

// ─────────────────────────────────────────────
// SECONDARY BUTTON
// ─────────────────────────────────────────────
class SecondaryButton extends StatelessWidget {
  const SecondaryButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.icon,
      this.small = false});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool small;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null
            ? Icon(icon, size: small ? 15 : 18)
            : const SizedBox.shrink(),
        label: Text(label,
            style: TextStyle(
                fontSize: small ? 13 : 14, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: Color(0xFFBFDBFE)),
          padding: EdgeInsets.symmetric(
              vertical: small ? 10 : 13, horizontal: small ? 14 : 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}

// ─────────────────────────────────────────────
// DANGER BUTTON
// ─────────────────────────────────────────────
class DangerButton extends StatelessWidget {
  const DangerButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.icon,
      this.small = false});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool small;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null
            ? Icon(icon, size: small ? 15 : 18)
            : const SizedBox.shrink(),
        label: Text(label,
            style: TextStyle(
                fontSize: small ? 13 : 14, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          side: BorderSide(color: AppColors.danger.withValues(alpha: .3)),
          padding: EdgeInsets.symmetric(
              vertical: small ? 10 : 13, horizontal: small ? 14 : 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}

// ─────────────────────────────────────────────
// MODERN SEARCH BAR
// ─────────────────────────────────────────────
class ModernSearchBar extends StatelessWidget {
  const ModernSearchBar(
      {super.key, required this.hint, this.onChanged, this.controller});
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A0F172A), blurRadius: 12, offset: Offset(0, 2))
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon:
                const Icon(Icons.search_rounded, color: AppColors.muted),
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.muted),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// FILTER CHIP BAR
// ─────────────────────────────────────────────
class FilterChipBar extends StatefulWidget {
  const FilterChipBar({super.key, required this.options, this.onSelected});
  final List<String> options;
  final ValueChanged<String>? onSelected;

  @override
  State<FilterChipBar> createState() => _FilterChipBarState();
}

class _FilterChipBarState extends State<FilterChipBar> {
  String _selected = 'All';

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.options.map((opt) {
            final sel = _selected == opt;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selected = opt);
                  widget.onSelected?.call(opt);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                        color:
                            sel ? AppColors.primary : const Color(0xFFE2E8F0)),
                    boxShadow: sel
                        ? [
                            const BoxShadow(
                                color: Color(0x332563EB), blurRadius: 8)
                          ]
                        : null,
                  ),
                  child: Text(opt,
                      style: TextStyle(
                          color: sel ? Colors.white : AppColors.muted,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ),
              ),
            );
          }).toList(),
        ),
      );
}

// ─────────────────────────────────────────────
// ADMIN BUS CARD (for bus management grid)
// ─────────────────────────────────────────────
class AdminBusCard extends StatelessWidget {
  const AdminBusCard(
      {super.key,
      required this.bus,
      this.onEdit,
      this.onAssign,
      this.onDeactivate});
  final AdminBus bus;
  final VoidCallback? onEdit, onAssign, onDeactivate;

  @override
  Widget build(BuildContext context) => Container(
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.directions_bus_filled_rounded,
                      color: AppColors.primary, size: 26),
                ),
                const Spacer(),
                StatusBadge(label: bus.status),
              ],
            ),
            const SizedBox(height: 14),
            Text(bus.busNumber,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
            Text(bus.busName,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            _InfoRow(Icons.confirmation_number_rounded, bus.registrationNumber),
            const SizedBox(height: 4),
            _InfoRow(Icons.people_rounded,
                '${bus.currentOccupancy}/${bus.capacity} passengers'),
            const SizedBox(height: 4),
            _InfoRow(Icons.person_rounded, bus.driverName),
            const SizedBox(height: 4),
            _InfoRow(Icons.alt_route_rounded, bus.assignedRoute),
            const SizedBox(height: 4),
            _InfoRow(Icons.manage_accounts_rounded, bus.assignedInchargeName),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: SecondaryButton(
                        label: 'Edit',
                        onPressed: onEdit,
                        icon: Icons.edit_rounded,
                        small: true)),
                const SizedBox(width: 8),
                Expanded(
                    child: SecondaryButton(
                        label: 'Assign',
                        onPressed: onAssign,
                        icon: Icons.link_rounded,
                        small: true)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: DangerButton(
                  label:
                      bus.status == 'Maintenance' ? 'Activate' : 'Deactivate',
                  onPressed: onDeactivate,
                  icon: Icons.power_settings_new_rounded,
                  small: true),
            ),
          ],
        ),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 13, color: AppColors.muted),
          const SizedBox(width: 6),
          Expanded(
              child: Text(text,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
        ],
      );
}

// ─────────────────────────────────────────────
// ROUTE CARD (for route approval)
// ─────────────────────────────────────────────
class ApprovalRouteCard extends StatelessWidget {
  const ApprovalRouteCard(
      {super.key,
      required this.route,
      this.onApprove,
      this.onReject,
      this.onView});
  final RouteRecord route;
  final VoidCallback? onApprove, onReject, onView;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A0F172A), blurRadius: 20, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map preview
            Container(
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F1ED),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned.fill(
                      child: CustomPaint(painter: _MiniMapPainter())),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: const [
                            BoxShadow(color: Color(0x22000000), blurRadius: 8)
                          ]),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.alt_route_rounded,
                              size: 13, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text('${route.distanceKm} km',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: StatusBadge(label: route.status),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(route.routeName,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.manage_accounts_rounded,
                          size: 14, color: AppColors.muted),
                      const SizedBox(width: 5),
                      Text('${route.inchargeName} · ${route.busNumber}',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 14, color: AppColors.muted),
                      const SizedBox(width: 5),
                      Text(route.createdAt,
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _MiniStat(Icons.location_on_rounded,
                          '${route.stops.length} stops'),
                      const SizedBox(width: 16),
                      _MiniStat(
                          Icons.timer_rounded, '${route.durationMinutes} min'),
                      const SizedBox(width: 16),
                      _MiniStat(
                          Icons.straighten_rounded, '${route.distanceKm} km'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                          child: SecondaryButton(
                              label: 'View Route',
                              onPressed: onView,
                              icon: Icons.map_rounded,
                              small: true)),
                      const SizedBox(width: 8),
                      if (route.status == 'Pending') ...[
                        Expanded(
                            child: DangerButton(
                                label: 'Reject',
                                onPressed: onReject,
                                small: true)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: PrimaryButton(
                                label: 'Approve',
                                onPressed: onApprove,
                                icon: Icons.check_rounded,
                                small: true)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      );
}

// ─────────────────────────────────────────────
// TIMELINE WIDGET (boarding stops timeline)
// ─────────────────────────────────────────────
class StopTimelineWidget extends StatelessWidget {
  const StopTimelineWidget({super.key, required this.stops});
  final List<RecordedBoardingStop> stops;

  @override
  Widget build(BuildContext context) => Column(
        children: List.generate(stops.length, (i) {
          final stop = stops[i];
          final isLast = i == stops.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 36,
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: i == 0
                            ? AppColors.primary
                            : (isLast
                                ? AppColors.success
                                : const Color(0xFFEFF6FF)),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: .3),
                            width: 2),
                      ),
                      child: Center(
                        child: i == 0
                            ? const Icon(Icons.trip_origin_rounded,
                                size: 13, color: Colors.white)
                            : isLast
                                ? const Icon(Icons.flag_rounded,
                                    size: 13, color: Colors.white)
                                : Text('${i + 1}',
                                    style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800)),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 48,
                        color: AppColors.primary.withValues(alpha: .2),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(stop.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(stop.landmark,
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          StatusBadge(label: stop.type),
                          const SizedBox(width: 8),
                          Text('~${stop.estimatedWaitMinutes} min wait',
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      );
}

// ─────────────────────────────────────────────
// INCHARGE QUICK ACTION CARD
// ─────────────────────────────────────────────
class QuickActionCard extends StatelessWidget {
  const QuickActionCard(
      {super.key,
      required this.label,
      required this.icon,
      required this.color,
      required this.onTap});
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0A0F172A),
                  blurRadius: 14,
                  offset: Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MINI MAP PAINTER (for approval cards)
// ─────────────────────────────────────────────
class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..color = const Color(0xFFCBDCD3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height * .7)
      ..cubicTo(size.width * .25, size.height * .2, size.width * .6,
          size.height * 1.1, size.width, size.height * .3);
    canvas.drawPath(path, bg);
    canvas.drawPath(path, fg);
    // Draw stop dots
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * .2, size.height * .55), 5, dotPaint);
    canvas.drawCircle(Offset(size.width * .5, size.height * .6), 5, dotPaint);
    canvas.drawCircle(Offset(size.width * .8, size.height * .38), 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────
// INCHARGE ROUTE CARD (for history list)
// ─────────────────────────────────────────────
class InchargeRouteCard extends StatelessWidget {
  const InchargeRouteCard({super.key, required this.route, this.onTap});
  final RouteRecord route;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0A0F172A),
                  blurRadius: 14,
                  offset: Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.alt_route_rounded,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(route.routeName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                        '${route.createdAt} · ${route.distanceKm} km · ${route.stops.length} stops',
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(label: route.status),
                  const SizedBox(height: 6),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.muted, size: 20),
                ],
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// GLASSMORPHIC METRIC CHIP (for record route bottom sheet)
// ─────────────────────────────────────────────
class MetricChip extends StatelessWidget {
  const MetricChip(
      {super.key,
      required this.label,
      required this.value,
      required this.icon});
  final String label, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .06),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(height: 5),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 14)),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// ADMIN ADVERTISEMENT CARD
// ─────────────────────────────────────────────
class AdminAdCard extends StatelessWidget {
  const AdminAdCard(
      {super.key, required this.ad, this.onEdit, this.onDelete, this.onToggle});
  final AdminAdvertisement ad;
  final VoidCallback? onEdit, onDelete, onToggle;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            // Banner preview
            Container(
              height: 110,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [ad.color, ad.color.withValues(alpha: .7)]),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ad.tag,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.3)),
                  const SizedBox(height: 5),
                  Text(ad.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(ad.subtitle,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            // Controls
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(20))),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatusBadge(label: ad.status),
                          const SizedBox(height: 4),
                          Text('${ad.impressions} impressions',
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 12)),
                        ],
                      )),
                      Switch(
                          value: ad.status == 'Active',
                          onChanged: (_) => onToggle?.call(),
                          activeThumbColor: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${ad.scheduledFrom} – ${ad.scheduledTo}',
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 11)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: SecondaryButton(
                              label: 'Edit',
                              onPressed: onEdit,
                              icon: Icons.edit_rounded,
                              small: true)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: DangerButton(
                              label: 'Delete',
                              onPressed: onDelete,
                              icon: Icons.delete_rounded,
                              small: true)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────
// LIVE BUS STATUS ROW
// ─────────────────────────────────────────────
class LiveBusStatusRow extends StatelessWidget {
  const LiveBusStatusRow({super.key, required this.bus});
  final AdminBus bus;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x080F172A), blurRadius: 10)
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.directions_bus_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${bus.busNumber} · ${bus.busName}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(bus.assignedRoute,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(label: bus.status),
                const SizedBox(height: 3),
                Text('${bus.currentOccupancy}/${bus.capacity}',
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 11)),
              ],
            ),
          ],
        ),
      );
}
