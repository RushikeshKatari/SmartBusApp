import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_models.dart';
import '../../providers/smart_bus_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_widgets.dart';

class AdminStudents extends StatefulWidget {
  const AdminStudents({super.key});

  @override
  State<AdminStudents> createState() => _AdminStudentsState();
}

class _AdminStudentsState extends State<AdminStudents> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedDept = 'All';
  String _selectedYear = 'All';
  String _selectedBus = 'All';
  String _selectedStatus = 'All';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SmartBusProvider>(context);
    final allStudents = provider.adminStudents;

    final filteredStudents = allStudents.where((student) {
      final matchesQuery =
          student.name.toLowerCase().contains(_query.toLowerCase()) ||
              student.rollNumber.toLowerCase().contains(_query.toLowerCase()) ||
              student.department.toLowerCase().contains(_query.toLowerCase());
      final matchesDept =
          _selectedDept == 'All' || student.department == _selectedDept;
      final matchesYear =
          _selectedYear == 'All' || student.year == _selectedYear;
      final matchesBus =
          _selectedBus == 'All' || student.assignedBus.contains(_selectedBus);
      final matchesStatus =
          _selectedStatus == 'All' || student.status == _selectedStatus;
      return matchesQuery &&
          matchesDept &&
          matchesYear &&
          matchesBus &&
          matchesStatus;
    }).toList();

    final departments = [
      'All',
      'Computer Science',
      'Electronics',
      'Mechanical',
      'Civil',
      'Electrical',
      'Information Tech'
    ];
    final years = ['All', '1st Year', '2nd Year', '3rd Year', '4th Year'];
    final buses = ['All', 'SB-04', 'SB-12', 'SB-09', 'SB-02', 'SB-17'];
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
                      const Text('Student Management',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800)),
                      Text(
                          'Manage, filter, and assign buses to ${allStudents.length} students',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 13)),
                    ],
                  ),
                ),
                PrimaryButton(
                  label: 'Add Student',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: () => _showAddStudentDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ModernSearchBar(
              hint: 'Search students by name, roll number, or department...',
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _query = val),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterDropdown('Dept', _selectedDept, departments,
                      (val) => setState(() => _selectedDept = val!)),
                  const SizedBox(width: 8),
                  _buildFilterDropdown('Year', _selectedYear, years,
                      (val) => setState(() => _selectedYear = val!)),
                  const SizedBox(width: 8),
                  _buildFilterDropdown('Bus', _selectedBus, buses,
                      (val) => setState(() => _selectedBus = val!)),
                  const SizedBox(width: 8),
                  _buildFilterDropdown('Status', _selectedStatus, statuses,
                      (val) => setState(() => _selectedStatus = val!)),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 700) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 24,
                        headingRowColor:
                            WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                        columns: const [
                          DataColumn(
                              label: Text('Student',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w800))),
                          DataColumn(
                              label: Text('Roll Number',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w800))),
                          DataColumn(
                              label: Text('Department',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w800))),
                          DataColumn(
                              label: Text('Assigned Bus',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w800))),
                          DataColumn(
                              label: Text('Status',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w800))),
                          DataColumn(
                              label: Text('Actions',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w800))),
                        ],
                        rows: filteredStudents
                            .map((st) => DataRow(
                                  cells: [
                                    DataCell(Row(
                                      children: [
                                        AdminAvatar(
                                            initials: st.initials,
                                            color: st.avatarColor,
                                            radius: 16),
                                        const SizedBox(width: 12),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(st.name,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 13)),
                                            Text(st.year,
                                                style: const TextStyle(
                                                    color: AppColors.muted,
                                                    fontSize: 11)),
                                          ],
                                        ),
                                      ],
                                    )),
                                    DataCell(Text(st.rollNumber,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13))),
                                    DataCell(Text(st.department,
                                        style: const TextStyle(fontSize: 13))),
                                    DataCell(Text(st.assignedBus,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                            fontSize: 13))),
                                    DataCell(StatusBadge(label: st.status)),
                                    DataCell(Row(
                                      children: [
                                        IconButton(
                                            icon: const Icon(
                                                Icons
                                                    .directions_bus_filled_outlined,
                                                size: 18,
                                                color: Color(0xFF7C3AED)),
                                            onPressed: () =>
                                                _showAssignBusDialog(
                                                    context, st),
                                            tooltip: 'Assign Bus'),
                                        IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 18,
                                                color: AppColors.danger),
                                            onPressed: () =>
                                                _showDeleteConfirmation(
                                                    context, st),
                                            tooltip: 'Delete'),
                                      ],
                                    )),
                                  ],
                                ))
                            .toList(),
                      ),
                    );
                  } else {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredStudents.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (_, idx) {
                        final st = filteredStudents[idx];
                        return ListTile(
                          leading: AdminAvatar(
                              initials: st.initials,
                              color: st.avatarColor,
                              radius: 18),
                          title: Text(st.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle:
                              Text('${st.rollNumber} · ${st.assignedBus}'),
                          trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: AppColors.danger),
                              onPressed: () =>
                                  _showDeleteConfirmation(context, st)),
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

  Widget _buildFilterDropdown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items
              .map((i) => DropdownMenuItem(
                  value: i,
                  child: Text(i == 'All' ? '$label: All' : i,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted))))
              .toList(),
        ),
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final rollCtrl = TextEditingController();
    String dept = 'Computer Science';
    String bus = 'Campus Express 04';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Student',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name')),
            TextField(
                controller: rollCtrl,
                decoration: const InputDecoration(labelText: 'Roll Number')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: bus,
              decoration: const InputDecoration(labelText: 'Assign Bus'),
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
              if (nameCtrl.text.isNotEmpty && rollCtrl.text.isNotEmpty) {
                final newStudent = AdminStudent(
                  id: 'STU-${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text,
                  rollNumber: rollCtrl.text,
                  department: dept,
                  year: '1st Year',
                  assignedBus: bus,
                  phone: '+91 99999 00000',
                  email:
                      '${nameCtrl.text.toLowerCase().replaceAll(' ', '')}@college.edu',
                  status: 'Active',
                  initials: nameCtrl.text.isNotEmpty
                      ? nameCtrl.text.substring(0, 1).toUpperCase()
                      : 'S',
                  avatarColor: AppColors.primary,
                );
                Provider.of<SmartBusProvider>(context, listen: false)
                    .addStudent(newStudent);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Student added successfully!')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAssignBusDialog(BuildContext context, AdminStudent student) {
    String selectedBus = student.assignedBus;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Assign Bus to ${student.name}'),
        content: DropdownButtonFormField<String>(
          initialValue: [
            'Campus Express 04',
            'City Connector 12',
            'Green Line 09'
          ].contains(selectedBus)
              ? selectedBus
              : 'Campus Express 04',
          decoration: const InputDecoration(labelText: 'Bus Route'),
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
                  .updateStudentBus(student.id, selectedBus);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Assigned $selectedBus to ${student.name}')));
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AdminStudent student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to remove ${student.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Provider.of<SmartBusProvider>(context, listen: false)
                  .removeStudent(student.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${student.name} removed')));
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
