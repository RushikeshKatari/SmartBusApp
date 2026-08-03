import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// STUDENT MODULE MODELS (unchanged)
// ─────────────────────────────────────────────

class Student {
  const Student({required this.name, required this.rollNumber, required this.department, required this.busName, required this.initials});
  final String name, rollNumber, department, busName, initials;
}

class Bus {
  const Bus({required this.name, required this.number, required this.driver, required this.eta, required this.nextStop, required this.occupancy, required this.distance, required this.status});
  final String name, number, driver, eta, nextStop, occupancy, distance, status;
}

class BusStop {
  const BusStop({required this.name, required this.time, required this.distance, this.isNext = false});
  final String name, time, distance;
  final bool isNext;
}

class AppNotification {
  const AppNotification({required this.title, required this.message, required this.time, required this.category, required this.icon, this.unread = false});
  final String title, message, time, category;
  final IconData icon;
  final bool unread;
}

class Advertisement {
  const Advertisement({required this.tag, required this.title, required this.subtitle, required this.color});
  final String tag, title, subtitle;
  final Color color;
}

// ─────────────────────────────────────────────
// ADMIN & BUS IN-CHARGE MODULE MODELS
// ─────────────────────────────────────────────

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
  final String id, name, rollNumber, department, year, assignedBus, phone, email, status, initials;
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
  final String id, name, assignedBus, assignedBusId, phone, email, status, initials, joinedDate;
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
  final String id, busNumber, busName, registrationNumber, driverName, driverPhone, assignedRoute, assignedInchargeId, assignedInchargeName, status, lastService;
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
  final String id, routeName, busId, busNumber, inchargeId, inchargeName, createdAt, status;
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
  const AttendancePoint({required this.label, required this.value, required this.total});
  final String label;
  final int value, total;
}

class OccupancyPoint {
  const OccupancyPoint({required this.busNumber, required this.percentage});
  final String busNumber;
  final double percentage;
}
