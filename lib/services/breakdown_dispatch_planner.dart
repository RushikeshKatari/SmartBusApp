import 'dart:math' as _math;

import '../models/app_models.dart';

/// Capacity-constrained greedy dispatch for the current demo fleet.
///
/// Demand is distributed evenly across remaining stops because the current
/// application has no per-stop passenger counts. Each stop's passenger group
/// stays together; an assignment is made only when one rescue bus has enough
/// spare seats for the whole estimated group.
class BreakdownDispatchPlanner {
  const BreakdownDispatchPlanner._();

  static const double assumedAverageSpeedKmh = 25;

  static BreakdownDispatchPlan plan({
    required List<LiveRouteStop> affectedStops,
    required List<LiveBusRoute> availableRoutes,
    required Map<String, int> spareSeatsByBus,
    required String brokenBusNumber,
    required int strandedStudents,
  }) {
    if (affectedStops.isEmpty || strandedStudents <= 0) {
      return BreakdownDispatchPlan(
        assignments: const [],
        unassignedStudents: strandedStudents < 0 ? 0 : strandedStudents,
        unassignedStudentsByStop: const {},
      );
    }

    final remainingSeats = Map<String, int>.from(spareSeatsByBus);
    final eligibleRoutes = availableRoutes
        .where(
          (route) =>
              route.busNumber != brokenBusNumber &&
              !route.isBrokenDown &&
              (remainingSeats[route.busNumber] ?? 0) > 0,
        )
        .toList();

    final demands = <_StopDemand>[];
    final baseDemand = strandedStudents ~/ affectedStops.length;
    final remainder = strandedStudents % affectedStops.length;
    for (var i = 0; i < affectedStops.length; i++) {
      demands.add(
        _StopDemand(
          stop: affectedStops[i],
          passengers: baseDemand + (i < remainder ? 1 : 0),
          routeOrder: i,
        ),
      );
    }

    // Prioritize groups that fewer buses can carry, then larger groups, then
    // original route order. This reduces avoidable capacity dead-ends.
    demands.sort((a, b) {
      final aOptions = eligibleRoutes
          .where(
            (route) => (remainingSeats[route.busNumber] ?? 0) >= a.passengers,
          )
          .length;
      final bOptions = eligibleRoutes
          .where(
            (route) => (remainingSeats[route.busNumber] ?? 0) >= b.passengers,
          )
          .length;
      final scarcity = aOptions.compareTo(bOptions);
      if (scarcity != 0) return scarcity;
      final groupSize = b.passengers.compareTo(a.passengers);
      return groupSize != 0 ? groupSize : a.routeOrder.compareTo(b.routeOrder);
    });

    final assignments = <DivertedStopAssignment>[];
    final unassignedStudentsByStop = <String, int>{};
    var unassignedStudents = 0;

    for (final demand in demands) {
      if (demand.passengers == 0) continue;

      final feasibleRoutes =
          eligibleRoutes
              .where(
                (route) =>
                    (remainingSeats[route.busNumber] ?? 0) >= demand.passengers,
              )
              .toList()
            ..sort((a, b) {
              final distance = _roundTripDetourKm(
                a,
                demand.stop,
              ).compareTo(_roundTripDetourKm(b, demand.stop));
              return distance != 0
                  ? distance
                  : a.busNumber.compareTo(b.busNumber);
            });

      if (feasibleRoutes.isEmpty) {
        unassignedStudents += demand.passengers;
        unassignedStudentsByStop[demand.stop.id] = demand.passengers;
        continue;
      }

      final bus = feasibleRoutes.first;
      final seatsBefore = remainingSeats[bus.busNumber]!;
      remainingSeats[bus.busNumber] = seatsBefore - demand.passengers;
      final detourKm = _roundTripDetourKm(bus, demand.stop);
      final etaMinutes = (detourKm / assumedAverageSpeedKmh * 60).ceil();

      assignments.add(
        DivertedStopAssignment(
          stopId: demand.stop.id,
          stopName: demand.stop.name,
          originalBusNumber: brokenBusNumber,
          assignedBusNumber: bus.busNumber,
          assignedBusName: bus.busName,
          driverName: bus.driverName,
          driverPhone: bus.driverPhone,
          latitude: demand.stop.latitude,
          longitude: demand.stop.longitude,
          isUturnRequired: true,
          detourDistanceKm: detourKm,
          estimatedArrival: '~$etaMinutes min',
          studentCount: demand.passengers,
          spareSeatsBefore: seatsBefore,
        ),
      );
    }

    assignments.sort((a, b) {
      final aIndex = affectedStops.indexWhere((stop) => stop.id == a.stopId);
      final bIndex = affectedStops.indexWhere((stop) => stop.id == b.stopId);
      return aIndex.compareTo(bIndex);
    });

    return BreakdownDispatchPlan(
      assignments: List.unmodifiable(assignments),
      unassignedStudents: unassignedStudents,
      unassignedStudentsByStop: Map.unmodifiable(unassignedStudentsByStop),
    );
  }

  static double _roundTripDetourKm(LiveBusRoute route, LiveRouteStop target) {
    var nearestKm = double.infinity;
    for (final stop in route.stops) {
      final distance = _distanceKm(
        stop.latitude,
        stop.longitude,
        target.latitude,
        target.longitude,
      );
      if (distance < nearestKm) nearestKm = distance;
    }
    // Straight-line out-and-back detour is a lower-bound estimate, not a
    // road-network route distance.
    return (nearestKm.isFinite ? nearestKm * 2 : 0)
        .clamp(0.0, 9999.0)
        .toDouble();
  }

  static double _distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final dLat = (lat2 - lat1) * p;
    final dLon = (lon2 - lon1) * p;
    final sinLat = _sin(dLat / 2);
    final sinLon = _sin(dLon / 2);
    final a =
        sinLat * sinLat + _cos(lat1 * p) * _cos(lat2 * p) * sinLon * sinLon;
    return 12742 * _math.asin(_math.sqrt(a.clamp(0.0, 1.0)));
  }

  static double _cos(double value) => _math.cos(value);
  static double _sin(double value) => _math.sin(value);
}

class BreakdownDispatchPlan {
  const BreakdownDispatchPlan({
    required this.assignments,
    required this.unassignedStudents,
    required this.unassignedStudentsByStop,
  });

  final List<DivertedStopAssignment> assignments;
  final int unassignedStudents;
  final Map<String, int> unassignedStudentsByStop;
}

class _StopDemand {
  const _StopDemand({
    required this.stop,
    required this.passengers,
    required this.routeOrder,
  });

  final LiveRouteStop stop;
  final int passengers;
  final int routeOrder;
}
