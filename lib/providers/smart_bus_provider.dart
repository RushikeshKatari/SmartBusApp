import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';

class SmartBusProvider extends ChangeNotifier {
  // ─── THEME & NAVIGATION ─────────────────────────────
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
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

  void selectTab(int value) { _tab = value; notifyListeners(); }
  void setAlarm(bool value) { _alarmEnabled = value; notifyListeners(); }
  void setAlarmOption(String value) { _alarmOption = value; notifyListeners(); }
  void verifyLocationQr() { _sharingTransferred = _sharingActive; notifyListeners(); }
  void startLocationSharing() { _sharingActive = true; notifyListeners(); }
  void endLocationSharing() { _sharingActive = false; _sharingTransferred = false; notifyListeners(); }

  // ─── ATTENDANCE LOGS & BREAKDOWN ALERTS ─────────────────
  final List<Map<String, String>> _attendanceLogs = [
    {'rollNumber': 'CS2024-117', 'name': 'Aarav Sharma', 'busName': 'Campus Express 04', 'time': '08:14 AM', 'method': 'QR Scan'},
    {'rollNumber': 'EC2024-042', 'name': 'Priya Patel', 'busName': 'Campus Express 04', 'time': '08:18 AM', 'method': 'QR Scan'},
  ];
  List<Map<String, String>> get attendanceLogs => List.unmodifiable(_attendanceLogs);

  final List<Map<String, String>> _breakdownAlerts = [];
  List<Map<String, String>> get breakdownAlerts => List.unmodifiable(_breakdownAlerts);

  // New state for breakdown workflow
  String? _breakdownReason;
  final List<String> _breakdownScannedIds = [];
  String? get breakdownReason => _breakdownReason;
  List<String> get breakdownScannedIds => List.unmodifiable(_breakdownScannedIds);

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

  void submitBreakdownReport({required String busNumber, required String busName, required String inchargeName, required String location}) {
    final reason = _breakdownReason ?? 'No reason';
    reportBreakdown(busNumber, busName, inchargeName, reason, location);
    _breakdownReason = null;
    _breakdownScannedIds.clear();
    notifyListeners();
  }

  void reportBreakdown(String busNumber, String busName, String inchargeName, String reason, String location) {
    final now = TimeOfDay.now();
    final formattedTime = '${now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} ${now.period == DayPeriod.am ? 'AM' : 'PM'}';
    _breakdownAlerts.insert(0, {
      'id': 'BRK-${DateTime.now().millisecondsSinceEpoch}',
      'busNumber': busNumber,
      'busName': busName,
      'inchargeName': inchargeName,
      'reason': reason,
      'location': location,
      'time': formattedTime,
    });
    notifyListeners();
  }

  void resolveBreakdown(String alertId) {
    _breakdownAlerts.removeWhere((a) => a['id'] == alertId);
    notifyListeners();
  }

