import 'package:flutter/material.dart';
import '../../mock/mock_data.dart';
import '../../models/app_models.dart';
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

  List<AdminStudent> get _filteredStudents {
    return MockData.students.where((student) {
      final matchesQuery = student.name.toLowerCase().contains(_query.toLowerCase()) ||
          student.rollNumber.toLowerCase().contains(_query.toLowerCase()) ||
          student.department.toLowerCase().contains(_query.toLowerCase());
      final matchesDept = _selectedDept == 'All' || student.department == _selectedDept;
      final matchesYear = _selectedYear == 'All' || student.year == _selectedYear;
      final matchesBus = _selectedBus == 'All' || student.assignedBus == _selectedBus;
      final matchesStatus = _selectedStatus == 'All' || student.status == _selectedStatus;
      return matchesQuery && matchesDept && matchesYear && matchesBus && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final students = _filteredStudents;
    final departments = ['All', 'Computer Science', 'Electronics', 'Mechanical', 'Civil', 'Electrical', 'Information Tech'];
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
                      const Text(
                        'Student Management',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Manage, filter, and assign buses to ${MockData.students.length} students',
                        style: const TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                PrimaryButton(
                  label: 'Add Student',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: () => _showAddStudentDialog(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Bar
            ModernSearchBar(
              hint: 'Search students by name, roll number, or department...',
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _query = val),
            ),
            const SizedBox(height: 16),

            // Filter Chips Label
            const Text('Filters', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),

            // Scrollable filter section
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterDropdown('Dept', _selectedDept, departments, (val) {
                    if (val != null) setState(() => _selectedDept = val);
                  }),
                  const SizedBox(width: 8),
                  _buildFilterDropdown('Year', _selectedYear, years, (val) {
                    if (val != null) setState(() => _selectedYear = val);
                  }),
                  const SizedBox(width: 8),
                  _buildFilterDropdown('Bus', _selectedBus, buses, (val) {
                    if (val != null) setState(() => _selectedBus = val);
                  }),
                  const SizedBox(width: 8),
                  _buildFilterDropdown('Status', _selectedStatus, statuses, (val) {
                    if (val != null) setState(() => _selectedStatus = val);
                  }),
                  if (_selectedDept != 'All' || _selectedYear != 'All' || _selectedBus != 'All' || _selectedStatus != 'All') ...[
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedDept = 'All';
                          _selectedYear = 'All';
                          _selectedBus = 'All';
                          _selectedStatus = 'All';
                          _searchCtrl.clear();
                          _query = '';
                        });
                      },
                      icon: const Icon(Icons.clear_all_rounded, size: 16, color: AppColors.danger),
                      label: const Text('Reset All', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Data Table / Responsive cards depending on size
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
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 24,
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                        columns: const [
                          DataColumn(label: Text('Student', style: TextStyle(fontWeight: FontWeight.w800))),
                          DataColumn(label: Text('Roll Number', style: TextStyle(fontWeight: FontWeight.w800))),
                          DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.w800))),
                          DataColumn(label: Text('Assigned Bus', style: TextStyle(fontWeight: FontWeight.w800))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w800))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w800))),
                        ],
                        rows: students.map((st) => DataRow(
                          cells: [
                            DataCell(Row(
                              children: [
                                AdminAvatar(initials: st.initials, color: st.avatarColor, radius: 16),
                                const SizedBox(width: 12),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(st.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                    Text(st.year, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                                  ],
                                ),
                              ],
                            )),
                            DataCell(Text(st.rollNumber, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                            DataCell(Text(st.department, style: const TextStyle(fontSize: 13))),
                            DataCell(Text(st.assignedBus, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13))),
                            DataCell(StatusBadge(label: st.status)),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                                  onPressed: () => _showStudentDetails(st),
                                  tooltip: 'View',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.success),
                                  onPressed: () => _showEditStudentDialog(st),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.directions_bus_filled_outlined, size: 18, color: Color(0xFF7C3AED)),
                                  onPressed: () => _showAssignBusDialog(st),
                                  tooltip: 'Assign Bus',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                                  onPressed: () => _showDeleteConfirmation(st),
                                  tooltip: 'Delete',
                                ),
                              ],
                            )),
                          ],
                        )).toList(),
                      ),
                    );
                  } else {
                    // Mobile View Cards
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: students.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (_, idx) {
                        final st = students[idx];
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AdminAvatar(initials: st.initials, color: st.avatarColor, radius: 18),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(st.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                        Text('${st.rollNumber} · ${st.year}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  StatusBadge(label: st.status),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Dept: ${st.department}', style: const TextStyle(fontSize: 12)),
                                  Text('Bus: ${st.assignedBus}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SecondaryButton(label: 'View', onPressed: () => _showStudentDetails(st), small: true),
                                  const SizedBox(width: 6),
                                  SecondaryButton(label: 'Edit', onPressed: () => _showEditStudentDialog(st), small: true),
                                  const SizedBox(width: 6),
                                  SecondaryButton(label: 'Assign', onPressed: () => _showAssignBusDialog(st), small: true),
                                  const SizedBox(width: 6),
                                  DangerButton(label: 'Delete', onPressed: () => _showDeleteConfirmation(st), small: true),
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

  void _showStudentDetails(AdminStudent student) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Student Details', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: AdminAvatar(initials: student.initials, color: student.avatarColor, radius: 36),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(student.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ),
            const SizedBox(height: 20),
            _dialogDetailRow('Roll Number', student.rollNumber),
            _dialogDetailRow('Department', student.department),
            _dialogDetailRow('Year', student.year),
            _dialogDetailRow('Assigned Bus', student.assignedBus),
            _dialogDetailRow('Phone', student.phone),
            _dialogDetailRow('Email', student.email),
            _dialogDetailRow('Status', student.status),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _dialogDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }

  void _showAddStudentDialog() {
    final nameCtrl = TextEditingController();
    final rollCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String dept = 'Computer Science';
    String year = '1st Year';
    String bus = 'SB-04';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Student', style: TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
                TextField(controller: rollCtrl, decoration: const InputDecoration(labelText: 'Roll Number')),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: dept,
                  decoration: const InputDecoration(labelText: 'Department'),
                  items: ['Computer Science', 'Electronics', 'Mechanical', 'Civil', 'Electrical', 'Information Tech']
                      .map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) => setS(() => dept = val!),
                ),
                DropdownButtonFormField<String>(
                  value: year,
                  decoration: const InputDecoration(labelText: 'Year'),
                  items: ['1st Year', '2nd Year', '3rd Year', '4th Year']
                      .map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                  onChanged: (val) => setS(() => year = val!),
                ),
                DropdownButtonFormField<String>(
                  value: bus,
                  decoration: const InputDecoration(labelText: 'Assign Bus'),
                  items: ['SB-04', 'SB-12', 'SB-09', 'SB-02', 'SB-17']
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
                  const SnackBar(content: Text('Student added successfully (Mock) ✓'), behavior: SnackBarBehavior.floating),
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

  void _showEditStudentDialog(AdminStudent student) {
    final nameCtrl = TextEditingController(text: student.name);
    final rollCtrl = TextEditingController(text: student.rollNumber);
    final phoneCtrl = TextEditingController(text: student.phone);
    final emailCtrl = TextEditingController(text: student.email);
    String dept = student.department;
    String year = student.year;
    String status = student.status;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Edit ${student.name}', style: const TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
                TextField(controller: rollCtrl, decoration: const InputDecoration(labelText: 'Roll Number')),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: dept,
                  decoration: const InputDecoration(labelText: 'Department'),
                  items: ['Computer Science', 'Electronics', 'Mechanical', 'Civil', 'Electrical', 'Information Tech']
                      .map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) => setS(() => dept = val!),
                ),
                DropdownButtonFormField<String>(
                  value: year,
                  decoration: const InputDecoration(labelText: 'Year'),
                  items: ['1st Year', '2nd Year', '3rd Year', '4th Year']
                      .map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                  onChanged: (val) => setS(() => year = val!),
                ),
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
                  const SnackBar(content: Text('Student updated successfully (Mock) ✓'), behavior: SnackBarBehavior.floating),
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

  void _showAssignBusDialog(AdminStudent student) {
    String selectedBus = student.assignedBus;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Assign Bus to ${student.name}', style: const TextStyle(fontWeight: FontWeight.w800)),
          content: DropdownButtonFormField<String>(
            value: selectedBus,
            decoration: const InputDecoration(labelText: 'Bus Route'),
            items: ['SB-04', 'SB-12', 'SB-09', 'SB-02', 'SB-17', 'Unassigned']
                .map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
            onChanged: (val) => setS(() => selectedBus = val!),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Assigned $selectedBus to ${student.name} (Mock) ✓'), behavior: SnackBarBehavior.floating),
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

  void _showDeleteConfirmation(AdminStudent student) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Student', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to delete ${student.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${student.name} deleted (Mock) ✓'), behavior: SnackBarBehavior.floating),
              );
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
