import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/smart_bus_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/location_sharing_widgets.dart';
import 'active_sharing_screen.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.watch<SmartBusProvider>();
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                  child: Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: .11),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.location_searching_rounded,
                          color: AppColors.primary, size: 43))),
              const SizedBox(height: 25),
              const Text('Enable Location Sharing',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text(
                  'This trip needs a few permissions to keep fellow riders informed.',
                  style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 22),
              const SurfaceCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('This trip requires',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 17)),
                    SizedBox(height: 8),
                    PermissionTile(
                        icon: Icons.my_location_rounded,
                        title: 'Precise Location',
                        detail: 'Accurate live bus position'),
                    PermissionTile(
                        icon: Icons.language_rounded,
                        title: 'Internet Connection',
                        detail: 'Securely updates trip status'),
                    PermissionTile(
                        icon: Icons.location_history_rounded,
                        title: 'Background Location',
                        detail: 'Keeps sharing active while you travel',
                        recommended: true)
                  ])),
              if (p.sharingTransferred)
                const Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: SurfaceCard(
                        color: Color(0xFFFFFBEB),
                        child: Row(children: [
                          Icon(Icons.swap_horiz_rounded,
                              color: AppColors.warning),
                          SizedBox(width: 10),
                          Expanded(
                              child: Text(
                                  'Location sharing has been transferred to this device.',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)))
                        ]))),
              const Spacer(),
              ModernPrimaryButton(
                  label: 'Start sharing',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () {
                    p.startLocationSharing();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ActiveSharingScreen()));
                  })
            ])));
  }
}
