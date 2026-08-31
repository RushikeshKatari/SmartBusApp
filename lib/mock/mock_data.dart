import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
// MOCK STUDENTS
// ─────────────────────────────────────────────
class MockData {
  static const List<AdminStudent> students = [
    AdminStudent(id: 'S001', name: 'Aarav Sharma', rollNumber: 'CS2024-117', department: 'Computer Science', year: '3rd Year', assignedBus: 'SB-04', phone: '98765 43210', email: 'aarav.s@college.edu', status: 'Active', initials: 'AS', avatarColor: AppColors.primary),
    AdminStudent(id: 'S002', name: 'Nisha Patel', rollNumber: 'EC2024-063', department: 'Electronics', year: '3rd Year', assignedBus: 'SB-12', phone: '87654 32109', email: 'nisha.p@college.edu', status: 'Active', initials: 'NP', avatarColor: Color(0xFF7C3AED)),
    AdminStudent(id: 'S003', name: 'Rohan Mehta', rollNumber: 'ME2024-021', department: 'Mechanical', year: '2nd Year', assignedBus: 'SB-04', phone: '76543 21098', email: 'rohan.m@college.edu', status: 'Active', initials: 'RM', avatarColor: AppColors.success),
    AdminStudent(id: 'S004', name: 'Priya Rao', rollNumber: 'CI2025-088', department: 'Civil', year: '1st Year', assignedBus: 'SB-09', phone: '65432 10987', email: 'priya.r@college.edu', status: 'Inactive', initials: 'PR', avatarColor: AppColors.warning),
    AdminStudent(id: 'S005', name: 'Karthik Iyer', rollNumber: 'EE2023-145', department: 'Electrical', year: '4th Year', assignedBus: 'SB-02', phone: '54321 09876', email: 'karthik.i@college.edu', status: 'Active', initials: 'KI', avatarColor: Color(0xFFEC4899)),
    AdminStudent(id: 'S006', name: 'Ananya Singh', rollNumber: 'CS2025-033', department: 'Computer Science', year: '1st Year', assignedBus: 'SB-04', phone: '43210 98765', email: 'ananya.s@college.edu', status: 'Active', initials: 'AS', avatarColor: Color(0xFF0891B2)),
    AdminStudent(id: 'S007', name: 'Vikram Gupta', rollNumber: 'ME2023-077', department: 'Mechanical', year: '4th Year', assignedBus: 'SB-12', phone: '32109 87654', email: 'vikram.g@college.edu', status: 'Active', initials: 'VG', avatarColor: Color(0xFFF97316)),
    AdminStudent(id: 'S008', name: 'Sneha Desai', rollNumber: 'EC2024-112', department: 'Electronics', year: '3rd Year', assignedBus: 'SB-09', phone: '21098 76543', email: 'sneha.d@college.edu', status: 'Inactive', initials: 'SD', avatarColor: Color(0xFF14B8A6)),
    AdminStudent(id: 'S009', name: 'Arjun Nair', rollNumber: 'IT2024-056', department: 'Information Tech', year: '3rd Year', assignedBus: 'SB-04', phone: '10987 65432', email: 'arjun.n@college.edu', status: 'Active', initials: 'AN', avatarColor: Color(0xFF8B5CF6)),
    AdminStudent(id: 'S010', name: 'Divya Kumar', rollNumber: 'CI2024-099', department: 'Civil', year: '3rd Year', assignedBus: 'SB-02', phone: '90876 54321', email: 'divya.k@college.edu', status: 'Active', initials: 'DK', avatarColor: Color(0xFFEF4444)),
  ];

