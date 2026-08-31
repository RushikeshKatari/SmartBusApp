import 'package:flutter/material.dart';
import '../../mock/mock_data.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_widgets.dart';

class AdminBuses extends StatefulWidget {
  const AdminBuses({super.key});

  @override
  State<AdminBuses> createState() => _AdminBusesState();
}

class _AdminBusesState extends State<AdminBuses> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    const buses = MockData.buses;

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
                        'Bus Management',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Manage your fleet of ${buses.length} buses',
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // Grid/List toggle
                IconButton(
                  icon: Icon(
                      _isGridView
                          ? Icons.view_list_rounded
                          : Icons.grid_view_rounded,
                      color: AppColors.primary),
                  onPressed: () => setState(() => _isGridView = !_isGridView),
                  tooltip: _isGridView
                      ? 'Switch to List View'
                      : 'Switch to Grid View',
                ),
                const SizedBox(width: 8),
                PrimaryButton(
                  label: 'Add Bus',
                  icon: Icons.add_rounded,
                  onPressed: () => _showAddBusDialog(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _isGridView
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount =
                          (constraints.maxWidth / 300).floor().clamp(1, 4);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: buses.length,
                        itemBuilder: (context, index) {
                          final bus = buses[index];
                          return AdminBusCard(
                            bus: bus,
                            onEdit: () => _showEditBusDialog(bus),
                            onAssign: () => _showAssignInchargeDialog(bus),
                            onDeactivate: () =>
                                _showDeactivateConfirmation(bus),
                          );
                        },
                      );
                    },
                  )
                : Container(
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
                      itemCount: buses.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final bus = buses[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(
                                Icons.directions_bus_filled_rounded,
                                color: AppColors.primary),
                          ),
                          title: Text('${bus.busNumber} · ${bus.busName}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text(
                              'Driver: ${bus.driverName} · Cap: ${bus.capacity} · Route: ${bus.assignedRoute}',
                              style: const TextStyle(fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StatusBadge(label: bus.status),
                              const SizedBox(width: 12),
                              PopupMenuButton<String>(
                                onSelected: (val) {
                                  if (val == 'edit') _showEditBusDialog(bus);
                                  if (val == 'assign') {
                                    _showAssignInchargeDialog(bus);
                                  }
                                  if (val == 'status') {
                                    _showDeactivateConfirmation(bus);
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                      value: 'edit', child: Text('Edit Bus')),
                                  const PopupMenuItem(
                                      value: 'assign',
                                      child: Text('Assign In-charge')),
                                  PopupMenuItem(
                                      value: 'status',
                                      child: Text(bus.status == 'Maintenance'
                                          ? 'Activate'
                                          : 'Deactivate')),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showAddBusDialog() {
    final numberCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final regCtrl = TextEditingController();
    final capacityCtrl = TextEditingController();
    final driverNameCtrl = TextEditingController();
    final driverPhoneCtrl = TextEditingController();
    String route = 'North Campus Morning Run';
    String incharge = 'Meera Singh';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Bus',
              style: TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: numberCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Bus Number (e.g. SB-04)')),
                TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Bus Name (e.g. Campus Express)')),
                TextField(
                    controller: regCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Registration Number')),
                TextField(
                    controller: capacityCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Capacity (Seats)'),
                    keyboardType: TextInputType.number),
                TextField(
                    controller: driverNameCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Driver Name')),
                TextField(
                    controller: driverPhoneCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Driver Phone')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: route,
                  decoration: const InputDecoration(labelText: 'Route'),
                  items: [
                    'North Campus Morning Run',
                    'West Gate Evening Loop',
                    'South Campus Loop',
                    'East Wing Route',
                    'North Hostel Run'
                  ]
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) => setS(() => route = val!),
                ),
                DropdownButtonFormField<String>(
                  initialValue: incharge,
                  decoration: const InputDecoration(labelText: 'Bus In-charge'),
                  items: [
                    'Meera Singh',
                    'Suresh Rao',
                    'Fatima Khan',
                    'Ranjit Verma',
                    'Lakshmi Pillai'
                  ]
                      .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                      .toList(),
                  onChanged: (val) => setS(() => incharge = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Bus created successfully (Mock) ✓'),
                      behavior: SnackBarBehavior.floating),
                );
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBusDialog(AdminBus bus) {
    final nameCtrl = TextEditingController(text: bus.busName);
    final regCtrl = TextEditingController(text: bus.registrationNumber);
    final capacityCtrl = TextEditingController(text: bus.capacity.toString());
    final driverNameCtrl = TextEditingController(text: bus.driverName);
    final driverPhoneCtrl = TextEditingController(text: bus.driverPhone);
    String status = bus.status;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Edit ${bus.busNumber}',
              style: const TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Bus Name')),
                TextField(
                    controller: regCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Registration Number')),
                TextField(
                    controller: capacityCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Capacity (Seats)'),
                    keyboardType: TextInputType.number),
                TextField(
                    controller: driverNameCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Driver Name')),
                TextField(
                    controller: driverPhoneCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Driver Phone')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ['Active', 'On Duty', 'Maintenance']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setS(() => status = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Bus updated successfully (Mock) ✓'),
                      behavior: SnackBarBehavior.floating),
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

  void _showAssignInchargeDialog(AdminBus bus) {
    String selectedIncharge = bus.assignedInchargeName;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Assign In-charge for ${bus.busNumber}',
              style: const TextStyle(fontWeight: FontWeight.w800)),
          content: DropdownButtonFormField<String>(
            initialValue: selectedIncharge,
            decoration: const InputDecoration(labelText: 'In-charge'),
            items: [
              'Meera Singh',
              'Suresh Rao',
              'Fatima Khan',
              'Ranjit Verma',
              'Lakshmi Pillai',
              'None'
            ].map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            onChanged: (val) => setS(() => selectedIncharge = val!),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Assigned $selectedIncharge to ${bus.busNumber} (Mock) ✓'),
                      behavior: SnackBarBehavior.floating),
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

  void _showDeactivateConfirmation(AdminBus bus) {
    final toActivate = bus.status == 'Maintenance';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(toActivate ? 'Activate Bus' : 'Deactivate Bus',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(toActivate
            ? 'Are you sure you want to activate ${bus.busNumber}?'
            : 'Are you sure you want to deactivate ${bus.busNumber}? It will be marked under maintenance.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${bus.busNumber} status changed successfully (Mock) ✓'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
                backgroundColor:
                    toActivate ? AppColors.success : AppColors.danger),
            child: Text(toActivate ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );
  }
}
