import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class HodApiService {
  static String get _baseUrl => AppConfig.endpoint('/api/hod');
  static String? _token;

  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(Uri.parse('$_baseUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}));
      if (response.statusCode != 200) return false;
      _token = (jsonDecode(response.body) as Map<String, dynamic>)['token']
          as String?;
      return _token != null;
    } catch (_) {
      return false;
    }
  }

  static Future<List<dynamic>> fetchEmergencyReports() async {
    if (_token == null) return [];
    try {
      final response = await http.get(Uri.parse('$_baseUrl/emergency-reports'),
          headers: {'Authorization': 'Bearer $_token'});
      return response.statusCode == 200
          ? jsonDecode(response.body) as List<dynamic>
          : [];
    } catch (_) {
      return [];
    }
  }

  static Future<bool> createAcademicSection({
    required int academicYear,
    required String specialization,
    required String sectionNumber,
    required List<Map<String, dynamic>> students,
  }) async {
    if (_token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/academic/sections'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'academicYear': academicYear,
          'specialization': specialization,
          'sectionNumber': sectionNumber,
          'students': students
        }),
      );
      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> approveEmergencyAttendance(String reportId) =>
      _sendEmergencyAction(reportId, 'approve-attendance');

  static Future<bool> grantEmergencyPermission(String reportId) =>
      _sendEmergencyAction(reportId, 'give-permission');

  static Future<bool> _sendEmergencyAction(
      String reportId, String action) async {
    if (_token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/emergency-reports/$reportId/$action'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
