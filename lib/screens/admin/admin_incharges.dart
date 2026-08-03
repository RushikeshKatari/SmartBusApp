import 'package:flutter/material.dart';
import '../../mock/mock_data.dart';
import '../../models/app_models.dart';
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
  String _selectedStatus = 'All';

  List<BusIncharge> get _filteredIncharges {
    return MockData.incharges.where((ic) {
      final matchesQuery = ic.name.toLowerCase().contains(_query.toLowerCase()) ||
          ic.assignedBus.toLowerCase().contains(_query.toLowerCase()) ||
          ic.email.toLowerCase().contains(_query.toLowerCase());
      final matchesStatus = _selectedStatus == 'All' || ic.status == _selectedStatus;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incharges = _filteredIncharges;
    final statuses = ['All', 'Active', 'Inactive'];

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
                      const Text(
                        'Bus In-charge Management',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Assign routes and manage ${MockData.incharges.length} active staff members',
                        style: const TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                PrimaryButton(
                  label: 'Add In-charge',
                  icon: Icons.person_add_rounded,
                  onPressed: () => _showAddInchargeDialog(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Bar & Filters row
            Row(
              children: [
                Expanded(
                  child: ModernSearchBar(
                    hint: 'Search by name, email, or assigned bus...',
                    controller: _searchCtrl,
                    onChanged: (val) => setState(() => _query = val),
                  ),
                ),
                const SizedBox(width: 12),
                _buildFilterDropdown('Status', _selectedStatus, statuses, (val) {
                  if (val != null) setState(() => _selectedStatus = val);
                }),
              ],
            ),
            const SizedBox(height: 24),

            // Responsive Data Table or List view
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 700) {
                    return DataTable(
                      columnSpacing: 24,
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                      columns: const [
                        DataColumn(label: Text('In-charge', style: TextStyle(fontWeight: FontWeight.w800))),
                        DataColumn(label: Text('Assigned Bus', style: TextStyle(fontWeight: FontWeight.w800))),
                        DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.w800))),
                        DataColumn(label: Text('Joined Date', style: TextStyle(fontWeight: FontWeight.w800))),
                        DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w800))),
                        DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w800))),
                      ],
                      rows: incharges.map((ic) => DataRow(
                        cells: [
                          DataCell(Row(
                            children: [
                              AdminAvatar(initials: ic.initials, color: ic.avatarColor, radius: 16),
                              const SizedBox(width: 12),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ic.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                  Text(ic.email, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                                ],
                              ),
                            ],
                          )),
                          DataCell(Text(ic.assignedBus, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13))),
                          DataCell(Text(ic.phone, style: const TextStyle(fontSize: 13))),
                          DataCell(Text(ic.joinedDate, style: const TextStyle(fontSize: 13))),
                          DataCell(StatusBadge(label: ic.status)),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.success),
                                onPressed: () => _showEditInchargeDialog(ic),
                                tooltip: 'Edit Details',
                              ),
                              IconButton(
                                icon: const Icon(Icons.link_rounded, size: 18, color: Color(0xFF7C3AED)),
                                onPressed: () => _showAssignBusDialog(ic),
                                tooltip: 'Assign Bus',
                              ),
                              IconButton(
                                icon: Icon(
                                  ic.status == 'Active' ? Icons.block_flipped : Icons.check_circle_outline_rounded,
                                  size: 18,
                                  color: ic.status == 'Active' ? AppColors.danger : AppColors.success,
                                ),
                                onPressed: () => _showDeactivateConfirmation(ic),
                                tooltip: ic.status == 'Active' ? 'Deactivate' : 'Activate',
                              ),
                            ],
                          )),
                        ],
                      )).toList(),
                    );
                  } else {
                    // Mobile View Cards List
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: incharges.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (_, idx) {
                        final ic = incharges[idx];
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AdminAvatar(initials: ic.initials, color: ic.avatarColor, radius: 18),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(ic.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                        Text(ic.email, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  StatusBadge(label: ic.status),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Bus: ${ic.assignedBus}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)),
                                  Text('Phone: ${ic.phone}', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SecondaryButton(label: 'Edit', onPressed: () => _showEditInchargeDialog(ic), small: true),
                                  const SizedBox(width: 8),
                                  SecondaryButton(label: 'Assign Bus', onPressed: () => _showAssignBusDialog(ic), small: true),
                                  const SizedBox(width: 8),
                                  DangerButton(
                                    label: ic.status == 'Active' ? 'Block' : 'Activate',
                                    onPressed: () => _showDeactivateConfirmation(ic),
                                    small: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((i) => DropdownMenuItem(
            value: i,
            child: Text(
              i == 'All' ? '$label: All' : i,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted),
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _showAddInchargeDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String bus = 'SB-04';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Bus In-charge', style: TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: bus,
                  decoration: const InputDecoration(labelText: 'Assigned Bus'),
                  items: ['SB-04', 'SB-12', 'SB-09', 'SB-02', 'SB-17', 'None']
                      .map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                  onChanged: (val) => setS(() => bus = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bus In-charge added successfully (Mock) ✓'), behavior: SnackBarBehavior.floating),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditInchargeDialog(BusIncharge ic) {
    final nameCtrl = TextEditingController(text: ic.name);
    final emailCtrl = TextEditingController(text: ic.email);
    final phoneCtrl = TextEditingController(text: ic.phone);
    String status = ic.status;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Edit ${ic.name}', style: const TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ['Active', 'Inactive']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setS(() => status = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Staff details updated successfully (Mock) ✓'), behavior: SnackBarBehavior.floating),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignBusDialog(BusIncharge ic) {
    String selectedBus = ic.assignedBusId.isEmpty ? 'None' : ic.assignedBusId;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Assign Bus to ${ic.name}', style: const TextStyle(fontWeight: FontWeight.w800)),
          content: DropdownButtonFormField<String>(
            value: selectedBus,
            decoration: const InputDecoration(labelText: 'Bus'),
            items: ['SB-04', 'SB-12', 'SB-09', 'SB-02', 'SB-17', 'None']
                .map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
            onChanged: (val) => setS(() => selectedBus = val!),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Assigned bus $selectedBus to ${ic.name} (Mock) ✓'), behavior: SnackBarBehavior.floating),
                );
                Navigator.pop(context);
              },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeactivateConfirmation(BusIncharge ic) {
    final toActivate = ic.status == 'Inactive';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(toActivate ? 'Activate Staff' : 'Deactivate Staff', style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(toActivate
            ? 'Are you sure you want to activate ${ic.name}?'
            : 'Are you sure you want to deactivate ${ic.name}? They will not be able to log in.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${ic.name} status updated successfully (Mock) ✓'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: toActivate ? AppColors.success : AppColors.danger),
            child: Text(toActivate ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );
  }
}
