import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/location_sharing_widgets.dart';

class TripCompletedScreen extends StatelessWidget {
  const TripCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: .13),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.success, size: 54),
                ),
                const SizedBox(height: 24),
                const Text('Trip completed',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text(
                    'Location sharing stopped. Thanks for helping riders stay informed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, height: 1.5)),
                const SizedBox(height: 28),
                ModernPrimaryButton(
                    label: 'Back to SmartBus',
                    icon: Icons.home_rounded,
                    onPressed: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst)),
              ],
            ),
          ),
        ),
      );
}
