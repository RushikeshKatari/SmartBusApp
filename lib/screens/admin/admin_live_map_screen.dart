import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:latlong2/latlong.dart' as geo;
import '../../models/app_models.dart';
import '../../mock/hyderabad_route_data.dart';
import '../../providers/smart_bus_provider.dart';
import '../../services/route_path_api_service.dart';
import '../../theme/app_theme.dart';

class AdminLiveMapScreen extends StatefulWidget {
  const AdminLiveMapScreen({super.key});

  @override
  State<AdminLiveMapScreen> createState() => _AdminLiveMapScreenState();
}

class _AdminLiveMapScreenState extends State<AdminLiveMapScreen> {
  final osm.MapController _mapController = osm.MapController();
  LiveBusRoute? _selectedRoute;
  LiveRouteStop? _selectedStop;
  bool _isBreakdownTabSelected = false;
  int _simulatedStrandedPassengers = 15;
  Set<String> _selectedBreakdownBusNumbers = {};
  bool _isSimulatingBreakdown = false;
  Map<String, List<geo.LatLng>> _roadPaths = const {};
  bool _fleetSimulationRunning = false;
  bool _fleetSimulationStarted = false;
  double _minimumSpeedKmh = 60;
  double _maximumSpeedKmh = 100;
  DateTime? _lastFleetTickAt;
  final Map<String, double> _busDistanceKm = {};
  final Map<String, double> _busRouteLengthsKm = {};
  final Map<String, double> _busSpeedsKmh = {};
  final math.Random _simulationRandom = math.Random();
  Timer? _busTicker;
  Timer? _breakdownBlinkTimer;
  bool _rescueGlowOn = true;
  String? _visualizedBreakdownId;
  final Map<String, Color> _rescueRouteColors = {};
  final Map<String, List<geo.LatLng>> _emergencyRoadPaths = {};
  final Set<String> _emergencyRoadPathUnavailable = {};
  String? _roadPathRequestSignature;
  bool _roadPathsReady = false;

