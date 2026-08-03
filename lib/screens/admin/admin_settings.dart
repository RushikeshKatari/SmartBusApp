import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_widgets.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  final _collegeNameCtrl = TextEditingController(text: 'National Institute of Engineering');
  final _emailCtrl = TextEditingController(text: 'support.smartbus@nie.edu.in');
  final _mapsApiCtrl = TextEditingController(text: 'AIzaSyA_mockMapsAPIkeyForClientOnly18359');
  String _selectedTheme = 'System Light';
  String _selectedLang = 'English';

  @override
  void dispose() {
    _collegeNameCtrl.dispose();
    _emailCtrl.dispose();
    _mapsApiCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration settings saved successfully ✓'), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Global Settings',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const Text(
                'Configure SmartBus application settings and layout options',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // College Info Card
              _buildSectionCard(
                title: 'College Profile',
                icon: Icons.school_rounded,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Center(
                          child: Icon(Icons.business_rounded, color: AppColors.primary, size: 32),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SecondaryButton(
                            label: 'Upload New Logo',
                            onPressed: () {},
                            small: true,
                          ),
                          const SizedBox(height: 4),
                          const Text('SVG, PNG format recommended (max. 1MB)', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _collegeNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'College name / Institution',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Support Contact Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Maps API Configuration
              _buildSectionCard(
                title: 'API Integrations',
                icon: Icons.api_rounded,
                children: [
                  TextField(
                    controller: _mapsApiCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Google Maps API Key (Front-end Rendering)',
                      border: OutlineInputBorder(),
                      helperText: 'API keys are stored securely locally for visual renders only.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // UI Preferences
              _buildSectionCard(
                title: 'Preferences',
                icon: Icons.palette_rounded,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedTheme,
                    decoration: const InputDecoration(
                      labelText: 'Default Theme Mode',
                      border: OutlineInputBorder(),
                    ),
                    items: ['System Light', 'Force Dark Mode', 'Amoled Black']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _selectedTheme = val!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedLang,
                    decoration: const InputDecoration(
                      labelText: 'Default Language',
                      border: OutlineInputBorder(),
                    ),
                    items: ['English', 'Spanish', 'Hindi', 'French', 'German']
                        .map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                    onChanged: (val) => setState(() => _selectedLang = val!),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Save Action Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Save Configuration Settings',
                  icon: Icons.check_rounded,
                  onPressed: _saveSettings,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