  // ─────────────────────────────────────────────
  // MOCK BUS INCHARGES
  // ─────────────────────────────────────────────
  static const List<BusIncharge> incharges = [
    BusIncharge(id: 'I001', name: 'Meera Singh', assignedBus: 'Campus Express', assignedBusId: 'SB-04', phone: '94567 89012', email: 'meera.s@college.edu', status: 'Active', initials: 'MS', avatarColor: Color(0xFF7C3AED), joinedDate: 'Jan 2023'),
    BusIncharge(id: 'I002', name: 'Suresh Rao', assignedBus: 'City Connector', assignedBusId: 'SB-12', phone: '83456 78901', email: 'suresh.r@college.edu', status: 'Active', initials: 'SR', avatarColor: AppColors.success, joinedDate: 'Mar 2022'),
    BusIncharge(id: 'I003', name: 'Fatima Khan', assignedBus: 'Green Line', assignedBusId: 'SB-09', phone: '72345 67890', email: 'fatima.k@college.edu', status: 'Active', initials: 'FK', avatarColor: Color(0xFFEC4899), joinedDate: 'Jun 2023'),
    BusIncharge(id: 'I004', name: 'Ranjit Verma', assignedBus: 'Blue Arrow', assignedBusId: 'SB-02', phone: '61234 56789', email: 'ranjit.v@college.edu', status: 'Inactive', initials: 'RV', avatarColor: AppColors.warning, joinedDate: 'Sep 2021'),
    BusIncharge(id: 'I005', name: 'Lakshmi Pillai', assignedBus: 'North Shuttle', assignedBusId: 'SB-17', phone: '50123 45678', email: 'lakshmi.p@college.edu', status: 'Active', initials: 'LP', avatarColor: Color(0xFF0891B2), joinedDate: 'Feb 2024'),
  ];

  // ─────────────────────────────────────────────
  // MOCK BUSES
  // ─────────────────────────────────────────────
  static const List<AdminBus> buses = [
    AdminBus(id: 'B001', busNumber: 'SB-04', busName: 'Campus Express', registrationNumber: 'KA 01 AB 4021', capacity: 48, currentOccupancy: 34, driverName: 'Ravi Kumar', driverPhone: '98765 43210', assignedRoute: 'North Campus Morning Run', assignedInchargeId: 'I001', assignedInchargeName: 'Meera Singh', status: 'Active', lastService: '10 Jul 2026'),
    AdminBus(id: 'B002', busNumber: 'SB-12', busName: 'City Connector', registrationNumber: 'KA 01 CD 1234', capacity: 52, currentOccupancy: 41, driverName: 'Imran Khan', driverPhone: '87654 32109', assignedRoute: 'West Gate Evening Loop', assignedInchargeId: 'I002', assignedInchargeName: 'Suresh Rao', status: 'Active', lastService: '5 Jul 2026'),
    AdminBus(id: 'B003', busNumber: 'SB-09', busName: 'Green Line', registrationNumber: 'KA 02 EF 5678', capacity: 44, currentOccupancy: 22, driverName: 'Nisha Patel', driverPhone: '76543 21098', assignedRoute: 'South Campus Loop', assignedInchargeId: 'I003', assignedInchargeName: 'Fatima Khan', status: 'On Duty', lastService: '12 Jul 2026'),
    AdminBus(id: 'B004', busNumber: 'SB-02', busName: 'Blue Arrow', registrationNumber: 'KA 03 GH 9012', capacity: 56, currentOccupancy: 0, driverName: 'Suresh Rao', driverPhone: '65432 10987', assignedRoute: 'East Wing Route', assignedInchargeId: 'I004', assignedInchargeName: 'Ranjit Verma', status: 'Maintenance', lastService: '1 Jul 2026'),
    AdminBus(id: 'B005', busNumber: 'SB-17', busName: 'North Shuttle', registrationNumber: 'KA 04 IJ 3456', capacity: 38, currentOccupancy: 19, driverName: 'Priya Rao', driverPhone: '54321 09876', assignedRoute: 'North Hostel Run', assignedInchargeId: 'I005', assignedInchargeName: 'Lakshmi Pillai', status: 'Active', lastService: '8 Jul 2026'),
  ];

