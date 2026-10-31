import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as geo;
import 'package:provider/provider.dart';
import '../../models/app_models.dart';
import '../../providers/smart_bus_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_widgets.dart';
import '../../widgets/common_widgets.dart';
import '../../services/route_path_api_service.dart';

class InchargeRouteDetail extends StatefulWidget {
  const InchargeRouteDetail({
    super.key,
    required this.routeName,
    required this.distanceKm,
    required this.durationMinutes,
    required this.stops,
    required this.isPreview,
    this.routeRecord,
  });

  final String routeName;
  final double distanceKm;
  final int durationMinutes;
  final List<Map<String, dynamic>> stops;
  final bool isPreview;
  final RouteRecord? routeRecord;

  @override
  State<InchargeRouteDetail> createState() => _InchargeRouteDetailState();
}

class _InchargeRouteDetailState extends State<InchargeRouteDetail> {
  late List<RecordedBoardingStop> _workingStops;
  late List<RecordedBoardingStop> _savedStops;
  late double _distanceKm;
  late int _durationMinutes;
  bool _isEditingPath = false;
  bool _hasLocalEdits = false;

  List<RecordedBoardingStop> _initialStops() =>
      widget.routeRecord?.stops ??
      widget.stops
          .map<RecordedBoardingStop>((stop) => RecordedBoardingStop(
                id: 'preview-${stop['name'] ?? 'stop'}',
                name: stop['name']?.toString() ?? '',
                landmark: stop['landmark']?.toString() ?? '',
                type: stop['type']?.toString() ?? 'Pickup',
                estimatedWaitMinutes: 3,
              ))
          .toList();

  @override
  void initState() {
    super.initState();
    _workingStops = _initialStops();
    _savedStops = List.of(_workingStops);
    _distanceKm = widget.distanceKm;
    _durationMinutes = widget.durationMinutes;
  }

