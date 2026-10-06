import 'dart:typed_data';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_models.dart';
import '../../providers/smart_bus_provider.dart';
import '../../services/hod_api_service.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';

class HodPortal extends StatefulWidget {
  const HodPortal({super.key});
  @override
  State<HodPortal> createState() => _HodPortalState();
}

class _HodPortalState extends State<HodPortal> {
  static const _years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
  int _selected = 0;
  List<Map<String, dynamic>> _emergencyReports = [];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 760;
    final content = _selected == 0
        ? const _AcademicDashboard()
        : _selected == 5
            ? _EmergencyApprovalsPage(
                reports: _emergencyReports, onRefresh: _loadEmergencyReports)
            : _YearAttendancePage(
                year: _years[_selected - 1], onAddSection: _showAddSection);
    final title = _selected == 0
        ? 'HOD Dashboard'
        : _selected == 5
            ? 'Emergency Approvals'
            : '${_years[_selected - 1]} Attendance';
    return Scaffold(
      body: Row(children: [
        if (isDesktop)
          _HodSidebar(
              selected: _selected,
              onSelect: (index) => setState(() => _selected = index)),
        Expanded(
            child: Column(children: [
          Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
            child: Row(children: [
              if (!isDesktop)
                IconButton(
                    icon: const Icon(Icons.menu_rounded),
                    onPressed: () => _showHodDrawer(context)),
              Text(title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800)),
              const Spacer(),
              IconButton(
                  onPressed: () =>
                      context.read<SmartBusProvider>().toggleTheme(),
                  icon: const Icon(Icons.dark_mode_outlined,
                      color: AppColors.muted)),
              const SizedBox(width: 10),
              const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF0F766E),
                  child: Text('HD',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800))),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
                tooltip: 'Logout',
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const SingleLoginScreen()),
                  (route) => false,
                ),
              ),
            ]),
          ),
          Expanded(child: content),
        ])),
      ]),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _selected,
              onDestinationSelected: (index) =>
                  setState(() => _selected = index),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: 'Overview'),
                NavigationDestination(
                    icon: Icon(Icons.looks_one_outlined),
                    selectedIcon: Icon(Icons.looks_one),
                    label: '1st'),
                NavigationDestination(
                    icon: Icon(Icons.looks_two_outlined),
                    selectedIcon: Icon(Icons.looks_two),
                    label: '2nd'),
                NavigationDestination(
                    icon: Icon(Icons.looks_3_outlined),
                    selectedIcon: Icon(Icons.looks_3),
                    label: '3rd'),
                NavigationDestination(
                    icon: Icon(Icons.looks_4_outlined),
                    selectedIcon: Icon(Icons.looks_4),
                    label: '4th'),
                NavigationDestination(
                    icon: Icon(Icons.emergency_outlined),
                    selectedIcon: Icon(Icons.emergency),
                    label: 'Emergency'),
              ],
            ),
    );
  }

  void _showHodDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Row(children: [
        _HodSidebar(
            selected: _selected,
            onSelect: (index) {
              setState(() => _selected = index);
              Navigator.pop(context);
            }),
        Expanded(
            child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.black54))),
      ]),
    );
  }

  Future<void> _loadEmergencyReports() async {
    final remoteReports = await HodApiService.fetchEmergencyReports();
    if (!mounted) return;
    if (remoteReports.isNotEmpty) {
      setState(() => _emergencyReports = remoteReports.cast<Map<String, dynamic>>());
    } else {
      final providerReports = context.read<SmartBusProvider>().hodReports;
      setState(() => _emergencyReports = providerReports.map((r) => {
            'id': r.id,
            'busNumber': r.busNumber,
            'busName': r.busName,
            'inchargeName': r.inchargeName,
            'reason': r.reason,
            'location': r.location,
            'attendanceApprovedAt': r.attendanceGiven ? 'Approved' : null,
            'permissionGrantedAt': r.permissionGiven ? 'Granted' : null,
            'students': r.students.map((s) => {
                  'studentName': s['name'] ?? 'Student',
                  'rollNumber': s['rollNumber'] ?? '',
                  'department': 'Computer Science',
                }).toList(),
          }).toList());
    }
  }

  Future<void> _showAddSection(String year) async {
    final specialization = TextEditingController();
    final section = TextEditingController();
    List<AcademicStudent> students = [];
    String? fileName;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
                title: Text('Add section · $year'),
                content: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: specialization,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: const InputDecoration(
                          labelText: 'Specialization',
                          hintText: 'e.g. Computer Science')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: section,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: const InputDecoration(
                          labelText: 'Section number', hintText: 'e.g. A')),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['xlsx'],
                          withData: true);
                      if (picked == null || picked.files.single.bytes == null) {
                        return;
                      }
                      final imported = _readRoster(picked.files.single.bytes!);
                      setDialogState(() {
                        students = imported;
                        fileName = picked.files.single.name;
                      });
                    },
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text('Upload Excel sheet'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      fileName == null
                          ? 'Excel columns required: Name, Roll No\nOptional: Attendance %'
                          : '$fileName · ${students.length} students imported',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 12)),
                ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: specialization.text.trim().isEmpty ||
                              section.text.trim().isEmpty ||
                              students.isEmpty
                          ? null
                          : () async {
                              final addedRemotely =
                                  await HodApiService.createAcademicSection(
                                academicYear: _years.indexOf(year) + 1,
                                specialization: specialization.text.trim(),
                                sectionNumber: section.text.trim(),
                                students: students
                                    .map((student) => {
                                          'name': student.name,
                                          'rollNumber': student.rollNumber,
                                          'attendancePercent':
                                              student.attendancePercent
                                        })
                                    .toList(),
                              );
                              if (!context.mounted) return;
                              context
                                  .read<SmartBusProvider>()
                                  .addAcademicSection(
                                      year: year,
                                      specialization:
                                          specialization.text.trim(),
                                      sectionNumber: section.text.trim(),
                                      students: students);
                              Navigator.pop(dialogContext);
                              if (!mounted) return;
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                      content: Text(addedRemotely
                                          ? 'Section and student roster added.'
                                          : 'Section added locally. It will sync after the HOD backend is available.')));
                            },
                      child: const Text('Add section')),
                ],
              )),
    );
    specialization.dispose();
    section.dispose();
  }

  List<AcademicStudent> _readRoster(Uint8List bytes) {
    final workbook = Excel.decodeBytes(bytes);
    if (workbook.tables.isEmpty) return [];
    final rows = workbook.tables.values.first.rows;
    if (rows.length < 2) return [];
    final headers = rows.first
        .map(_cellText)
        .map(
            (value) => value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''))
        .toList();
    final nameIndex = headers
        .indexWhere((value) => value == 'name' || value == 'studentname');
    final rollIndex = headers
        .indexWhere((value) => value == 'rollno' || value == 'rollnumber');
    final attendanceIndex = headers.indexWhere(
        (value) => value == 'attendance' || value == 'attendancepercent');
    if (nameIndex < 0 || rollIndex < 0) return [];
    return rows
        .skip(1)
        .map((row) {
          final name = nameIndex < row.length ? _cellText(row[nameIndex]) : '';
          final roll = rollIndex < row.length ? _cellText(row[rollIndex]) : '';
          final rawAttendance =
              attendanceIndex >= 0 && attendanceIndex < row.length
                  ? _cellText(row[attendanceIndex]).replaceAll('%', '')
                  : '';
          return AcademicStudent(
              name: name,
              rollNumber: roll,
              attendancePercent: double.tryParse(rawAttendance) ?? 0);
        })
        .where((student) =>
            student.name.isNotEmpty && student.rollNumber.isNotEmpty)
        .toList();
  }

  String _cellText(Data? cell) {
    final value = cell?.value;
    if (value == null) return '';
    final dynamic dynamicValue = value;
    return '${dynamicValue.value ?? dynamicValue}'.trim();
  }
}

