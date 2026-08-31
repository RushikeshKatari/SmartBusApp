import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/smart_bus_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'qr_screen.dart';
import 'routes_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class SmartBusShell extends StatelessWidget {
  const SmartBusShell({super.key});
  @override
  Widget build(BuildContext context) {
    final tab = context.watch<SmartBusProvider>().tab;
    final pages = [const HomeScreen(), const QrScreen(), const RoutesScreen()];
    return Scaffold(
      appBar: AppBar(
          leading: const Icon(Icons.menu_rounded),
          title: const Text('SmartBus',
              style: TextStyle(fontWeight: FontWeight.w800)),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsScreen())),
                icon: const Badge(
                    smallSize: 8,
                    child: Icon(Icons.notifications_none_rounded))),
            Padding(
                padding: const EdgeInsets.only(right: 14),
                child: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProfileScreen())),
                    child: Hero(
                        tag: 'avatar',
                        child: CircleAvatar(
                            radius: 17,
                            backgroundColor: AppColors.primary,
                            child: Text(
                                context
                                    .read<SmartBusProvider>()
                                    .student
                                    .initials,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700))))))
          ]),
      body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250), child: pages[tab]),
      bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: context.read<SmartBusProvider>().selectTab,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.qr_code_scanner_outlined),
                selectedIcon: Icon(Icons.qr_code_scanner_rounded),
                label: 'QR'),
            NavigationDestination(
                icon: Icon(Icons.route_outlined),
                selectedIcon: Icon(Icons.route_rounded),
                label: 'Other Routes')
          ]),
    );
  }
}
