import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:latlong2/latlong.dart' as geo;

import '../models/app_models.dart';
import '../mock/hyderabad_route_data.dart';
import '../services/route_path_api_service.dart';
import '../theme/app_theme.dart';

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D0F172A),
              blurRadius: 18,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: child,
      );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});
  final String title;
  final String? action;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (action != null)
            Text(
              action!,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      );
}

class LiveStatusChip extends StatelessWidget {
  const LiveStatusChip({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final color = label == 'Delayed' ? AppColors.warning : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 8),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class ModernButton extends StatelessWidget {
  const ModernButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.secondary = false,
  });
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool secondary;
  @override
  Widget build(BuildContext context) => FilledButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor:
              secondary ? const Color(0xFFEFF6FF) : AppColors.primary,
          foregroundColor: secondary ? AppColors.primary : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
}

class AdvertisementCard extends StatelessWidget {
  const AdvertisementCard({super.key, required this.ad});
  final Advertisement ad;
  @override
  Widget build(BuildContext context) => Container(
        width: 330,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ad.color, ad.color.withValues(alpha: .75)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ad.tag,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ad.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(ad.subtitle, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      );
}

class BusCard extends StatelessWidget {
  const BusCard({super.key, required this.bus});
  final Bus bus;
  @override
  Widget build(BuildContext context) => SurfaceCard(
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.directions_bus_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bus.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${bus.number} · ${bus.distance}',
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 7),
                  LiveStatusChip(label: bus.status),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  bus.eta,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const Text(
                  'ETA',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      );
}

class BottomSheetCard extends StatelessWidget {
  const BottomSheetCard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      SurfaceCard(color: const Color(0xFFF8FAFC), child: child);
}

class BoardingStopCard extends StatelessWidget {
  const BoardingStopCard({super.key, required this.stop});
  final BusStop stop;
  @override
  Widget build(BuildContext context) => SurfaceCard(
        child: Row(
          children: [
            Icon(
              stop.isNext ? Icons.location_on_rounded : Icons.circle_outlined,
              color: stop.isNext ? AppColors.primary : AppColors.muted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stop.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    stop.distance,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              stop.time,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ],
        ),
      );
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.notification});
  final AppNotification notification;
  @override
  Widget build(BuildContext context) => SurfaceCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(notification.icon, color: AppColors.primary),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (notification.unread)
                        const Icon(Icons.circle,
                            color: AppColors.primary, size: 8),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.time,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class MapPlaceholder extends StatefulWidget {
  const MapPlaceholder({
    super.key,
    this.height = 280,
    this.busNumber,
    this.assignedStops,
  });
  final double height;
  final String? busNumber;
  final List<LiveRouteStop>? assignedStops;

  @override
  State<MapPlaceholder> createState() => _MapPlaceholderState();
}

class _MapPlaceholderState extends State<MapPlaceholder> {
  final osm.MapController _mapController = osm.MapController();
  final DateTime _simulationStartedAt = DateTime.now();
  Map<String, List<geo.LatLng>> _roadPaths = const {};
  Timer? _busTicker;

  @override
  void initState() {
    super.initState();
    _loadRoadPaths();
    _busTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant MapPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.busNumber != widget.busNumber ||
        oldWidget.assignedStops != widget.assignedStops) {
      _loadRoadPaths();
    }
  }

  Future<void> _loadRoadPaths() async {
    final paths = await RoutePathApiService.fetchRoadPaths(
      busNumber: widget.busNumber,
    );
    if (mounted && paths.isNotEmpty) setState(() => _roadPaths = paths);
  }

