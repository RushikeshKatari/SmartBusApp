import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/smart_bus_provider.dart';
import 'screens/role_selection_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const SmartBusApp());

class SmartBusApp extends StatelessWidget {
  const SmartBusApp({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => SmartBusProvider(),
        child: MaterialApp(
          title: 'SmartBus',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const RoleSelectionScreen(),
        ),
      );
}