  // ─────────────────────────────────────────────
  // MOCK ROUTES (for approval)
  // ─────────────────────────────────────────────
  static final List<RouteRecord> routeRecords = [
    const RouteRecord(
      id: 'R001',
      routeName: 'North Campus Morning Run',
      busId: 'B001',
      busNumber: 'SB-04',
      inchargeId: 'I001',
      inchargeName: 'Meera Singh',
      distanceKm: 18.6,
      durationMinutes: 42,
      createdAt: '18 Jul 2026, 08:30 AM',
      status: 'Pending',
      stops: [
        RecordedBoardingStop(id: 'BS001', name: 'Central Library', landmark: 'Near Admin Block', type: 'Pickup & Drop', estimatedWaitMinutes: 3),
        RecordedBoardingStop(id: 'BS002', name: 'Tech Park Gate', landmark: 'Opp. Canteen', type: 'Pickup', estimatedWaitMinutes: 2),
        RecordedBoardingStop(id: 'BS003', name: 'North Hostel', landmark: 'Boys Hostel A', type: 'Pickup & Drop', estimatedWaitMinutes: 4),
        RecordedBoardingStop(id: 'BS004', name: 'Innovation Hub', landmark: 'Next to Lab Block', type: 'Drop', estimatedWaitMinutes: 2),
        RecordedBoardingStop(id: 'BS005', name: 'Sports Complex', landmark: 'Near Football Ground', type: 'Pickup', estimatedWaitMinutes: 3),
      ],
    ),
    const RouteRecord(
      id: 'R002',
      routeName: 'West Gate Evening Loop',
      busId: 'B002',
      busNumber: 'SB-12',
      inchargeId: 'I002',
      inchargeName: 'Suresh Rao',
      distanceKm: 14.2,
      durationMinutes: 35,
      createdAt: '17 Jul 2026, 05:15 PM',
      status: 'Approved',
      stops: [
        RecordedBoardingStop(id: 'BS006', name: 'Main Gate', landmark: 'College Main Entrance', type: 'Pickup & Drop', estimatedWaitMinutes: 5),
        RecordedBoardingStop(id: 'BS007', name: 'West Hostel', landmark: 'Girls Hostel B', type: 'Drop', estimatedWaitMinutes: 3),
        RecordedBoardingStop(id: 'BS008', name: 'City Market', landmark: 'Near Bus Stand', type: 'Pickup & Drop', estimatedWaitMinutes: 4),
      ],
    ),
    const RouteRecord(
      id: 'R003',
      routeName: 'South Campus Loop',
      busId: 'B003',
      busNumber: 'SB-09',
      inchargeId: 'I003',
      inchargeName: 'Fatima Khan',
      distanceKm: 11.8,
      durationMinutes: 28,
      createdAt: '16 Jul 2026, 07:45 AM',
      status: 'Pending',
      stops: [
        RecordedBoardingStop(id: 'BS009', name: 'South Gate', landmark: 'Back Entrance', type: 'Pickup', estimatedWaitMinutes: 2),
        RecordedBoardingStop(id: 'BS010', name: 'Medical Block', landmark: 'Near Hospital', type: 'Pickup & Drop', estimatedWaitMinutes: 3),
        RecordedBoardingStop(id: 'BS011', name: 'Research Center', landmark: 'IT Park', type: 'Drop', estimatedWaitMinutes: 2),
        RecordedBoardingStop(id: 'BS012', name: 'Garden Area', landmark: 'Near Clock Tower', type: 'Pickup', estimatedWaitMinutes: 2),
      ],
    ),
    const RouteRecord(
      id: 'R004',
      routeName: 'East Wing Route',
      busId: 'B004',
      busNumber: 'SB-02',
      inchargeId: 'I004',
      inchargeName: 'Ranjit Verma',
      distanceKm: 22.4,
      durationMinutes: 55,
      createdAt: '15 Jul 2026, 09:00 AM',
      status: 'Rejected',
      stops: [
        RecordedBoardingStop(id: 'BS013', name: 'East Campus', landmark: 'Engineering Block', type: 'Pickup', estimatedWaitMinutes: 4),
        RecordedBoardingStop(id: 'BS014', name: 'Library Junction', landmark: 'Old Library', type: 'Pickup & Drop', estimatedWaitMinutes: 3),
      ],
    ),
    const RouteRecord(
      id: 'R005',
      routeName: 'North Hostel Run',
      busId: 'B005',
      busNumber: 'SB-17',
      inchargeId: 'I005',
      inchargeName: 'Lakshmi Pillai',
      distanceKm: 9.3,
      durationMinutes: 22,
      createdAt: '19 Jul 2026, 06:30 AM',
      status: 'Pending',
      stops: [
        RecordedBoardingStop(id: 'BS015', name: 'North Hostel Block', landmark: 'Near Water Tank', type: 'Pickup', estimatedWaitMinutes: 5),
        RecordedBoardingStop(id: 'BS016', name: 'Faculty Quarters', landmark: 'Staff Colony', type: 'Pickup', estimatedWaitMinutes: 3),
        RecordedBoardingStop(id: 'BS017', name: 'Admin Block', landmark: 'Principal Office', type: 'Drop', estimatedWaitMinutes: 2),
      ],
    ),
  ];

