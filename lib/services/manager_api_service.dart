import 'dart:convert';
import 'package:http/http.dart' as http;

class ManagerApiService {
  static const String baseUrl = 'http://localhost:8080/api/manager';
  static String? _jwtToken;

  static Future<bool> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _jwtToken = data['token'];
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getMetrics(String timeframe) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/metrics?timeframe=$timeframe'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
      return {};
    } catch (e) {
      return {};
    }
  }

  static Future<List<dynamic>> getServiceBilling() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/billing/services'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getConfigs() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/configs'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
      return [];
    } catch (e) {
      return [];
    }
  }
  static Future<bool> sendEmergencyReport(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/emergency'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_jwtToken',
        },
        body: jsonEncode(data),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

