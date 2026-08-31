import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_models.dart';
import '../../providers/smart_bus_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_widgets.dart';

class AdminIncharges extends StatefulWidget {
  const AdminIncharges({super.key});

  @override
  State<AdminIncharges> createState() => _AdminInchargesState();
}

class _AdminInchargesState extends State<AdminIncharges> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SmartBusProvider>(context);
    final allIncharges = provider.adminIncharges;

    final filteredIncharges = allIncharges.where((ic) {
      return ic.name.toLowerCase().contains(_query.toLowerCase()) ||
          ic.assignedBus.toLowerCase().contains(_query.toLowerCase()) ||
          ic.email.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bus In-charge Management',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800)),
                      Text(
                          'Assign routes and manage ${allIncharges.length} active staff members',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 13)),
                    ],
                  ),
                ),
                PrimaryButton(
                  label: 'Add In-charge',
                  icon: Icons.person_add_rounded,
                  onPressed: () => _showAddInchargeDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ModernSearchBar(
              hint: 'Search by name, email, or assigned bus...',
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _query = val),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0A0F172A),
                      blurRadius: 16,
                      offset: Offset(0, 4))
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredIncharges.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                itemBuilder: (_, idx) {
                  final ic = filteredIncharges[idx];
                  return ListTile(
                    leading: AdminAvatar(
                        initials: ic.initials,
                        color: ic.avatarColor,
                        radius: 18),
                    title: Text(ic.name,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('${ic.email} · Assigned: ${ic.assignedBus}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.link_rounded,
                              color: Color(0xFF7C3AED)),
                          onPressed: () => _showAssignBusDialog(context, ic),
                          tooltip: 'Assign Bus',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.danger),
                          onPressed: () => _showDeleteConfirmation(context, ic),
                          tooltip: 'Remove',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAddInchargeDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String bus = 'Campus Express 04';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Bus In-charge'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name')),
            TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: bus,
              decoration: const InputDecoration(labelText: 'Assigned Bus'),
              items: ['Campus Express 04', 'City Connector 12', 'Green Line 09']
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (val) => bus = val!,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                final newIc = BusIncharge(
                  id: 'INC-${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text,
                  assignedBus: bus,
                  assignedBusId: 'BUS-NEW',
                  phone: phoneCtrl.text.isNotEmpty
                      ? phoneCtrl.text
                      : '+91 94440 00000',
                  email: emailCtrl.text.isNotEmpty
                      ? emailCtrl.text
                      : '${nameCtrl.text.toLowerCase()}@college.edu',
                  status: 'On Duty',
                  initials: nameCtrl.text.substring(0, 1).toUpperCase(),
                  avatarColor: const Color(0xFF7C3AED),
                  joinedDate: 'Just Now',
                );
                Provider.of<SmartBusProvider>(context, listen: false)
                    .addIncharge(newIc);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bus In-charge added!')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAssignBusDialog(BuildContext context, BusIncharge ic) {
    String selectedBus = ic.assignedBus;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Assign Bus to ${ic.name}'),
        content: DropdownButtonFormField<String>(
          initialValue: [
            'Campus Express 04',
            'City Connector 12',
            'Green Line 09'
          ].contains(selectedBus)
              ? selectedBus
              : 'Campus Express 04',
          decoration: const InputDecoration(labelText: 'Assigned Bus'),
          items: ['Campus Express 04', 'City Connector 12', 'Green Line 09']
              .map((b) => DropdownMenuItem(value: b, child: Text(b)))
              .toList(),
          onChanged: (val) => selectedBus = val!,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Provider.of<SmartBusProvider>(context, listen: false)
                  .assignInchargeBus(ic.id, selectedBus, 'BUS-001');
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Assigned $selectedBus to ${ic.name}')));
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, BusIncharge ic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove In-charge'),
        content: Text('Are you sure you want to remove ${ic.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Provider.of<SmartBusProvider>(context, listen: false)
                  .removeIncharge(ic.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('${ic.name} removed')));
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