  // ─────────────────────────────────────────────
  // MOCK ADVERTISEMENTS
  // ─────────────────────────────────────────────
  static const List<AdminAdvertisement> advertisements = [
    AdminAdvertisement(id: 'AD001', title: 'Your ride, right on time.', subtitle: 'Track every stop in real time.', tag: 'SMART TRAVEL', color: AppColors.primary, status: 'Active', scheduledFrom: '1 Jul 2026', scheduledTo: '31 Jul 2026', impressions: 12480),
    AdminAdvertisement(id: 'AD002', title: 'Never miss a class again.', subtitle: 'Set a smart arrival alarm.', tag: 'CAMPUS LIFE', color: Color(0xFF7C3AED), status: 'Active', scheduledFrom: '15 Jul 2026', scheduledTo: '15 Aug 2026', impressions: 8930),
    AdminAdvertisement(id: 'AD003', title: 'Safety first, always.', subtitle: 'Our buses are GPS tracked 24/7.', tag: 'SAFETY', color: AppColors.success, status: 'Inactive', scheduledFrom: '1 Jun 2026', scheduledTo: '30 Jun 2026', impressions: 5210),
    AdminAdvertisement(id: 'AD004', title: 'Green commute initiative.', subtitle: 'Save fuel, ride together.', tag: 'ECO CAMPUS', color: Color(0xFF0891B2), status: 'Scheduled', scheduledFrom: '1 Aug 2026', scheduledTo: '31 Aug 2026', impressions: 0),
  ];

  // ─────────────────────────────────────────────
  // MOCK NOTIFICATIONS
  // ─────────────────────────────────────────────
  static const List<AdminNotificationItem> sentNotifications = [
    AdminNotificationItem(id: 'N001', title: 'Bus Schedule Update', message: 'SB-04 Campus Express will run 15 minutes late tomorrow due to maintenance.', audience: 'All Students', sentAt: '19 Jul 2026, 8:00 PM', reachCount: 4285),
    AdminNotificationItem(id: 'N002', title: 'Route Change Alert', message: 'Green Line route diverted via South Gate for 3 days.', audience: 'SB-09 Passengers', sentAt: '18 Jul 2026, 3:45 PM', reachCount: 312),
    AdminNotificationItem(id: 'N003', title: 'New Route Approved', message: 'North Campus Morning Run route has been approved and is now live.', audience: 'Bus Incharges', sentAt: '17 Jul 2026, 11:00 AM', reachCount: 5),
    AdminNotificationItem(id: 'N004', title: 'Holiday Notice', message: 'No bus services on 22 Jul 2026 due to college holiday.', audience: 'All Students', sentAt: '16 Jul 2026, 9:00 AM', reachCount: 4285),
  ];

  // ─────────────────────────────────────────────
  // MOCK REPORT DATA
  // ─────────────────────────────────────────────
  static const List<AttendancePoint> weeklyAttendance = [
    AttendancePoint(label: 'Mon', value: 3820, total: 4285),
    AttendancePoint(label: 'Tue', value: 4100, total: 4285),
    AttendancePoint(label: 'Wed', value: 3950, total: 4285),
    AttendancePoint(label: 'Thu', value: 4200, total: 4285),
    AttendancePoint(label: 'Fri', value: 3700, total: 4285),
    AttendancePoint(label: 'Sat', value: 1200, total: 4285),
  ];

  static const List<OccupancyPoint> busOccupancy = [
    OccupancyPoint(busNumber: 'SB-04', percentage: 70.8),
    OccupancyPoint(busNumber: 'SB-12', percentage: 78.8),
    OccupancyPoint(busNumber: 'SB-09', percentage: 50.0),
    OccupancyPoint(busNumber: 'SB-02', percentage: 0.0),
    OccupancyPoint(busNumber: 'SB-17', percentage: 50.0),
  ];

  // ─────────────────────────────────────────────
  // INCHARGE — MY BUS (Meera's assigned bus)
  // ─────────────────────────────────────────────
  static const AdminBus meeraBus = AdminBus(
    id: 'B001',
    busNumber: 'SB-04',
    busName: 'Campus Express',
    registrationNumber: 'KA 01 AB 4021',
    capacity: 48,
    currentOccupancy: 34,
    driverName: 'Ravi Kumar',
    driverPhone: '98765 43210',
    assignedRoute: 'North Campus Morning Run',
    assignedInchargeId: 'I001',
    assignedInchargeName: 'Meera Singh',
    status: 'Active',
    lastService: '10 Jul 2026',
  );

  // Routes submitted by Meera
  static List<RouteRecord> get meeraRoutes =>
      routeRecords.where((r) => r.inchargeId == 'I001').toList();
}
