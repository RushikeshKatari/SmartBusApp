import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'auth_api_service.dart';

class AccountApiService {
  static Future<Map<String, String>?> createStudent({
    required String name,
    required String rollNumber,
    required String department,
    required String phone,
    required int academicYear,
    required String busNumber,
  }) =>
      _post('/api/admin/students', {
        'displayName': name,
        'rollNumber': rollNumber,
        'department': department,
        'phone': phone,
        'academicYear': academicYear,
        'busNumber': busNumber,
      });

  static Future<Map<String, String>?> createAccount({
    required String username,
    required String displayName,
    required String role,
  }) =>
      _post('/api/admin/accounts', {
        'username': username,
        'displayName': displayName,
        'role': role,
      });

  static Future<Map<String, String>?> resetPassword(String username) => _post(
      '/api/admin/accounts/${Uri.encodeComponent(username)}/reset-password',
      {});

  static Future<Map<String, dynamic>?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.endpoint('/api/auth/password/change')),
        headers: AuthApiService.authenticatedHeaders,
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      if (response.statusCode != 200) return null;
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, String>?> _post(
    String path,
    Map<String, Object?> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.endpoint(path)),
        headers: AuthApiService.authenticatedHeaders,
        body: jsonEncode(body),
      );
      if (response.statusCode != 200 && response.statusCode != 201) return null;
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (_) {
      return null;
    }
  }
}
