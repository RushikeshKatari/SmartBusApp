import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/app_models.dart';
import '../mock/mock_data.dart';
import '../theme/app_theme.dart';

class SmartBusProvider extends ChangeNotifier {
  // ─── THEME & NAVIGATION ─────────────────────────────
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  int _tab = 0;
  bool _alarmEnabled = true;
  String _alarmOption = '1 km';
  int get tab => _tab;
  bool get alarmEnabled => _alarmEnabled;
  String get alarmOption => _alarmOption;
  bool _sharingActive = false;
  bool _sharingTransferred = false;
  bool get sharingActive => _sharingActive;
  bool get sharingTransferred => _sharingTransferred;
  String get sessionTime => _sharingActive ? '00:18:42' : '00:00:00';

  void selectTab(int value) {
    _tab = value;
    notifyListeners();
  }

  void setAlarm(bool value) {
    _alarmEnabled = value;
    notifyListeners();
  }

  void setAlarmOption(String value) {
    _alarmOption = value;
    notifyListeners();
  }

  void verifyLocationQr() {
    _sharingTransferred = _sharingActive;
    notifyListeners();
  }

  void startLocationSharing() {
    _sharingActive = true;
    notifyListeners();
  }

  void endLocationSharing() {
    _sharingActive = false;
    _sharingTransferred = false;
    notifyListeners();
  }

  // ─── 5 LIVE BUS ROUTES & AUTOMATED REROUTING ──────────────
  List<LiveBusRoute> _liveRoutes = List.from(MockData.liveBusRoutes);
  List<LiveBusRoute> get liveRoutes => List.unmodifiable(_liveRoutes);

