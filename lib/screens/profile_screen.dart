import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/smart_bus_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'active_sharing_screen.dart';
import 'location_scanner_screen.dart';
import 'role_selection_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SmartBusProvider>();
    final s = provider.student;
    final hodReports = provider.hodReports;

    // Filter reports that apply to this student and have permission granted by HOD
    final studentPermissions = hodReports.where((report) {
      final hasStudent = report.students.any((st) =>
          st['rollNumber'] == s.rollNumber ||
          (st['name'] != null && st['name']!.toLowerCase() == s.name.toLowerCase()));
      return hasStudent && report.permissionGiven;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            tooltip: 'Logout / Switch Portal',
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
              (route) => false,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Student Avatar and Name Header
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Text(
                s.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              s.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '${s.rollNumber} · ${s.department}',
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),

          // ─── 1. HOD GRANTED PERMISSIONS TAB / SECTION ─────────────
          if (studentPermissions.isNotEmpty) ...[
            Row(
              children: [
                const SectionHeader(title: 'Permissions'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF10B981), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user_rounded,
                          color: Color(0xFF10B981), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${studentPermissions.length} Active',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...studentPermissions.map((perm) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF064E3B).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.verified_rounded,
                                  color: Color(0xFF059669), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Academic Exemption Permission',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: Color(0xFF065F46),
                                    ),
                                  ),
                                  Text(
                                    'Approved by Head of Department (${s.department})',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF047857),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'GRANTED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded,
                                      color: AppColors.muted, size: 14),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Reason: ${perm.reason}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bus: ${perm.busName} (${perm.busNumber}) • Location: ${perm.location}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.muted),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Authorized by Bus In-charge: ${perm.inchargeName}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.muted),
                              ),
                              if (perm.attendanceGiven) ...[
                                const SizedBox(height: 6),
                                const Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        color: Color(0xFF10B981), size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'Class attendance credit automatically preserved',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF059669),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 14),
          ],

          // ─── 2. SHARE LIVE LOCATION CARD ────────────────────────
          const SectionHeader(title: 'Live Location Sharing'),
          const SizedBox(height: 10),
          SurfaceCard(
            color: provider.sharingActive
                ? const Color(0xFFECFDF5)
                : const Color(0xFFEFF6FF),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: provider.sharingActive
                        ? const Color(0xFF10B981).withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.share_location_rounded,
                    color: provider.sharingActive
                        ? const Color(0xFF059669)
                        : AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Share bus location',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          if (provider.sharingActive) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('ACTIVE',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        provider.sharingActive
                            ? 'Sharing active for ${provider.sessionTime}. Tap to manage.'
                            : 'Scan bus QR to help fellow riders track this trip live.',
                        style: const TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => provider.sharingActive
                          ? const ActiveSharingScreen()
                          : const LocationScannerScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── STUDENT ATTENDANCE QR CODE PASS ─────────────
          const SectionHeader(title: 'Digital Bus Pass & Attendance QR'),
          const SizedBox(height: 10),
          _StudentAttendanceQrCard(student: s),
          const SizedBox(height: 20),

          // Academic & Bus Details Card
          const SectionHeader(title: 'Bus & Department'),
          const SizedBox(height: 10),
          SurfaceCard(
            child: Column(
              children: [
                _row(Icons.school_rounded, 'Department', s.department),
                const Divider(),
                _row(Icons.directions_bus_rounded, 'Assigned Bus', s.busName),
                const Divider(),
                _row(Icons.verified_user_rounded, 'Pass Status', 'Active • Valid for 2026-2027'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Account Settings
          const SectionHeader(title: 'Account & Settings'),
          const SizedBox(height: 10),
          SurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _tile(Icons.settings_outlined, 'Preferences'),
                _tile(Icons.info_outline_rounded, 'About SmartBus'),
                _tile(Icons.help_outline_rounded, 'Help & Support'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
              (route) => false,
            ),
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            label: const Text('Switch Role / Logout',
                style: TextStyle(
                    color: AppColors.danger, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0x33EF4444)),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData i, String t, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(i, color: AppColors.primary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
                  Text(v,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _tile(IconData i, String t) => ListTile(
        leading: Icon(i, color: AppColors.ink),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded),
      );
}

// ─────────────────────────────────────────────
// STUDENT ATTENDANCE QR CARD WIDGET
// ─────────────────────────────────────────────
class _StudentAttendanceQrCard extends StatelessWidget {
  const _StudentAttendanceQrCard({required this.student});
  final dynamic student;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.qr_code_2_rounded,
                      color: Color(0xFF60A5FA), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Official Boarding QR',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800)),
                      Text('Scan with Bus In-charge to mark attendance',
                          style: TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: const Color(0xFF10B981), width: 0.8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: Color(0xFF10B981), size: 12),
                      SizedBox(width: 4),
                      Text('VALID',
                          style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 10,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // White QR Canvas Box
            GestureDetector(
              onTap: () => _showFullScreenQr(context),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 170,
                      height: 170,
                      child: CustomPaint(
                        painter: _QrCodePainter(
                          data: '${student.rollNumber}:${student.name}:${student.busName}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Roll: ${student.rollNumber}',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.touch_app_rounded,
                    color: Colors.white54, size: 14),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: () => _showFullScreenQr(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF93C5FD),
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Tap to zoom full-screen',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenQr(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              student.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              '${student.rollNumber} • ${student.busName}',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                width: 240,
                height: 240,
                child: CustomPaint(
                  painter: _QrCodePainter(
                    data: '${student.rollNumber}:${student.name}:${student.busName}',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Present this QR code to the bus in-charge or driver upon boarding.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          Center(
            child: FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// VECTOR QR CODE PAINTER
// ─────────────────────────────────────────────
class _QrCodePainter extends CustomPainter {
  const _QrCodePainter({required this.data});
  final String data;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0F172A);
    const matrixSize = 25;
    final cellSize = size.width / matrixSize;

    // Fixed QR finder pattern drawer
    void drawFinder(double x, double y) {
      // Outer 7x7
      canvas.drawRect(Rect.fromLTWH(x, y, cellSize * 7, cellSize * 7), paint);
      // Inner clear 5x5
      canvas.drawRect(
          Rect.fromLTWH(x + cellSize, y + cellSize, cellSize * 5, cellSize * 5),
          Paint()..color = Colors.white);
      // Center solid 3x3
      canvas.drawRect(
          Rect.fromLTWH(x + cellSize * 2, y + cellSize * 2, cellSize * 3, cellSize * 3),
          paint);
    }

    // Top-Left Finder
    drawFinder(0, 0);
    // Top-Right Finder
    drawFinder((matrixSize - 7) * cellSize, 0);
    // Bottom-Left Finder
    drawFinder(0, (matrixSize - 7) * cellSize);

    // Hash-based pseudo-random data module pattern generated from student data
    final hash = data.hashCode.abs();
    for (int r = 0; r < matrixSize; r++) {
      for (int c = 0; c < matrixSize; c++) {
        // Skip finder regions
        if ((r < 8 && c < 8) || (r < 8 && c >= matrixSize - 8) || (r >= matrixSize - 8 && c < 8)) {
          continue;
        }
        // Timing patterns
        if (r == 6 || c == 6) {
          if ((r + c) % 2 == 0) {
            canvas.drawRect(
                Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize),
                paint);
          }
          continue;
        }
        // Deterministic QR modules
        final bit = ((hash * (r + 1) * 31 + c * 17 + (r ^ c)) % 100) > 48;
        if (bit) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                  c * cellSize + 0.5, r * cellSize + 0.5, cellSize - 1, cellSize - 1),
              const Radius.circular(1.5),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
