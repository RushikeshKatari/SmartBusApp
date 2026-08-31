import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'incharge_dashboard.dart';
import 'incharge_my_bus.dart';
import 'incharge_qr_scanner.dart';

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
      icon: Icon(Icons.qr_code_scanner_rounded),
      selectedIcon: Icon(Icons.qr_code_scanner),
      label: 'Scan & GPS',
    ),
    NavigationDestination(
      icon: Icon(Icons.directions_bus_outlined),
      selectedIcon: Icon(Icons.directions_bus_filled_rounded),
      label: 'My Bus',
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
                color: AppColors.primary.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_bus_filled_rounded,
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Bus In-charge',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF7C3AED).withValues(alpha: .15),
              child: const Text('MS',
                  style: TextStyle(
                      color: Color(0xFF7C3AED),
                      fontWeight: FontWeight.w800,
                      fontSize: 12)),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
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
        return const InchargeQrScanner(key: ValueKey('scanner'));
      case 2:
        return const InchargeMyBus(key: ValueKey('bus'));
      default:
        return const InchargeDashboard(key: ValueKey('dash'));
    }
  }
}
