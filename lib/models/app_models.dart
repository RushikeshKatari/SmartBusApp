import 'package:flutter/material.dart';

class Student {
  const Student(
      {required this.name,
      required this.rollNumber,
      required this.department,
      required this.busName,
      required this.initials});
  final String name, rollNumber, department, busName, initials;
}

class Bus {
  const Bus(
      {required this.name,
      required this.number,
      required this.driver,
      required this.eta,
      required this.nextStop,
      required this.occupancy,
      required this.distance,
      required this.status});
  final String name, number, driver, eta, nextStop, occupancy, distance, status;
}

class BusStop {
  const BusStop(
      {required this.name,
      required this.time,
      required this.distance,
      this.isNext = false});
  final String name, time, distance;
  final bool isNext;
}

class AppNotification {
  const AppNotification(
      {required this.title,
      required this.message,
      required this.time,
      required this.category,
      required this.icon,
      this.unread = false});
  final String title, message, time, category;
  final IconData icon;
  final bool unread;
}

class Advertisement {
  const Advertisement(
      {required this.tag,
      required this.title,
      required this.subtitle,
      required this.color});
  final String tag, title, subtitle;
  final Color color;
}

class AdminStudent {
  const AdminStudent({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.department,
    required this.year,
    required this.assignedBus,
    required this.phone,
    required this.email,
    required this.status,
    required this.initials,
    required this.avatarColor,
  });
  final String id,
      name,
      rollNumber,
      department,
      year,
      assignedBus,
      phone,
      email,
      status,
      initials;
  final Color avatarColor;
}

class BusIncharge {
  const BusIncharge({
    required this.id,
    required this.name,
    required this.assignedBus,
    required this.assignedBusId,
    required this.phone,
    required this.email,
    required this.status,
    required this.initials,
    required this.avatarColor,
    required this.joinedDate,
  });
  final String id,
      name,
      assignedBus,
      assignedBusId,
      phone,
      email,
      status,
      initials,
      joinedDate;
  final Color avatarColor;
}

class AdminBus {
  const AdminBus({
    required this.id,
    required this.busNumber,
    required this.busName,
    required this.registrationNumber,
    required this.capacity,
    required this.currentOccupancy,
    required this.driverName,
    required this.driverPhone,
    required this.assignedRoute,
    required this.assignedInchargeId,
    required this.assignedInchargeName,
    required this.status,
    required this.lastService,
  });
  final String id,
      busNumber,
      busName,
      registrationNumber,
      driverName,
      driverPhone,
      assignedRoute,
      assignedInchargeId,
      assignedInchargeName,
      status,
      lastService;
  final int capacity, currentOccupancy;
}

class RecordedBoardingStop {
  const RecordedBoardingStop({
    required this.id,
    required this.name,
    required this.landmark,
    required this.type,
    required this.estimatedWaitMinutes,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });
  final String id, name, landmark, type;
  final int estimatedWaitMinutes;
  final double latitude, longitude;
}

class RouteRecord {
  const RouteRecord({
    required this.id,
    required this.routeName,
    required this.busId,
    required this.busNumber,
    required this.inchargeId,
    required this.inchargeName,
    required this.distanceKm,
    required this.durationMinutes,
    required this.stops,
    required this.createdAt,
    required this.status,
  });
  final String id,
      routeName,
      busId,
      busNumber,
      inchargeId,
      inchargeName,
      createdAt,
      status;
  final double distanceKm;
  final int durationMinutes;
  final List<RecordedBoardingStop> stops;
}

class AdminAdvertisement {
  const AdminAdvertisement({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.color,
    required this.status,
    required this.scheduledFrom,
    required this.scheduledTo,
    required this.impressions,
  });
  final String id, title, subtitle, tag, status, scheduledFrom, scheduledTo;
  final Color color;
  final int impressions;
}

class AdminNotificationItem {
  const AdminNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.audience,
    required this.sentAt,
    required this.reachCount,
  });
  final String id, title, message, audience, sentAt;
  final int reachCount;
}

class AttendancePoint {
  const AttendancePoint(
      {required this.label, required this.value, required this.total});
  final String label;
  final int value, total;
}

class OccupancyPoint {
  const OccupancyPoint({required this.busNumber, required this.percentage});
  final String busNumber;
  final double percentage;
}

