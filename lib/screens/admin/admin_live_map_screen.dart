import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_models.dart';
import '../../providers/smart_bus_provider.dart';
import '../../theme/app_theme.dart';

class AdminLiveMapScreen extends StatefulWidget {
  const AdminLiveMapScreen({super.key});

  @override
  State<AdminLiveMapScreen> createState() => _AdminLiveMapScreenState();
}

class _AdminLiveMapScreenState extends State<AdminLiveMapScreen> {
  LiveBusRoute? _selectedRoute;
  LiveRouteStop? _selectedStop;
  bool _isBreakdownTabSelected = false;

  void _showInvalidateDialog(
      BuildContext context,
      SmartBusProvider provider,
      String stopId,
      String stopName,
      List<LiveBusRoute> routes) {
    // Pick other available stops as redirect candidates
    final candidateStops = <String>[];
    for (final r in routes) {
      for (final s in r.stops) {
        if (s.name != stopName && !candidateStops.contains(s.name)) {
          candidateStops.add(s.name);
        }
      }
    }
    String selectedTargetStop = candidateStops.isNotEmpty
        ? candidateStops.first
        : 'Central Campus Gate';
    final walkMsgController = TextEditingController(
      text: 'Stop temporarily merged into $selectedTargetStop. Please walk to $selectedTargetStop for pickup.',
    );

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF334155)),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.do_not_disturb_on_rounded,
                        color: AppColors.danger, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Invalidate Stop',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'No bus detour needed for "$stopName"',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select nearest stop to redirect students to:',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedTargetStop,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                          items: candidateStops.map((name) {
                            return DropdownMenuItem<String>(
                              value: name,
                              child: Row(
                                children: [
                                  const Icon(Icons.pin_drop_rounded,
                                      color: Color(0xFF38BDF8), size: 16),
                                  const SizedBox(width: 8),
                                  Text(name),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedTargetStop = val;
                                walkMsgController.text =
                                    'Stop temporarily merged into $val. Please walk to $val for pickup.';
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Walking instructions & Student notification:',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: walkMsgController,
                      maxLines: 2,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        hintText: 'e.g., Walk 200m north to next junction...',
                        hintStyle: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF334155)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF334155)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white60)),
                ),
                FilledButton.icon(
                  onPressed: () {
                    provider.adminInvalidateStop(
                      stopId: stopId,
                      redirectToStopName: selectedTargetStop,
                      walkInstructions: walkMsgController.text.trim(),
                    );
                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Stop "$stopName" invalidated. Detour removed & redirected to $selectedTargetStop.'),
                        backgroundColor: const Color(0xFF0F172A),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.directions_walk_rounded, size: 16),
                  label: const Text('Invalidate & Redirect'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SmartBusProvider>();
    final routes = provider.liveRoutes;
    final breakdown = provider.activeBreakdown;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: Row(
        children: [
          // ─── LEFT SIDEBAR: ROUTE CONTROLS & FLEET BREAKDOWN ───
          Container(
            width: 360,
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(
                right: BorderSide(color: Color(0xFF1E293B)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.map_rounded,
                                color: Color(0xFF60A5FA), size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Fleet Live Map',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800)),
                                Text('5 Routes • Real-time GPS',
                                    style: TextStyle(
                                        color: Colors.white60, fontSize: 11)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text('LIVE',
                                    style: TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Simulation Breakdown Trigger Button
                      if (breakdown == null)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              provider.triggerAutomatedBreakdownReroute(
                                busNumber: 'SB-04',
                                busName: 'Campus Express',
                                inchargeName: 'Meera Singh',
                                reason: 'Engine Breakdown',
                                location: 'Tech Park Gate (2 km)',
                                strandedStudentsCount: 15,
                              );
                              setState(() {
                                _isBreakdownTabSelected = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      '🚨 Simulated breakdown on Bus SB-04. Auto-rerouting activated!'),
                                  backgroundColor: AppColors.danger,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.warning_amber_rounded, size: 18),
                            label: const Text('Simulate SB-04 Breakdown'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        )
                      else
                        // Breakdown Alert Card & Breakdown Tab Switcher
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.danger.withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.emergency_rounded,
                                      color: AppColors.danger, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${breakdown.brokenBusNumber} Breakdown',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      provider.resolveActiveBreakdown();
                                      setState(() {
                                        _isBreakdownTabSelected = false;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Breakdown resolved. Standard fleet paths restored.'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF60A5FA),
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('Resolve',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: const Color(0xFF10B981)
                                          .withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.verified_rounded,
                                        color: Color(0xFF10B981), size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      '100% Coverage (${breakdown.coveredRemainingStops}/${breakdown.totalRemainingStops} Stops Handled)',
                                      style: const TextStyle(
                                          color: Color(0xFF34D399),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Interactive Tab Button for Breakdown Bus
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isBreakdownTabSelected = !_isBreakdownTabSelected;
                                    _selectedRoute = null;
                                    _selectedStop = null;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _isBreakdownTabSelected
                                        ? AppColors.danger.withValues(alpha: 0.35)
                                        : const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _isBreakdownTabSelected
                                          ? AppColors.danger
                                          : const Color(0xFF334155),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _isBreakdownTabSelected
                                            ? Icons.dashboard_customize_rounded
                                            : Icons.tab_rounded,
                                        color: _isBreakdownTabSelected
                                            ? const Color(0xFFFCA5A5)
                                            : Colors.white70,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Breakdown Bus: ${breakdown.brokenBusNumber}',
                                          style: TextStyle(
                                            color: _isBreakdownTabSelected
                                                ? Colors.white
                                                : Colors.white70,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _isBreakdownTabSelected
                                              ? AppColors.danger
                                              : Colors.white10,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _isBreakdownTabSelected ? 'OPEN' : 'VIEW STOPS',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Tab Switcher / Navigation indicator
                if (breakdown != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E293B),
                      border: Border(bottom: BorderSide(color: Color(0xFF334155))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isBreakdownTabSelected = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: !_isBreakdownTabSelected
                                    ? AppColors.primary.withValues(alpha: 0.25)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: !_isBreakdownTabSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'All Routes (5)',
                                style: TextStyle(
                                  color: !_isBreakdownTabSelected
                                      ? const Color(0xFF60A5FA)
                                      : Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isBreakdownTabSelected = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: _isBreakdownTabSelected
                                    ? AppColors.danger.withValues(alpha: 0.3)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _isBreakdownTabSelected
                                      ? AppColors.danger
                                      : Colors.transparent,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Breakdown Tab',
                                style: TextStyle(
                                  color: _isBreakdownTabSelected
                                      ? const Color(0xFFFCA5A5)
                                      : Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Main Sidebar Content: Either Breakdown Stops View OR Standard 5 Route List
                Expanded(
                  child: _isBreakdownTabSelected && breakdown != null
                      ? _buildBreakdownStopsTab(context, provider, breakdown, routes)
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: routes.length,
                          itemBuilder: (context, i) {
                            final r = routes[i];
                      final isSelected = _selectedRoute?.id == r.id;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? r.color.withValues(alpha: 0.18)
                              : const Color(0xFF1E293B).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? r.color
                                : r.isBrokenDown
                                    ? AppColors.danger
                                    : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              _selectedRoute = isSelected ? null : r;
                              _selectedStop = null;
                            });
                          },
                          leading: CircleAvatar(
                            backgroundColor: r.isBrokenDown
                                ? AppColors.danger
                                : r.color,
                            radius: 16,
                            child: Icon(
                              r.isBrokenDown
                                  ? Icons.warning_rounded
                                  : Icons.directions_bus_filled_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          title: Text(
                            r.name,
                            style: TextStyle(
                              color: r.isBrokenDown
                                  ? const Color(0xFFFCA5A5)
                                  : Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            '${r.busNumber} • ${r.stops.length} stops (${r.totalDistanceKm} km)',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 11),
                          ),
                          trailing: r.isBrokenDown
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: AppColors.danger, width: 0.8),
                                  ),
                                  child: const Text(
                                    'BREAKDOWN',
                                    style: TextStyle(
                                        color: AppColors.danger,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900),
                                  ),
                                )
                              : Icon(Icons.chevron_right_rounded,
                                  color: r.color, size: 18),
                        ),
                      );
                    },
                  ),
                ),

                // Selected Stop Info & Manual Reassign Tool
                if (_selectedStop != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E293B),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      border: Border(top: BorderSide(color: Color(0xFF334155))),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: Color(0xFF60A5FA), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedStop!.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _selectedStop = null),
                              icon: const Icon(Icons.close_rounded,
                                  color: Colors.white54, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Landmark: ${_selectedStop!.landmark} (Stop #${_selectedStop!.order})',
                          style: const TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                        const SizedBox(height: 12),
                        const Text('Reassign stop to another bus:',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: routes.map((rt) {
                            final isCurrent = _selectedStop!.assignedPickupBusNumber == rt.busNumber ||
                                (_selectedStop!.assignedPickupBusNumber == null && _selectedRoute?.busNumber == rt.busNumber);
                            return FilterChip(
                              label: Text(rt.busNumber,
                                  style: TextStyle(
                                      color: isCurrent ? Colors.white : Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                              selected: isCurrent,
                              selectedColor: rt.color,
                              backgroundColor: const Color(0xFF0F172A),
                              onSelected: (_) {
                                provider.adminReassignStopToBus(
                                    _selectedStop!.id, rt.busNumber);
                                setState(() {
                                  _selectedStop = _selectedStop!.copyWith(
                                    assignedPickupBusNumber: rt.busNumber,
                                  );
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Reassigned "${_selectedStop!.name}" to ${rt.busNumber} (${rt.busName})'),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ─── RIGHT CANVAS: UNIFIED 5-ROUTE MAP VISUALIZER ───
          Expanded(
            child: Stack(
              children: [
                // Interactive InteractiveViewer Map
                InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(200),
                  minScale: 0.6,
                  maxScale: 3.5,
                  child: CustomPaint(
                    size: const Size(1200, 900),
                    painter: _UnifiedFleetMapPainter(
                      routes: routes,
                      breakdown: breakdown,
                      selectedRouteId: _selectedRoute?.id,
                      selectedStopId: _selectedStop?.id,
                    ),
                  ),
                ),

                // Map Overlay Top Bar (Stats & Legend)
                Positioned(
                  top: 16,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1E293B)),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black45,
                                blurRadius: 14,
                                offset: Offset(0, 6))
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _routeBadge('Route 1 (North)', const Color(0xFF2563EB)),
                            const SizedBox(width: 10),
                            _routeBadge('Route 2 (West)', const Color(0xFF7C3AED)),
                            const SizedBox(width: 10),
                            _routeBadge('Route 3 (South)', const Color(0xFF10B981)),
                            const SizedBox(width: 10),
                            _routeBadge('Route 4 (East)', const Color(0xFFF59E0B)),
                            const SizedBox(width: 10),
                            _routeBadge('Route 5 (Outer)', const Color(0xFFEC4899)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (breakdown != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7F1D1D).withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.danger),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 14,
                                  offset: Offset(0, 6))
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.alt_route_rounded,
                                  color: Color(0xFFFDE047), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Detour Active: ${breakdown.assignedPickupBusNumber} Rescue Path (+${breakdown.detourDistanceKm} km)',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Floating Map Controls
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Column(
                    children: [
                      _mapFab(Icons.layers_rounded, 'Reset View', () {
                        setState(() {
                          _selectedRoute = null;
                          _selectedStop = null;
                        });
                      }),
                      const SizedBox(height: 10),
                      _mapFab(Icons.info_outline_rounded, 'Stops Info', () {
                        if (routes.isNotEmpty && routes.first.stops.isNotEmpty) {
                          setState(() {
                            _selectedRoute = routes.first;
                            _selectedStop = routes.first.stops[2];
                          });
                        }
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeBadge(String label, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      );

  Widget _mapFab(IconData icon, String tooltip, VoidCallback onTap) =>
      FloatingActionButton.small(
        tooltip: tooltip,
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        onPressed: onTap,
        child: Icon(icon, size: 18),
      );

  Widget _buildBreakdownStopsTab(
    BuildContext context,
    SmartBusProvider provider,
    BreakdownRerouteEvent breakdown,
    List<LiveBusRoute> routes,
  ) {
    // Find the broken route to access its full stops list
    LiveBusRoute? brokenRoute;
    for (final r in routes) {
      if (r.busNumber == breakdown.brokenBusNumber) {
        brokenRoute = r;
        break;
      }
    }

    final stops = brokenRoute?.stops ?? [];
    // Identify broken stop order (usually stops from index 2 onwards are remaining)
    final remainingStops = stops.where((s) => s.order >= 3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breakdown Tab Subheader
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: const Color(0xFF131D31),
          child: Row(
            children: [
              const Icon(Icons.hub_rounded, color: Color(0xFFFBBF24), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${breakdown.brokenBusNumber} Remaining Stops (${remainingStops.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'Per-stop bus reassignment & student invalidation',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _isBreakdownTabSelected = false),
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white54, size: 18),
                tooltip: 'Back to Route List',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),

        // Stop List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: remainingStops.length,
            itemBuilder: (context, idx) {
              final stop = remainingStops[idx];
              final isInvalidated = stop.isInvalidated;

              // Find current assignment from breakdown or stop
              final assignmentMatch = breakdown.stopAssignments
                  .where((a) => a.stopId == stop.id);
              final currentAssignedBus = assignmentMatch.isNotEmpty
                  ? assignmentMatch.first.assignedBusNumber
                  : (stop.assignedPickupBusNumber ?? 'SB-12');

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isInvalidated
                      ? const Color(0xFF1E293B).withValues(alpha: 0.4)
                      : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isInvalidated
                        ? Colors.white12
                        : const Color(0xFF334155),
                    width: 1.2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stop Title & Status Tag
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isInvalidated
                                  ? Colors.grey.withValues(alpha: 0.2)
                                  : AppColors.danger.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${stop.order}',
                              style: TextStyle(
                                color: isInvalidated
                                    ? Colors.white54
                                    : AppColors.danger,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stop.name,
                                  style: TextStyle(
                                    color: isInvalidated
                                        ? Colors.white54
                                        : Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    decoration: isInvalidated
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                Text(
                                  stop.landmark,
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isInvalidated)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF64748B)
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'INVALIDATED',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'ACTIVE RESCUE',
                                style: TextStyle(
                                  color: Color(0xFF34D399),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Invalidation notice / Redirection callout
                      if (isInvalidated && stop.redirectToStopName != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFF334155), width: 0.8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.directions_walk_rounded,
                                  color: Color(0xFF38BDF8), size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Redirected to: ${stop.redirectToStopName}',
                                      style: const TextStyle(
                                        color: Color(0xFF38BDF8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (stop.redirectMessage != null)
                                      Text(
                                        stop.redirectMessage!,
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Bus Reassignment Chips (Active stops only)
                      if (!isInvalidated) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Assigned Rescue Bus:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: routes
                              .where((r) => r.busNumber != breakdown.brokenBusNumber)
                              .map((rt) {
                            final isAssigned =
                                currentAssignedBus == rt.busNumber;
                            return ChoiceChip(
                              label: Text(
                                rt.busNumber,
                                style: TextStyle(
                                  color: isAssigned
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              selected: isAssigned,
                              selectedColor: rt.color,
                              backgroundColor: const Color(0xFF0F172A),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 0),
                              onSelected: (selected) {
                                if (selected) {
                                  provider.adminReassignStopToBus(
                                      stop.id, rt.busNumber);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Assigned "${stop.name}" to ${rt.busNumber} (${rt.busName})'),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: 10),
                      const Divider(color: Color(0xFF334155), height: 1),
                      const SizedBox(height: 8),

                      // Bottom Action Buttons: Invalidate OR Reactivate
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isInvalidated)
                            TextButton.icon(
                              onPressed: () {
                                provider.adminReactivateStop(stop.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Stop "${stop.name}" reactivated and restored to rescue path.'),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.replay_rounded,
                                  size: 14, color: Color(0xFF34D399)),
                              label: const Text(
                                'Reactivate Stop',
                                style: TextStyle(
                                    color: Color(0xFF34D399), fontSize: 11),
                              ),
                            )
                          else
                            OutlinedButton.icon(
                              onPressed: () => _showInvalidateDialog(
                                context,
                                provider,
                                stop.id,
                                stop.name,
                                routes,
                              ),
                              icon: const Icon(Icons.do_not_disturb_on_outlined,
                                  size: 14, color: Color(0xFFFCA5A5)),
                              label: const Text(
                                'Invalidate & Redirect',
                                style: TextStyle(
                                  color: Color(0xFFFCA5A5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color(0xFF7F1D1D), width: 0.8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// UNIFIED 5-ROUTE MAP CANVAS PAINTER
// ─────────────────────────────────────────────
class _UnifiedFleetMapPainter extends CustomPainter {
  const _UnifiedFleetMapPainter({
    required this.routes,
    this.breakdown,
    this.selectedRouteId,
    this.selectedStopId,
  });

  final List<LiveBusRoute> routes;
  final BreakdownRerouteEvent? breakdown;
  final String? selectedRouteId;
  final String? selectedStopId;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 1. Draw Map Grid & Background Roads
    _drawCampusMapGrid(canvas, size);

    // 2. Draw Central Campus Hub Node
    final campusPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawCircle(Offset(cx, cy), 18, campusPaint);
    canvas.drawCircle(
        Offset(cx, cy),
        26,
        Paint()
          ..color = const Color(0xFF38BDF8).withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '🏛️ Campus Gate',
        style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            backgroundColor: Color(0xCC0F172A)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(cx - textPainter.width / 2, cy + 32));

    // Convert GPS coordinates to canvas scale around (cx, cy)
    Offset toCanvasOffset(double lat, double lon) {
      const centerLat = 12.9450;
      const centerLon = 77.6000;
      final dx = (lon - centerLon) * 7500;
      final dy = -(lat - centerLat) * 7500;
      return Offset(cx + dx, cy + dy);
    }

    // 3. Draw All 5 Route Lines & Stop Nodes
    for (final route in routes) {
      final isDimmed = selectedRouteId != null && selectedRouteId != route.id;
      final alpha = isDimmed ? 0.3 : 1.0;
      final routeColor = route.color.withValues(alpha: alpha);

      final path = Path();
      final offsets = <Offset>[];

      for (int i = 0; i < route.stops.length; i++) {
        final stop = route.stops[i];
        final pt = toCanvasOffset(stop.latitude, stop.longitude);
        offsets.add(pt);
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }

      // Draw Main Route Line (Glow + Solid Path)
      final glowPaint = Paint()
        ..color = routeColor.withValues(alpha: 0.25 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, glowPaint);

      final linePaint = Paint()
        ..color = routeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, linePaint);

      // Draw Stop Pins (~1 km intervals)
      for (int i = 0; i < route.stops.length; i++) {
        final stop = route.stops[i];
        final pt = offsets[i];
        final isSelected = selectedStopId == stop.id;
        final isInvalidated = stop.isInvalidated;

        final isStranded = (stop.isBreakdownStranded ||
            (breakdown != null &&
                breakdown!.brokenBusNumber == route.busNumber &&
                i >= 2)) && !isInvalidated;

        final pinColor = isInvalidated
            ? const Color(0xFF64748B)
            : isStranded
                ? AppColors.danger
                : isSelected
                    ? const Color(0xFFFDE047)
                    : route.color;

        // Outer pulse circle for stranded stops
        if (isStranded) {
          canvas.drawCircle(
              pt,
              16,
              Paint()
                ..color = AppColors.danger.withValues(alpha: 0.35)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3);
        }

        // Draw walking vector line if stop is invalidated & redirected
        if (isInvalidated && stop.redirectToStopName != null) {
          // Find the target redirect stop position
          for (final r in routes) {
            final targetMatches = r.stops.where((s) => s.name == stop.redirectToStopName);
            if (targetMatches.isNotEmpty) {
              final targetPt = toCanvasOffset(
                  targetMatches.first.latitude, targetMatches.first.longitude);

              // Dotted/dashed walking vector
              final walkPaint = Paint()
                ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
                ..strokeWidth = 2
                ..style = PaintingStyle.stroke;

              const dashWidth = 5.0;
              const dashSpace = 4.0;
              final distance = (targetPt - pt).distance;
              final dx = (targetPt.dx - pt.dx) / distance;
              final dy = (targetPt.dy - pt.dy) / distance;
              double currentDist = 0.0;
              while (currentDist < distance) {
                final start = Offset(pt.dx + dx * currentDist, pt.dy + dy * currentDist);
                final endDist = math.min(currentDist + dashWidth, distance);
                final end = Offset(pt.dx + dx * endDist, pt.dy + dy * endDist);
                canvas.drawLine(start, end, walkPaint);
                currentDist += dashWidth + dashSpace;
              }

              // Walking icon badge halfway
              final midPt = Offset((pt.dx + targetPt.dx) / 2, (pt.dy + targetPt.dy) / 2);
              final walkBadge = TextPainter(
                text: const TextSpan(
                  text: '🚶 Walk to Pickup',
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    backgroundColor: Color(0xDD0F172A),
                  ),
                ),
                textDirection: TextDirection.ltr,
              )..layout();
              walkBadge.paint(canvas, Offset(midPt.dx - walkBadge.width / 2, midPt.dy - 12));
              break;
            }
          }
        }

        // Stop circle
        canvas.drawCircle(pt, isSelected ? 9 : 6, Paint()..color = pinColor);
        canvas.drawCircle(
            pt,
            isSelected ? 9 : 6,
            Paint()
              ..color = isInvalidated ? const Color(0xFF94A3B8) : Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.8);

        // Cross or inner mark for invalidated stop
        if (isInvalidated) {
          canvas.drawLine(
            Offset(pt.dx - 4, pt.dy - 4),
            Offset(pt.dx + 4, pt.dy + 4),
            Paint()
              ..color = Colors.white70
              ..strokeWidth = 1.5,
          );
          canvas.drawLine(
            Offset(pt.dx - 4, pt.dy + 4),
            Offset(pt.dx + 4, pt.dy - 4),
            Paint()
              ..color = Colors.white70
              ..strokeWidth = 1.5,
          );
        }

        // Stop Label (every stop or selected)
        final labelPainter = TextPainter(
          text: TextSpan(
            text: isInvalidated
                ? '✕ ${stop.name} (Walk to ${stop.redirectToStopName ?? "Nearby"})'
                : '${stop.name} (${stop.order})',
            style: TextStyle(
              color: isInvalidated
                  ? const Color(0xFF94A3B8)
                  : isStranded
                      ? const Color(0xFFFCA5A5)
                      : Colors.white70,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              decoration: isInvalidated ? TextDecoration.lineThrough : null,
              backgroundColor: const Color(0xCC0F172A),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        labelPainter.paint(canvas, Offset(pt.dx + 10, pt.dy - 6));
      }

      // Draw Bus Marker along the route
      if (offsets.length >= 3) {
        final busIndex = route.isBrokenDown ? 2 : 1;
        final busPt = offsets[busIndex];

        if (route.isBrokenDown) {
          // Broken Bus Warning Marker
          canvas.drawCircle(busPt, 18, Paint()..color = AppColors.danger);
          canvas.drawCircle(
              busPt,
              26,
              Paint()
                ..color = AppColors.danger.withValues(alpha: 0.4)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4);
          final brokenBusLabel = TextPainter(
            text: TextSpan(
              text: '⚠️ ${route.busNumber} BROKEN DOWN',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                backgroundColor: AppColors.danger,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          brokenBusLabel.paint(
              canvas, Offset(busPt.dx - brokenBusLabel.width / 2, busPt.dy - 32));
        } else {
          // Active Moving Bus Marker
          canvas.drawCircle(busPt, 14, Paint()..color = route.color);
          canvas.drawCircle(
              busPt,
              14,
              Paint()
                ..color = Colors.white
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2);

          final busLabel = TextPainter(
            text: TextSpan(
              text: '🚍 ${route.busNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                backgroundColor: Color(0xDD0F172A),
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          busLabel.paint(
              canvas, Offset(busPt.dx - busLabel.width / 2, busPt.dy - 22));
        }
      }
    }

    // 4. Draw Automated Breakdown Detour Reroute Path (Glowing Amber/Cyan)
    if (breakdown != null) {
      _drawOptimizedDetourPath(canvas, toCanvasOffset);
    }
  }

  void _drawCampusMapGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.4)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawOptimizedDetourPath(
      Canvas canvas, Offset Function(double, double) toOffset) {
    // Dynamically scan routes for any diverted stops assigned during breakdown
    for (final route in routes) {
      final divertedStops =
          route.stops.where((s) => s.isDivertedPickup).toList();
      if (divertedStops.isEmpty) continue;

      final firstDivertedIndex =
          route.stops.indexWhere((s) => s.isDivertedPickup);
      final lastDivertedIndex =
          route.stops.lastIndexWhere((s) => s.isDivertedPickup);

      final prevStop = firstDivertedIndex > 0
          ? route.stops[firstDivertedIndex - 1]
          : route.stops.first;
      final nextStop = lastDivertedIndex < route.stops.length - 1
          ? route.stops[lastDivertedIndex + 1]
          : route.stops.last;

      final startPt = toOffset(prevStop.latitude, prevStop.longitude);
      final endPt = toOffset(nextStop.latitude, nextStop.longitude);

      final detourPath = Path()..moveTo(startPt.dx, startPt.dy);

      for (final ds in divertedStops) {
        final pt = toOffset(ds.latitude, ds.longitude);
        detourPath.lineTo(pt.dx, pt.dy);
      }
      detourPath.lineTo(endPt.dx, endPt.dy);

      // Glowing Detour Path (Gold/Amber)
      final detourGlow = Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(detourPath, detourGlow);

      final detourLine = Paint()
        ..color = const Color(0xFFFBBF24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(detourPath, detourLine);

      // Draw U-Turn callout at the first diverted stop if U-turn is required
      final firstDiverted = divertedStops.first;
      if (firstDiverted.isUturnDetour) {
        final uTurnPt =
            toOffset(firstDiverted.latitude, firstDiverted.longitude);
        final uTurnBadge = TextPainter(
          text: TextSpan(
            text: '↩️ U-TURN & DIVERT: ${route.busNumber} to ${firstDiverted.name}',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              backgroundColor: Color(0xFFFDE047),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        uTurnBadge.paint(
          canvas,
          Offset(uTurnPt.dx - uTurnBadge.width / 2, uTurnPt.dy - 34),
        );
      }

      // Draw badges on each diverted stop
      for (final ds in divertedStops) {
        final pt = toOffset(ds.latitude, ds.longitude);
        // Outer pulsing amber ring
        canvas.drawCircle(
          pt,
          20,
          Paint()
            ..color = const Color(0xFFF59E0B).withValues(alpha: 0.45)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5,
        );

        final stopBadge = TextPainter(
          text: TextSpan(
            text: '🚍 Visited by ${route.busNumber}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              backgroundColor: Color(0xFFB45309),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        stopBadge.paint(canvas, Offset(pt.dx + 12, pt.dy + 8));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _UnifiedFleetMapPainter oldDelegate) => true;
}