  void addAttendanceRecord(String rollNumber, String name, String busName) {
    final now = TimeOfDay.now();
    final formattedTime = '${now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} ${now.period == DayPeriod.am ? 'AM' : 'PM'}';
    final existingIdx = _attendanceLogs.indexWhere((a) => a['rollNumber'] == rollNumber);
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
    const AdminStudent(id: 'STU-001', name: 'Aarav Sharma', rollNumber: 'CS2024-117', department: 'Computer Science', year: '3rd Year', assignedBus: 'Campus Express 04', phone: '+91 98765 43210', email: 'aarav@college.edu', status: 'Active', initials: 'AS', avatarColor: AppColors.primary),
    const AdminStudent(id: 'STU-002', name: 'Priya Patel', rollNumber: 'EC2024-042', department: 'Electronics', year: '2nd Year', assignedBus: 'City Connector 12', phone: '+91 98765 43211', email: 'priya@college.edu', status: 'Active', initials: 'PP', avatarColor: Color(0xFF7C3AED)),
    const AdminStudent(id: 'STU-003', name: 'Rohan Verma', rollNumber: 'ME2024-089', department: 'Mechanical', year: '4th Year', assignedBus: 'Green Line 09', phone: '+91 98765 43212', email: 'rohan@college.edu', status: 'Active', initials: 'RV', avatarColor: AppColors.success),
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
        id: old.id, name: old.name, rollNumber: old.rollNumber, department: old.department,
        year: old.year, assignedBus: newBus, phone: old.phone, email: old.email,
        status: old.status, initials: old.initials, avatarColor: old.avatarColor,
      );
      notifyListeners();
    }
  }

  // ─── BUS IN-CHARGES STATE & CRUD ─────────────────────
  final List<BusIncharge> _adminIncharges = [
    const BusIncharge(id: 'INC-001', name: 'Suresh Kumar', assignedBus: 'Campus Express 04', assignedBusId: 'BUS-001', phone: '+91 94440 12345', email: 'suresh@college.edu', status: 'On Duty', initials: 'SK', avatarColor: AppColors.primary, joinedDate: 'Jan 2023'),
    const BusIncharge(id: 'INC-002', name: 'Meena Kumari', assignedBus: 'City Connector 12', assignedBusId: 'BUS-002', phone: '+91 94440 12346', email: 'meena@college.edu', status: 'Off Duty', initials: 'MK', avatarColor: Color(0xFF7C3AED), joinedDate: 'Aug 2023'),
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
        id: old.id, name: old.name, assignedBus: busName, assignedBusId: busId,
        phone: old.phone, email: old.email, status: old.status, initials: old.initials,
        avatarColor: old.avatarColor, joinedDate: old.joinedDate,
      );
      notifyListeners();
    }
  }

  // ─── ADMIN BUSES & ROUTES STATE & CRUD ───────────────
  final List<AdminBus> _adminBuses = [
    const AdminBus(id: 'BUS-001', busNumber: 'SB-04', busName: 'Campus Express 04', registrationNumber: 'KA-01-EQ-1234', capacity: 50, currentOccupancy: 42, driverName: 'Ravi Kumar', driverPhone: '+91 98888 11111', assignedRoute: 'Route A - Central Line', assignedInchargeId: 'INC-001', assignedInchargeName: 'Suresh Kumar', status: 'Active', lastService: '12 May 2024'),
    const AdminBus(id: 'BUS-002', busNumber: 'SB-12', busName: 'City Connector 12', registrationNumber: 'KA-01-EQ-5678', capacity: 60, currentOccupancy: 38, driverName: 'Imran Khan', driverPhone: '+91 98888 22222', assignedRoute: 'Route B - North Circuit', assignedInchargeId: 'INC-002', assignedInchargeName: 'Meena Kumari', status: 'Active', lastService: '01 Jun 2024'),
  ];
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
    {'id': 'STF-01', 'name': 'Dr. Rajesh Rao', 'role': 'Transport Head', 'email': 'rajesh@college.edu', 'phone': '+91 91111 22222'},
    {'id': 'STF-02', 'name': 'Anita Desai', 'role': 'System Admin', 'email': 'anita@college.edu', 'phone': '+91 91111 33333'},
  ];
  List<Map<String, String>> get staffMembers => List.unmodifiable(_staffMembers);

  void addStaff(Map<String, String> staff) {
    _staffMembers.insert(0, staff);
    notifyListeners();
  }

  void removeStaff(String id) {
    _staffMembers.removeWhere((s) => s['id'] == id);
    notifyListeners();
  }

  // ─── EXISTING STUDENT APP MOCK MODELS ─────────────────
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
  ];
  final ads = const [
    Advertisement(tag: 'SMART TRAVEL', title: 'Your ride, right on time.', subtitle: 'Track every stop in real time.', color: AppColors.primary),
  ];
  final notifications = const [
    AppNotification(title: 'Bus is approaching', message: 'Campus Express will reach Central Library in 8 minutes.', time: 'Now', category: 'Trip', icon: Icons.directions_bus_rounded, unread: true),
  ];
}
