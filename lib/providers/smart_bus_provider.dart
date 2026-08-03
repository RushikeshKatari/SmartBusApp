import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';

class SmartBusProvider extends ChangeNotifier {
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
  void selectTab(int value) { _tab = value; notifyListeners(); }
  void setAlarm(bool value) { _alarmEnabled = value; notifyListeners(); }
  void setAlarmOption(String value) { _alarmOption = value; notifyListeners(); }
  void verifyLocationQr() { _sharingTransferred = _sharingActive; notifyListeners(); }
  void startLocationSharing() { _sharingActive = true; notifyListeners(); }
  void endLocationSharing() { _sharingActive = false; _sharingTransferred = false; notifyListeners(); }

  final student = const Student(name: 'Aarav Sharma', rollNumber: 'CS2024-117', department: 'Computer Science & Engineering', busName: 'Campus Express 04', initials: 'AS');
  final assignedBus = const Bus(name: 'Campus Express', number: 'SB-04', driver: 'Ravi Kumar', eta: '8 min', nextStop: 'Central Library', occupancy: '42%', distance: '1.8 km away', status: 'On time');
  final stops = const [
    BusStop(name: 'Central Library', time: '08:42 AM', distance: '1.8 km', isNext: true),
    BusStop(name: 'Tech Park Gate', time: '08:48 AM', distance: '3.2 km'),
    BusStop(name: 'North Hostel', time: '08:55 AM', distance: '5.1 km'),
  ];
  final nearbyBuses = const [
    Bus(name: 'City Connector', number: 'SB-12', driver: 'Imran Khan', eta: '4 min', nextStop: 'Main Gate', occupancy: '68%', distance: '0.7 km away', status: 'Arriving'),
    Bus(name: 'Green Line', number: 'SB-09', driver: 'Nisha Patel', eta: '11 min', nextStop: 'Innovation Hub', occupancy: '31%', distance: '2.4 km away', status: 'On time'),
    Bus(name: 'Campus Express', number: 'SB-02', driver: 'Suresh Rao', eta: '16 min', nextStop: 'South Gate', occupancy: '76%', distance: '3.8 km away', status: 'Delayed'),
  ];
  final ads = const [
    Advertisement(tag: 'SMART TRAVEL', title: 'Your ride, right on time.', subtitle: 'Track every stop in real time.', color: AppColors.primary),
    Advertisement(tag: 'CAMPUS LIFE', title: 'Never miss a class again.', subtitle: 'Set a smart arrival alarm.', color: Color(0xFF7C3AED)),
  ];
  final notifications = const [
    AppNotification(title: 'Bus is approaching', message: 'Campus Express will reach Central Library in 8 minutes.', time: 'Now', category: 'Trip', icon: Icons.directions_bus_rounded, unread: true),
    AppNotification(title: 'Attendance marked', message: 'Your boarding attendance was recorded successfully.', time: 'Today, 8:13 AM', category: 'Attendance', icon: Icons.verified_rounded, unread: true),
    AppNotification(title: 'Route update', message: 'Green Line has a minor diversion near West Gate.', time: 'Yesterday', category: 'Route', icon: Icons.alt_route_rounded),
  ];
}