class _HodSidebar extends StatelessWidget {
  const _HodSidebar({required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;
  static const labels = [
    'Overview',
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Emergency'
  ];
  static const icons = [
    Icons.dashboard_outlined,
    Icons.looks_one_outlined,
    Icons.looks_two_outlined,
    Icons.looks_3_outlined,
    Icons.looks_4_outlined,
    Icons.emergency_outlined,
  ];
  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFF123A36),
        child: SizedBox(
          width: 240,
          child: Column(children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: const Row(children: [
                _HodBrandIcon(),
                SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('HOD Portal',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  Text('Academic Office',
                      style: TextStyle(color: Colors.white38, fontSize: 11)),
                ]),
              ])),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Color(0xFF28534E))),
          const SizedBox(height: 8),
          Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: labels.length,
                  itemBuilder: (_, index) {
                    final isSelected = selected == index;
                    return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          onTap: () => onSelect(index),
                          selected: isSelected,
                          selectedTileColor:
                              const Color(0xFF2DD4BF).withValues(alpha: .16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          leading: Icon(icons[index],
                              size: 20,
                              color: isSelected
                                  ? const Color(0xFF5EEAD4)
                                  : const Color(0xFF94A3B8)),
                          title: Text(labels[index],
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF94A3B8),
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500)),
                        ));
                  })),
          const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(children: [
                CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF2DD4BF),
                    child: Text('HD',
                        style: TextStyle(
                            color: Color(0xFF123A36),
                            fontSize: 11,
                            fontWeight: FontWeight.w800))),
                SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Head of Department',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  Text('HOD access',
                      style: TextStyle(color: Colors.white38, fontSize: 10))
                ])
              ])),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            child: ListTile(
              onTap: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (_) => const SingleLoginScreen()),
                (route) => false,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.logout_rounded,
                  color: Color(0xFFF87171), size: 20),
              title: const Text('Logout',
                  style: TextStyle(
                      color: Color(0xFFF87171),
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              dense: true,
            ),
          ),
        ]),
      ),
    );
}