  @override
  void didUpdateWidget(covariant InchargeRouteDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routeRecord?.id != widget.routeRecord?.id) {
      _workingStops = _initialStops();
      _savedStops = List.of(_workingStops);
      _distanceKm = widget.distanceKm;
      _durationMinutes = widget.durationMinutes;
      _isEditingPath = false;
      _hasLocalEdits = false;
    }
  }

  bool get _canEditPath =>
      widget.routeRecord != null &&
      (_isEditingPath || _workingStops.where(_hasValidCoordinates).length >= 2);

  void _updateStop(
    String stopId, {
    String? name,
    String? landmark,
    double? latitude,
    double? longitude,
  }) {
    final index = _workingStops.indexWhere((stop) => stop.id == stopId);
    if (index == -1) return;
    final current = _workingStops[index];
    setState(() {
      _workingStops[index] = RecordedBoardingStop(
        id: current.id,
        name: name ?? current.name,
        landmark: landmark ?? current.landmark,
        type: current.type,
        estimatedWaitMinutes: current.estimatedWaitMinutes,
        latitude: latitude ?? current.latitude,
        longitude: longitude ?? current.longitude,
      );
      _hasLocalEdits = true;
    });
  }

  void _moveStop(int index, int direction) {
    final nextIndex = index + direction;
    if (nextIndex < 0 || nextIndex >= _workingStops.length) return;
    setState(() {
      final stop = _workingStops.removeAt(index);
      _workingStops.insert(nextIndex, stop);
      _hasLocalEdits = true;
    });
  }

  void _removeStop(String stopId) {
    setState(() {
      _workingStops.removeWhere((stop) => stop.id == stopId);
      _hasLocalEdits = true;
    });
  }

  Future<void> _addStop({geo.LatLng? mapPoint}) async {
    final nameController = TextEditingController();
    final landmarkController = TextEditingController();
    final latitudeController = TextEditingController(
      text: mapPoint?.latitude.toStringAsFixed(6) ?? '',
    );
    final longitudeController = TextEditingController(
      text: mapPoint?.longitude.toStringAsFixed(6) ?? '',
    );

    final newStop = await showDialog<RecordedBoardingStop>(
      context: context,
      builder: (dialogContext) {
        String? validationError;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: const Text('Add route stop'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Stop name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: landmarkController,
                    decoration: const InputDecoration(labelText: 'Landmark'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: latitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: longitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (validationError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      validationError!,
                      style: TextStyle(
                        color: Theme.of(dialogContext).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final latitude =
                      double.tryParse(latitudeController.text.trim());
                  final longitude =
                      double.tryParse(longitudeController.text.trim());
                  if (nameController.text.trim().isEmpty ||
                      latitude == null ||
                      longitude == null ||
                      !latitude.isFinite ||
                      !longitude.isFinite ||
                      latitude < -90 ||
                      latitude > 90 ||
                      longitude < -180 ||
                      longitude > 180) {
                    setDialogState(() {
                      validationError =
                          'Enter a stop name and valid latitude/longitude.';
                    });
                    return;
                  }
                  Navigator.pop(
                    dialogContext,
                    RecordedBoardingStop(
                      id: 'EDIT-${DateTime.now().microsecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      landmark: landmarkController.text.trim().isEmpty
                          ? nameController.text.trim()
                          : landmarkController.text.trim(),
                      type: 'Pickup',
                      estimatedWaitMinutes: 3,
                      latitude: latitude,
                      longitude: longitude,
                    ),
                  );
                },
                child: const Text('Add stop'),
              ),
            ],
          ),
        );
      },
    );

    nameController.dispose();
    landmarkController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    if (!mounted || newStop == null) return;
    setState(() {
      final campusIndex = _workingStops.indexWhere(
        (stop) => stop.name.toLowerCase().contains('campus'),
      );
      _workingStops.insert(
        campusIndex < 0 ? _workingStops.length : campusIndex,
        newStop,
      );
      _hasLocalEdits = true;
    });
  }

  Future<void> _savePath() async {
    if (_workingStops.length < 2 ||
        _workingStops.any((stop) =>
            !_hasValidCoordinates(stop) || stop.name.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Every stop needs a name and valid coordinates.'),
        ),
      );
      return;
    }
    final provider = context.read<SmartBusProvider>();
    final saved = provider.adminUpdateRoutePath(
      widget.routeRecord!.busNumber,
      _workingStops,
    );
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save this path. Resolve any active breakdown first.',
          ),
        ),
      );
      return;
    }
    final updatedRoute = provider.liveRoutes.firstWhere(
      (route) => route.busNumber == widget.routeRecord!.busNumber,
    );
    setState(() {
      _savedStops = List.of(_workingStops);
      _distanceKm = updatedRoute.totalDistanceKm;
      _durationMinutes = updatedRoute.totalDurationMinutes;
      _isEditingPath = false;
      _hasLocalEdits = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Route path saved for this session.')),
    );
  }

  void _cancelPathEdit() {
    setState(() {
      _workingStops = List.of(_savedStops);
      _isEditingPath = false;
    });
  }

  Widget _buildStopEditor(int index) {
    final stop = _workingStops[index];
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
    return Container(
      key: ValueKey('editor-${stop.id}'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text('${index + 1}',
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(stop.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              IconButton(
                tooltip: 'Move stop up',
                onPressed: index > 0 ? () => _moveStop(index, -1) : null,
                icon: const Icon(Icons.keyboard_arrow_up_rounded),
              ),
              IconButton(
                tooltip: 'Move stop down',
                onPressed: index < _workingStops.length - 1
                    ? () => _moveStop(index, 1)
                    : null,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
              IconButton(
                tooltip: 'Remove stop',
                onPressed: () => _removeStop(stop.id),
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.danger),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: ValueKey('name-${stop.id}'),
            initialValue: stop.name,
            decoration: inputDecoration.copyWith(labelText: 'Stop name'),
            onChanged: (value) => _updateStop(stop.id, name: value),
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: ValueKey('landmark-${stop.id}'),
            initialValue: stop.landmark,
            decoration: inputDecoration.copyWith(labelText: 'Landmark'),
            onChanged: (value) => _updateStop(stop.id, landmark: value),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey('latitude-${stop.id}'),
                  initialValue: stop.latitude.toStringAsFixed(6),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: inputDecoration.copyWith(labelText: 'Latitude'),
                  onChanged: (value) {
                    final latitude = double.tryParse(value.trim());
                    if (latitude != null && latitude >= -90 && latitude <= 90) {
                      _updateStop(stop.id, latitude: latitude);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  key: ValueKey('longitude-${stop.id}'),
                  initialValue: stop.longitude.toStringAsFixed(6),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: inputDecoration.copyWith(labelText: 'Longitude'),
                  onChanged: (value) {
                    final longitude = double.tryParse(value.trim());
                    if (longitude != null &&
                        longitude >= -180 &&
                        longitude <= 180) {
                      _updateStop(stop.id, longitude: longitude);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeRecord = widget.routeRecord;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            title: Text(widget.routeName,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            flexibleSpace: FlexibleSpaceBar(
              background: routeRecord != null && _canEditPath
                  ? _RouteRecordMapPreview(
                      key: ValueKey('${routeRecord.id}-$_hasLocalEdits'),
                      route: routeRecord,
                      stops: _workingStops,
                      isEditingPath: _isEditingPath,
                      useRoadPath: !_isEditingPath && !_hasLocalEdits,
                      onMapTap: _isEditingPath
                          ? (point) => _addStop(mapPoint: point)
                          : null,
                    )
                  : const MapPlaceholder(height: 260),
            ),
            actions: [
              if (!widget.isPreview)
                IconButton(
                    icon: const Icon(Icons.share_rounded), onPressed: () {}),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x0A0F172A),
                            blurRadius: 16,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(
                            'Total Distance',
                            '${_distanceKm.toStringAsFixed(1)} km',
                            Icons.straighten_rounded,
                            AppColors.primary),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        _SummaryRow('Estimated Time', '$_durationMinutes min',
                            Icons.timer_rounded, AppColors.success),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        _SummaryRow(
                            'Total Stops',
                            '${_workingStops.length} stops',
                            Icons.location_on_rounded,
                            AppColors.warning),
                        if (routeRecord != null) ...[
                          const Divider(height: 24, color: Color(0xFFF1F5F9)),
                          _SummaryRow('Status', routeRecord.status,
                              Icons.info_outline_rounded, AppColors.muted),
                        ],
                      ],
                    ),
                  ),
                  if (_canEditPath) ...[
                    const SizedBox(height: 16),
                    if (!_isEditingPath)
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _isEditingPath = true),
                        icon: const Icon(Icons.edit_road_rounded),
                        label: const Text('Edit Path'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      )
                    else ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _addStop(),
                              icon: const Icon(Icons.add_location_alt_rounded),
                              label: const Text('Add Stop'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _savePath,
                              icon: const Icon(Icons.save_rounded),
                              label: const Text('Save Path'),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Cancel editing',
                            onPressed: _cancelPathEdit,
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Edit coordinates below, tap the map to add a stop, or use the arrows to change stop order.',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                  AdminSectionHeader(
                    title:
                        _isEditingPath ? 'Edit Route Stops' : 'Boarding Stops',
                  ),
                  const SizedBox(height: 14),
                  if (_workingStops.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('No boarding stops added.',
                            style: TextStyle(color: AppColors.muted)),
                      ),
                    )
                  else if (_isEditingPath)
                    ...List.generate(
                      _workingStops.length,
                      _buildStopEditor,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x0A0F172A),
                              blurRadius: 16,
                              offset: Offset(0, 4))
                        ],
                      ),
                      child: StopTimelineWidget(stops: _workingStops),
                    ),
                  const SizedBox(height: 24),
                  if (widget.isPreview) ...[
                    FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Route submitted for approval ✓'),
                              behavior: SnackBarBehavior.floating),
                        );
                        Navigator.popUntil(context,
                            (r) => r.isFirst || r.settings.name == '/incharge');
                      },
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Submit Route',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Discard Route',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: BorderSide(
                            color: AppColors.danger.withValues(alpha: .3)),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

bool _hasValidCoordinates(RecordedBoardingStop stop) =>
    stop.latitude >= -90 &&
    stop.latitude <= 90 &&
    stop.longitude >= -180 &&
    stop.longitude <= 180 &&
    (stop.latitude != 0 || stop.longitude != 0);

class _RouteRecordMapPreview extends StatefulWidget {
  const _RouteRecordMapPreview({
    super.key,
    required this.route,
    required this.stops,
    required this.isEditingPath,
    required this.useRoadPath,
    this.onMapTap,
  });

  final RouteRecord route;
  final List<RecordedBoardingStop> stops;
  final bool isEditingPath;
  final bool useRoadPath;
  final ValueChanged<geo.LatLng>? onMapTap;

  @override
  State<_RouteRecordMapPreview> createState() => _RouteRecordMapPreviewState();
}

class _RouteRecordMapPreviewState extends State<_RouteRecordMapPreview> {
  List<geo.LatLng> _roadPath = const [];
  final fm.MapController _mapController = fm.MapController();

  List<RecordedBoardingStop> get _stops =>
      widget.stops.where(_hasValidCoordinates).toList(growable: false);

  List<geo.LatLng> get _path => widget.useRoadPath && _roadPath.length > 1
      ? _roadPath
      : _stops
          .map((stop) => geo.LatLng(stop.latitude, stop.longitude))
          .toList(growable: false);

  @override
  void initState() {
    super.initState();
    if (widget.useRoadPath) _loadRoadPath();
  }

  @override
  void didUpdateWidget(covariant _RouteRecordMapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.useRoadPath &&
        (!oldWidget.useRoadPath ||
            oldWidget.route.busNumber != widget.route.busNumber)) {
      _roadPath = const [];
      _loadRoadPath();
    }
  }

  Future<void> _loadRoadPath() async {
    final paths = await RoutePathApiService.fetchRoadPaths(
      busNumber: widget.route.busNumber,
    );
    final path = paths[widget.route.busNumber];
    if (mounted && path != null && path.length > 1) {
      setState(() => _roadPath = path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = _path;
    if (points.length < 2) {
      return const MapPlaceholder(height: 260);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        fm.FlutterMap(
          key: ValueKey('${widget.route.id}-${_roadPath.length}'),
          options: fm.MapOptions(
            initialCenter: points.first,
            initialZoom: 12,
            initialCameraFit: fm.CameraFit.bounds(
              bounds: fm.LatLngBounds.fromPoints(points),
              padding: const EdgeInsets.all(48),
            ),
            interactionOptions: const fm.InteractionOptions(
              flags: fm.InteractiveFlag.all & ~fm.InteractiveFlag.rotate,
            ),
            onTap: widget.isEditingPath
                ? (_, point) => widget.onMapTap?.call(point)
                : null,
          ),
          mapController: _mapController,
          children: [
            fm.TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.smartbus',
            ),
            fm.PolylineLayer(
              polylines: [
                fm.Polyline(
                  points: points,
                  color: AppColors.primary,
                  strokeWidth: 5,
                ),
              ],
            ),
            fm.MarkerLayer(
              markers: [
                for (var index = 0; index < _stops.length; index++)
                  fm.Marker(
                    point: geo.LatLng(
                      _stops[index].latitude,
                      _stops[index].longitude,
                    ),
                    width: 30,
                    height: 36,
                    child: Tooltip(
                      message: _stops[index].name,
                      child: Icon(
                        Icons.location_on,
                        color: index == _stops.length - 1
                            ? AppColors.success
                            : AppColors.primary,
                        size: 30,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          right: 14,
          bottom: 56,
          child: Material(
            color: Colors.white.withValues(alpha: 0.96),
            elevation: 3,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Zoom in',
                  onPressed: () => _zoomBy(1),
                  icon: const Icon(Icons.add_rounded),
                ),
                const Divider(height: 1),
                IconButton(
                  tooltip: 'Zoom out',
                  onPressed: () => _zoomBy(-1),
                  icon: const Icon(Icons.remove_rounded),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                '${widget.route.busNumber} · ${_stops.length} stops',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _zoomBy(double amount) {
    try {
      final camera = _mapController.camera;
      final zoom = (camera.zoom + amount).clamp(3.0, 18.0);
      _mapController.move(camera.center, zoom);
    } catch (_) {
      // The map controller attaches after the first frame.
    }
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, this.icon, this.color);
  final String label, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 14)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        ],
      );
}
