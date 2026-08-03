import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_widgets.dart';
import '../../widgets/common_widgets.dart';
import 'incharge_route_detail.dart';

enum _RecordingState { idle, recording, paused, stopped }

class InchargeRecordRoute extends StatefulWidget {
  const InchargeRecordRoute({super.key});
  @override
  State<InchargeRecordRoute> createState() => _InchargeRecordRouteState();
}

class _InchargeRecordRouteState extends State<InchargeRecordRoute> with TickerProviderStateMixin {
  _RecordingState _state = _RecordingState.idle;
  int _recordedPoints = 0;
  double _distance = 0.0;
  int _seconds = 0;
  double _speed = 0.0;
  final List<Map<String, String>> _addedStops = [];

  late final AnimationController _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  String get _timeString {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '00:$m:$s';
  }

  void _startRecording() {
    setState(() {
      _state = _RecordingState.recording;
      _recordedPoints = 12;
      _distance = 1.2;
      _seconds = 185;
      _speed = 24.5;
    });
  }

  void _pauseRecording() => setState(() => _state = _RecordingState.paused);
  void _resumeRecording() => setState(() => _state = _RecordingState.recording);

  void _stopRecording() {
    setState(() {
      _state = _RecordingState.stopped;
      _recordedPoints = 47;
      _distance = 8.6;
      _seconds = 1242;
    });
    // Navigate to preview
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => InchargeRouteDetail(
        routeName: 'New Route · SB-04',
        distanceKm: _distance,
        durationMinutes: _seconds ~/ 60,
        stops: _addedStops,
        isPreview: true,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(.95),
        title: Row(
          children: [
            const Text('SB-04', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(width: 10),
            if (_state == _RecordingState.recording)
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(.1 + _pulseCtrl.value * .1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: AppColors.danger, size: 8),
                      const SizedBox(width: 5),
                      const Text('Recording', style: TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              )
            else if (_state == _RecordingState.paused)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.warning.withOpacity(.1), borderRadius: BorderRadius.circular(99)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pause_circle_filled_rounded, color: AppColors.warning, size: 14),
                    SizedBox(width: 5),
                    Text('Paused', style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.muted.withOpacity(.1), borderRadius: BorderRadius.circular(99)),
                child: const Text('Ready', style: TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Full screen map
          const Positioned.fill(child: MapPlaceholder(height: 9999)),

          // Floating action buttons (right side)
          Positioned(
            right: 16,
            top: 120,
            child: Column(
              children: [
                if (_state == _RecordingState.idle)
                  _MapFab(
                    icon: Icons.play_arrow_rounded,
                    color: AppColors.success,
                    label: 'Start',
                    onTap: _startRecording,
                  ),
                if (_state == _RecordingState.recording) ...[
                  _MapFab(
                    icon: Icons.pause_rounded,
                    color: AppColors.warning,
                    label: 'Pause',
                    onTap: _pauseRecording,
                  ),
                  const SizedBox(height: 12),
                  _MapFab(
                    icon: Icons.stop_rounded,
                    color: AppColors.danger,
                    label: 'Stop',
                    onTap: _stopRecording,
                  ),
                  const SizedBox(height: 12),
                  _MapFab(
                    icon: Icons.add_location_alt_rounded,
                    color: AppColors.primary,
                    label: 'Add Stop',
                    onTap: () => _showAddStopSheet(context),
                  ),
                ],
                if (_state == _RecordingState.paused) ...[
                  _MapFab(
                    icon: Icons.play_arrow_rounded,
                    color: AppColors.success,
                    label: 'Resume',
                    onTap: _resumeRecording,
                  ),
                  const SizedBox(height: 12),
                  _MapFab(
                    icon: Icons.stop_rounded,
                    color: AppColors.danger,
                    label: 'Stop',
                    onTap: _stopRecording,
                  ),
                ],
              ],
            ),
          ),

          // Bottom sheet
          DraggableScrollableSheet(
            initialChildSize: .28,
            minChildSize: .22,
            maxChildSize: .55,
            builder: (_, controller) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 20, offset: Offset(0, -4))],
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(99)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: MetricChip(label: 'DISTANCE', value: '${_distance.toStringAsFixed(1)} km', icon: Icons.straighten_rounded)),
                      const SizedBox(width: 8),
                      Expanded(child: MetricChip(label: 'TIME', value: _timeString, icon: Icons.timer_rounded)),
                      const SizedBox(width: 8),
                      Expanded(child: MetricChip(label: 'GPS', value: _state == _RecordingState.idle ? '—' : 'Good', icon: Icons.gps_fixed_rounded)),
                      const SizedBox(width: 8),
                      Expanded(child: MetricChip(label: 'POINTS', value: '$_recordedPoints', icon: Icons.location_on_rounded)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  MetricChip(
                    label: 'SPEED',
                    value: _state == _RecordingState.recording ? '${_speed.toStringAsFixed(1)} km/h' : '0.0 km/h',
                    icon: Icons.speed_rounded,
                  ),
                  const SizedBox(height: 16),
                  if (_addedStops.isNotEmpty) ...[
                    Text('Added Stops (${_addedStops.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 8),
                    ..._addedStops.map((s) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                          title: Text(s['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          subtitle: Text(s['type'] ?? '', style: const TextStyle(fontSize: 11)),
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStopSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final landmarkCtrl = TextEditingController();
    String selectedType = 'Pickup';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AnimatedPadding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.add_location_alt_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    const Text('Add Boarding Stop', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 20),
                _SheetField(controller: nameCtrl, label: 'Stop Name', icon: Icons.location_on_rounded),
                const SizedBox(height: 12),
                _SheetField(controller: landmarkCtrl, label: 'Landmark / Nearby Area', icon: Icons.place_rounded),
                const SizedBox(height: 16),
                const Text('Stop Type', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Pickup', 'Drop', 'Pickup & Drop'].map((t) => ChoiceChip(
                    label: Text(t),
                    selected: selectedType == t,
                    onSelected: (_) => setS(() => selectedType = t),
                    selectedColor: AppColors.primary.withOpacity(.15),
                    labelStyle: TextStyle(
                      color: selectedType == t ? AppColors.primary : AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (nameCtrl.text.isNotEmpty) {
                            setState(() => _addedStops.add({'name': nameCtrl.text, 'landmark': landmarkCtrl.text, 'type': selectedType}));
                          }
                          Navigator.pop(context);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Save Stop', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapFab extends StatelessWidget {
  const _MapFab({required this.icon, required this.color, required this.label, required this.onTap});
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color.withOpacity(.4), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 6)]),
            child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      );
}

class _SheetField extends StatelessWidget {
  const _SheetField({required this.controller, required this.label, required this.icon});
  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
        ),
      );
}