  @override
  void dispose() {
    _busTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routes = HyderabadRouteData.liveRoutes
        .where((route) =>
            widget.busNumber == null || route.busNumber == widget.busNumber)
        .toList();
    final routeLines = <osm.Polyline>[];
    final routeMarkers = <osm.Marker>[];
    final allStops = <LiveRouteStop>[];

    if (widget.assignedStops != null) {
      allStops.addAll(widget.assignedStops!);
      final localRoute = routes.isEmpty ? null : routes.first;
      if (allStops.isNotEmpty) {
        final color = localRoute?.color ?? AppColors.primary;
        final points = _roadPaths[widget.busNumber] ??
            allStops
                .map((stop) => geo.LatLng(stop.latitude, stop.longitude))
                .toList();
        routeLines
            .add(osm.Polyline(points: points, color: color, strokeWidth: 4));
        for (final stop in allStops) {
          final markerPoint = _nearestRoutePoint(
            geo.LatLng(stop.latitude, stop.longitude),
            points,
          );
          routeMarkers.add(_stopMarker(
            stop,
            color,
            '${widget.busNumber ?? 'Assigned bus'} · stop ${stop.order}',
            markerPoint: markerPoint,
          ));
        }
        if (points.length > 1) {
          routeMarkers.add(_busMarker(
            _positionOnRoute(points),
            color,
            widget.busNumber ?? 'Assigned bus',
          ));
        }
      }
    } else {
      var routeIndex = 0;
      for (final route in routes) {
        allStops.addAll(route.stops);
        final points = _roadPaths[route.busNumber] ??
            route.stops
                .map((stop) => geo.LatLng(stop.latitude, stop.longitude))
                .toList();
        routeLines.add(
          osm.Polyline(points: points, color: route.color, strokeWidth: 4),
        );
        for (final stop in route.stops) {
          final markerPoint = _nearestRoutePoint(
            geo.LatLng(stop.latitude, stop.longitude),
            points,
          );
          routeMarkers.add(_stopMarker(
            stop,
            route.color,
            '${route.routeNumber} · ${route.busNumber}',
            markerPoint: markerPoint,
          ));
        }
        if (points.length > 1) {
          routeMarkers.add(_busMarker(
            _positionOnRoute(points, phaseOffset: routeIndex * 0.11),
            route.color,
            route.busNumber,
          ));
        }
        routeIndex++;
      }
    }

    if (allStops.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
            child: Text('No route is currently assigned to this account.')),
      );
    }
    final center = geo.LatLng(
      allStops.map((stop) => stop.latitude).reduce((a, b) => a + b) /
          allStops.length,
      allStops.map((stop) => stop.longitude).reduce((a, b) => a + b) /
          allStops.length,
    );
    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            osm.FlutterMap(
              mapController: _mapController,
              options: osm.MapOptions(
                initialCenter: center,
                initialZoom: widget.assignedStops == null ? 9.5 : 11.5,
                initialCameraFit: osm.CameraFit.bounds(
                  bounds: osm.LatLngBounds.fromPoints(
                    allStops
                        .map(
                            (stop) => geo.LatLng(stop.latitude, stop.longitude))
                        .toList(),
                  ),
                  padding: const EdgeInsets.all(32),
                ),
              ),
              children: [
                osm.TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.smartbus',
                ),
                osm.PolylineLayer(polylines: routeLines),
                osm.MarkerLayer(markers: routeMarkers),
                osm.SimpleAttributionWidget(
                  source: const Text('OpenStreetMap contributors'),
                ),
              ],
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'map-zoom-in-${_mapController.hashCode}',
                    tooltip: 'Zoom in',
                    onPressed: () => _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    ),
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'map-zoom-out-${_mapController.hashCode}',
                    tooltip: 'Zoom out',
                    onPressed: () => _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    ),
                    child: const Icon(Icons.remove),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  osm.Marker _stopMarker(
    LiveRouteStop stop,
    Color color,
    String routeLabel, {
    geo.LatLng? markerPoint,
  }) =>
      osm.Marker(
        point: markerPoint ?? geo.LatLng(stop.latitude, stop.longitude),
        width: 28,
        height: 34,
        child: Tooltip(
          message: '${stop.name}\n$routeLabel',
          child: Icon(Icons.location_on, color: color, size: 28),
        ),
      );

  osm.Marker _busMarker(geo.LatLng point, Color color, String busNumber) =>
      osm.Marker(
        point: point,
        width: 48,
        height: 48,
        child: Tooltip(
          message: '$busNumber · simulated bus position',
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 8),
              ],
            ),
            child:
                const Icon(Icons.directions_bus, color: Colors.white, size: 24),
          ),
        ),
      );

  geo.LatLng _positionOnRoute(
    List<geo.LatLng> points, {
    double phaseOffset = 0,
  }) {
    final elapsed =
        DateTime.now().difference(_simulationStartedAt).inMilliseconds / 90000;
    final progress = (elapsed + phaseOffset) % 1;
    final position = progress * (points.length - 1);
    final index = position.floor();
    final fraction = position - index;
    final start = points[index];
    final end = points[(index + 1).clamp(0, points.length - 1)];
    return geo.LatLng(
      start.latitude + (end.latitude - start.latitude) * fraction,
      start.longitude + (end.longitude - start.longitude) * fraction,
    );
  }

  geo.LatLng _nearestRoutePoint(geo.LatLng stop, List<geo.LatLng> path) {
    if (path.isEmpty) return stop;
    return path.reduce((nearest, candidate) {
      final currentDistance = math.pow(nearest.latitude - stop.latitude, 2) +
          math.pow(nearest.longitude - stop.longitude, 2);
      final candidateDistance =
          math.pow(candidate.latitude - stop.latitude, 2) +
              math.pow(candidate.longitude - stop.longitude, 2);
      return candidateDistance < currentDistance ? candidate : nearest;
    });
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = const Color(0xFFCBDCD3)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(-20, s.height * .72)
      ..cubicTo(
        s.width * .2,
        s.height * .22,
        s.width * .5,
        s.height * 1.1,
        s.width + 20,
        s.height * .25,
      );
    c.drawPath(path, p);
    final p2 = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    c.drawPath(path, p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
