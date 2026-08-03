import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'incharge_dashboard.dart';
import 'incharge_my_bus.dart';
import 'incharge_route_history.dart';

class InchargeShell extends StatefulWidget {
  const InchargeShell({super.key});
  @override
  State<InchargeShell> createState() => _InchargeShellState();
}

class _InchargeShellState extends State<InchargeShell> {
  int _tab = 0;

  static const _navItems = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard_rounded),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.directions_bus_outlined),
      selectedIcon: Icon(Icons.directions_bus_filled_rounded),
      label: 'My Bus',
    ),
    NavigationDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history_rounded),
      label: 'Route History',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_bus_filled_rounded, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Bus In-charge', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF7C3AED).withOpacity(.15),
              child: const Text('MS', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
        child: _buildPage(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: _navItems,
      ),
    );
  }

  Widget _buildPage() {
    switch (_tab) {
      case 0:
        return const InchargeDashboard(key: ValueKey('dash'));
      case 1:
        return const InchargeMyBus(key: ValueKey('bus'));
      case 2:
        return const InchargeRouteHistory(key: ValueKey('hist'));
      case 3:
        return _buildProfile();
      default:
        return const InchargeDashboard(key: ValueKey('dash'));
    }
  }

  Widget _buildProfile() => ListView(
        key: const ValueKey('profile'),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: const Color(0xFF7C3AED).withOpacity(.15),
              child: const Text('MS', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w800, fontSize: 28)),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Column(children: [
              Text('Meera Singh', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Text('Bus In-charge · SB-04', style: TextStyle(color: AppColors.muted)),
            ]),
          ),
          const SizedBox(height: 28),
          _ProfileRow(Icons.phone_rounded, 'Phone', '94567 89012'),
          _ProfileRow(Icons.email_rounded, 'Email', 'meera.s@college.edu'),
          _ProfileRow(Icons.calendar_today_rounded, 'Joined', 'January 2023'),
          _ProfileRow(Icons.directions_bus_rounded, 'Assigned Bus', 'Campus Express · SB-04'),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: BorderSide(color: AppColors.danger.withOpacity(.3)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      );
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(.08), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ],
            ),
          ],
        ),
      );
}
