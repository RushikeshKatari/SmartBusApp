import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/smart_bus_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_widgets.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  final _collegeNameCtrl =
      TextEditingController(text: 'National Institute of Engineering');
  final _emailCtrl = TextEditingController(text: 'support.smartbus@nie.edu.in');

  @override
  void dispose() {
    _collegeNameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SmartBusProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Global Settings',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const Text(
                  'Configure SmartBus application settings, theme, and staff members',
                  style: TextStyle(color: AppColors.muted, fontSize: 13)),
              const SizedBox(height: 24),

              // Theme Switch Card
              _buildSectionCard(
                title: 'Theme Preferences',
                icon: Icons.palette_rounded,
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text(
                        'Toggle dark color scheme across all workspaces'),
                    value: provider.isDarkMode,
                    onChanged: (val) => provider.toggleTheme(),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Staff Members Card (Add / Delete Staff)
              _buildSectionCard(
                title: 'Staff Management',
                icon: Icons.badge_rounded,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Active Staff (${provider.staffMembers.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      PrimaryButton(
                        label: 'Add Staff',
                        icon: Icons.person_add,
                        onPressed: () => _showAddStaffDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...provider.staffMembers.map((staff) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(staff['name']!,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${staff['role']} · ${staff['email']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.danger),
                          onPressed: () {
                            provider.removeStaff(staff['id']!);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    '${staff['name']} removed from staff')));
                          },
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 20),

              // College Info Card
              _buildSectionCard(
                title: 'College Profile',
                icon: Icons.school_rounded,
                children: [
                  TextField(
                      controller: _collegeNameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'College name / Institution',
                          border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Support Contact Email',
                          border: OutlineInputBorder())),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Staff Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name')),
            TextField(
                controller: roleCtrl,
                decoration: const InputDecoration(
                    labelText: 'Role (e.g. Transport Officer)')),
            TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                Provider.of<SmartBusProvider>(context, listen: false).addStaff({
                  'id': 'STF-${DateTime.now().millisecondsSinceEpoch}',
                  'name': nameCtrl.text,
                  'role': roleCtrl.text.isNotEmpty ? roleCtrl.text : 'Staff',
                  'email': emailCtrl.text.isNotEmpty
                      ? emailCtrl.text
                      : 'staff@college.edu',
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Staff member added!')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: AppColors.primary, size: 18)),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
