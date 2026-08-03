import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'admin/admin_shell.dart';
import 'incharge/incharge_shell.dart';
import 'smart_bus_shell.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(padding: const EdgeInsets.all(24), children: [
            const SizedBox(height: 24),
            Center(child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Color(0x442563EB), blurRadius: 20, offset: Offset(0, 8))]), child: const Icon(Icons.directions_bus_filled_rounded, color: Colors.white, size: 34))),
            const SizedBox(height: 20),
            const Center(child: Text('Welcome to SmartBus', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800))),
            const SizedBox(height: 7),
            const Center(child: Text('Choose your workspace to continue.', style: TextStyle(color: AppColors.muted))),
            const SizedBox(height: 34),
            LayoutBuilder(builder: (context, constraints) => Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                SizedBox(width: constraints.maxWidth > 650 ? 250 : constraints.maxWidth, child: _RoleCard(icon: Icons.school_rounded, title: 'Student Login', description: 'Track your assigned bus, scan QR codes, and manage smart alarms.', color: AppColors.primary, action: 'Open student app', onOpen: () => _open(context, const SmartBusShell()))),
                SizedBox(width: constraints.maxWidth > 650 ? 250 : constraints.maxWidth, child: _RoleCard(icon: Icons.directions_bus_filled_rounded, title: 'Bus In-charge', description: 'Manage your assigned bus, daily route, stops, and route history.', color: const Color(0xFF7C3AED), action: 'Open in-charge dashboard', onOpen: () => _open(context, const InchargeShell()))),
                SizedBox(width: constraints.maxWidth > 650 ? 250 : constraints.maxWidth, child: _RoleCard(icon: Icons.admin_panel_settings_rounded, title: 'Admin', description: 'Monitor students, buses, routes, reports, and campus operations.', color: AppColors.success, action: 'Open admin dashboard', onOpen: () => _open(context, const AdminShell()))),
              ],
            )),
            const SizedBox(height: 25),
            const Center(child: Text('Demo workspaces use realistic mock data only.', style: TextStyle(fontSize: 12, color: AppColors.muted))),
          ],
        )))),
      );

  void _open(BuildContext context, Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.icon, required this.title, required this.description, required this.color, required this.action, required this.onOpen});
  final IconData icon; final String title, description, action; final Color color; final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) => SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 28)),
    const SizedBox(height: 18), Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)), const SizedBox(height: 7),
    Text(description, style: const TextStyle(color: AppColors.muted, height: 1.4)), const SizedBox(height: 21),
    FilledButton.icon(onPressed: onOpen, icon: const Icon(Icons.arrow_forward_rounded, size: 18), label: Text(action), style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
  ]));
}