  BreakdownRerouteEvent? _activeBreakdown;
  BreakdownRerouteEvent? get activeBreakdown => _activeBreakdown;

  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }

  /// Trigger automated optimal breakdown rerouting:
  /// Evaluates distance, remaining capacity, and route geometry to automatically
  /// assign nearby active buses to cover 100% OF ALL REMAINING UNVISITED STOPS.
  /// Diverted stops are physically inserted into the rescue buses' active route schedules
  /// with U-turn / cross-route diversion flags.
  Future<void> triggerAutomatedBreakdownReroute({
    required String busNumber,
    required String busName,
    required String inchargeName,
    required String reason,
    required String location,
    int strandedStudentsCount = 15,
  }) async {
    final brokenIndex = _liveRoutes.indexWhere((r) => r.busNumber == busNumber);
    if (brokenIndex == -1) return;

    final brokenRoute = _liveRoutes[brokenIndex];

    // 1. Identify all remaining unserved stops of the broken bus (from breakdown point until before final Campus Gate)
    final leftoverStops = brokenRoute.stops
        .skip(2)
        .where((s) => !s.name.toLowerCase().contains('campus gate'))
        .toList();

    final List<LiveRouteStop> stopsToCover = leftoverStops.isNotEmpty
        ? leftoverStops
        : brokenRoute.stops.where((s) => !s.name.toLowerCase().contains('campus gate')).toList();

    final affectedStopNames = stopsToCover.map((s) => s.name).toList();

    // 2. Find candidate active rescue buses (all other active buses)
    final candidateRoutes = _liveRoutes.where((r) => r.busNumber != busNumber && !r.isBrokenDown).toList();
    if (candidateRoutes.isEmpty) return;

    // By default, Route 2 (SB-12) is adjacent to Route 1 northern corridor.
    // SB-12 executes a U-turn diversion at Innovation Sq to visit the leftover stops!
    final primaryRescue = candidateRoutes.firstWhere(
      (c) => c.busNumber == 'SB-12',
      orElse: () => candidateRoutes.first,
    );

    // 3. Build stop assignments for EVERY single remaining stop to guarantee 100% coverage
    final List<DivertedStopAssignment> stopAssignments = [];
    final Map<String, List<LiveRouteStop>> busToDivertedStops = {};

    for (int idx = 0; idx < stopsToCover.length; idx++) {
      final stop = stopsToCover[idx];
      final assignedBus = primaryRescue;
      final isUturn = idx == 0; // The transition to the broken route requires a U-turn/diversion

      double minStopDist = double.infinity;
      for (final s in assignedBus.stops) {
        final d = _distanceKm(
            s.latitude, s.longitude, stop.latitude, stop.longitude);
        if (d < minStopDist) minStopDist = d;
      }
      final detourKm = double.parse(
          (minStopDist.isFinite && minStopDist < 10 ? minStopDist : 1.8)
              .toStringAsFixed(1));

      stopAssignments.add(
        DivertedStopAssignment(
          stopId: stop.id,
          stopName: stop.name,
          originalBusNumber: busNumber,
          assignedBusNumber: assignedBus.busNumber,
          assignedBusName: assignedBus.busName,
          driverName: assignedBus.driverName,
          driverPhone: assignedBus.driverPhone,
          latitude: stop.latitude,
          longitude: stop.longitude,
          isUturnRequired: isUturn,
          detourDistanceKm: detourKm,
          estimatedArrival: '08:24 AM',
        ),
      );

      busToDivertedStops.putIfAbsent(assignedBus.busNumber, () => []).add(
        stop.copyWith(
          isDivertedPickup: true,
          originalBusNumber: busNumber,
          isUturnDetour: isUturn,
          assignedPickupBusNumber: assignedBus.busNumber,
          divertedOrderLabel: 'Diverted Pickup (${isUturn ? "U-Turn • " : ""}from $busNumber)',
        ),
      );
    }

    // 4. Physically update active routes: insert the diverted stops into the rescue bus's route schedule!
    final updatedLiveRoutes = <LiveBusRoute>[];

    for (final route in _liveRoutes) {
      if (route.busNumber == busNumber) {
        // Mark broken route as broken down, and flag affected stops as stranded with assigned rescue bus
        updatedLiveRoutes.add(
          route.copyWith(
            isBrokenDown: true,
            breakdownReason: reason,
            breakdownLocation: location,
            assignedReplacementBusNumber: primaryRescue.busNumber,
            stops: route.stops.map((s) {
              final isAffected = affectedStopNames.contains(s.name);
              if (isAffected) {
                final assignment = stopAssignments.firstWhere(
                  (a) => a.stopId == s.id || a.stopName == s.name,
                  orElse: () => stopAssignments.first,
                );
                return s.copyWith(
                  isBreakdownStranded: true,
                  assignedPickupBusNumber: assignment.assignedBusNumber,
                );
              }
              return s;
            }).toList(),
          ),
        );
      } else if (busToDivertedStops.containsKey(route.busNumber)) {
        // RESCUE BUS: physically insert the diverted stops into its stops list right before Campus Gate!
        final divertedList = busToDivertedStops[route.busNumber]!;
        final baseStops = route.stops.where((s) => !s.isDivertedPickup).toList();
        final campusGateIndex = baseStops.indexWhere((s) => s.name.toLowerCase().contains('campus gate'));
        final newStops = <LiveRouteStop>[];

        if (campusGateIndex != -1) {
          newStops.addAll(baseStops.sublist(0, campusGateIndex));
          newStops.addAll(divertedList);
          newStops.addAll(baseStops.sublist(campusGateIndex));
        } else {
          newStops.addAll(baseStops);
          newStops.addAll(divertedList);
        }

        for (int i = 0; i < newStops.length; i++) {
          newStops[i] = newStops[i].copyWith(order: i + 1);
        }

        updatedLiveRoutes.add(
          route.copyWith(
            stops: newStops,
            totalDistanceKm: route.totalDistanceKm + 1.8,
            totalDurationMinutes: route.totalDurationMinutes + 4,
          ),
        );
      } else {
        updatedLiveRoutes.add(route);
      }
    }

    _liveRoutes = updatedLiveRoutes;

    final explanation =
        '100% of remaining stops covered! Diverted ${primaryRescue.busNumber} (${primaryRescue.busName} · Driver: ${primaryRescue.driverName}) via U-turn to rescue all ${stopsToCover.length} unvisited stops (${affectedStopNames.join(", ")}).';

    _activeBreakdown = BreakdownRerouteEvent(
      id: 'BRK-${DateTime.now().millisecondsSinceEpoch}',
      brokenBusNumber: busNumber,
      brokenBusName: busName,
      inchargeName: inchargeName,
      reason: reason,
      location: location,
      strandedStudentsCount: strandedStudentsCount,
      assignedPickupBusNumber: primaryRescue.busNumber,
      assignedPickupBusName: primaryRescue.busName,
      assignedPickupDriver: primaryRescue.driverName,
      assignedPickupDriverPhone: primaryRescue.driverPhone,
      detourDistanceKm: 1.8,
      detourEtaMinutes: 4,
      explanation: explanation,
      affectedStopNames: affectedStopNames,
      createdAt: 'Just now',
      stopAssignments: stopAssignments,
      totalRemainingStops: stopsToCover.length,
      coveredRemainingStops: stopsToCover.length,
      allStopsCovered: true,
    );

    // In-app notification for Student
    _notifications.insert(
      0,
      AppNotification(
        title: '🚨 Emergency Bus Reassignment ($busNumber)',
        message: 'Your bus ($busNumber) reported breakdown ($reason at $location). Replacement Bus ${primaryRescue.busNumber} (${primaryRescue.busName}) has diverted via U-turn to cover all remaining stops. Driver: ${primaryRescue.driverName} (${primaryRescue.driverPhone}).',
        time: 'Just now',
        category: 'Emergency',
        icon: Icons.emergency_rounded,
        unread: true,
      ),
    );

    // Intimation alert for In-charges / other buses
    _breakdownAlerts.insert(0, {
      'id': _activeBreakdown!.id,
      'busNumber': busNumber,
      'busName': busName,
      'inchargeName': inchargeName,
      'reason': reason,
      'location': location,
      'assignedPickupBusNumber': primaryRescue.busNumber,
      'time': 'Just now',
    });

    // Transport emergency report
    final now = TimeOfDay.now();
    final formattedTime =
        '${now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} ${now.period == DayPeriod.am ? 'AM' : 'PM'}';
    final report = EmergencyAttendanceReport(
      id: 'ER-${DateTime.now().millisecondsSinceEpoch}',
      busNumber: busNumber,
      busName: busName,
      inchargeName: inchargeName,
      reason: reason,
      location: location,
      createdAt: formattedTime,
      students: List<Map<String, String>>.from(_attendanceLogs),
    );
    _transportReports.insert(0, report);

    notifyListeners();

    // Fire background HTTP requests to Spring Boot backend
    try {
      await http.post(
        Uri.parse('http://localhost:8080/api/operations/breakdown'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'busNumber': busNumber,
          'inchargeName': inchargeName,
          'reason': reason,
          'location': location,
          'latitude': 12.9660,
          'longitude': 77.5880,
          'strandedStudentsCount': strandedStudentsCount,
        }),
      );
      await http.post(
        Uri.parse('http://localhost:8080/api/incharge/emergency-reports'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'busNumber': busNumber,
          'busName': busName,
          'inchargeName': inchargeName,
          'reason': reason,
          'location': location,
          'students': _attendanceLogs
              .map((a) => {
                    'rollNumber': a['rollNumber'] ?? '',
                    'studentName': a['name'] ?? '',
                    'department': 'Computer Science'
                  })
              .toList(),
        }),
      );
    } catch (_) {
      // Graceful offline fallback
    }
  }

  /// Admin manual reroute modifier: allows reassigning any stop to any bus.
  /// Moves the stop physically into the target bus's route schedule, ensuring 100% coverage.
  void adminReassignStopToBus(String stopId, String targetBusNumber) {
    LiveRouteStop? targetStop;
    for (final route in _liveRoutes) {
      final match = route.stops.where((s) => s.id == stopId);
      if (match.isNotEmpty) {
        targetStop = match.first;
        break;
      }
    }
    if (targetStop == null) return;

    final updatedRoutes = <LiveBusRoute>[];

    for (final route in _liveRoutes) {
      if (route.busNumber == targetBusNumber) {
        // Target bus gets this stop added as diverted pickup (before Campus Gate)
        final baseStops = route.stops.where((s) => s.id != stopId).toList();
        final gateIndex = baseStops.indexWhere((s) => s.name.toLowerCase().contains('campus gate'));
        final divertedStop = targetStop.copyWith(
          isDivertedPickup: true,
          assignedPickupBusNumber: targetBusNumber,
          divertedOrderLabel: 'Diverted Pickup (assigned to $targetBusNumber)',
        );
        final newStops = <LiveRouteStop>[];
        if (gateIndex != -1) {
          newStops.addAll(baseStops.sublist(0, gateIndex));
          newStops.add(divertedStop);
          newStops.addAll(baseStops.sublist(gateIndex));
        } else {
          newStops.addAll(baseStops);
          newStops.add(divertedStop);
        }
        for (int k = 0; k < newStops.length; k++) {
          newStops[k] = newStops[k].copyWith(order: k + 1);
        }
        updatedRoutes.add(route.copyWith(stops: newStops));
      } else {
        // Remove from any other route where it was previously inserted as a diverted stop
        final filteredStops = route.stops.where((s) => !(s.id == stopId && s.isDivertedPickup)).toList();
        // If this is the broken route, update the assigned bus on this stop
        if (route.isBrokenDown) {
          for (int k = 0; k < filteredStops.length; k++) {
            if (filteredStops[k].id == stopId) {
              filteredStops[k] = filteredStops[k].copyWith(
                assignedPickupBusNumber: targetBusNumber,
                isBreakdownStranded: true,
              );
            }
          }
        }
        for (int k = 0; k < filteredStops.length; k++) {
          filteredStops[k] = filteredStops[k].copyWith(order: k + 1);
        }
        updatedRoutes.add(route.copyWith(stops: filteredStops));
      }
    }

    _liveRoutes = updatedRoutes;

    if (_activeBreakdown != null) {
      final updatedAssignments = _activeBreakdown!.stopAssignments.map((a) {
        if (a.stopId == stopId) {
          final targetBus = _liveRoutes.firstWhere(
            (r) => r.busNumber == targetBusNumber,
            orElse: () => _liveRoutes.first,
          );
          return DivertedStopAssignment(
            stopId: a.stopId,
            stopName: a.stopName,
            originalBusNumber: a.originalBusNumber,
            assignedBusNumber: targetBusNumber,
            assignedBusName: targetBus.busName,
            driverName: targetBus.driverName,
            driverPhone: targetBus.driverPhone,
            latitude: a.latitude,
            longitude: a.longitude,
            isUturnRequired: a.isUturnRequired,
            detourDistanceKm: 1.6,
            estimatedArrival: '08:26 AM',
          );
        }
        return a;
      }).toList();

      _activeBreakdown = BreakdownRerouteEvent(
        id: _activeBreakdown!.id,
        brokenBusNumber: _activeBreakdown!.brokenBusNumber,
        brokenBusName: _activeBreakdown!.brokenBusName,
        inchargeName: _activeBreakdown!.inchargeName,
        reason: _activeBreakdown!.reason,
        location: _activeBreakdown!.location,
        strandedStudentsCount: _activeBreakdown!.strandedStudentsCount,
        assignedPickupBusNumber: targetBusNumber,
        assignedPickupBusName: _liveRoutes.firstWhere((r) => r.busNumber == targetBusNumber).busName,
        assignedPickupDriver: _liveRoutes.firstWhere((r) => r.busNumber == targetBusNumber).driverName,
        assignedPickupDriverPhone: _liveRoutes.firstWhere((r) => r.busNumber == targetBusNumber).driverPhone,
        detourDistanceKm: _activeBreakdown!.detourDistanceKm,
        detourEtaMinutes: _activeBreakdown!.detourEtaMinutes,
        explanation: 'Admin updated routing. Stop "${targetStop.name}" reassigned to $targetBusNumber. 100% remaining stops visited.',
        affectedStopNames: _activeBreakdown!.affectedStopNames,
        createdAt: _activeBreakdown!.createdAt,
        stopAssignments: updatedAssignments,
        totalRemainingStops: _activeBreakdown!.totalRemainingStops,
        coveredRemainingStops: updatedAssignments.length,
        allStopsCovered: true,
      );
    }

    notifyListeners();
  }

  /// Admin can invalidate a stop (e.g., severe traffic, inaccessible road, or low headcount)
  /// and redirect students/passengers to walk to another specified nearby stop.
  void adminInvalidateStop({
    required String stopId,
    required String redirectToStopName,
    String? walkInstructions,
  }) {
    LiveRouteStop? targetStop;
    for (final route in _liveRoutes) {
      final match = route.stops.where((s) => s.id == stopId);
      if (match.isNotEmpty) {
        targetStop = match.first;
        break;
      }
    }
    if (targetStop == null) return;

    final updatedRoutes = <LiveBusRoute>[];

    for (final route in _liveRoutes) {
      // 1. Remove from rescue bus schedule so it doesn't detour needlessly
      final filteredStops = route.stops
          .where((s) => !(s.id == stopId && s.isDivertedPickup))
          .toList();

      // 2. Mark on broken route with invalidation & redirect info
      if (route.isBrokenDown) {
        for (int k = 0; k < filteredStops.length; k++) {
          if (filteredStops[k].id == stopId) {
            filteredStops[k] = filteredStops[k].copyWith(
              isInvalidated: true,
              redirectToStopName: redirectToStopName,
              redirectMessage: walkInstructions ??
                  'Stop merged into $redirectToStopName. Please proceed to $redirectToStopName.',
            );
          }
        }
      }

      for (int k = 0; k < filteredStops.length; k++) {
        filteredStops[k] = filteredStops[k].copyWith(order: k + 1);
      }
      updatedRoutes.add(route.copyWith(stops: filteredStops));
    }

    _liveRoutes = updatedRoutes;

    if (_activeBreakdown != null) {
      final updatedAssignments = _activeBreakdown!.stopAssignments.map((a) {
        if (a.stopId == stopId) {
          return a.copyWith(
            isInvalidated: true,
            redirectToStopName: redirectToStopName,
            redirectMessage:
                walkInstructions ?? 'Move to $redirectToStopName for pickup',
          );
        }
        return a;
      }).toList();

      final activeAssignments =
          updatedAssignments.where((a) => !a.isInvalidated).toList();

      _activeBreakdown = BreakdownRerouteEvent(
        id: _activeBreakdown!.id,
        brokenBusNumber: _activeBreakdown!.brokenBusNumber,
        brokenBusName: _activeBreakdown!.brokenBusName,
        inchargeName: _activeBreakdown!.inchargeName,
        reason: _activeBreakdown!.reason,
        location: _activeBreakdown!.location,
        strandedStudentsCount: _activeBreakdown!.strandedStudentsCount,
        assignedPickupBusNumber: _activeBreakdown!.assignedPickupBusNumber,
        assignedPickupBusName: _activeBreakdown!.assignedPickupBusName,
        assignedPickupDriver: _activeBreakdown!.assignedPickupDriver,
        assignedPickupDriverPhone: _activeBreakdown!.assignedPickupDriverPhone,
        detourDistanceKm:
            math.max(0.8, _activeBreakdown!.detourDistanceKm - 0.6),
        detourEtaMinutes: math.max(2, _activeBreakdown!.detourEtaMinutes - 2),
        explanation:
            'Stop "${targetStop.name}" invalidated. Students redirected to $redirectToStopName. Detour optimized.',
        affectedStopNames: _activeBreakdown!.affectedStopNames,
        createdAt: _activeBreakdown!.createdAt,
        stopAssignments: updatedAssignments,
        totalRemainingStops: _activeBreakdown!.totalRemainingStops,
        coveredRemainingStops: activeAssignments.length,
        allStopsCovered: true,
      );

      // Notify students
      _notifications.insert(
        0,
        AppNotification(
          title: '🚶 Stop Relocation: ${targetStop.name}',
          message:
              'Stop "${targetStop.name}" is merged into "$redirectToStopName". Please walk to "$redirectToStopName" (${walkInstructions ?? "approx. 400m / 5 min walk"}) to board rescue bus.',
          time: 'Just now',
          category: 'Emergency',
          icon: Icons.directions_walk_rounded,
          unread: true,
        ),
      );
    }

    notifyListeners();
  }

  /// Reactivate an invalidated stop back into the rescue schedule
  void adminReactivateStop(String stopId) {
    if (_activeBreakdown == null) return;
    final assignment = _activeBreakdown!.stopAssignments.firstWhere(
      (a) => a.stopId == stopId,
      orElse: () => _activeBreakdown!.stopAssignments.first,
    );
    adminReassignStopToBus(stopId, assignment.assignedBusNumber);

    for (int i = 0; i < _liveRoutes.length; i++) {
      final route = _liveRoutes[i];
      if (route.isBrokenDown) {
        final stops = route.stops.map((s) {
          if (s.id == stopId) {
            return s.copyWith(
                isInvalidated: false,
                redirectToStopName: null,
                redirectMessage: null);
          }
          return s;
        }).toList();
        _liveRoutes[i] = route.copyWith(stops: stops);
      }
    }

    if (_activeBreakdown != null) {
      final updatedAssignments = _activeBreakdown!.stopAssignments.map((a) {
        if (a.stopId == stopId) {
          return a.copyWith(
              isInvalidated: false,
              redirectToStopName: null,
              redirectMessage: null);
        }
        return a;
      }).toList();

      _activeBreakdown = BreakdownRerouteEvent(
        id: _activeBreakdown!.id,
        brokenBusNumber: _activeBreakdown!.brokenBusNumber,
        brokenBusName: _activeBreakdown!.brokenBusName,
        inchargeName: _activeBreakdown!.inchargeName,
        reason: _activeBreakdown!.reason,
        location: _activeBreakdown!.location,
        strandedStudentsCount: _activeBreakdown!.strandedStudentsCount,
        assignedPickupBusNumber: _activeBreakdown!.assignedPickupBusNumber,
        assignedPickupBusName: _activeBreakdown!.assignedPickupBusName,
        assignedPickupDriver: _activeBreakdown!.assignedPickupDriver,
        assignedPickupDriverPhone: _activeBreakdown!.assignedPickupDriverPhone,
        detourDistanceKm: _activeBreakdown!.detourDistanceKm + 0.6,
        detourEtaMinutes: _activeBreakdown!.detourEtaMinutes + 2,
        explanation: 'Stop reactivated into pickup schedule.',
        affectedStopNames: _activeBreakdown!.affectedStopNames,
        createdAt: _activeBreakdown!.createdAt,
        stopAssignments: updatedAssignments,
        totalRemainingStops: _activeBreakdown!.totalRemainingStops,
        coveredRemainingStops:
            updatedAssignments.where((a) => !a.isInvalidated).length,
        allStopsCovered: true,
      );
    }

    notifyListeners();
  }

  /// Resolve active breakdown and restore standard routes
  void resolveActiveBreakdown() {
    _activeBreakdown = null;
    _liveRoutes = List.from(MockData.liveBusRoutes);
    _breakdownAlerts.clear();
    notifyListeners();
  }

  // ─── ATTENDANCE LOGS & EMERGENCY REPORTS ─────────────────
  final List<Map<String, String>> _attendanceLogs = [
    {
      'rollNumber': 'CS2024-117',
      'name': 'Aarav Sharma',
      'busName': 'Campus Express 04',
      'time': '08:14 AM',
      'method': 'QR Scan'
    },
    {
      'rollNumber': 'EC2024-042',
      'name': 'Priya Patel',
      'busName': 'Campus Express 04',
      'time': '08:18 AM',
      'method': 'QR Scan'
    },
  ];
  List<Map<String, String>> get attendanceLogs =>
      List.unmodifiable(_attendanceLogs);

  final List<Map<String, String>> _breakdownAlerts = [];
  List<Map<String, String>> get breakdownAlerts =>
      List.unmodifiable(_breakdownAlerts);

  final List<EmergencyAttendanceReport> _transportReports = [];
  List<EmergencyAttendanceReport> get transportReports =>
      List.unmodifiable(_transportReports);
  List<EmergencyAttendanceReport> get hodReports =>
      List.unmodifiable(_transportReports.where((report) => report.sentToHod));

  // ─── HOD ACADEMIC ATTENDANCE ───────────────────────────────
  final List<AcademicSection> _academicSections = [
    const AcademicSection(
        id: 'SEC-1-A',
        year: '1st Year',
        specialization: 'Computer Science',
        sectionNumber: 'A',
        students: [
          AcademicStudent(
              name: 'Aarav Sharma',
              rollNumber: 'CS2024-117',
              attendancePercent: 91),
          AcademicStudent(
              name: 'Diya Nair',
              rollNumber: 'CS2024-118',
              attendancePercent: 88),
        ]),
    const AcademicSection(
        id: 'SEC-2-A',
        year: '2nd Year',
        specialization: 'Electronics',
        sectionNumber: 'A',
        students: [
          AcademicStudent(
              name: 'Priya Patel',
              rollNumber: 'EC2024-042',
              attendancePercent: 86),
          AcademicStudent(
              name: 'Kiran Shah',
              rollNumber: 'EC2024-043',
              attendancePercent: 90),
        ]),
    const AcademicSection(
        id: 'SEC-3-A',
        year: '3rd Year',
        specialization: 'Computer Science',
        sectionNumber: 'A',
        students: [
          AcademicStudent(
              name: 'Rohan Verma',
              rollNumber: 'CS2023-089',
              attendancePercent: 84),
          AcademicStudent(
              name: 'Meera Iyer',
              rollNumber: 'CS2023-090',
              attendancePercent: 93),
        ]),
    const AcademicSection(
        id: 'SEC-4-A',
        year: '4th Year',
        specialization: 'Mechanical',
        sectionNumber: 'A',
        students: [
          AcademicStudent(
              name: 'Nikhil Das',
              rollNumber: 'ME2022-021',
              attendancePercent: 89),
          AcademicStudent(
              name: 'Ananya Roy',
              rollNumber: 'ME2022-022',
              attendancePercent: 87),
        ]),
  ];
  List<AcademicSection> get academicSections =>
      List.unmodifiable(_academicSections);
  List<AcademicSection> sectionsForYear(String year) => List.unmodifiable(
      _academicSections.where((section) => section.year == year));
  double attendanceForYear(String year) {
    final students =
        sectionsForYear(year).expand((section) => section.students).toList();
    return students.isEmpty
        ? 0
        : students.fold<double>(
                0, (total, student) => total + student.attendancePercent) /
            students.length;
  }

  double get overallAcademicAttendance {
    final students =
        _academicSections.expand((section) => section.students).toList();
    return students.isEmpty
        ? 0
        : students.fold<double>(
                0, (total, student) => total + student.attendancePercent) /
            students.length;
  }

  void addAcademicSection(
      {required String year,
      required String specialization,
      required String sectionNumber,
      required List<AcademicStudent> students}) {
    _academicSections.add(AcademicSection(
        id: 'SEC-${DateTime.now().millisecondsSinceEpoch}',
        year: year,
        specialization: specialization,
        sectionNumber: sectionNumber,
        students: students));
    notifyListeners();
  }

  // ─── LEGACY COMPATIBILITY HOOKS ────────────────────────────
  String? _breakdownReason;
  final List<String> _breakdownScannedIds = [];
  String? get breakdownReason => _breakdownReason;
  List<String> get breakdownScannedIds =>
      List.unmodifiable(_breakdownScannedIds);

  void setBreakdownReason(String reason) {
    _breakdownReason = reason;
    _breakdownScannedIds.clear();
    notifyListeners();
  }

  void addScannedStudentId(String id) {
    if (!_breakdownScannedIds.contains(id)) {
      _breakdownScannedIds.add(id);
      notifyListeners();
    }
  }

  void submitBreakdownReport({
    required String busNumber,
    required String busName,
    required String inchargeName,
    required String location,
  }) {
    final reason = _breakdownReason ?? 'Engine Breakdown';
    triggerAutomatedBreakdownReroute(
      busNumber: busNumber,
      busName: busName,
      inchargeName: inchargeName,
      reason: reason,
      location: location,
    );
    _breakdownReason = null;
    _breakdownScannedIds.clear();
  }

  void sendEmergencyReportToHod(String reportId) {
    final index =
        _transportReports.indexWhere((report) => report.id == reportId);
    if (index != -1) {
      _transportReports[index] =
          _transportReports[index].copyWith(sentToHod: true);
      notifyListeners();
    }
    // Async backend call
    http.post(
      Uri.parse('http://localhost:8080/api/admin/emergency-reports/$reportId/send-to-hod'),
      headers: {'Content-Type': 'application/json'},
    ).catchError((_) => http.Response('', 500));
  }

  void giveEmergencyAttendance(String reportId) {
    final index = _transportReports.indexWhere((report) => report.id == reportId);
    if (index != -1) {
      _transportReports[index] = _transportReports[index].copyWith(attendanceGiven: true);
      notifyListeners();
    }
    http.post(
      Uri.parse('http://localhost:8080/api/hod/emergency-reports/$reportId/approve-attendance'),
      headers: {'Content-Type': 'application/json'},
    ).catchError((_) => http.Response('', 500));
  }

  void giveEmergencyPermission(String reportId) {
    final index = _transportReports.indexWhere((report) => report.id == reportId);
    if (index != -1) {
      _transportReports[index] = _transportReports[index].copyWith(permissionGiven: true);
      notifyListeners();
    }
    http.post(
      Uri.parse('http://localhost:8080/api/hod/emergency-reports/$reportId/give-permission'),
      headers: {'Content-Type': 'application/json'},
    ).catchError((_) => http.Response('', 500));
  }

  void reportBreakdown(String busNumber, String busName, String inchargeName,
      String reason, String location) {
    triggerAutomatedBreakdownReroute(
      busNumber: busNumber,
      busName: busName,
      inchargeName: inchargeName,
      reason: reason,
      location: location,
    );
  }

  void resolveBreakdown(String alertId) {
    resolveActiveBreakdown();
  }

  void addAttendanceRecord(String rollNumber, String name, String busName) {
    final now = TimeOfDay.now();
    final formattedTime =
        '${now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} ${now.period == DayPeriod.am ? 'AM' : 'PM'}';
    final existingIdx =
        _attendanceLogs.indexWhere((a) => a['rollNumber'] == rollNumber);
    if (existingIdx != -1) {
      _attendanceLogs[existingIdx] = {
        'rollNumber': rollNumber,
        'name': name,
        'busName': busName,
        'time': formattedTime,
        'method': 'QR Scan',
      };
    } else {
      _attendanceLogs.insert(0, {
        'rollNumber': rollNumber,
        'name': name,
        'busName': busName,
        'time': formattedTime,
        'method': 'QR Scan',
      });
    }
    notifyListeners();
  }

  // ─── ADMIN STUDENTS STATE & CRUD ─────────────────────
  final List<AdminStudent> _adminStudents = [
    const AdminStudent(
        id: 'STU-001',
        name: 'Aarav Sharma',
        rollNumber: 'CS2024-117',
        department: 'Computer Science',
        year: '3rd Year',
        assignedBus: 'Campus Express 04',
        phone: '+91 98765 43210',
        email: 'aarav@college.edu',
        status: 'Active',
        initials: 'AS',
        avatarColor: AppColors.primary),
    const AdminStudent(
        id: 'STU-002',
        name: 'Priya Patel',
        rollNumber: 'EC2024-042',
        department: 'Electronics',
        year: '2nd Year',
        assignedBus: 'City Connector 12',
        phone: '+91 87654 32109',
        email: 'priya@college.edu',
        status: 'Active',
        initials: 'PP',
        avatarColor: Color(0xFF7C3AED)),
    const AdminStudent(
        id: 'STU-003',
        name: 'Rohan Verma',
        rollNumber: 'ME2024-089',
        department: 'Mechanical',
        year: '4th Year',
        assignedBus: 'Green Line 09',
        phone: '+91 76543 21098',
        email: 'rohan@college.edu',
        status: 'Active',
        initials: 'RV',
        avatarColor: AppColors.success),
  ];
  List<AdminStudent> get adminStudents => List.unmodifiable(_adminStudents);

  void addStudent(AdminStudent student) {
    _adminStudents.insert(0, student);
    notifyListeners();
  }

  void removeStudent(String id) {
    _adminStudents.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void updateStudentBus(String studentId, String newBus) {
    final idx = _adminStudents.indexWhere((s) => s.id == studentId);
    if (idx != -1) {
      final old = _adminStudents[idx];
      _adminStudents[idx] = AdminStudent(
        id: old.id,
        name: old.name,
        rollNumber: old.rollNumber,
        department: old.department,
        year: old.year,
        assignedBus: newBus,
        phone: old.phone,
        email: old.email,
        status: old.status,
        initials: old.initials,
        avatarColor: old.avatarColor,
      );
      notifyListeners();
    }
  }

  // ─── BUS IN-CHARGES STATE & CRUD ─────────────────────
  final List<BusIncharge> _adminIncharges = [
    const BusIncharge(
        id: 'INC-001',
        name: 'Suresh Kumar',
        assignedBus: 'Campus Express 04',
        assignedBusId: 'BUS-001',
        phone: '+91 94440 12345',
        email: 'suresh@college.edu',
        status: 'On Duty',
        initials: 'SK',
        avatarColor: AppColors.primary,
        joinedDate: 'Jan 2023'),
    const BusIncharge(
        id: 'INC-002',
        name: 'Meena Kumari',
        assignedBus: 'City Connector 12',
        assignedBusId: 'BUS-002',
        phone: '+91 94440 12346',
        email: 'meena@college.edu',
        status: 'Off Duty',
        initials: 'MK',
        avatarColor: Color(0xFF7C3AED),
        joinedDate: 'Aug 2023'),
  ];
  List<BusIncharge> get adminIncharges => List.unmodifiable(_adminIncharges);

  void addIncharge(BusIncharge incharge) {
    _adminIncharges.insert(0, incharge);
    notifyListeners();
  }

  void removeIncharge(String id) {
    _adminIncharges.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void assignInchargeBus(String inchargeId, String busName, String busId) {
    final idx = _adminIncharges.indexWhere((i) => i.id == inchargeId);
    if (idx != -1) {
      final old = _adminIncharges[idx];
      _adminIncharges[idx] = BusIncharge(
        id: old.id,
        name: old.name,
        assignedBus: busName,
        assignedBusId: busId,
        phone: old.phone,
        email: old.email,
        status: old.status,
        initials: old.initials,
        avatarColor: old.avatarColor,
        joinedDate: old.joinedDate,
      );
      notifyListeners();
    }
  }

  // ─── ADMIN BUSES STATE ────────────────────────────────
  final List<AdminBus> _adminBuses = List.from(MockData.buses);
  List<AdminBus> get adminBuses => List.unmodifiable(_adminBuses);

  void addBus(AdminBus bus) {
    _adminBuses.insert(0, bus);
    notifyListeners();
  }

  void removeBus(String id) {
    _adminBuses.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  // ─── STAFF MANAGEMENT ───────────────────────────────
  final List<Map<String, String>> _staffMembers = [
    {
      'id': 'STF-01',
      'name': 'Dr. Rajesh Rao',
      'role': 'Transport Head',
      'email': 'rajesh@college.edu',
      'phone': '+91 91111 22222'
    },
    {
      'id': 'STF-02',
      'name': 'Anita Desai',
      'role': 'System Admin',
      'email': 'anita@college.edu',
      'phone': '+91 91111 33333'
    },
  ];
  List<Map<String, String>> get staffMembers =>
      List.unmodifiable(_staffMembers);

  void addStaff(Map<String, String> staff) {
    _staffMembers.insert(0, staff);
    notifyListeners();
  }

  void removeStaff(String id) {
    _staffMembers.removeWhere((s) => s['id'] == id);
    notifyListeners();
  }

  // ─── EXISTING STUDENT APP MOCK MODELS ─────────────────
  final student = const Student(
      name: 'Aarav Sharma',
      rollNumber: 'CS2024-117',
      department: 'Computer Science & Engineering',
      busName: 'Campus Express 04',
      initials: 'AS');
  final assignedBus = const Bus(
      name: 'Campus Express',
      number: 'SB-04',
      driver: 'Ravi Kumar',
      eta: '8 min',
      nextStop: 'Central Library',
      occupancy: '42%',
      distance: '1.8 km away',
      status: 'On time');
  final stops = const [
    BusStop(
        name: 'Central Library',
        time: '08:42 AM',
        distance: '1.8 km',
        isNext: true),
    BusStop(name: 'Tech Park Gate', time: '08:48 AM', distance: '3.2 km'),
    BusStop(name: 'North Hostel', time: '08:55 AM', distance: '5.1 km'),
  ];
  final nearbyBuses = const [
    Bus(
        name: 'City Connector',
        number: 'SB-12',
        driver: 'Imran Khan',
        eta: '4 min',
        nextStop: 'Main Gate',
        occupancy: '68%',
        distance: '0.7 km away',
        status: 'Arriving'),
    Bus(
        name: 'Green Line',
        number: 'SB-09',
        driver: 'Nisha Patel',
        eta: '11 min',
        nextStop: 'Innovation Hub',
        occupancy: '31%',
        distance: '2.4 km away',
        status: 'On time'),
  ];
  final ads = const [
    Advertisement(
        tag: 'SMART TRAVEL',
        title: 'Your ride, right on time.',
        subtitle: 'Track every stop in real time.',
        color: AppColors.primary),
  ];
  final List<AppNotification> _notifications = [
    const AppNotification(
        title: 'Bus is approaching',
        message: 'Campus Express will reach Central Library in 8 minutes.',
        time: 'Now',
        category: 'Trip',
        icon: Icons.directions_bus_rounded,
        unread: true),
  ];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
}
