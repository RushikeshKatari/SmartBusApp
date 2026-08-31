import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';

class SurfaceCard extends StatelessWidget {
  const SurfaceCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(18),
      this.color});
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
                color: Color(0x0D0F172A), blurRadius: 18, offset: Offset(0, 7))
          ]),
      child: child);
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});
  final String title;
  final String? action;
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        if (action != null)
          Text(action!,
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600))
      ]);
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
            borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.circle, color: color, size: 8),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700))
        ]));
  }
}

class ModernButton extends StatelessWidget {
  const ModernButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.icon,
      this.secondary = false});
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
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))));
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
              colors: [ad.color, ad.color.withValues(alpha: .75)]),
          borderRadius: BorderRadius.circular(24)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(ad.tag,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.3)),
            const SizedBox(height: 8),
            Text(ad.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(ad.subtitle, style: const TextStyle(color: Colors.white70))
          ]));
}

class BusCard extends StatelessWidget {
  const BusCard({super.key, required this.bus});
  final Bus bus;
  @override
  Widget build(BuildContext context) => SurfaceCard(
          child: Row(children: [
        Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.directions_bus_rounded,
                color: AppColors.primary)),
        const SizedBox(width: 13),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(bus.name,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          Text('${bus.number} · ${bus.distance}',
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 7),
          LiveStatusChip(label: bus.status)
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(bus.eta,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const Text('ETA',
              style: TextStyle(color: AppColors.muted, fontSize: 11))
        ])
      ]));
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
          child: Row(children: [
        Icon(stop.isNext ? Icons.location_on_rounded : Icons.circle_outlined,
            color: stop.isNext ? AppColors.primary : AppColors.muted),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(stop.name, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(stop.distance,
              style: const TextStyle(color: AppColors.muted, fontSize: 12))
        ])),
        Text(stop.time,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))
      ]));
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.notification});
  final AppNotification notification;
  @override
  Widget build(BuildContext context) => SurfaceCard(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(13)),
            child: Icon(notification.icon, color: AppColors.primary)),
        const SizedBox(width: 13),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(notification.title,
                    style: const TextStyle(fontWeight: FontWeight.w800))),
            if (notification.unread)
              const Icon(Icons.circle, color: AppColors.primary, size: 8)
          ]),
          const SizedBox(height: 4),
          Text(notification.message,
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 13, height: 1.35)),
          const SizedBox(height: 8),
          Text(notification.time,
              style: const TextStyle(color: AppColors.muted, fontSize: 11))
        ]))
      ]));
}

class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key, this.height = 280});
  final double height;
  @override
  Widget build(BuildContext context) => Container(
      height: height,
      decoration: BoxDecoration(
          color: const Color(0xFFE8F1ED),
          borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _MapPainter())),
        const Positioned(
            top: 18, left: 18, child: LiveStatusChip(label: 'Live tracking')),
        Center(
            child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Color(0x552563EB), blurRadius: 15)
                    ]),
                child: const Icon(Icons.directions_bus_rounded,
                    color: Colors.white, size: 28))),
        Positioned(
            bottom: 17,
            right: 17,
            child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.my_location_rounded,
                    color: AppColors.primary)))
      ]));
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
      ..cubicTo(s.width * .2, s.height * .22, s.width * .5, s.height * 1.1,
          s.width + 20, s.height * .25);
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
