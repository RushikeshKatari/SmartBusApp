import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/app_models.dart';
import '../mock/mock_data.dart';
import '../mock/hyderabad_route_data.dart';
import '../services/breakdown_dispatch_planner.dart';
import '../services/auth_api_service.dart';
import '../services/account_api_service.dart';
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

  bool _isCampusStop(String name) {
    final lower = name.toLowerCase();
    return lower.contains('campus gate') ||
        lower.contains('klh aziz nagar campus');
  }

  /// Create an explainable, capacity-constrained rescue plan for the demo fleet.
  /// Passenger counts are evenly estimated per remaining stop until the app has
  /// connected, per-stop attendance demand.
  Future<bool> triggerAutomatedBreakdownReroute({
    required String busNumber,
    required String busName,
    required String inchargeName,
    required String reason,
    required String location,
    int strandedStudentsCount = 15,
  }) async {
    final brokenIndex = _liveRoutes.indexWhere((r) => r.busNumber == busNumber);
    if (brokenIndex == -1) return false;

    final brokenRoute = _liveRoutes[brokenIndex];
    final strandedCount = math.max(0, strandedStudentsCount).toInt();

    // 1. Identify all remaining unserved stops of the broken bus (from breakdown point until before final Campus Gate)
    final leftoverStops =
        brokenRoute.stops.skip(2).where((s) => !_isCampusStop(s.name)).toList();

    final List<LiveRouteStop> stopsToCover = leftoverStops.isNotEmpty
        ? leftoverStops
        : brokenRoute.stops.where((s) => !_isCampusStop(s.name)).toList();

    final demandStopCount =
        math.min(strandedCount, stopsToCover.length).toInt();
    final demandStops = stopsToCover.take(demandStopCount).toList();

    // The Java backend owns dispatch decisions. Flutter only applies and
    // displays its returned plan; it never independently assigns the stops.
    final breakdownPoint = brokenRoute.stops.length > 1
        ? brokenRoute.stops[1]
        : brokenRoute.stops.first;
    late final Map<String, dynamic> backendPlan;
    try {
      final response = await http
          .post(
            Uri.parse(AppConfig.endpoint('/api/operations/breakdown')),
            headers: AuthApiService.authenticatedHeaders,
            body: jsonEncode({
              'busNumber': busNumber,
              'inchargeName': inchargeName,
              'reason': reason,
              'location': location,
              'latitude': breakdownPoint.latitude,
              'longitude': breakdownPoint.longitude,
              'strandedStudentsCount': strandedCount,
            }),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 201) return false;
      backendPlan = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return false;
    }

    final fleetByNumber = {
      for (final bus in MockData.buses) bus.busNumber: bus,
    };
    final availableRoutes = _liveRoutes.where((route) {
      final fleetBus = fleetByNumber[route.busNumber];
      return route.busNumber != busNumber &&
          !route.isBrokenDown &&
          fleetBus != null &&
          (fleetBus.status == 'Active' || fleetBus.status == 'On Duty');
    }).toList();
    final serverAssignments =
        backendPlan['assignments'] as List<dynamic>? ?? [];
    final stopAssignments = <DivertedStopAssignment>[];
    for (final item in serverAssignments) {
      final data = item as Map<String, dynamic>;
      final stopName = data['stopName']?.toString();
      final matchingStops = demandStops.where((stop) => stop.name == stopName);
      final rescueBusNumber = data['assignedBusNumber']?.toString() ?? '';
      final matchingRoutes = availableRoutes.where(
        (route) => route.busNumber == rescueBusNumber,
      );
      if (matchingStops.isEmpty || matchingRoutes.isEmpty) continue;
      final stop = matchingStops.first;
      final rescueRoute = matchingRoutes.first;
      final etaMinutes = (data['detourEtaMinutes'] as num?)?.toInt() ?? 0;
      stopAssignments.add(
        DivertedStopAssignment(
          stopId: stop.id,
          stopName: stop.name,
          originalBusNumber: busNumber,
          assignedBusNumber: rescueBusNumber,
          assignedBusName:
              data['assignedBusName']?.toString() ?? rescueRoute.busName,
          driverName: data['driverName']?.toString() ?? rescueRoute.driverName,
          driverPhone:
              data['driverPhone']?.toString() ?? rescueRoute.driverPhone,
          latitude: stop.latitude,
          longitude: stop.longitude,
          isUturnRequired: true,
          detourDistanceKm: (data['detourDistanceKm'] as num?)?.toDouble() ?? 0,
          estimatedArrival: '~$etaMinutes min',
          studentCount: (data['studentCount'] as num?)?.toInt() ?? 0,
          spareSeatsBefore: (data['spareSeatsBefore'] as num?)?.toInt() ?? 0,
        ),
      );
    }
    final unassignedByName =
        backendPlan['unassignedStudentsByStop'] as Map<String, dynamic>? ?? {};
    final unassignedById = <String, int>{};
    for (final stop in demandStops) {
      final count = unassignedByName[stop.name];
      if (count is num && count > 0) unassignedById[stop.id] = count.toInt();
    }
    final plan = BreakdownDispatchPlan(
      assignments: List.unmodifiable(stopAssignments),
      unassignedStudents:
          (backendPlan['unassignedStudentsCount'] as num?)?.toInt() ??
              math.max(
                0,
                strandedCount -
                    stopAssignments.fold<int>(
                      0,
                      (sum, assignment) => sum + assignment.studentCount,
                    ),
              ),
      unassignedStudentsByStop: Map.unmodifiable(unassignedById),
    );
    final assignmentsByStop = {
      for (final assignment in stopAssignments) assignment.stopId: assignment,
    };
    final busToDivertedStops = <String, List<LiveRouteStop>>{};
    for (final assignment in stopAssignments) {
      final stop = demandStops.firstWhere((s) => s.id == assignment.stopId);
      busToDivertedStops
          .putIfAbsent(assignment.assignedBusNumber, () => [])
          .add(
            stop.copyWith(
              isDivertedPickup: true,
              originalBusNumber: busNumber,
              isUturnDetour: assignment.isUturnRequired,
              assignedPickupBusNumber: assignment.assignedBusNumber,
              divertedOrderLabel:
                  'Rescue pickup (${assignment.studentCount} students from $busNumber)',
            ),
          );
    }

    final rescueRoutes = availableRoutes
        .where((route) => busToDivertedStops.containsKey(route.busNumber))
        .toList();
    final primaryRescue = stopAssignments.isEmpty
        ? null
        : rescueRoutes.firstWhere(
            (route) =>
                route.busNumber == stopAssignments.first.assignedBusNumber,
          );
    final affectedStopNames = demandStops.map((s) => s.name).toList();
    final coveredStudents = stopAssignments.fold<int>(
      0,
      (total, assignment) => total + assignment.studentCount,
    );
    final addedDetourKm = stopAssignments.fold<double>(
      0,
      (total, assignment) => total + assignment.detourDistanceKm,
    );

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
            assignedReplacementBusNumber:
                primaryRescue?.busNumber ?? 'No capacity available',
            stops: route.stops.map((s) {
              final isAffected = affectedStopNames.contains(s.name);
              if (isAffected) {
                final assignment = assignmentsByStop[s.id];
                return s.copyWith(
                  isBreakdownStranded: true,
                  assignedPickupBusNumber: assignment?.assignedBusNumber,
                );
              }
              return s;
            }).toList(),
          ),
        );
      } else if (busToDivertedStops.containsKey(route.busNumber)) {
        // Insert this bus's assigned rescue pickups before its campus endpoint.
        final divertedList = busToDivertedStops[route.busNumber]!;
        final baseStops =
            route.stops.where((s) => !s.isDivertedPickup).toList();
        final campusGateIndex = baseStops.indexWhere(
          (s) => _isCampusStop(s.name),
        );
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
            totalDistanceKm: route.totalDistanceKm +
                stopAssignments
                    .where((a) => a.assignedBusNumber == route.busNumber)
                    .fold<double>(0, (sum, a) => sum + a.detourDistanceKm),
            totalDurationMinutes: route.totalDurationMinutes +
                (stopAssignments
                            .where(
                              (a) => a.assignedBusNumber == route.busNumber,
                            )
                            .fold<double>(
                              0,
                              (sum, a) => sum + a.detourDistanceKm,
                            ) /
                        BreakdownDispatchPlanner.assumedAverageSpeedKmh *
                        60)
                    .ceil(),
          ),
        );
      } else {
        updatedLiveRoutes.add(route);
      }
    }

    _liveRoutes = updatedLiveRoutes;

    final rescueBusNumbers = stopAssignments
        .map((assignment) => assignment.assignedBusNumber)
        .toSet()
        .toList();
    final explanation = backendPlan['explanation']?.toString() ??
        'Java dispatch assigned $coveredStudents/$strandedCount passengers. ${plan.unassignedStudents} need manual support.';

    _activeBreakdown = BreakdownRerouteEvent(
      id: backendPlan['id']?.toString() ??
          'BRK-${DateTime.now().millisecondsSinceEpoch}',
      brokenBusNumber: busNumber,
      brokenBusName: busName,
      inchargeName: inchargeName,
      reason: reason,
      location: location,
      strandedStudentsCount: strandedCount,
      assignedPickupBusNumber:
          primaryRescue?.busNumber ?? 'No capacity available',
      assignedPickupBusName:
          primaryRescue?.busName ?? 'Manual support required',
      assignedPickupDriver: primaryRescue?.driverName ?? 'Unassigned',
      assignedPickupDriverPhone: primaryRescue?.driverPhone ?? '',
      detourDistanceKm: addedDetourKm,
      detourEtaMinutes: (backendPlan['detourEtaMinutes'] as num?)?.toInt() ?? 0,
      explanation: explanation,
      affectedStopNames: affectedStopNames,
      createdAt: backendPlan['createdAt']?.toString() ?? 'Just now',
      stopAssignments: stopAssignments,
      unassignedStudentsByStop: plan.unassignedStudentsByStop,
      totalRemainingStops:
          (backendPlan['affectedStopsCount'] as num?)?.toInt() ??
              demandStopCount,
      coveredRemainingStops:
          (backendPlan['coveredStopsCount'] as num?)?.toInt() ??
              stopAssignments.length,
      allStopsCovered: backendPlan['allStopsCovered'] as bool? ??
          stopAssignments.length == demandStopCount,
    );

    // In-app notification for Student
    _notifications.insert(
      0,
      AppNotification(
        title: '🚨 Emergency Bus Reassignment ($busNumber)',
        message:
            'Your bus ($busNumber) reported breakdown ($reason at $location). The rescue plan assigned $coveredStudents/$strandedCount students across ${rescueBusNumbers.isEmpty ? "no available buses" : rescueBusNumbers.join(", ")}; ${plan.unassignedStudents} need manual support.',
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
      'assignedPickupBusNumber':
          primaryRescue?.busNumber ?? 'No capacity available',
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
      final attendanceResponse = await http.post(
        Uri.parse(AppConfig.endpoint('/api/incharge/emergency-reports')),
        headers: AuthApiService.authenticatedHeaders,
        body: jsonEncode({
          'busNumber': busNumber,
          'busName': busName,
          'inchargeName': inchargeName,
          'reason': reason,
          'location': location,
          'students': _attendanceLogs
              .map(
                (a) => {
                  'rollNumber': a['rollNumber'] ?? '',
                  'studentName': a['name'] ?? '',
                  'department': 'Computer Science',
                },
              )
              .toList(),
        }),
      );
      if (attendanceResponse.statusCode == 201) {
        final remote =
            jsonDecode(attendanceResponse.body) as Map<String, dynamic>;
        final localIndex = _transportReports.indexWhere(
          (r) => r.id == report.id,
        );
        if (localIndex != -1 && remote['id'] != null) {
          _transportReports[localIndex] = report.copyWith(
            id: remote['id'].toString(),
          );
          notifyListeners();
        }
      }
    } catch (_) {
      // Graceful offline fallback
    }
    return true;
  }

  /// Admin can move an assigned passenger group when the target has spare seats.
  bool adminReassignStopToBus(String stopId, String targetBusNumber) {
    final breakdown = _activeBreakdown;
    if (breakdown != null && targetBusNumber == breakdown.brokenBusNumber) {
      return false;
    }

    LiveRouteStop? targetStop;
    for (final route in _liveRoutes) {
      final match = route.stops.where((s) => s.id == stopId);
      if (match.isNotEmpty) {
        targetStop = match.first;
        break;
      }
    }
    if (targetStop == null) return false;

    final matchingAssignments = breakdown?.stopAssignments
            .where((assignment) => assignment.stopId == stopId)
            .toList() ??
        <DivertedStopAssignment>[];
    final currentAssignment =
        matchingAssignments.isEmpty ? null : matchingAssignments.first;
    final groupSize = currentAssignment?.studentCount ??
        breakdown?.unassignedStudentsByStop[stopId] ??
        0;
    if (breakdown != null && groupSize <= 0) return false;
    final targetRouteMatches = _liveRoutes.where(
      (route) => route.busNumber == targetBusNumber,
    );
    if (targetRouteMatches.isEmpty || targetRouteMatches.first.isBrokenDown) {
      return false;
    }
    final targetFleetMatches = MockData.buses.where(
      (bus) => bus.busNumber == targetBusNumber,
    );
    if (targetFleetMatches.isEmpty ||
        (targetFleetMatches.first.status != 'Active' &&
            targetFleetMatches.first.status != 'On Duty')) {
      return false;
    }
    final targetBus = targetFleetMatches.first;
    final alreadyAssigned =
        (breakdown?.stopAssignments ?? const <DivertedStopAssignment>[])
            .where(
              (assignment) =>
                  assignment.assignedBusNumber == targetBusNumber &&
                  assignment.stopId != stopId &&
                  !assignment.isInvalidated,
            )
            .fold<int>(0, (sum, assignment) => sum + assignment.studentCount);
    final spareBefore = math
        .max(
          0,
          targetBus.capacity - targetBus.currentOccupancy - alreadyAssigned,
        )
        .toInt();
    if (breakdown != null && spareBefore < groupSize) return false;

    final updatedRoutes = <LiveBusRoute>[];

    for (final route in _liveRoutes) {
      if (route.busNumber == targetBusNumber) {
        // Target bus gets this stop added as diverted pickup (before Campus Gate)
        final baseStops = route.stops.where((s) => s.id != stopId).toList();
        final gateIndex = baseStops.indexWhere((s) => _isCampusStop(s.name));
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
        final filteredStops = route.stops
            .where((s) => !(s.id == stopId && s.isDivertedPickup))
            .toList();
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
      final targetRoute = _liveRoutes.firstWhere(
        (r) => r.busNumber == targetBusNumber,
      );
      final detourKm = _distanceKm(
            targetStop!.latitude,
            targetStop.longitude,
            targetRoute.stops.first.latitude,
            targetRoute.stops.first.longitude,
          ) *
          2;
      var insertedAssignment = false;
      final updatedAssignments = <DivertedStopAssignment>[];
      for (final a in _activeBreakdown!.stopAssignments) {
        if (a.stopId == stopId) {
          if (!insertedAssignment) {
            updatedAssignments.add(
              DivertedStopAssignment(
                stopId: a.stopId,
                stopName: a.stopName,
                originalBusNumber: a.originalBusNumber,
                assignedBusNumber: targetBusNumber,
                assignedBusName: targetRoute.busName,
                driverName: targetRoute.driverName,
                driverPhone: targetRoute.driverPhone,
                latitude: a.latitude,
                longitude: a.longitude,
                isUturnRequired: true,
                detourDistanceKm: detourKm,
                estimatedArrival:
                    '~${(detourKm / BreakdownDispatchPlanner.assumedAverageSpeedKmh * 60).ceil()} min',
                studentCount: groupSize,
                spareSeatsBefore: spareBefore,
              ),
            );
            insertedAssignment = true;
          }
        } else {
          updatedAssignments.add(a);
        }
      }
      if (!insertedAssignment) {
        updatedAssignments.add(
          DivertedStopAssignment(
            stopId: stopId,
            stopName: targetStop!.name,
            originalBusNumber: _activeBreakdown!.brokenBusNumber,
            assignedBusNumber: targetBusNumber,
            assignedBusName: targetRoute.busName,
            driverName: targetRoute.driverName,
            driverPhone: targetRoute.driverPhone,
            latitude: targetStop.latitude,
            longitude: targetStop.longitude,
            isUturnRequired: true,
            detourDistanceKm: detourKm,
            estimatedArrival:
                '~${(detourKm / BreakdownDispatchPlanner.assumedAverageSpeedKmh * 60).ceil()} min',
            studentCount: groupSize,
            spareSeatsBefore: spareBefore,
          ),
        );
      }
      final unassignedByStop = Map<String, int>.from(
        _activeBreakdown!.unassignedStudentsByStop,
      )..remove(stopId);
      final coveredStopCount = updatedAssignments
          .map((assignment) => assignment.stopId)
          .toSet()
          .length;
      final newRescueBus = updatedAssignments.isEmpty
          ? null
          : _liveRoutes.firstWhere(
              (r) => r.busNumber == updatedAssignments.first.assignedBusNumber,
            );

      _activeBreakdown = BreakdownRerouteEvent(
        id: _activeBreakdown!.id,
        brokenBusNumber: _activeBreakdown!.brokenBusNumber,
        brokenBusName: _activeBreakdown!.brokenBusName,
        inchargeName: _activeBreakdown!.inchargeName,
        reason: _activeBreakdown!.reason,
        location: _activeBreakdown!.location,
        strandedStudentsCount: _activeBreakdown!.strandedStudentsCount,
        assignedPickupBusNumber:
            newRescueBus?.busNumber ?? 'No capacity available',
        assignedPickupBusName:
            newRescueBus?.busName ?? 'Manual support required',
        assignedPickupDriver: newRescueBus?.driverName ?? 'Unassigned',
        assignedPickupDriverPhone: newRescueBus?.driverPhone ?? '',
        detourDistanceKm: updatedAssignments.fold<double>(
          0,
          (sum, assignment) => sum + assignment.detourDistanceKm,
        ),
        detourEtaMinutes: updatedAssignments.isEmpty
            ? 0
            : (updatedAssignments.first.detourDistanceKm /
                    BreakdownDispatchPlanner.assumedAverageSpeedKmh *
                    60)
                .ceil(),
        explanation:
            'Admin reassigned "${targetStop.name}" to $targetBusNumber after checking spare seat capacity.',
        affectedStopNames: _activeBreakdown!.affectedStopNames,
        createdAt: _activeBreakdown!.createdAt,
        stopAssignments: updatedAssignments,
        unassignedStudentsByStop: unassignedByStop,
        totalRemainingStops: _activeBreakdown!.totalRemainingStops,
        coveredRemainingStops: coveredStopCount,
        allStopsCovered:
            coveredStopCount == _activeBreakdown!.totalRemainingStops,
      );
    }

    notifyListeners();
    return true;
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

      final coveredStopCount = updatedAssignments
          .map((assignment) => assignment.stopId)
          .toSet()
          .length;

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
        detourDistanceKm: math.max(
          0.8,
          _activeBreakdown!.detourDistanceKm - 0.6,
        ),
        detourEtaMinutes: math.max(2, _activeBreakdown!.detourEtaMinutes - 2),
        explanation:
            'Stop "${targetStop.name}" invalidated. Students redirected to $redirectToStopName. Detour optimized.',
        affectedStopNames: _activeBreakdown!.affectedStopNames,
        createdAt: _activeBreakdown!.createdAt,
        stopAssignments: updatedAssignments,
        unassignedStudentsByStop: _activeBreakdown!.unassignedStudentsByStop,
        totalRemainingStops: _activeBreakdown!.totalRemainingStops,
        coveredRemainingStops: coveredStopCount,
        allStopsCovered:
            coveredStopCount == _activeBreakdown!.totalRemainingStops,
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
    final matchingAssignments = _activeBreakdown!.stopAssignments
        .where((a) => a.stopId == stopId)
        .toList();
    if (matchingAssignments.isEmpty) return;
    final assignment = _activeBreakdown!.stopAssignments.firstWhere(
      (a) => a.stopId == stopId,
    );
    if (!adminReassignStopToBus(stopId, assignment.assignedBusNumber)) return;

    for (int i = 0; i < _liveRoutes.length; i++) {
      final route = _liveRoutes[i];
      if (route.isBrokenDown) {
        final stops = route.stops.map((s) {
          if (s.id == stopId) {
            return s.copyWith(
              isInvalidated: false,
              redirectToStopName: null,
              redirectMessage: null,
            );
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
            redirectMessage: null,
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
        unassignedStudentsByStop: _activeBreakdown!.unassignedStudentsByStop,
        totalRemainingStops: _activeBreakdown!.totalRemainingStops,
        coveredRemainingStops: updatedAssignments
            .map((assignment) => assignment.stopId)
            .toSet()
            .length,
        allStopsCovered:
            updatedAssignments.map((a) => a.stopId).toSet().length ==
                _activeBreakdown!.totalRemainingStops,
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
      'method': 'QR Scan',
    },
    {
      'rollNumber': 'EC2024-042',
      'name': 'Priya Patel',
      'busName': 'Campus Express 04',
      'time': '08:18 AM',
      'method': 'QR Scan',
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

  Future<bool> loadTransportReports() async {
    try {
      final response = await http
          .get(
            Uri.parse(AppConfig.endpoint('/api/admin/emergency-reports')),
            headers: AuthApiService.authenticatedHeaders,
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return false;
      final rows = jsonDecode(response.body) as List<dynamic>;
      _transportReports
        ..clear()
        ..addAll(
          rows.map((row) {
            final data = row as Map<String, dynamic>;
            final students =
                (data['students'] as List<dynamic>? ?? const []).map((value) {
              final student = value as Map<String, dynamic>;
              return <String, String>{
                'name': student['studentName']?.toString() ?? 'Student',
                'rollNumber': student['rollNumber']?.toString() ?? '',
                'department': student['department']?.toString() ?? '',
              };
            }).toList();
            return EmergencyAttendanceReport(
              id: data['id']?.toString() ?? '',
              busNumber: data['busNumber']?.toString() ?? '',
              busName: data['busName']?.toString() ?? '',
              inchargeName: data['inchargeName']?.toString() ?? '',
              reason: data['reason']?.toString() ?? '',
              location: data['location']?.toString() ?? '',
              createdAt: data['sentToTransportAt']?.toString() ?? '',
              students: students,
              sentToHod: data['status'] == 'SENT_TO_HOD' ||
                  data['sentToHodAt'] != null,
              attendanceGiven: data['attendanceApprovedAt'] != null,
              permissionGiven: data['permissionGrantedAt'] != null,
            );
          }),
        );
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

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
          attendancePercent: 91,
        ),
        AcademicStudent(
          name: 'Diya Nair',
          rollNumber: 'CS2024-118',
          attendancePercent: 88,
        ),
      ],
    ),
    const AcademicSection(
      id: 'SEC-2-A',
      year: '2nd Year',
      specialization: 'Electronics',
      sectionNumber: 'A',
      students: [
        AcademicStudent(
          name: 'Priya Patel',
          rollNumber: 'EC2024-042',
          attendancePercent: 86,
        ),
        AcademicStudent(
          name: 'Kiran Shah',
          rollNumber: 'EC2024-043',
          attendancePercent: 90,
        ),
      ],
    ),
    const AcademicSection(
      id: 'SEC-3-A',
      year: '3rd Year',
      specialization: 'Computer Science',
      sectionNumber: 'A',
      students: [
        AcademicStudent(
          name: 'Rohan Verma',
          rollNumber: 'CS2023-089',
          attendancePercent: 84,
        ),
        AcademicStudent(
          name: 'Meera Iyer',
          rollNumber: 'CS2023-090',
          attendancePercent: 93,
        ),
      ],
    ),
    const AcademicSection(
      id: 'SEC-4-A',
      year: '4th Year',
      specialization: 'Mechanical',
      sectionNumber: 'A',
      students: [
        AcademicStudent(
          name: 'Nikhil Das',
          rollNumber: 'ME2022-021',
          attendancePercent: 89,
        ),
        AcademicStudent(
          name: 'Ananya Roy',
          rollNumber: 'ME2022-022',
          attendancePercent: 87,
        ),
      ],
    ),
  ];
  List<AcademicSection> get academicSections =>
      List.unmodifiable(_academicSections);
  List<AcademicSection> sectionsForYear(String year) => List.unmodifiable(
        _academicSections.where((section) => section.year == year),
      );
  double attendanceForYear(String year) {
    final students = sectionsForYear(
      year,
    ).expand((section) => section.students).toList();
    return students.isEmpty
        ? 0
        : students.fold<double>(
              0,
              (total, student) => total + student.attendancePercent,
            ) /
            students.length;
  }

  double get overallAcademicAttendance {
    final students =
        _academicSections.expand((section) => section.students).toList();
    return students.isEmpty
        ? 0
        : students.fold<double>(
              0,
              (total, student) => total + student.attendancePercent,
            ) /
            students.length;
  }

  void addAcademicSection({
    required String year,
    required String specialization,
    required String sectionNumber,
    required List<AcademicStudent> students,
  }) {
    _academicSections.add(
      AcademicSection(
        id: 'SEC-${DateTime.now().millisecondsSinceEpoch}',
        year: year,
        specialization: specialization,
        sectionNumber: sectionNumber,
        students: students,
      ),
    );
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

  Future<bool> sendEmergencyReportToHod(String reportId) async {
    try {
      final response = await http.post(
        Uri.parse(
          AppConfig.endpoint(
            '/api/admin/emergency-reports/$reportId/send-to-hod',
          ),
        ),
        headers: AuthApiService.authenticatedHeaders,
      );
      if (response.statusCode != 200) return false;
    } catch (_) {
      return false;
    }
    final index = _transportReports.indexWhere(
      (report) => report.id == reportId,
    );
    if (index != -1) {
      _transportReports[index] = _transportReports[index].copyWith(
        sentToHod: true,
      );
      notifyListeners();
    }
    return true;
  }

  void giveEmergencyAttendance(String reportId) {
    final index = _transportReports.indexWhere(
      (report) => report.id == reportId,
    );
    if (index != -1) {
      _transportReports[index] = _transportReports[index].copyWith(
        attendanceGiven: true,
      );
      notifyListeners();
    }
    // HOD screens call the HOD API service and refresh from the server.
  }

  void giveEmergencyPermission(String reportId) {
    final index = _transportReports.indexWhere(
      (report) => report.id == reportId,
    );
    if (index != -1) {
      _transportReports[index] = _transportReports[index].copyWith(
        permissionGiven: true,
      );
      notifyListeners();
    }
    // HOD screens call the HOD API service and refresh from the server.
  }

  void reportBreakdown(
    String busNumber,
    String busName,
    String inchargeName,
    String reason,
    String location,
  ) {
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
    final existingIdx = _attendanceLogs.indexWhere(
      (a) => a['rollNumber'] == rollNumber,
    );
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
      avatarColor: AppColors.primary,
    ),
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
      avatarColor: Color(0xFF7C3AED),
    ),
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
      avatarColor: AppColors.success,
    ),
  ];
  List<AdminStudent> get adminStudents => List.unmodifiable(_adminStudents);

  void addStudent(AdminStudent student) {
    _adminStudents.insert(0, student);
    notifyListeners();
  }

  Future<Map<String, String>?> createStudentWithLogin(
      AdminStudent student) async {
    final year = int.tryParse(student.year) ??
        int.tryParse(student.year.replaceAll(RegExp(r'\D'), '')) ??
        1;
    final credentials = await AccountApiService.createStudent(
      name: student.name,
      rollNumber: student.rollNumber,
      department: student.department,
      phone: student.phone,
      academicYear: year,
      busNumber: _busNumberForAssignment(student.assignedBus),
    );
    if (credentials == null) return null;
    _adminStudents.insert(
      0,
      AdminStudent(
        id: credentials['id'] ?? student.id,
        name: student.name,
        rollNumber: student.rollNumber,
        department: student.department,
        year: student.year,
        assignedBus: student.assignedBus,
        phone: student.phone,
        email: student.email,
        status: student.status,
        initials: student.initials,
        avatarColor: student.avatarColor,
      ),
    );
    notifyListeners();
    return credentials;
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
      joinedDate: 'Jan 2023',
    ),
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
      joinedDate: 'Aug 2023',
    ),
  ];
  List<BusIncharge> get adminIncharges => List.unmodifiable(_adminIncharges);

  void addIncharge(BusIncharge incharge) {
    _adminIncharges.insert(0, incharge);
    notifyListeners();
  }

  Future<Map<String, String>?> createInchargeWithLogin(
    BusIncharge incharge,
  ) async {
    final credentials = await AccountApiService.createAccount(
      username: incharge.email,
      displayName: incharge.name,
      role: 'INCHARGE',
    );
    if (credentials == null) return null;
    _adminIncharges.insert(
      0,
      BusIncharge(
        id: credentials['id'] ?? incharge.id,
        name: incharge.name,
        assignedBus: incharge.assignedBus,
        assignedBusId: incharge.assignedBusId,
        phone: incharge.phone,
        email: incharge.email,
        status: incharge.status,
        initials: incharge.initials,
        avatarColor: incharge.avatarColor,
        joinedDate: incharge.joinedDate,
      ),
    );
    notifyListeners();
    return credentials;
  }

  Future<Map<String, String>?> createFacultyWithLogin({
    required String name,
    required String email,
  }) async {
    final credentials = await AccountApiService.createAccount(
      username: email,
      displayName: name,
      role: 'HOD',
    );
    if (credentials == null) return null;
    _staffMembers.insert(0, {
      'id':
          credentials['id'] ?? 'STAFF-${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'role': 'Faculty',
      'email': email,
    });
    notifyListeners();
    return credentials;
  }

  Future<Map<String, String>?> resetAccountPassword(String username) =>
      AccountApiService.resetPassword(username);

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
      'phone': '+91 91111 22222',
    },
    {
      'id': 'STF-02',
      'name': 'Anita Desai',
      'role': 'System Admin',
      'email': 'anita@college.edu',
      'phone': '+91 91111 33333',
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
  Student _student = const Student(
    name: 'Aarav Sharma',
    rollNumber: 'CS2024-117',
    department: 'Computer Science & Engineering',
    busName: 'Campus Express 04',
    initials: 'AS',
    busNumber: 'SB-04',
  );
  List<LiveRouteStop> _authenticatedStudentRouteStops = const [];
  Student get student => _student;

  List<LiveRouteStop> get assignedRouteStops {
    if (_authenticatedStudentRouteStops.isNotEmpty) {
      return List.unmodifiable(_authenticatedStudentRouteStops);
    }
    for (final route in HyderabadRouteData.liveRoutes) {
      if (route.busNumber == _student.busNumber) return route.stops;
    }
    return const [];
  }

  void applyAuthenticatedStudentProfile(Map<String, dynamic> profile) {
    final name = profile['displayName']?.toString();
    final rollNumber = profile['rollNumber']?.toString();
    final department = profile['department']?.toString();
    if (name == null || name.isEmpty) return;
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    _student = Student(
      name: name,
      rollNumber:
          rollNumber?.isNotEmpty == true ? rollNumber! : _student.rollNumber,
      department:
          department?.isNotEmpty == true ? department! : _student.department,
      busName: profile['busName']?.toString() ?? 'No route assigned',
      initials: initials,
      busNumber: profile['busNumber']?.toString() ?? '',
    );
    final routeStops = profile['routeStops'];
    if (routeStops is List) {
      _authenticatedStudentRouteStops = routeStops
          .whereType<Map>()
          .map((stop) {
            final order = int.tryParse(stop['order']?.toString() ?? '') ?? 0;
            return LiveRouteStop(
              id: stop['id']?.toString() ?? 'student-route-stop-$order',
              name: stop['name']?.toString() ?? 'Route stop $order',
              landmark: stop['landmark']?.toString() ?? '',
              latitude:
                  double.tryParse(stop['latitude']?.toString() ?? '') ?? 0,
              longitude:
                  double.tryParse(stop['longitude']?.toString() ?? '') ?? 0,
              order: order,
            );
          })
          .where((stop) => stop.latitude != 0 && stop.longitude != 0)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } else {
      _authenticatedStudentRouteStops = const [];
    }
    notifyListeners();
  }

  String _busNumberForAssignment(String assignment) {
    final normalized = assignment.toLowerCase();
    for (final route in HyderabadRouteData.routes) {
      if (normalized.contains(route.busNumber.toLowerCase()) ||
          normalized.contains(route.busName.toLowerCase())) {
        return route.busNumber;
      }
    }
    return '';
  }

  Bus get assignedBus {
    DemoRouteDefinition? route;
    for (final item in HyderabadRouteData.routes) {
      if (item.busNumber == _student.busNumber) {
        route = item;
        break;
      }
    }
    if (_student.busNumber.isEmpty) {
      return const Bus(
        name: 'No bus assigned',
        number: 'Unassigned',
        driver: '—',
        eta: '—',
        nextStop: 'No stop assigned',
        occupancy: '—',
        distance: '—',
        status: 'Unassigned',
      );
    }
    if (route == null) {
      return Bus(
        name: _student.busName,
        number: _student.busNumber,
        driver: 'Assigned driver',
        eta: '—',
        nextStop: assignedRouteStops.isEmpty
            ? 'Route stops unavailable'
            : assignedRouteStops.first.name,
        occupancy: '—',
        distance: '—',
        status: 'Assigned',
      );
    }
    return Bus(
      name: route.busName,
      number: route.busNumber,
      driver: route.driverName,
      eta: '8 min',
      nextStop: assignedRouteStops.isNotEmpty
          ? assignedRouteStops.first.name
          : route.stops.first.name,
      occupancy: '${(route.occupancy / route.capacity * 100).round()}%',
      distance: '1.8 km away',
      status: 'On time',
    );
  }

  List<BusStop> get stops => assignedRouteStops
      .map((stop) => BusStop(
            name: stop.name,
            time: 'Stop ${stop.order}',
            distance: stop.landmark.isEmpty ? 'Assigned route' : stop.landmark,
            isNext: stop.order == assignedRouteStops.first.order,
          ))
      .toList();
  final nearbyBuses = const [
    Bus(
      name: 'City Connector',
      number: 'SB-12',
      driver: 'Imran Khan',
      eta: '4 min',
      nextStop: 'Main Gate',
      occupancy: '68%',
      distance: '0.7 km away',
      status: 'Arriving',
    ),
    Bus(
      name: 'Green Line',
      number: 'SB-09',
      driver: 'Nisha Patel',
      eta: '11 min',
      nextStop: 'Innovation Hub',
      occupancy: '31%',
      distance: '2.4 km away',
      status: 'On time',
    ),
  ];
  final ads = const [
    Advertisement(
      tag: 'SMART TRAVEL',
      title: 'Your ride, right on time.',
      subtitle: 'Track every stop in real time.',
      color: AppColors.primary,
    ),
  ];
  final List<AppNotification> _notifications = [
    const AppNotification(
      title: 'Bus is approaching',
      message:
          'Your assigned bus is on its route. Check the live map for stops.',
      time: 'Now',
      category: 'Trip',
      icon: Icons.directions_bus_rounded,
      unread: true,
    ),
  ];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
}
