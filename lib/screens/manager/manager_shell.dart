import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../providers/smart_bus_provider.dart';
import '../../theme/app_theme.dart';
import 'manager_dashboard.dart';
import 'manager_service_billing.dart';
import 'manager_configs.dart';

class ManagerShell extends StatefulWidget {
  const ManagerShell({super.key});
  @override
  State<ManagerShell> createState() => _ManagerShellState();
}

class _ManagerShellState extends State<ManagerShell> {
  int _selected = 0;

  static const _navItems = [
    _NavItem(Icons.dashboard_rounded, Icons.dashboard_outlined,
        'Home (Daily Report)'),
    _NavItem(Icons.receipt_long_rounded, Icons.receipt_long_outlined,
        'Service Billing'),
    _NavItem(Icons.settings_suggest_rounded, Icons.settings_suggest_outlined,
        'System Configs'),
  ];

  Widget _buildPage() {
    switch (_selected) {
      case 0:
        return const ManagerDashboard(key: ValueKey('dash'));
      case 1:
        return const ManagerServiceBilling(key: ValueKey('billing'));
      case 2:
        return const ManagerConfigs(key: ValueKey('configs'));
      default:
        return const ManagerDashboard(key: ValueKey('dash'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 820;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            _Sidebar(
                selected: _selected,
                onSelect: (i) => setState(() => _selected = i)),
          Expanded(
            child: Column(
              children: [
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
                      const SizedBox(width: 12),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFEA580C),
                        child: Text('AM',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
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
              }),
          Expanded(
              child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(color: Colors.black54))),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;
  static const _navItems = _ManagerShellState._navItems;

  @override
  Widget build(BuildContext context) => Container(
        width: 240,
        color: const Color(0xFF1E140C),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEA580C),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.settings_system_daydream_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('App Manager',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                      Text('Super Admin',
                          style:
                              TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: Color(0xFF32241A))),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _navItems.length,
                itemBuilder: (_, i) {
                  final sel = selected == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      onTap: () => onSelect(i),
                      selected: sel,
                      selectedTileColor:
                          const Color(0xFFEA580C).withValues(alpha: .2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      leading: Icon(
                          sel ? _navItems[i].iconFilled : _navItems[i].icon,
                          color: sel
                              ? const Color(0xFFEA580C)
                              : const Color(0xFF94A3B8),
                          size: 20),
                      title: Text(_navItems[i].label,
                          style: TextStyle(
                              color:
                                  sel ? Colors.white : const Color(0xFF94A3B8),
                              fontWeight:
                                  sel ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 14)),
                    ),
                  );
                },
              ),
            ),
            ListTile(
              onTap: () => Navigator.pop(context),
              leading: const Icon(Icons.logout_rounded,
                  color: Color(0xFF94A3B8), size: 20),
              title: const Text('Logout',
                  style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            const SizedBox(height: 16)
          ],
        ),
      );
}

class _NavItem {
  const _NavItem(this.iconFilled, this.icon, this.label);
  final IconData iconFilled, icon;
  final String label;
}
