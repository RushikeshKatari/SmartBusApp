import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ManagerConfigs extends StatefulWidget {
  const ManagerConfigs({super.key});

  @override
  State<ManagerConfigs> createState() => _ManagerConfigsState();
}

class _ManagerConfigsState extends State<ManagerConfigs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> _apiKeys = [
    {
      'key': 'google_maps_api_key',
      'value': 'AIzaSy_DEFAULT_KEY',
      'desc': 'API key for Google Maps'
    },
    {
      'key': 'stripe_secret_key',
      'value': 'sk_test_DEFAULT_KEY',
      'desc': 'Secret key for Stripe billing'
    },
    {
      'key': 'fcm_server_key',
      'value': 'AAAA_DEFAULT_KEY',
      'desc': 'Firebase Cloud Messaging Key'
    },
  ];

  final List<Map<String, String>> _dbLinks = [
    {
      'key': 'postgres_url',
      'value': 'jdbc:postgresql://db:5432/smartbus_db',
      'desc': 'PostgreSQL Database URL'
    },
    {
      'key': 'redis_url',
      'value': 'redis://redis:6379',
      'desc': 'Redis Cache URL'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('System Configurations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              FilledButton.icon(
                onPressed: () => _showEditDialog(null),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Config'),
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFEA580C),
          unselectedLabelColor: AppColors.muted,
          indicatorColor: const Color(0xFFEA580C),
          tabs: const [
            Tab(text: 'API Keys & Secrets'),
            Tab(text: 'Database Links'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildConfigList(_apiKeys),
              _buildConfigList(_dbLinks),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfigList(List<Map<String, String>> configs) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: configs
          .map((config) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SurfaceCard(
                  child: ListTile(
                    title: Text(config['key']!,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Value: ${config['value']}',
                            style: const TextStyle(fontFamily: 'monospace')),
                        const SizedBox(height: 4),
                        Text(config['desc']!,
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: () => _showEditDialog(config),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  void _showEditDialog(Map<String, String>? config) {
    final keyCtrl = TextEditingController(text: config?['key'] ?? '');
    final valCtrl = TextEditingController(text: config?['value'] ?? '');
    final descCtrl = TextEditingController(text: config?['desc'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:
            Text(config == null ? 'Add Configuration' : 'Edit Configuration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: keyCtrl,
                decoration: const InputDecoration(labelText: 'Config Key')),
            const SizedBox(height: 12),
            TextField(
                controller: valCtrl,
                decoration: const InputDecoration(labelText: 'Value')),
            const SizedBox(height: 12),
            TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Configuration saved successfully')));
            },
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEA580C)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