class EmergencyAttendanceReport {
  const EmergencyAttendanceReport({
    required this.id,
    required this.busNumber,
    required this.busName,
    required this.inchargeName,
    required this.reason,
    required this.location,
    required this.createdAt,
    required this.students,
    this.sentToHod = false,
    this.attendanceGiven = false,
    this.permissionGiven = false,
  });
  final String id,
      busNumber,
      busName,
      inchargeName,
      reason,
      location,
      createdAt;
  final List<Map<String, String>> students;
  final bool sentToHod, attendanceGiven, permissionGiven;

  EmergencyAttendanceReport copyWith({bool? sentToHod, bool? attendanceGiven, bool? permissionGiven}) =>
      EmergencyAttendanceReport(
        id: id,
        busNumber: busNumber,
        busName: busName,
        inchargeName: inchargeName,
        reason: reason,
        location: location,
        createdAt: createdAt,
        students: students,
        sentToHod: sentToHod ?? this.sentToHod,
        attendanceGiven: attendanceGiven ?? this.attendanceGiven,
        permissionGiven: permissionGiven ?? this.permissionGiven,
      );
}

class AcademicStudent {
  const AcademicStudent(
      {required this.name,
      required this.rollNumber,
      this.attendancePercent = 0});
  final String name, rollNumber;
  final double attendancePercent;
}

class AcademicSection {
  const AcademicSection({
    required this.id,
    required this.year,
    required this.specialization,
    required this.sectionNumber,
    required this.students,
  });
  final String id, year, specialization, sectionNumber;
  final List<AcademicStudent> students;
  double get attendancePercent => students.isEmpty
      ? 0
      : students.fold<double>(
              0, (total, student) => total + student.attendancePercent) /
          students.length;
}

class LiveRouteStop {
  const LiveRouteStop({
    required this.id,
    required this.name,
    required this.landmark,
    required this.latitude,
    required this.longitude,
    required this.order,
    this.distanceFromPreviousKm = 1.0,
    this.estimatedArrivalMinutes = 0,
    this.isBreakdownStranded = false,
    this.assignedPickupBusNumber,
    this.isDivertedPickup = false,
    this.originalBusNumber,
    this.isUturnDetour = false,
    this.divertedOrderLabel,
    this.isInvalidated = false,
    this.redirectToStopName,
    this.redirectMessage,
  });
  final String id, name, landmark;
  final double latitude, longitude, distanceFromPreviousKm;
  final int order, estimatedArrivalMinutes;
  final bool isBreakdownStranded;
  final String? assignedPickupBusNumber;
  final bool isDivertedPickup;
  final String? originalBusNumber;
  final bool isUturnDetour;
  final String? divertedOrderLabel;
  final bool isInvalidated;
  final String? redirectToStopName;
  final String? redirectMessage;

  LiveRouteStop copyWith({
    bool? isBreakdownStranded,
    String? assignedPickupBusNumber,
    bool? isDivertedPickup,
    String? originalBusNumber,
    bool? isUturnDetour,
    String? divertedOrderLabel,
    bool? isInvalidated,
    String? redirectToStopName,
    String? redirectMessage,
    int? order,
  }) =>
      LiveRouteStop(
        id: id,
        name: name,
        landmark: landmark,
        latitude: latitude,
        longitude: longitude,
        order: order ?? this.order,
        distanceFromPreviousKm: distanceFromPreviousKm,
        estimatedArrivalMinutes: estimatedArrivalMinutes,
        isBreakdownStranded: isBreakdownStranded ?? this.isBreakdownStranded,
        assignedPickupBusNumber:
            assignedPickupBusNumber ?? this.assignedPickupBusNumber,
        isDivertedPickup: isDivertedPickup ?? this.isDivertedPickup,
        originalBusNumber: originalBusNumber ?? this.originalBusNumber,
        isUturnDetour: isUturnDetour ?? this.isUturnDetour,
        divertedOrderLabel: divertedOrderLabel ?? this.divertedOrderLabel,
        isInvalidated: isInvalidated ?? this.isInvalidated,
        redirectToStopName: redirectToStopName ?? this.redirectToStopName,
        redirectMessage: redirectMessage ?? this.redirectMessage,
      );
}

class LiveBusRoute {
  const LiveBusRoute({
    required this.id,
    required this.routeNumber,
    required this.name,
    required this.busNumber,
    required this.busName,
    required this.driverName,
    required this.driverPhone,
    required this.color,
    required this.stops,
    required this.totalDistanceKm,
    required this.totalDurationMinutes,
    this.isBrokenDown = false,
    this.breakdownReason,
    this.breakdownLocation,
    this.assignedReplacementBusNumber,
  });
  final String id, routeNumber, name, busNumber, busName, driverName, driverPhone;
  final Color color;
  final List<LiveRouteStop> stops;
  final double totalDistanceKm;
  final int totalDurationMinutes;
  final bool isBrokenDown;
  final String? breakdownReason, breakdownLocation, assignedReplacementBusNumber;