class _HodBrandIcon extends StatelessWidget {
  const _HodBrandIcon();
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
          color: const Color(0xFF2DD4BF),
          borderRadius: BorderRadius.circular(12)),
      child: const Icon(Icons.account_balance_rounded,
          color: Color(0xFF123A36), size: 20));
}

class _AcademicDashboard extends StatelessWidget {
  const _AcademicDashboard();
  static const years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
  @override
  Widget build(BuildContext context) =>
      Consumer<SmartBusProvider>(builder: (context, provider, _) {
        return ListView(padding: const EdgeInsets.all(24), children: [
          const Text('Academic attendance overview',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
              'Attendance across all years, sections, and specializations.',
              style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 22),
          _MetricCard(
              label: 'Overall attendance',
              value:
                  '${provider.overallAcademicAttendance.toStringAsFixed(1)}%',
              icon: Icons.percent_rounded,
              color: AppColors.primary),
          const SizedBox(height: 22),
          const Text('Attendance by year',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ...years.map((year) => Card(
              child: ListTile(
                  leading: CircleAvatar(child: Text(year.substring(0, 1))),
                  title: Text(year),
                  subtitle: Text(
                      '${provider.sectionsForYear(year).length} sections · ${provider.sectionsForYear(year).expand((section) => section.students).length} students'),
                  trailing: Text(
                      '${provider.attendanceForYear(year).toStringAsFixed(1)}%',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 17))))),
        ]);
      });
}

class _YearAttendancePage extends StatelessWidget {
  const _YearAttendancePage({required this.year, required this.onAddSection});
  final String year;
  final ValueChanged<String> onAddSection;
  @override
  Widget build(BuildContext context) =>
      Consumer<SmartBusProvider>(builder: (context, provider, _) {
        final sections = provider.sectionsForYear(year);
        return ListView(padding: const EdgeInsets.all(24), children: [
          Row(children: [
            Expanded(
                child: _MetricCard(
                    label: '$year attendance',
                    value:
                        '${provider.attendanceForYear(year).toStringAsFixed(1)}%',
                    icon: Icons.percent_rounded,
                    color: AppColors.success)),
            const SizedBox(width: 12),
            FilledButton.icon(
                onPressed: () => onAddSection(year),
                icon: const Icon(Icons.add),
                label: const Text('Add section'))
          ]),
          const SizedBox(height: 24),
          Text('$year sections',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (sections.isEmpty)
            const Padding(
                padding: EdgeInsets.all(36),
                child: Center(
                    child: Text(
                        'No sections yet. Add a section and upload its roster.'))),
          ...sections.map((section) => Card(
              child: ExpansionTile(
                  title: Text(
                      '${section.specialization} · Section ${section.sectionNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${section.students.length} students'),
                  trailing: Text(
                      '${section.attendancePercent.toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  children: section.students
                      .map((student) => ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(student.name),
                          subtitle: Text(student.rollNumber),
                          trailing: Text(
                              '${student.attendancePercent.toStringAsFixed(0)}%')))
                      .toList()))),
        ]);
      });
}

class _EmergencyApprovalsPage extends StatefulWidget {
  const _EmergencyApprovalsPage(
      {required this.reports, required this.onRefresh});
  final List<Map<String, dynamic>> reports;
  final Future<void> Function() onRefresh;

