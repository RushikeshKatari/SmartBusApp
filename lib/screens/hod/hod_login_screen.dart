import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/hod_api_service.dart';
import '../role_selection_screen.dart';
import 'hod_portal.dart';

class HodLoginScreen extends StatefulWidget {
  const HodLoginScreen({super.key});
  @override
  State<HodLoginScreen> createState() => _HodLoginScreenState();
}

class _HodLoginScreenState extends State<HodLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController(text: 'hod');
  final _password = TextEditingController(text: 'hod123');
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final user = _username.text.trim();
    final pass = _password.text;

    // Try backend authentication first
    final authenticated = await HodApiService.login(user, pass);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // If backend authenticated OR standard demo credentials matched, allow entry
    final isDemoValid = (user == 'hod' && pass == 'hod123') ||
        (user == 'superadmin' && pass == 'admin123') ||
        (user == 'admin' && pass == 'admin123');

    if (!authenticated && !isDemoValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Invalid credentials. Use username "hod" and password "hod123".'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HodPortal()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
            child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                    key: _formKey,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: const Color(0xFF0F766E)
                                  .withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.account_balance_rounded,
                              color: Color(0xFF0F766E), size: 34)),
                      const SizedBox(height: 18),
                      const Text('HOD Login',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 7),
                      const Text(
                          'Access emergency attendance reports sent by Transport.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.muted)),
                      const SizedBox(height: 24),
                      TextFormField(
                          controller: _username,
                          decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person_outline)),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter your username'
                                  : null),
                      const SizedBox(height: 12),
                      TextFormField(
                          controller: _password,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined),
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword))),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Enter your password'
                              : null,
                          onFieldSubmitted: (_) => _login()),
                      const SizedBox(height: 22),
                      SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                              onPressed: _isSubmitting ? null : _login,
                              child: Text(_isSubmitting
                                  ? 'Logging in…'
                                  : 'Login to HOD Portal'))),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F766E).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  const Color(0xFF0F766E).withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: Color(0xFF0F766E), size: 18),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Demo Credentials: hod / hod123',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F766E)),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _username.text = 'hod';
                                _password.text = 'hod123';
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Autofill',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F766E))),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const RoleSelectionScreen()),
                          (route) => false,
                        ),
                        icon: const Icon(Icons.arrow_back_rounded, size: 16),
                        label: const Text('Back to Portals',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ])),
              )),
        )),
      );
}