  @override
  void initState() {
    super.initState();
    _busTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_fleetSimulationRunning) return;
      final now = DateTime.now();
      final previous = _lastFleetTickAt ?? now;
      final elapsedSeconds = now.difference(previous).inMilliseconds / 1000;
      for (final entry in _busSpeedsKmh.entries) {
        final advancedDistance = (_busDistanceKm[entry.key] ?? 0) +
            entry.value * elapsedSeconds / 3600;
        final routeLength = _busRouteLengthsKm[entry.key];
        _busDistanceKm[entry.key] = routeLength == null
            ? advancedDistance
            : advancedDistance.clamp(0.0, routeLength);
      }
      _lastFleetTickAt = now;
      setState(() {});
    });
  }

  void _toggleFleetSimulation(List<LiveBusRoute> routes) {
    setState(() {
      if (_fleetSimulationRunning) {
        _lastFleetTickAt = null;
        _fleetSimulationRunning = false;
        return;
      }

      _randomizeBusSpeeds(routes);
      _busRouteLengthsKm
        ..clear()
        ..addEntries(routes.map((route) => MapEntry(
              route.busNumber,
              _routeDistanceKm(_mapPathFor(route)),
            )));
      if (!_fleetSimulationStarted) _busDistanceKm.clear();
      _fleetSimulationStarted = true;
      _lastFleetTickAt = DateTime.now();
      _fleetSimulationRunning = true;
    });
  }

  void _randomizeBusSpeeds(List<LiveBusRoute> routes) {
    _busSpeedsKmh
      ..clear()
      ..addEntries(routes.map((route) => MapEntry(
            route.busNumber,
            _minimumSpeedKmh +
                _simulationRandom.nextDouble() *
                    (_maximumSpeedKmh - _minimumSpeedKmh),
          )));
  }

  void _startBreakdownBlink(
    BreakdownRerouteEvent breakdown,
    List<LiveBusRoute> routes,
  ) {
    _breakdownBlinkTimer?.cancel();
    const palette = [
      Color(0xFFEF4444),
      Color(0xFF3B82F6),
      Color(0xFF22C55E),
      Color(0xFFFACC15),
    ];
    final shuffledPalette = [...palette]..shuffle(_simulationRandom);
    _rescueRouteColors
      ..clear()
      ..addEntries([
        for (var index = 0; index < breakdown.rescueBusNumbers.length; index++)
          MapEntry(
            breakdown.rescueBusNumbers[index],
            shuffledPalette[index % shuffledPalette.length],
          ),
      ]);
    _emergencyRoadPaths.clear();
    _emergencyRoadPathUnavailable.clear();
    _rescueGlowOn = true;
    _busRouteLengthsKm
      ..clear()
      ..addEntries(routes.map((route) => MapEntry(
            route.busNumber,
            _routeDistanceKm(_mapPathFor(route)),
          )));
    for (final rescueBusNumber in breakdown.rescueBusNumbers) {
      _busDistanceKm[rescueBusNumber] = 0;
    }
    _breakdownBlinkTimer = Timer.periodic(
      const Duration(milliseconds: 900),
      (_) {
        if (mounted) setState(() => _rescueGlowOn = !_rescueGlowOn);
      },
    );
    setState(() {});
  }

  void _stopBreakdownBlink() {
    _breakdownBlinkTimer?.cancel();
    _breakdownBlinkTimer = null;
    _rescueRouteColors.clear();
    _emergencyRoadPaths.clear();
    _emergencyRoadPathUnavailable.clear();
    _rescueGlowOn = true;
    _visualizedBreakdownId = null;
  }

  Future<List<String>?> _chooseBreakdownBuses(
    List<LiveBusRoute> routes,
    Set<String> alreadyBroken,
  ) =>
      showDialog<List<String>>(
        context: context,
        builder: (dialogContext) {
          final eligible = routes
              .where((route) => !alreadyBroken.contains(route.busNumber))
              .toList();
          final selected = <String>{
            ..._selectedBreakdownBusNumbers.where(
              (number) => eligible.any((route) => route.busNumber == number),
            ),
          };
          return StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: const Text('Select buses to break down'),
              content: SizedBox(
                width: 420,
                height: 360,
                child: eligible.isEmpty
                    ? const Center(child: Text('No active buses available.'))
                    : ListView.builder(
                        itemCount: eligible.length,
                        itemBuilder: (context, index) {
                          final route = eligible[index];
                          return CheckboxListTile(
                            value: selected.contains(route.busNumber),
                            title:
                                Text('${route.busNumber} · ${route.busName}'),
                            subtitle: Text(route.driverName),
                            dense: true,
                            onChanged: (checked) => setDialogState(() {
                              if (checked == true) {
                                selected.add(route.busNumber);
                              } else {
                                selected.remove(route.busNumber);
                              }
                            }),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () => Navigator.pop(dialogContext, selected.toList()),
                  child: Text('Use ${selected.length} buses'),
                ),
              ],
            ),
          );
        },
      );

  Future<void> _simulateBreakdowns(
    SmartBusProvider provider,
    List<LiveBusRoute> routes,
    Set<String> alreadyBroken,
  ) async {
    final selected = await _chooseBreakdownBuses(routes, alreadyBroken);
    if (!mounted || selected == null || selected.isEmpty) return;
    setState(() => _isSimulatingBreakdown = true);
    var completed = 0;
    for (final busNumber in selected) {
      final route = routes.firstWhere(
        (item) => item.busNumber == busNumber,
        orElse: () => routes.first,
      );
      final stop = route.stops.length > 1 ? route.stops[1] : route.stops.first;
      final success = await provider.triggerAutomatedBreakdownReroute(
        busNumber: route.busNumber,
        busName: route.busName,
        inchargeName: route.driverName,
        reason: 'Engine Breakdown',
        location: stop.landmark,
        strandedStudentsCount: _simulatedStrandedPassengers,
      );
      if (!success) break;
      completed++;
    }
    if (!mounted) return;
    setState(() {
      _isSimulatingBreakdown = false;
      _isBreakdownTabSelected = true;
      _selectedRoute = null;
      _selectedStop = null;
      _selectedBreakdownBusNumbers = {};
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          completed == selected.length
              ? '🚨 Java dispatch created for $completed bus breakdown${completed == 1 ? '' : 's'}.'
              : 'Dispatch created for $completed of ${selected.length} buses. Check backend connectivity or capacity.',
        ),
        backgroundColor: completed == selected.length
            ? AppColors.success
            : AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildRescueAssignmentSummary(
    LiveBusRoute route,
    BreakdownRerouteEvent breakdown,
  ) {
    final regularStopCount =
        route.stops.where((stop) => !stop.isDivertedPickup).length;
    final passengerCount = breakdown.stopAssignments
        .where((assignment) => assignment.assignedBusNumber == route.busNumber)
        .fold<int>(0, (total, assignment) => total + assignment.studentCount);
    final rationale = breakdown.stopAssignments
        .where((assignment) => assignment.assignedBusNumber == route.busNumber)
        .map((assignment) => assignment.assignmentReason)
        .where((reason) => reason.isNotEmpty)
        .toSet()
        .join(' ');
    final emergencyStops = route.stops
        .where((stop) => stop.isDivertedPickup)
        .map((stop) => stop.isBreakdownPickup ? 'Breakdown pickup' : stop.name)
        .toList();
    final color = _rescueRouteColors[route.busNumber] ?? route.color;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 9,
            height: 9,
            margin: const EdgeInsets.only(top: 3),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color, blurRadius: 7)],
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              '${route.busNumber} · ${route.driverName} · $passengerCount passengers · $regularStopCount original stops kept\n${emergencyStops.isEmpty ? "No emergency stops" : emergencyStops.join(" → ")}${rationale.isEmpty ? "" : "\nWhy this bus: $rationale"}',
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSpeed(double speed) => speed == speed.roundToDouble()
      ? speed.round().toString()
      : speed.toStringAsFixed(1);

  Future<void> _editSimulationSpeedRange(List<LiveBusRoute> routes) async {
    final minimumController = TextEditingController(
      text: _formatSpeed(_minimumSpeedKmh),
    );
    final maximumController = TextEditingController(
      text: _formatSpeed(_maximumSpeedKmh),
    );
    final updatedRange = await showDialog<(double, double)>(
      context: context,
      builder: (dialogContext) {
        String? validationError;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: const Text('Simulation speed range'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Each bus gets a random speed in this range.'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minimumController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Minimum',
                          suffixText: 'km/h',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: maximumController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Maximum',
                          suffixText: 'km/h',
                        ),
                      ),
                    ),
                  ],
                ),
                if (validationError != null) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      validationError!,
                      style: TextStyle(
                        color: Theme.of(dialogContext).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final minimum =
                      double.tryParse(minimumController.text.trim());
                  final maximum =
                      double.tryParse(maximumController.text.trim());
                  final validSpeeds = minimum != null &&
                      maximum != null &&
                      minimum.isFinite &&
                      maximum.isFinite &&
                      minimum >= 1 &&
                      maximum <= 200 &&
                      maximum >= minimum;
                  if (!validSpeeds) {
                    setDialogState(() {
                      validationError =
                          'Use speeds from 1 to 200 km/h, with maximum at least minimum.';
                    });
                    return;
                  }
                  Navigator.of(dialogContext).pop((minimum, maximum));
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        );
      },
    );

    minimumController.dispose();
    maximumController.dispose();
    if (!mounted || updatedRange == null) return;
    setState(() {
      _minimumSpeedKmh = updatedRange.$1;
      _maximumSpeedKmh = updatedRange.$2;
      if (_fleetSimulationRunning) _randomizeBusSpeeds(routes);
    });
  }

  String _pathSignature(List<LiveBusRoute> routes) => routes
      .map((route) =>
          '${route.busNumber}:${route.hasCustomPath}:${route.stops.where((stop) => !stop.isDivertedPickup).map((stop) => '${stop.latitude.toStringAsFixed(6)},${stop.longitude.toStringAsFixed(6)}').join(';')}')
      .join('|');

  Future<void> _loadRoadPaths(
    List<LiveBusRoute> routes,
    String signature,
  ) async {
    final serverPaths = await RoutePathApiService.fetchRoadPaths();
    final entries = await Future.wait(routes.map((route) async {
      final orderedStops = route.stops
          .where((stop) => !stop.isDivertedPickup)
          .toList(growable: false);
      if (orderedStops.length < 2) {
        return MapEntry(route.busNumber, const <geo.LatLng>[]);
      }
      final expected = orderedStops
          .map((stop) => geo.LatLng(stop.latitude, stop.longitude))
          .toList(growable: false);
      var path = serverPaths[route.busNumber] ?? const <geo.LatLng>[];
      var pathMatchesRoute = path.length > 1 &&
          _endpointErrorKm(path, expected, reverse: false) <= 0.5;
      if (path.length > 1) {
        final reverseError = _endpointErrorKm(path, expected, reverse: true);
        if (reverseError < _endpointErrorKm(path, expected, reverse: false)) {
          path = path.reversed.toList(growable: false);
          pathMatchesRoute = reverseError <= 0.5;
        }
      }
      if (route.hasCustomPath || !pathMatchesRoute) {
        final routed = await RoutePathApiService.fetchOrderedRoadPath(expected);
        if (routed != null && routed.followsRoads && routed.points.length > 1) {
          path = routed.points;
        } else if (!pathMatchesRoute || route.hasCustomPath) {
          path = expected;
        }
      }
      return MapEntry(route.busNumber, path);
    }));
    if (!mounted || _roadPathRequestSignature != signature) return;
    final paths = Map<String, List<geo.LatLng>>.fromEntries(entries);
    setState(() {
      _roadPaths = paths;
      _roadPathsReady = true;
      _busRouteLengthsKm
        ..clear()
        ..addEntries(routes.map((route) => MapEntry(
              route.busNumber,
              _routeDistanceKm(_mapPathFor(route)),
            )));
      for (final route in routes) {
        final length = _busRouteLengthsKm[route.busNumber] ?? 0;
        _busDistanceKm[route.busNumber] =
            (_busDistanceKm[route.busNumber] ?? 0).clamp(0.0, length);
      }
    });
  }

  double _endpointErrorKm(
    List<geo.LatLng> path,
    List<geo.LatLng> orderedStops, {
    required bool reverse,
  }) {
    final start = reverse ? path.last : path.first;
    final end = reverse ? path.first : path.last;
    return _segmentDistanceKm(start, orderedStops.first) +
        _segmentDistanceKm(end, orderedStops.last);
  }

  @override
  void dispose() {
    _busTicker?.cancel();
    _breakdownBlinkTimer?.cancel();
    super.dispose();
  }

  List<geo.LatLng> _pathFor(LiveBusRoute route) =>
      _roadPaths[route.busNumber] ??
      route.stops
          .where((stop) => !stop.isDivertedPickup)
          .map((stop) => geo.LatLng(stop.latitude, stop.longitude))
          .toList();

  List<geo.LatLng> _mapPathFor(LiveBusRoute route) {
    final path = _pathFor(route);
    if (path.length < 2) return path;
    final emergencyStops =
        route.stops.where((item) => item.isDivertedPickup).toList();
    if (emergencyStops.isEmpty) return path;
    // Do not draw an invented straight-line rescue path while street routing
    // is pending or unavailable.
    return _emergencyRoadPaths[route.busNumber] ?? const <geo.LatLng>[];
  }

  Future<void> _loadEmergencyRoadPaths(
    BreakdownRerouteEvent breakdown,
    List<LiveBusRoute> routes,
  ) async {
    final rescueNumbers = breakdown.rescueBusNumbers.toSet();
    final rescueRoutes = routes.where((route) =>
        rescueNumbers.contains(route.busNumber) &&
        route.stops.any((stop) => stop.isDivertedPickup));
    final unavailableBuses = <String>[];
    for (final route in rescueRoutes) {
      final regularStops = route.stops
          .where((stop) => !stop.isDivertedPickup)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      final emergencyStops = route.stops
          .where((stop) => stop.isDivertedPickup)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      if (regularStops.length < 2 || emergencyStops.isEmpty) continue;

      final start = geo.LatLng(
        regularStops.first.latitude,
        regularStops.first.longitude,
      );
      final waypoints = <geo.LatLng>[
        start,
        ...emergencyStops.map(
          (stop) => geo.LatLng(stop.latitude, stop.longitude),
        ),
        start,
        ...regularStops.skip(1).map(
              (stop) => geo.LatLng(stop.latitude, stop.longitude),
            ),
      ];
      final result = await RoutePathApiService.fetchOrderedRoadPath(waypoints);
      if (!mounted || _visualizedBreakdownId != breakdown.id) return;
      if (result != null && result.followsRoads && result.points.length > 1) {
        _emergencyRoadPaths[route.busNumber] = result.points;
        _emergencyRoadPathUnavailable.remove(route.busNumber);
      } else {
        _emergencyRoadPathUnavailable.add(route.busNumber);
        unavailableBuses.add(route.busNumber);
      }
      _busRouteLengthsKm[route.busNumber] =
          _routeDistanceKm(_mapPathFor(route));
      setState(() {});
    }
    if (mounted &&
        _visualizedBreakdownId == breakdown.id &&
        unavailableBuses.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Road routing unavailable for ${unavailableBuses.join(', ')}. Rescue route lines are hidden instead of shown as straight shortcuts.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<osm.Marker> _directionArrowMarkers(
    LiveBusRoute route,
    List<geo.LatLng> path,
  ) {
    if (path.length < 2) return const [];
    final segmentLengths = <double>[];
    var totalDistance = 0.0;
    for (var index = 0; index < path.length - 1; index++) {
      final length = _segmentDistanceKm(path[index], path[index + 1]);
      segmentLengths.add(length);
      totalDistance += length;
    }
    if (totalDistance < 0.3) return const [];

    final color = _rescueRouteColors[route.busNumber] ?? route.color;
    final arrowCount = (totalDistance / 1.2).ceil().clamp(3, 36);
    return List.generate(arrowCount, (arrowIndex) {
      final fraction = (arrowIndex + 1) / (arrowCount + 1);
      final targetDistance = totalDistance * fraction;
      var traversed = 0.0;
      var point = path.first;
      var angle = 0.0;
      for (var index = 0; index < segmentLengths.length; index++) {
        final segmentLength = segmentLengths[index];
        if (targetDistance <= traversed + segmentLength ||
            index == segmentLengths.length - 1) {
          final start = path[index];
          final end = path[index + 1];
          final segmentFraction = segmentLength == 0
              ? 0.0
              : ((targetDistance - traversed) / segmentLength).clamp(0.0, 1.0);
          point = geo.LatLng(
            start.latitude + (end.latitude - start.latitude) * segmentFraction,
            start.longitude +
                (end.longitude - start.longitude) * segmentFraction,
          );
          final latitudeScale = math.cos(
            ((start.latitude + end.latitude) / 2) * math.pi / 180,
          );
          angle = math.atan2(
            (end.longitude - start.longitude) * latitudeScale,
            end.latitude - start.latitude,
          );
          break;
        }
        traversed += segmentLength;
      }
      return osm.Marker(
        point: point,
        width: 20,
        height: 20,
        child: Tooltip(
          message: 'Rescue direction · ${route.busNumber}',
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xE6111827),
              shape: BoxShape.circle,
              border:
                  Border.all(color: color.withValues(alpha: 0.85), width: 1.5),
            ),
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: angle,
              child: Icon(Icons.arrow_upward_rounded, size: 13, color: color),
            ),
          ),
        ),
      );
    }).toList(growable: false);
  }

  void _focusRoute(LiveBusRoute? route, List<LiveBusRoute> allRoutes) {
    final focusedRoutes = route == null ? allRoutes : [route];
    final points = focusedRoutes.expand(_mapPathFor).toList();
    if (points.length < 2) return;
    _mapController.fitCamera(osm.CameraFit.bounds(
      bounds: osm.LatLngBounds.fromPoints(points),
      padding: const EdgeInsets.all(96),
    ));
  }

  geo.LatLng _positionOnRoute(List<geo.LatLng> points, String busNumber) {
    if (points.length < 2) return points.first;
    final distanceTraveled = _busDistanceKm[busNumber] ?? 0;
    var totalDistanceKm = 0.0;
    final segmentLengths = <double>[];
    for (var i = 0; i < points.length - 1; i++) {
      final segmentLength = _segmentDistanceKm(points[i], points[i + 1]);
      segmentLengths.add(segmentLength);
      totalDistanceKm += segmentLength;
    }
    if (totalDistanceKm == 0) return points.first;

    // Buses travel from the route's starting stop to campus, then stay parked.
    final distanceAlong = distanceTraveled.clamp(0.0, totalDistanceKm);
    var traversed = 0.0;
    for (var i = 0; i < segmentLengths.length; i++) {
      final segmentLength = segmentLengths[i];
      if (distanceAlong <= traversed + segmentLength ||
          i == segmentLengths.length - 1) {
        final fraction = segmentLength == 0
            ? 0.0
            : ((distanceAlong - traversed) / segmentLength).clamp(0.0, 1.0);
        final start = points[i];
        final end = points[i + 1];
        return geo.LatLng(
          start.latitude + (end.latitude - start.latitude) * fraction,
          start.longitude + (end.longitude - start.longitude) * fraction,
        );
      }
      traversed += segmentLength;
    }
    return points.last;
  }

  double _routeDistanceKm(List<geo.LatLng> points) {
    var distance = 0.0;
    for (var index = 0; index < points.length - 1; index++) {
      distance += _segmentDistanceKm(points[index], points[index + 1]);
    }
    return distance;
  }

  String _busTooltip(LiveBusRoute route) {
    final path = _mapPathFor(route);
    if (_fleetSimulationStarted &&
        path.length > 1 &&
        (_busDistanceKm[route.busNumber] ?? 0) >= _routeDistanceKm(path)) {
      return '${route.busNumber} · Arrived at KLH campus parking · Parked';
    }
    if (_fleetSimulationStarted) {
      return '${route.busNumber} · ${(_busSpeedsKmh[route.busNumber] ?? 0).round()} km/h · traveling to campus';
    }
    return '${route.busNumber} · waiting for simulation';
  }

  double _segmentDistanceKm(geo.LatLng start, geo.LatLng end) {
    final latitudeDelta = (end.latitude - start.latitude) * 111.32;
    final longitudeDelta = (end.longitude - start.longitude) *
        111.32 *
        math.cos(start.latitude * math.pi / 180);
    return math
        .sqrt(latitudeDelta * latitudeDelta + longitudeDelta * longitudeDelta);
  }

  geo.LatLng _snapToRoute(geo.LatLng point, List<geo.LatLng> path) {
    if (path.isEmpty) return point;
    return path.reduce((nearest, candidate) {
      final nearestDistance = math.pow(nearest.latitude - point.latitude, 2) +
          math.pow(nearest.longitude - point.longitude, 2);
      final candidateDistance =
          math.pow(candidate.latitude - point.latitude, 2) +
              math.pow(candidate.longitude - point.longitude, 2);
      return candidateDistance < nearestDistance ? candidate : nearest;
    });
  }

  void _showInvalidateDialog(
    BuildContext context,
    SmartBusProvider provider,
    String stopId,
    String stopName,
    List<LiveBusRoute> routes,
  ) {
    // Pick other available stops as redirect candidates
    final candidateStops = <String>[];
    for (final r in routes) {
      for (final s in r.stops) {
        if (s.name != stopName && !candidateStops.contains(s.name)) {
          candidateStops.add(s.name);
        }
      }
    }
    String selectedTargetStop = candidateStops.isNotEmpty
        ? candidateStops.first
        : 'Central Campus Gate';
    final walkMsgController = TextEditingController(
      text:
          'Stop temporarily merged into $selectedTargetStop. Please walk to $selectedTargetStop for pickup.',
    );

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF334155)),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.do_not_disturb_on_rounded,
                      color: AppColors.danger,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Invalidate Stop',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'No bus detour needed for "$stopName"',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select nearest stop to redirect students to:',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedTargetStop,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          items: candidateStops.map((name) {
                            return DropdownMenuItem<String>(
                              value: name,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.pin_drop_rounded,
                                    color: Color(0xFF38BDF8),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(name),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedTargetStop = val;
                                walkMsgController.text =
                                    'Stop temporarily merged into $val. Please walk to $val for pickup.';
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Walking instructions & Student notification:',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: walkMsgController,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        hintText: 'e.g., Walk 200m north to next junction...',
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF334155),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    provider.adminInvalidateStop(
                      stopId: stopId,
                      redirectToStopName: selectedTargetStop,
                      walkInstructions: walkMsgController.text.trim(),
                    );
                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Stop "$stopName" invalidated. Detour removed & redirected to $selectedTargetStop.',
                        ),
                        backgroundColor: const Color(0xFF0F172A),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.directions_walk_rounded, size: 16),
                  label: const Text('Invalidate & Redirect'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SmartBusProvider>();
    final routes = provider.liveRoutes;
    final pathSignature = _pathSignature(routes);
    if (pathSignature != _roadPathRequestSignature) {
      _roadPathRequestSignature = pathSignature;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_loadRoadPaths(routes, pathSignature));
      });
    }
    final breakdown = provider.activeBreakdown;
    final rescueBusNumbers = breakdown?.rescueBusNumbers.toSet() ?? <String>{};
    final brokenBusNumbers = breakdown?.brokenBusNumbers.toSet() ?? <String>{};
    final emphasizedBusNumbers = {
      ...brokenBusNumbers,
      ...rescueBusNumbers,
    };
    final visibleRoutes = _selectedRoute == null
        ? routes
        : routes.where((route) => route.id == _selectedRoute!.id).toList();
    if (breakdown?.id != _visualizedBreakdownId) {
      _visualizedBreakdownId = breakdown?.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (breakdown == null) {
          _stopBreakdownBlink();
        } else {
          _startBreakdownBlink(breakdown, routes);
          unawaited(_loadEmergencyRoadPaths(breakdown, routes));
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: Row(
        children: [
          // ─── LEFT SIDEBAR: ROUTE CONTROLS & FLEET BREAKDOWN ───
          Container(
            width: 360,
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(right: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF1E293B)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.map_rounded,
                              color: Color(0xFF60A5FA),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fleet Dispatch Simulator',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${routes.length} Hyderabad routes • Simulated dispatch',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFF59E0B,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF59E0B),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'DEMO',
                                  style: TextStyle(
                                    color: Color(0xFFFBBF24),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (breakdown == null) ...[
                        OutlinedButton.icon(
                          onPressed: _isSimulatingBreakdown
                              ? null
                              : () async {
                                  final selected = await _chooseBreakdownBuses(
                                    routes,
                                    brokenBusNumbers,
                                  );
                                  if (selected != null && mounted) {
                                    setState(() =>
                                        _selectedBreakdownBusNumbers =
                                            selected.toSet());
                                  }
                                },
                          icon: const Icon(Icons.library_add_check_rounded),
                          label: Text(
                            'Select buses (${_selectedBreakdownBusNumbers.length})',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 44),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Estimated passengers per bus: $_simulatedStrandedPassengers',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Slider(
                          value: _simulatedStrandedPassengers.toDouble(),
                          min: 1,
                          max: 60,
                          divisions: 59,
                          label: '$_simulatedStrandedPassengers',
                          onChanged: (value) => setState(() {
                            _simulatedStrandedPassengers = value.round();
                          }),
                        ),
                      ],
                      if (breakdown == null)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isSimulatingBreakdown ||
                                    _selectedBreakdownBusNumbers.isEmpty
                                ? null
                                : () => _simulateBreakdowns(
                                      provider,
                                      routes,
                                      brokenBusNumbers,
                                    ),
                            icon: const Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                            ),
                            label: Text(_isSimulatingBreakdown
                                ? 'Planning emergency dispatch…'
                                : 'Simulate ${_selectedBreakdownBusNumbers.length} breakdown${_selectedBreakdownBusNumbers.length == 1 ? '' : 's'}'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        )
                      else
                        // Breakdown Alert Card & Breakdown Tab Switcher
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.emergency_rounded,
                                    color: AppColors.danger,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${breakdown.brokenBusNumbers.length} Active Breakdown${breakdown.brokenBusNumbers.length == 1 ? '' : 's'}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      provider.resolveActiveBreakdown();
                                      setState(() {
                                        _isBreakdownTabSelected = false;
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Breakdown resolved. Standard fleet paths restored.',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF60A5FA),
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Resolve',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: (breakdown.studentsUnassigned == 0
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFF59E0B))
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: (breakdown.studentsUnassigned == 0
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFF59E0B))
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      breakdown.studentsUnassigned == 0
                                          ? Icons.verified_rounded
                                          : Icons.warning_amber_rounded,
                                      color: breakdown.studentsUnassigned == 0
                                          ? const Color(0xFF34D399)
                                          : const Color(0xFFFBBF24),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${breakdown.studentsCovered}/${breakdown.strandedStudentsCount} Passengers Covered • ${breakdown.coveredRemainingStops}/${breakdown.totalRemainingStops} Groups',
                                      style: TextStyle(
                                        color: breakdown.studentsUnassigned == 0
                                            ? const Color(0xFF34D399)
                                            : const Color(0xFFFBBF24),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (breakdown.explanation.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    breakdown.explanation,
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 9,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                              OutlinedButton.icon(
                                onPressed: _isSimulatingBreakdown
                                    ? null
                                    : () => _simulateBreakdowns(
                                          provider,
                                          routes,
                                          brokenBusNumbers,
                                        ),
                                icon: const Icon(Icons.add_road_rounded,
                                    size: 16),
                                label: Text(_isSimulatingBreakdown
                                    ? 'Planning additional dispatch…'
                                    : 'Add another bus breakdown'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 38),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'RESCUE ROUTE ASSIGNMENTS',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 9,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxHeight: 96),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: routes
                                        .where((route) => rescueBusNumbers
                                            .contains(route.busNumber))
                                        .map((route) =>
                                            _buildRescueAssignmentSummary(
                                                route, breakdown))
                                        .toList(),
                                  ),
                                ),
                              ),
                              if (breakdown.studentsUnassigned > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '${breakdown.studentsUnassigned} passengers still need manual support.',
                                    style: const TextStyle(
                                      color: Color(0xFFFBBF24),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),

                              // Interactive Tab Button for Breakdown Bus
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isBreakdownTabSelected =
                                        !_isBreakdownTabSelected;
                                    _selectedRoute = null;
                                    _selectedStop = null;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isBreakdownTabSelected
                                        ? AppColors.danger.withValues(
                                            alpha: 0.35,
                                          )
                                        : const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _isBreakdownTabSelected
                                          ? AppColors.danger
                                          : const Color(0xFF334155),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _isBreakdownTabSelected
                                            ? Icons.dashboard_customize_rounded
                                            : Icons.tab_rounded,
                                        color: _isBreakdownTabSelected
                                            ? const Color(0xFFFCA5A5)
                                            : Colors.white70,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Broken buses: ${breakdown.brokenBusNumbers.join(', ')}',
                                          style: TextStyle(
                                            color: _isBreakdownTabSelected
                                                ? Colors.white
                                                : Colors.white70,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _isBreakdownTabSelected
                                              ? AppColors.danger
                                              : Colors.white10,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          _isBreakdownTabSelected
                                              ? 'OPEN'
                                              : 'VIEW STOPS',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Tab Switcher / Navigation indicator
                if (breakdown != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E293B),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFF334155)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() {
                              _isBreakdownTabSelected = false;
                              _selectedRoute = null;
                              _selectedStop = null;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: !_isBreakdownTabSelected
                                    ? AppColors.primary.withValues(alpha: 0.25)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: !_isBreakdownTabSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'All Routes (${routes.length})',
                                style: TextStyle(
                                  color: !_isBreakdownTabSelected
                                      ? const Color(0xFF60A5FA)
                                      : Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                setState(() => _isBreakdownTabSelected = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: _isBreakdownTabSelected
                                    ? AppColors.danger.withValues(alpha: 0.3)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _isBreakdownTabSelected
                                      ? AppColors.danger
                                      : Colors.transparent,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Breakdown Tab',
                                style: TextStyle(
                                  color: _isBreakdownTabSelected
                                      ? const Color(0xFFFCA5A5)
                                      : Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Main Sidebar Content: Complete route list or breakdown assignments
                Expanded(
                  child: _isBreakdownTabSelected && breakdown != null
                      ? _buildBreakdownStopsTab(
                          context,
                          provider,
                          breakdown,
                          routes,
                        )
                      : Scrollbar(
                          thumbVisibility: true,
                          interactive: true,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: routes.length,
                            itemBuilder: (context, i) {
                              final r = routes[i];
                              final isSelected = _selectedRoute?.id == r.id;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? r.color.withValues(alpha: 0.18)
                                      : const Color(
                                          0xFF1E293B,
                                        ).withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? r.color
                                        : r.isBrokenDown
                                            ? AppColors.danger
                                            : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    final nextRoute = isSelected ? null : r;
                                    setState(() {
                                      _selectedRoute = nextRoute;
                                      _selectedStop = null;
                                    });
                                    _focusRoute(nextRoute, routes);
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor: r.isBrokenDown
                                        ? AppColors.danger
                                        : r.color,
                                    radius: 16,
                                    child: Icon(
                                      r.isBrokenDown
                                          ? Icons.warning_rounded
                                          : Icons.directions_bus_filled_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  title: Text(
                                    r.name,
                                    style: TextStyle(
                                      color: r.isBrokenDown
                                          ? const Color(0xFFFCA5A5)
                                          : Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${r.busNumber} • ${r.stops.length} stops (${r.totalDistanceKm} km)',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: r.isBrokenDown
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.danger.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: AppColors.danger,
                                              width: 0.8,
                                            ),
                                          ),
                                          child: const Text(
                                            'BREAKDOWN',
                                            style: TextStyle(
                                              color: AppColors.danger,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.chevron_right_rounded,
                                          color: r.color,
                                          size: 18,
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                ),

                // Selected Stop Info & Manual Reassign Tool
                if (_selectedStop != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E293B),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      border: Border(top: BorderSide(color: Color(0xFF334155))),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFF60A5FA),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedStop!.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _selectedStop = null),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white54,
                                size: 18,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Landmark: ${_selectedStop!.landmark} (Stop #${_selectedStop!.order})',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Reassign stop to another bus:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: routes.map((rt) {
                            final isCurrent = _selectedStop!
                                        .assignedPickupBusNumber ==
                                    rt.busNumber ||
                                (_selectedStop!.assignedPickupBusNumber ==
                                        null &&
                                    _selectedRoute?.busNumber == rt.busNumber);
                            return FilterChip(
                              label: Text(
                                rt.busNumber,
                                style: TextStyle(
                                  color:
                                      isCurrent ? Colors.white : Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              selected: isCurrent,
                              selectedColor: rt.color,
                              backgroundColor: const Color(0xFF0F172A),
                              onSelected: (_) {
                                final moved = provider.adminReassignStopToBus(
                                  _selectedStop!.id,
                                  rt.busNumber,
                                );
                                if (!moved) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${rt.busNumber} is unavailable or lacks spare seats for this passenger group.',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                setState(() {
                                  _selectedStop = _selectedStop!.copyWith(
                                    assignedPickupBusNumber: rt.busNumber,
                                  );
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Reassigned "${_selectedStop!.name}" to ${rt.busNumber} (${rt.busName})',
                                    ),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ─── RIGHT CANVAS: UNIFIED 5-ROUTE MAP VISUALIZER ───
          Expanded(
            child: Stack(
              children: [
                osm.FlutterMap(
                  mapController: _mapController,
                  options: osm.MapOptions(
                    initialCenter: const geo.LatLng(17.348301, 78.339918),
                    initialZoom: 10.8,
                    interactionOptions: const osm.InteractionOptions(
                      flags: osm.InteractiveFlag.all,
                    ),
                    initialCameraFit: osm.CameraFit.bounds(
                      bounds: osm.LatLngBounds.fromPoints(
                          routes.expand((route) => _pathFor(route)).toList()),
                      padding: const EdgeInsets.all(72),
                    ),
                  ),
                  children: [
                    osm.TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.smartbus',
                    ),
                    if (breakdown != null)
                      osm.PolylineLayer(
                        polylines: visibleRoutes
                            .where((route) =>
                                rescueBusNumbers.contains(route.busNumber))
                            .map((route) => osm.Polyline(
                                  points: _mapPathFor(route),
                                  color: (_rescueRouteColors[route.busNumber] ??
                                          Colors.redAccent)
                                      .withValues(
                                          alpha: _rescueGlowOn ? 0.25 : 0.12),
                                  strokeWidth: _rescueGlowOn ? 9 : 6,
                                  useStrokeWidthInMeter: false,
                                ))
                            .toList(),
                      ),
                    if (breakdown != null)
                      osm.PolylineLayer(
                        polylines: visibleRoutes
                            .where((route) =>
                                rescueBusNumbers.contains(route.busNumber))
                            .map((route) => osm.Polyline(
                                  points: _mapPathFor(route),
                                  color: (_rescueRouteColors[route.busNumber] ??
                                          Colors.redAccent)
                                      .withValues(
                                          alpha: _rescueGlowOn ? 0.9 : 0.72),
                                  strokeWidth: _rescueGlowOn ? 4 : 3,
                                  useStrokeWidthInMeter: false,
                                ))
                            .toList(),
                      ),
                    osm.PolylineLayer(
                      polylines: visibleRoutes
                          .map((route) => osm.Polyline(
                                points: _mapPathFor(route),
                                color: emphasizedBusNumbers
                                        .contains(route.busNumber)
                                    ? (route.isBrokenDown
                                        ? Colors.redAccent
                                        : (_rescueRouteColors[
                                                route.busNumber] ??
                                            Colors.redAccent))
                                    : route.color.withValues(
                                        alpha: _selectedRoute == null ||
                                                _selectedRoute!.id == route.id
                                            ? 0.9
                                            : 0.18),
                                strokeWidth: emphasizedBusNumbers
                                        .contains(route.busNumber)
                                    ? 5
                                    : _selectedRoute?.id == route.id
                                        ? 5
                                        : 3,
                              ))
                          .toList(),
                    ),
                    if (breakdown != null)
                      osm.MarkerLayer(
                        markers: visibleRoutes
                            .where((route) =>
                                rescueBusNumbers.contains(route.busNumber) &&
                                _emergencyRoadPaths
                                    .containsKey(route.busNumber))
                            .expand((route) => _directionArrowMarkers(
                                  route,
                                  _mapPathFor(route),
                                ))
                            .toList(growable: false),
                      ),
                    osm.MarkerLayer(markers: [
                      for (final route in visibleRoutes)
                        for (final stop in route.stops)
                          osm.Marker(
                            point: stop.isDivertedPickup
                                ? geo.LatLng(stop.latitude, stop.longitude)
                                : _snapToRoute(
                                    geo.LatLng(stop.latitude, stop.longitude),
                                    _mapPathFor(route),
                                  ),
                            width: stop.isBreakdownStranded ||
                                    stop.isDivertedPickup
                                ? 46
                                : 34,
                            height: stop.isBreakdownStranded ||
                                    stop.isDivertedPickup
                                ? 46
                                : 38,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRoute = route;
                                  _selectedStop = stop;
                                });
                                _focusRoute(route, routes);
                              },
                              child: Tooltip(
                                message: stop.isBreakdownPickup
                                    ? '${breakdown?.location ?? stop.landmark} · Rescue bus ${route.busNumber} collects stranded passengers here'
                                    : stop.isDivertedPickup
                                        ? '${stop.name} · Rescue pickup by ${route.busNumber}'
                                        : stop.isBreakdownStranded
                                            ? '${stop.name} · Breakdown stop · Assigned ${stop.assignedPickupBusNumber ?? "manual support"}'
                                            : '${route.busNumber} · ${stop.name}',
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (stop.isBreakdownStranded ||
                                        stop.isDivertedPickup)
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: (stop.isBreakdownStranded
                                                  ? Colors.redAccent
                                                  : (_rescueRouteColors[
                                                          route.busNumber] ??
                                                      route.color))
                                              .withValues(alpha: 0.22),
                                          boxShadow: [
                                            BoxShadow(
                                              color: stop.isBreakdownStranded
                                                  ? Colors.redAccent
                                                  : (_rescueRouteColors[
                                                          route.busNumber] ??
                                                      route.color),
                                              blurRadius: 18,
                                              spreadRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    Icon(
                                      stop.isDivertedPickup
                                          ? Icons.emergency_share_rounded
                                          : Icons.location_on,
                                      size: stop.isBreakdownStranded ||
                                              stop.isDivertedPickup
                                          ? 36
                                          : 32,
                                      color: stop.isInvalidated
                                          ? Colors.grey
                                          : stop.isBreakdownStranded
                                              ? const Color(0xFFF87171)
                                              : stop.isDivertedPickup
                                                  ? (_rescueRouteColors[
                                                          route.busNumber] ??
                                                      route.color)
                                                  : route.color,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      for (final route in visibleRoutes)
                        if (_mapPathFor(route).length > 1)
                          osm.Marker(
                            point: _positionOnRoute(
                                _mapPathFor(route), route.busNumber),
                            width: 48,
                            height: 48,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRoute = route;
                                  _selectedStop = null;
                                });
                                _focusRoute(route, routes);
                              },
                              child: Tooltip(
                                message: _busTooltip(route),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: route.isBrokenDown
                                        ? Colors.red
                                        : route.color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black38, blurRadius: 8)
                                    ],
                                  ),
                                  child: const Icon(Icons.directions_bus,
                                      color: Colors.white, size: 24),
                                ),
                              ),
                            ),
                          ),
                      osm.Marker(
                        point: geo.LatLng(HyderabadRouteData.campus.latitude,
                            HyderabadRouteData.campus.longitude),
                        width: 40,
                        height: 44,
                        child: const Tooltip(
                            message: 'KLH Aziz Nagar Campus',
                            child: Icon(Icons.school,
                                color: Colors.black87, size: 32)),
                      ),
                    ]),
                    osm.SimpleAttributionWidget(
                        source: const Text('OpenStreetMap contributors')),
                  ],
                ),

                // Map Overlay Top Bar (Stats & Legend)
                Positioned(
                  top: 16,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1E293B)),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 14,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.directions_bus_filled,
                                color: Color(0xFF34D399), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _selectedRoute == null
                                  ? '${routes.length} routes · drag to pan · scroll or pinch to zoom'
                                  : 'Focused: ${_selectedRoute!.busNumber} · ${_selectedRoute!.name}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (breakdown != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF7F1D1D,
                            ).withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.danger),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black45,
                                blurRadius: 14,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.alt_route_rounded,
                                color: Color(0xFFFDE047),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Rescue fleet: ${breakdown.rescueBusNumbers.isEmpty ? "none available" : breakdown.rescueBusNumbers.join(" + ")} (+${breakdown.detourDistanceKm.toStringAsFixed(1)} km est.)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Floating Map Controls
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _editSimulationSpeedRange(routes),
                        icon: const Icon(Icons.speed_rounded),
                        label: Text(
                          'Speed range: ${_formatSpeed(_minimumSpeedKmh)}–${_formatSpeed(_maximumSpeedKmh)} km/h',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xDD0F172A),
                          side: const BorderSide(color: Colors.white24),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: routes.isEmpty || !_roadPathsReady
                            ? null
                            : () => _toggleFleetSimulation(routes),
                        icon: Icon(_fleetSimulationRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded),
                        label: Text(!_roadPathsReady
                            ? 'Loading road routes…'
                            : _fleetSimulationRunning
                                ? 'Pause fleet simulation'
                                : _fleetSimulationStarted
                                    ? 'Resume fleet simulation'
                                    : 'Start fleet simulation'),
                        style: FilledButton.styleFrom(
                          backgroundColor: _fleetSimulationRunning
                              ? const Color(0xFFB45309)
                              : const Color(0xFF047857),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Column(
                    children: [
                      _mapFab(Icons.add, 'Zoom in', () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1,
                        );
                      }),
                      const SizedBox(height: 8),
                      _mapFab(Icons.remove, 'Zoom out', () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom - 1,
                        );
                      }),
                      const SizedBox(height: 8),
                      _mapFab(Icons.fit_screen_rounded, 'Fit all routes', () {
                        setState(() {
                          _selectedRoute = null;
                          _selectedStop = null;
                        });
                        _focusRoute(null, routes);
                      }),
                      const SizedBox(height: 10),
                      _mapFab(Icons.info_outline_rounded, 'Stops Info', () {
                        if (routes.isNotEmpty &&
                            routes.first.stops.isNotEmpty) {
                          setState(() {
                            _selectedRoute = routes.first;
                            _selectedStop = routes.first.stops[2];
                          });
                          _focusRoute(routes.first, routes);
                        }
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeBadge(String label, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );

  Widget _mapFab(IconData icon, String tooltip, VoidCallback onTap) =>
      FloatingActionButton.small(
        tooltip: tooltip,
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        onPressed: onTap,
        child: Icon(icon, size: 18),
      );

  Widget _buildBreakdownStopsTab(
    BuildContext context,
    SmartBusProvider provider,
    BreakdownRerouteEvent breakdown,
    List<LiveBusRoute> routes,
  ) {
    final brokenBusNumbers = breakdown.brokenBusNumbers.toSet();
    final remainingStops = routes
        .where((route) => brokenBusNumbers.contains(route.busNumber))
        .expand((route) => route.stops)
        .where((stop) => stop.isBreakdownStranded)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breakdown Tab Subheader
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: const Color(0xFF131D31),
          child: Row(
            children: [
              const Icon(Icons.hub_rounded, color: Color(0xFFFBBF24), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${brokenBusNumbers.join(', ')} Remaining Stops (${remainingStops.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'Per-stop bus reassignment & student invalidation',
                      style: TextStyle(color: Colors.white54, fontSize: 10),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    setState(() => _isBreakdownTabSelected = false),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white54,
                  size: 18,
                ),
                tooltip: 'Back to Route List',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),

        // Stop List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: remainingStops.length,
            itemBuilder: (context, idx) {
              final stop = remainingStops[idx];
              final isInvalidated = stop.isInvalidated;

              // Find current assignment from breakdown or stop
              final assignmentMatch = breakdown.stopAssignments.where(
                (a) => a.stopId == stop.id,
              );
              final currentAssignedBus = assignmentMatch.isNotEmpty
                  ? assignmentMatch
                      .map((assignment) => assignment.assignedBusNumber)
                      .toSet()
                      .join(', ')
                  : (stop.assignedPickupBusNumber ?? 'Unassigned');

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isInvalidated
                      ? const Color(0xFF1E293B).withValues(alpha: 0.4)
                      : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isInvalidated
                        ? Colors.white12
                        : const Color(0xFF334155),
                    width: 1.2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stop Title & Status Tag
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isInvalidated
                                  ? Colors.grey.withValues(alpha: 0.2)
                                  : AppColors.danger.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${stop.order}',
                              style: TextStyle(
                                color: isInvalidated
                                    ? Colors.white54
                                    : AppColors.danger,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stop.name,
                                  style: TextStyle(
                                    color: isInvalidated
                                        ? Colors.white54
                                        : Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    decoration: isInvalidated
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                Text(
                                  stop.landmark,
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isInvalidated)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF64748B,
                                ).withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'INVALIDATED',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'ACTIVE RESCUE',
                                style: TextStyle(
                                  color: Color(0xFF34D399),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Invalidation notice / Redirection callout
                      if (isInvalidated && stop.redirectToStopName != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF334155),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.directions_walk_rounded,
                                color: Color(0xFF38BDF8),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Redirected to: ${stop.redirectToStopName}',
                                      style: const TextStyle(
                                        color: Color(0xFF38BDF8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (stop.redirectMessage != null)
                                      Text(
                                        stop.redirectMessage!,
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Bus Reassignment Chips (Active stops only)
                      if (!isInvalidated) ...[
                        const SizedBox(height: 10),
                        Text(
                          assignmentMatch.isNotEmpty
                              ? '${assignmentMatch.fold<int>(0, (sum, item) => sum + item.studentCount)} estimated passengers • assigned across ${assignmentMatch.map((item) => item.assignedBusNumber).toSet().length} bus(es) • ${assignmentMatch.fold<double>(0, (sum, item) => sum + item.detourDistanceKm).toStringAsFixed(1)} km detour estimate'
                              : '${breakdown.unassignedStudentsByStop[stop.id] ?? 0} estimated passengers • no single active bus currently has enough spare seats',
                          style: TextStyle(
                            color: assignmentMatch.isNotEmpty
                                ? Colors.white70
                                : const Color(0xFFFBBF24),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Assigned Rescue Bus:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: routes
                              .where(
                            (r) => !brokenBusNumbers.contains(r.busNumber),
                          )
                              .map((rt) {
                            final isAssigned = assignmentMatch.any(
                                  (assignment) =>
                                      assignment.assignedBusNumber ==
                                      rt.busNumber,
                                ) ||
                                (assignmentMatch.isEmpty &&
                                    currentAssignedBus == rt.busNumber);
                            return ChoiceChip(
                              label: Text(
                                rt.busNumber,
                                style: TextStyle(
                                  color: isAssigned
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              selected: isAssigned,
                              selectedColor: rt.color,
                              backgroundColor: const Color(0xFF0F172A),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 0,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  final moved = provider.adminReassignStopToBus(
                                    stop.id,
                                    rt.busNumber,
                                  );
                                  if (!moved) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${rt.busNumber} is unavailable or lacks spare seats for this passenger group.',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Assigned "${stop.name}" to ${rt.busNumber} (${rt.busName})',
                                      ),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: 10),
                      const Divider(color: Color(0xFF334155), height: 1),
                      const SizedBox(height: 8),

                      // Bottom Action Buttons: Invalidate OR Reactivate
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isInvalidated)
                            TextButton.icon(
                              onPressed: () {
                                provider.adminReactivateStop(stop.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Stop "${stop.name}" reactivated and restored to rescue path.',
                                    ),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.replay_rounded,
                                size: 14,
                                color: Color(0xFF34D399),
                              ),
                              label: const Text(
                                'Reactivate Stop',
                                style: TextStyle(
                                  color: Color(0xFF34D399),
                                  fontSize: 11,
                                ),
                              ),
                            )
                          else
                            OutlinedButton.icon(
                              onPressed: () => _showInvalidateDialog(
                                context,
                                provider,
                                stop.id,
                                stop.name,
                                routes,
                              ),
                              icon: const Icon(
                                Icons.do_not_disturb_on_outlined,
                                size: 14,
                                color: Color(0xFFFCA5A5),
                              ),
                              label: const Text(
                                'Invalidate & Redirect',
                                style: TextStyle(
                                  color: Color(0xFFFCA5A5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF7F1D1D),
                                  width: 0.8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// UNIFIED 5-ROUTE MAP CANVAS PAINTER
// ─────────────────────────────────────────────
class _UnifiedFleetMapPainter extends CustomPainter {
  const _UnifiedFleetMapPainter({
    required this.routes,
    this.breakdown,
    this.selectedRouteId,
    this.selectedStopId,
  });

  final List<LiveBusRoute> routes;
  final BreakdownRerouteEvent? breakdown;
  final String? selectedRouteId;
  final String? selectedStopId;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 1. Draw Map Grid & Background Roads
    _drawCampusMapGrid(canvas, size);

    // 2. Draw Central Campus Hub Node
    final campusPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawCircle(Offset(cx, cy), 18, campusPaint);
    canvas.drawCircle(
      Offset(cx, cy),
      26,
      Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '🏛️ Campus Gate',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          backgroundColor: Color(0xCC0F172A),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(cx - textPainter.width / 2, cy + 32));

    // Convert GPS coordinates to canvas scale around (cx, cy)
    Offset toCanvasOffset(double lat, double lon) {
      const centerLat = 12.9450;
      const centerLon = 77.6000;
      final dx = (lon - centerLon) * 7500;
      final dy = -(lat - centerLat) * 7500;
      return Offset(cx + dx, cy + dy);
    }

    // 3. Draw All 5 Route Lines & Stop Nodes
    for (final route in routes) {
      final isDimmed = selectedRouteId != null && selectedRouteId != route.id;
      final alpha = isDimmed ? 0.3 : 1.0;
      final routeColor = route.color.withValues(alpha: alpha);

      final path = Path();
      final offsets = <Offset>[];

      for (int i = 0; i < route.stops.length; i++) {
        final stop = route.stops[i];
        final pt = toCanvasOffset(stop.latitude, stop.longitude);
        offsets.add(pt);
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }

      // Draw Main Route Line (Glow + Solid Path)
      final glowPaint = Paint()
        ..color = routeColor.withValues(alpha: 0.25 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, glowPaint);

      final linePaint = Paint()
        ..color = routeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, linePaint);

      // Draw Stop Pins (~1 km intervals)
      for (int i = 0; i < route.stops.length; i++) {
        final stop = route.stops[i];
        final pt = offsets[i];
        final isSelected = selectedStopId == stop.id;
        final isInvalidated = stop.isInvalidated;

        final isStranded = (stop.isBreakdownStranded ||
                (breakdown != null &&
                    breakdown!.brokenBusNumbers.contains(route.busNumber) &&
                    i >= 2)) &&
            !isInvalidated;

        final pinColor = isInvalidated
            ? const Color(0xFF64748B)
            : isStranded
                ? AppColors.danger
                : isSelected
                    ? const Color(0xFFFDE047)
                    : route.color;

        // Outer pulse circle for stranded stops
        if (isStranded) {
          canvas.drawCircle(
            pt,
            16,
            Paint()
              ..color = AppColors.danger.withValues(alpha: 0.35)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3,
          );
        }

        // Draw walking vector line if stop is invalidated & redirected
        if (isInvalidated && stop.redirectToStopName != null) {
          // Find the target redirect stop position
          for (final r in routes) {
            final targetMatches = r.stops.where(
              (s) => s.name == stop.redirectToStopName,
            );
            if (targetMatches.isNotEmpty) {
              final targetPt = toCanvasOffset(
                targetMatches.first.latitude,
                targetMatches.first.longitude,
              );

              // Dotted/dashed walking vector
              final walkPaint = Paint()
                ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
                ..strokeWidth = 2
                ..style = PaintingStyle.stroke;

              const dashWidth = 5.0;
              const dashSpace = 4.0;
              final distance = (targetPt - pt).distance;
              final dx = (targetPt.dx - pt.dx) / distance;
              final dy = (targetPt.dy - pt.dy) / distance;
              double currentDist = 0.0;
              while (currentDist < distance) {
                final start = Offset(
                  pt.dx + dx * currentDist,
                  pt.dy + dy * currentDist,
                );
                final endDist = math.min(currentDist + dashWidth, distance);
                final end = Offset(pt.dx + dx * endDist, pt.dy + dy * endDist);
                canvas.drawLine(start, end, walkPaint);
                currentDist += dashWidth + dashSpace;
              }

              // Walking icon badge halfway
              final midPt = Offset(
                (pt.dx + targetPt.dx) / 2,
                (pt.dy + targetPt.dy) / 2,
              );
              final walkBadge = TextPainter(
                text: const TextSpan(
                  text: '🚶 Walk to Pickup',
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    backgroundColor: Color(0xDD0F172A),
                  ),
                ),
                textDirection: TextDirection.ltr,
              )..layout();
              walkBadge.paint(
                canvas,
                Offset(midPt.dx - walkBadge.width / 2, midPt.dy - 12),
              );
              break;
            }
          }
        }

        // Stop circle
        canvas.drawCircle(pt, isSelected ? 9 : 6, Paint()..color = pinColor);
        canvas.drawCircle(
          pt,
          isSelected ? 9 : 6,
          Paint()
            ..color = isInvalidated ? const Color(0xFF94A3B8) : Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );

        // Cross or inner mark for invalidated stop
        if (isInvalidated) {
          canvas.drawLine(
            Offset(pt.dx - 4, pt.dy - 4),
            Offset(pt.dx + 4, pt.dy + 4),
            Paint()
              ..color = Colors.white70
              ..strokeWidth = 1.5,
          );
          canvas.drawLine(
            Offset(pt.dx - 4, pt.dy + 4),
            Offset(pt.dx + 4, pt.dy - 4),
            Paint()
              ..color = Colors.white70
              ..strokeWidth = 1.5,
          );
        }

        // Stop Label (every stop or selected)
        final labelPainter = TextPainter(
          text: TextSpan(
            text: isInvalidated
                ? '✕ ${stop.name} (Walk to ${stop.redirectToStopName ?? "Nearby"})'
                : '${stop.name} (${stop.order})',
            style: TextStyle(
              color: isInvalidated
                  ? const Color(0xFF94A3B8)
                  : isStranded
                      ? const Color(0xFFFCA5A5)
                      : Colors.white70,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              decoration: isInvalidated ? TextDecoration.lineThrough : null,
              backgroundColor: const Color(0xCC0F172A),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        labelPainter.paint(canvas, Offset(pt.dx + 10, pt.dy - 6));
      }

      // Draw Bus Marker along the route
      if (offsets.length >= 3) {
        final busIndex = route.isBrokenDown ? 2 : 1;
        final busPt = offsets[busIndex];

        if (route.isBrokenDown) {
          // Broken Bus Warning Marker
          canvas.drawCircle(busPt, 18, Paint()..color = AppColors.danger);
          canvas.drawCircle(
            busPt,
            26,
            Paint()
              ..color = AppColors.danger.withValues(alpha: 0.4)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4,
          );
          final brokenBusLabel = TextPainter(
            text: TextSpan(
              text: '⚠️ ${route.busNumber} BROKEN DOWN',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                backgroundColor: AppColors.danger,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          brokenBusLabel.paint(
            canvas,
            Offset(busPt.dx - brokenBusLabel.width / 2, busPt.dy - 32),
          );
        } else {
          // Active Moving Bus Marker
          canvas.drawCircle(busPt, 14, Paint()..color = route.color);
          canvas.drawCircle(
            busPt,
            14,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );

          final busLabel = TextPainter(
            text: TextSpan(
              text: '🚍 ${route.busNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                backgroundColor: Color(0xDD0F172A),
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          busLabel.paint(
            canvas,
            Offset(busPt.dx - busLabel.width / 2, busPt.dy - 22),
          );
        }
      }
    }

    // 4. Draw Automated Breakdown Detour Reroute Path (Glowing Amber/Cyan)
    if (breakdown != null) {
      _drawOptimizedDetourPath(canvas, toCanvasOffset);
    }
  }

  void _drawCampusMapGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.4)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawOptimizedDetourPath(
    Canvas canvas,
    Offset Function(double, double) toOffset,
  ) {
    // Dynamically scan routes for any diverted stops assigned during breakdown
    for (final route in routes) {
      final divertedStops =
          route.stops.where((s) => s.isDivertedPickup).toList();
      if (divertedStops.isEmpty) continue;

      final firstDivertedIndex = route.stops.indexWhere(
        (s) => s.isDivertedPickup,
      );
      final lastDivertedIndex = route.stops.lastIndexWhere(
        (s) => s.isDivertedPickup,
      );

      final prevStop = firstDivertedIndex > 0
          ? route.stops[firstDivertedIndex - 1]
          : route.stops.first;
      final nextStop = lastDivertedIndex < route.stops.length - 1
          ? route.stops[lastDivertedIndex + 1]
          : route.stops.last;

      final startPt = toOffset(prevStop.latitude, prevStop.longitude);
      final endPt = toOffset(nextStop.latitude, nextStop.longitude);

      final detourPath = Path()..moveTo(startPt.dx, startPt.dy);

      for (final ds in divertedStops) {
        final pt = toOffset(ds.latitude, ds.longitude);
        detourPath.lineTo(pt.dx, pt.dy);
      }
      detourPath.lineTo(endPt.dx, endPt.dy);

      // Glowing Detour Path (Gold/Amber)
      final detourGlow = Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(detourPath, detourGlow);

      final detourLine = Paint()
        ..color = const Color(0xFFFBBF24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(detourPath, detourLine);

      // Draw U-Turn callout at the first diverted stop if U-turn is required
      final firstDiverted = divertedStops.first;
      if (firstDiverted.isUturnDetour) {
        final uTurnPt = toOffset(
          firstDiverted.latitude,
          firstDiverted.longitude,
        );
        final uTurnBadge = TextPainter(
          text: TextSpan(
            text:
                '↩️ U-TURN & DIVERT: ${route.busNumber} to ${firstDiverted.name}',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              backgroundColor: Color(0xFFFDE047),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        uTurnBadge.paint(
          canvas,
          Offset(uTurnPt.dx - uTurnBadge.width / 2, uTurnPt.dy - 34),
        );
      }

      // Draw badges on each diverted stop
      for (final ds in divertedStops) {
        final pt = toOffset(ds.latitude, ds.longitude);
        // Outer pulsing amber ring
        canvas.drawCircle(
          pt,
          20,
          Paint()
            ..color = const Color(0xFFF59E0B).withValues(alpha: 0.45)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5,
        );

        final stopBadge = TextPainter(
          text: TextSpan(
            text: '🚍 Visited by ${route.busNumber}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              backgroundColor: Color(0xFFB45309),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        stopBadge.paint(canvas, Offset(pt.dx + 12, pt.dy + 8));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _UnifiedFleetMapPainter oldDelegate) => true;
}