  @override
  State<_EmergencyApprovalsPage> createState() =>
      _EmergencyApprovalsPageState();
}

class _EmergencyApprovalsPageState extends State<_EmergencyApprovalsPage> {
  @override
  void initState() {
    super.initState();
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ListView(padding: const EdgeInsets.all(24), children: [
          const Text('Emergency report approvals',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
              'Review each forwarded transport attendance list. Approve attendance and grant emergency permission separately.',
              style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 20),
          if (widget.reports.isEmpty)
            const Padding(
                padding: EdgeInsets.all(36),
                child: Center(
                    child: Text(
                        'No emergency reports have been sent to HOD yet.'))),
          ...widget.reports.map((report) {
            final students = (report['students'] as List<dynamic>? ?? [])
                .cast<Map<String, dynamic>>();
            final attendanceApproved = report['attendanceApprovedAt'] != null;
            final permissionGranted = report['permissionGrantedAt'] != null;
            return Card(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.emergency_rounded,
                                color: AppColors.danger),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(
                                    '${report['busNumber'] ?? 'Bus'} · ${report['reason'] ?? 'Emergency'}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16)))
                          ]),
                          const SizedBox(height: 10),
                          Text(
                              '${report['busName'] ?? ''} · ${report['location'] ?? ''}'),
                          Text(
                              'Reported by ${report['inchargeName'] ?? 'Bus in-charge'}'),
                          const SizedBox(height: 10),
                          Text('Attendance list (${students.length} students)',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          ...students.map((student) => Text(
                              '${student['studentName'] ?? student['name'] ?? 'Student'} · ${student['rollNumber'] ?? ''}')),
                          const SizedBox(height: 14),
                          Wrap(spacing: 10, runSpacing: 8, children: [
                            FilledButton.icon(
                                onPressed: attendanceApproved
                                    ? null
                                    : () =>
                                        _apply(report['id'] as String, true),
                                icon: Icon(attendanceApproved
                                    ? Icons.check_circle
                                    : Icons.fact_check_rounded),
                                label: Text(attendanceApproved
                                    ? 'Attendance approved'
                                    : 'Approve attendance')),
                            OutlinedButton.icon(
                                onPressed: permissionGranted
                                    ? null
                                    : () =>
                                        _apply(report['id'] as String, false),
                                icon: Icon(permissionGranted
                                    ? Icons.check_circle
                                    : Icons.verified_user_outlined),
                                label: Text(permissionGranted
                                    ? 'Permission granted'
                                    : 'Give permission')),
                          ]),
                        ])));
          }),
        ]),
      );

  Future<void> _apply(String reportId, bool attendance) async {
    final provider = context.read<SmartBusProvider>();
    if (attendance) {
      provider.giveEmergencyAttendance(reportId);
    } else {
      provider.giveEmergencyPermission(reportId);
    }
    if (attendance) {
      await HodApiService.approveEmergencyAttendance(reportId);
    } else {
      await HodApiService.grantEmergencyPermission(reportId);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(attendance
            ? 'Attendance approved for emergency report.'
            : 'Emergency academic permission granted.')));
    await widget.onRefresh();
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
  final String label, value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            CircleAvatar(
                backgroundColor: color.withValues(alpha: .12),
                child: Icon(icon, color: color)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(color: AppColors.muted)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 25))
            ])
          ])));
}
