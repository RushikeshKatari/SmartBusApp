import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'hod_api_service.dart';
import 'manager_api_service.dart';

class AuthApiService {
  static String get baseUrl => AppConfig.endpoint('/api/auth');
  static String? _jwtToken;
  static String? _currentUserRole;
  static String? _currentUsername;
  static String? _currentDisplayName;

  static String? get jwtToken => _jwtToken;
  static String? get currentUserRole => _currentUserRole;
  static String? get currentUsername => _currentUsername;
  static String? get currentDisplayName => _currentDisplayName;

  static Map<String, String> get authenticatedHeaders => {
    'Content-Type': 'application/json',
    if (_jwtToken != null) 'Authorization': 'Bearer $_jwtToken',
  };

  /// Authenticate against backend /api/auth/login with fallback to offline demo credentials
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    String? expectedRole,
  }) async {
    logout();
    final cleanUser = username.trim();
    final cleanPass = password;

    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': cleanUser,
              'password': cleanPass,
              'role': expectedRole,
            }),
          )
          .timeout(const Duration(seconds: 3));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _jwtToken = data['token'] as String?;
        _currentUserRole = data['role'] as String? ?? expectedRole;
        _currentUsername = data['username'] as String? ?? cleanUser;
        _currentDisplayName = data['displayName'] as String?;
        if (_currentUserRole == 'HOD') HodApiService.attachToken(_jwtToken);
        if (_currentUserRole == 'APP_MANAGER') {
          ManagerApiService.attachToken(_jwtToken);
        }
        final profile = await currentUser();
        return {
          'success': true,
          'role': _currentUserRole,
          'username': _currentUsername,
          'displayName': _currentDisplayName,
          if (profile != null) ...profile,
          'isBackend': true,
        };
      }
      return {
        'success': false,
        'error':
            'Login rejected by the server (${res.statusCode}). Check your credentials and role.',
      };
    } catch (_) {
      // Network failure may use local credentials only when demo mode is enabled.
    }

    // Offline / Demo credentials validation
    final role = AppConfig.demoMode
        ? _verifyDemoCredentials(cleanUser, cleanPass, expectedRole)
        : null;
    if (role != null) {
      _currentUserRole = role;
      _currentUsername = cleanUser;
      _currentDisplayName = _getDemoDisplayName(role, cleanUser);
      return {
        'success': true,
        'role': role,
        'username': _currentUsername,
        'displayName': _currentDisplayName,
        'isBackend': false,
      };
    }

    return {
      'success': false,
      'error': AppConfig.demoMode
          ? 'Invalid credentials. Please enter a valid ID and password.'
          : 'Unable to reach the SmartBus server. Check your connection and API URL.',
    };
  }

  static String? _verifyDemoCredentials(
    String username,
    String password,
    String? expectedRole,
  ) {
    final u = username.toLowerCase();
    final p = password;

    // STUDENT: student / student123 or roll number CS2024-117
    if ((u == 'student' || u == 'cs2024-117' || u == 'aarav') &&
        (p == 'student123' || p == '123456')) {
      if (expectedRole == null || expectedRole == 'STUDENT') return 'STUDENT';
    }

    // INCHARGE: incharge / incharge123 or meera
    if ((u == 'incharge' || u == 'meera' || u == 'sb-04') &&
        (p == 'incharge123' || p == '123456')) {
      if (expectedRole == null || expectedRole == 'INCHARGE') return 'INCHARGE';
    }

    // ADMIN: admin / admin123 or transport
    if ((u == 'admin' || u == 'transport') &&
        (p == 'admin123' || p == '123456')) {
      if (expectedRole == null || expectedRole == 'ADMIN') return 'ADMIN';
    }

    // HOD: hod / hod123 or hodcse
    if ((u == 'hod' || u == 'hodcse') && (p == 'hod123' || p == '123456')) {
      if (expectedRole == null || expectedRole == 'HOD') return 'HOD';
    }

    // APP MANAGER: superadmin / admin123 or manager
    if ((u == 'superadmin' || u == 'manager') &&
        (p == 'admin123' || p == '123456')) {
      if (expectedRole == null || expectedRole == 'APP_MANAGER') {
        return 'APP_MANAGER';
      }
    }

    return null;
  }

  static String _getDemoDisplayName(String role, String username) {
    switch (role) {
      case 'STUDENT':
        return 'Aarav Sharma';
      case 'INCHARGE':
        return 'Meera Singh';
      case 'ADMIN':
        return 'Transport Administrator';
      case 'HOD':
        return 'Head of Department (CSE)';
      case 'APP_MANAGER':
        return 'System Application Manager';
      default:
        return username;
    }
  }

  static void logout() {
    _jwtToken = null;
    _currentUserRole = null;
    _currentUsername = null;
    _currentDisplayName = null;
    HodApiService.logout();
    ManagerApiService.logout();
  }

  static Future<Map<String, dynamic>?> currentUser() async {
    if (_jwtToken == null) return null;
    try {
      final response = await http.get(
        Uri.parse(AppConfig.endpoint('/api/auth/me')),
        headers: authenticatedHeaders,
      );
      if (response.statusCode != 200) return null;
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
