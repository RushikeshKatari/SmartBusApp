import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as geo;

import '../config/app_config.dart';
import 'auth_api_service.dart';

class RoutedPathResult {
  const RoutedPathResult({required this.points, required this.source});

  final List<geo.LatLng> points;
  final String source;

  bool get followsRoads => source == 'OSRM_OPENSTREETMAP';
}

class RoutePathApiService {
  static Future<RoutedPathResult?> fetchOrderedRoadPath(
    List<geo.LatLng> waypoints,
  ) async {
    if (waypoints.length < 2 || waypoints.length > 100) return null;
    try {
      final response = await http
          .post(
            Uri.parse(AppConfig.endpoint('/api/fleet/road-path')),
            headers: AuthApiService.authenticatedHeaders,
            body: jsonEncode({
              'waypoints': waypoints
                  .map((point) => {
                        'latitude': point.latitude,
                        'longitude': point.longitude,
                      })
                  .toList(),
            }),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final points = (body['points'] as List? ?? [])
          .whereType<Map>()
          .map((point) => geo.LatLng(
                (point['latitude'] as num).toDouble(),
                (point['longitude'] as num).toDouble(),
              ))
          .toList(growable: false);
      return RoutedPathResult(
        points: points,
        source: body['source']?.toString() ?? 'UNKNOWN',
      );
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, List<geo.LatLng>>> fetchRoadPaths({
    String? busNumber,
  }) async {
    try {
      final query = busNumber == null
          ? ''
          : '?busNumber=${Uri.encodeQueryComponent(busNumber)}';
      final response = await http
          .get(
            Uri.parse(AppConfig.endpoint('/api/fleet/road-paths$query')),
            headers: AuthApiService.authenticatedHeaders,
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) return {};
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body.map((bus, value) {
        final points = (value as Map<String, dynamic>)['points'] as List? ?? [];
        return MapEntry(
          bus,
          points
              .whereType<Map>()
              .map((point) => geo.LatLng(
                    (point['latitude'] as num).toDouble(),
                    (point['longitude'] as num).toDouble(),
                  ))
              .toList(),
        );
      });
    } catch (_) {
      return {};
    }
  }
}