  LiveBusRoute copyWith({
    bool? isBrokenDown,
    String? breakdownReason,
    String? breakdownLocation,
    String? assignedReplacementBusNumber,
    List<LiveRouteStop>? stops,
    double? totalDistanceKm,
    int? totalDurationMinutes,
  }) =>
      LiveBusRoute(
        id: id,
        routeNumber: routeNumber,
        name: name,
        busNumber: busNumber,
        busName: busName,
        driverName: driverName,
        driverPhone: driverPhone,
        color: color,
        stops: stops ?? this.stops,
        totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
        totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
        isBrokenDown: isBrokenDown ?? this.isBrokenDown,
        breakdownReason: breakdownReason ?? this.breakdownReason,
        breakdownLocation: breakdownLocation ?? this.breakdownLocation,
        assignedReplacementBusNumber:
            assignedReplacementBusNumber ?? this.assignedReplacementBusNumber,
      );
}

class DivertedStopAssignment {
  const DivertedStopAssignment({
    required this.stopId,
    required this.stopName,
    required this.originalBusNumber,
    required this.assignedBusNumber,
    required this.assignedBusName,
    required this.driverName,
    required this.driverPhone,
    required this.latitude,
    required this.longitude,
    required this.isUturnRequired,
    required this.detourDistanceKm,
    required this.estimatedArrival,
    this.isInvalidated = false,
    this.redirectToStopName,
    this.redirectMessage,
  });
  final String stopId,
      stopName,
      originalBusNumber,
      assignedBusNumber,
      assignedBusName,
      driverName,
      driverPhone,
      estimatedArrival;
  final double latitude, longitude, detourDistanceKm;
  final bool isUturnRequired;
  final bool isInvalidated;
  final String? redirectToStopName;
  final String? redirectMessage;

  DivertedStopAssignment copyWith({
    String? assignedBusNumber,
    String? assignedBusName,
    String? driverName,
    String? driverPhone,
    bool? isUturnRequired,
    double? detourDistanceKm,
    String? estimatedArrival,
    bool? isInvalidated,
    String? redirectToStopName,
    String? redirectMessage,
  }) =>
      DivertedStopAssignment(
        stopId: stopId,
        stopName: stopName,
        originalBusNumber: originalBusNumber,
        assignedBusNumber: assignedBusNumber ?? this.assignedBusNumber,
        assignedBusName: assignedBusName ?? this.assignedBusName,
        driverName: driverName ?? this.driverName,
        driverPhone: driverPhone ?? this.driverPhone,
        latitude: latitude,
        longitude: longitude,
        isUturnRequired: isUturnRequired ?? this.isUturnRequired,
        detourDistanceKm: detourDistanceKm ?? this.detourDistanceKm,
        estimatedArrival: estimatedArrival ?? this.estimatedArrival,
        isInvalidated: isInvalidated ?? this.isInvalidated,
        redirectToStopName: redirectToStopName ?? this.redirectToStopName,
        redirectMessage: redirectMessage ?? this.redirectMessage,
      );
}

class BreakdownRerouteEvent {
  const BreakdownRerouteEvent({
    required this.id,
    required this.brokenBusNumber,
    required this.brokenBusName,
    required this.inchargeName,
    required this.reason,
    required this.location,
    required this.strandedStudentsCount,
    required this.assignedPickupBusNumber,
    required this.assignedPickupBusName,
    required this.assignedPickupDriver,
    required this.assignedPickupDriverPhone,
    required this.detourDistanceKm,
    required this.detourEtaMinutes,
    required this.explanation,
    required this.affectedStopNames,
    required this.createdAt,
    this.stopAssignments = const [],
    this.totalRemainingStops = 0,
    this.coveredRemainingStops = 0,
    this.allStopsCovered = true,
  });
  final String id,
      brokenBusNumber,
      brokenBusName,
      inchargeName,
      reason,
      location,
      assignedPickupBusNumber,
      assignedPickupBusName,
      assignedPickupDriver,
      assignedPickupDriverPhone,
      explanation,
      createdAt;
  final int strandedStudentsCount, detourEtaMinutes;
  final double detourDistanceKm;
  final List<String> affectedStopNames;
  final List<DivertedStopAssignment> stopAssignments;
  final int totalRemainingStops;
  final int coveredRemainingStops;
  final bool allStopsCovered;
}

