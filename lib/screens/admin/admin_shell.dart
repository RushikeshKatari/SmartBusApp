import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/smart_bus_provider.dart';
import '../../theme/app_theme.dart';
import 'admin_dashboard.dart';
import 'admin_students.dart';
import 'admin_buses.dart';
import 'admin_incharges.dart';
import 'admin_routes.dart';
import 'admin_advertisements.dart';
import 'admin_notifications.dart';
import 'admin_reports.dart';
import 'admin_attendance.dart';
import 'admin_qr_scanner.dart';
import 'admin_settings.dart';
import 'admin_emergency.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selected = 0;

  static const _navItems = [
    _NavItem(Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
    _NavItem(Icons.people_alt_rounded, Icons.people_alt_outlined, 'Students'),
    _NavItem(Icons.manage_accounts_rounded, Icons.manage_accounts_outlined,
        'Bus Incharges'),
    _NavItem(
        Icons.directions_bus_rounded, Icons.directions_bus_outlined, 'Buses'),
    _NavItem(Icons.alt_route_rounded, Icons.route_outlined, 'Routes'),
    _NavItem(Icons.campaign_rounded, Icons.campaign_outlined, 'Advertisements'),
    _NavItem(Icons.notifications_rounded, Icons.notifications_outlined,
        'Notifications'),
    _NavItem(Icons.how_to_reg_rounded, Icons.how_to_reg_outlined, 'Attendance'),
    _NavItem(Icons.qr_code_scanner_rounded, Icons.qr_code_scanner_outlined,
        'QR Scanner'),
    _NavItem(Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Reports'),
    _NavItem(Icons.warning_rounded, Icons.warning_outlined, 'Emergency'),
    _NavItem(Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
  ];

  Widget _buildPage() {
    switch (_selected) {
      case 0:
        return const AdminDashboard(key: ValueKey('dash'));
      case 1:
        return const AdminStudents(key: ValueKey('students'));
      case 2:
        return const AdminIncharges(key: ValueKey('incharges'));
      case 3:
        return const AdminBuses(key: ValueKey('buses'));
      case 4:
        return const AdminRoutes(key: ValueKey('routes'));
      case 5:
        return const AdminAdvertisements(key: ValueKey('ads'));
      case 6:
        return const AdminNotifications(key: ValueKey('notif'));
      case 7:
        return const AdminAttendance(key: ValueKey('attd'));
      case 8:
        return const AdminQrScanner(key: ValueKey('scanner'));
      case 9:
        return const AdminReports(key: ValueKey('reports'));
      case 10:
        return const AdminEmergency(key: ValueKey('emergency'));
      case 11:
        return const AdminSettings(key: ValueKey('settings'));
      default:
        return const AdminDashboard(key: ValueKey('dash'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 820;
    final isTablet = screenWidth > 600 && screenWidth <= 820;

    return Scaffold(
      body: Row(
        children: [
          // Permanent sidebar on desktop
          if (isDesktop)
            _Sidebar(
                selected: _selected,
                onSelect: (i) => setState(() => _selected = i)),

          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 68,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border:
                        Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                  ),
                  child: Row(
                    children: [
                      if (!isDesktop)
                        IconButton(
                          icon: const Icon(Icons.menu_rounded),
                          onPressed: () => _showDrawer(context),
                        ),
                      Text(
                        _navItems[_selected].label,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      // Search icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.search_rounded,
                            color: AppColors.muted, size: 20),
                      ),
                      const SizedBox(width: 10),
                      // Theme toggle
                      Consumer<SmartBusProvider>(
                        builder: (context, provider, _) => IconButton(
                          icon: Icon(
                              provider.isDarkMode
                                  ? Icons.wb_sunny_rounded
                                  : Icons.nightlight_round,
                              color: AppColors.muted,
                              size: 20),
                          onPressed: () => provider.toggleTheme(),
                          tooltip: 'Toggle Theme',
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Notification
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Badge(
                          child: const Icon(Icons.notifications_outlined,
                              color: AppColors.muted, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Admin avatar
                      GestureDetector(
                        onTap: () => _showAdminMenu(context),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: .15),
                              child: const Text('AD',
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12)),
                            ),
                            if (isTablet || isDesktop) ...[
                              const SizedBox(width: 8),
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Admin',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13)),
                                  Text('Super Admin',
                                      style: TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 11)),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Page content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: _buildPage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Row(
        children: [
          _Sidebar(
            selected: _selected,
            onSelect: (i) {
              setState(() => _selected = i);
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdminMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Admin Account',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
                leading: Icon(Icons.person_rounded),
                title: Text('Super Admin'),
                subtitle: Text('admin@college.edu')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SIDEBAR
// ─────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;

  static const _navItems = _AdminShellState._navItems;

  @override
  Widget build(BuildContext context) => Container(
        width: 240,
        color: const Color(0xFF0F172A),
        child: Column(
          children: [
            // Logo area
            Container(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.directions_bus_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SmartBus',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                      Text('Admin Panel',
                          style:
                              TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _navItems.length,
                itemBuilder: (_, i) {
                  final item = _navItems[i];
                  final sel = selected == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      onTap: () => onSelect(i),
                      selected: sel,
                      selectedTileColor:
                          AppColors.primary.withValues(alpha: .2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      leading: Icon(sel ? item.iconFilled : item.icon,
                          color:
                              sel ? AppColors.primary : const Color(0xFF94A3B8),
                          size: 20),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          color: sel ? Colors.white : const Color(0xFF94A3B8),
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      dense: true,
                    ),
                  );
                },
              ),
            ),
            // Logout
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListTile(
                onTap: () => Navigator.pop(context),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.logout_rounded,
                    color: Color(0xFF94A3B8), size: 20),
                title: const Text('Logout',
                    style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                        fontSize: 14)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                dense: true,
              ),
            ),
          ],
        ),
      );
}

class _NavItem {
  const _NavItem(this.iconFilled, this.icon, this.label);
  final IconData iconFilled, icon;
  final String label;
}
