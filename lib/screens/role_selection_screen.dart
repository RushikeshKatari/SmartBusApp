import 'package:flutter/material.dart';
import 'login_screen.dart';

/// Legacy screen kept for backward compatibility.
/// The app now starts on [SingleLoginScreen] directly.
/// Any remaining logout buttons that push [RoleSelectionScreen] will simply
/// show the unified login page instead.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) => const SingleLoginScreen();
}
