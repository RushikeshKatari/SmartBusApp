import 'package:flutter/material.dart';
import '../services/auth_api_service.dart';
import '../theme/app_theme.dart';
import 'admin/admin_shell.dart';
import 'hod/hod_portal.dart';
import 'incharge/incharge_shell.dart';
import 'manager/manager_shell.dart';
import 'smart_bus_shell.dart';

class SingleLoginScreen extends StatefulWidget {
  const SingleLoginScreen({super.key});

  @override
  State<SingleLoginScreen> createState() => _SingleLoginScreenState();
}

class _SingleLoginScreenState extends State<SingleLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillPreset(String id, String password) {
    setState(() {
      _idController.text = id;
      _passwordController.text = password;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    // Call unified authentication without forcing a specific role:
    // the system resolves the role automatically based on ID & password!
    final result = await AuthApiService.login(
      username: _idController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      final roleStr = result['role'] as String?;
      Widget targetScreen;

      switch (roleStr) {
        case 'STUDENT':
          targetScreen = const SmartBusShell();
          break;
        case 'INCHARGE':
          targetScreen = const InchargeShell();
          break;
        case 'ADMIN':
          targetScreen = const AdminShell();
          break;
        case 'HOD':
          targetScreen = const HodPortal();
          break;
        case 'APP_MANAGER':
          targetScreen = const ManagerShell();
          break;
        default:
          targetScreen = const SmartBusShell();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => targetScreen),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['error'] as String? ??
                'Login failed. Invalid ID or password.',
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                elevation: 4,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Logo Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.directions_bus_filled_rounded,
                            color: AppColors.primary,
                            size: 38,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'SmartBus Login',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Sign in with your assigned ID and password.\nYour portal opens automatically based on your account.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // User ID / Roll Number Field
                        TextFormField(
                          controller: _idController,
                          decoration: InputDecoration(
                            labelText: 'User ID / Roll Number',
                            hintText: 'e.g. student, incharge, admin, hod',
                            prefixIcon:
                                const Icon(Icons.person_outline_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Please enter your ID or username'
                                  : null,
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Please enter your password'
                                  : null,
                          onFieldSubmitted: (_) => _handleLogin(),
                        ),
                        const SizedBox(height: 24),

                        // Login Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isSubmitting ? null : _handleLogin,
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.login_rounded, size: 18),
                            label: Text(
                              _isSubmitting ? 'Signing In…' : 'Sign In',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Quick Demo Credentials Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.vpn_key_outlined,
                                      size: 15, color: AppColors.muted),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Demo Credentials (1-Tap Fill):',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.muted,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _DemoPresetChip(
                                    role: 'Student',
                                    id: 'student',
                                    pass: 'student123',
                                    color: AppColors.primary,
                                    onTap: () =>
                                        _fillPreset('student', 'student123'),
                                  ),
                                  _DemoPresetChip(
                                    role: 'Bus In-charge',
                                    id: 'incharge',
                                    pass: 'incharge123',
                                    color: const Color(0xFF7C3AED),
                                    onTap: () => _fillPreset(
                                        'incharge', 'incharge123'),
                                  ),
                                  _DemoPresetChip(
                                    role: 'Admin',
                                    id: 'admin',
                                    pass: 'admin123',
                                    color: AppColors.success,
                                    onTap: () =>
                                        _fillPreset('admin', 'admin123'),
                                  ),
                                  _DemoPresetChip(
                                    role: 'HOD',
                                    id: 'hod',
                                    pass: 'hod123',
                                    color: const Color(0xFF0F766E),
                                    onTap: () =>
                                        _fillPreset('hod', 'hod123'),
                                  ),
                                  _DemoPresetChip(
                                    role: 'App Manager',
                                    id: 'superadmin',
                                    pass: 'admin123',
                                    color: const Color(0xFFEA580C),
                                    onTap: () =>
                                        _fillPreset('superadmin', 'admin123'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoPresetChip extends StatelessWidget {
  const _DemoPresetChip({
    required this.role,
    required this.id,
    required this.pass,
    required this.color,
    required this.onTap,
  });

  final String role;
  final String id;
  final String pass;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Text(
          role,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
