import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminQrScanner extends StatelessWidget {
  const AdminQrScanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Admin QR Verification Scanner',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text(
            'Scan student passes, staff badges, or bus beacon tokens for verification',
            style: TextStyle(color: AppColors.muted, fontSize: 12)),
        const SizedBox(height: 20),
        SurfaceCard(
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner_rounded,
                      color: AppColors.primary.withValues(alpha: 0.8),
                      size: 90),
                  const SizedBox(height: 16),
                  const Text('Admin Verification Scanner Active',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Position pass code inside frame',
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
