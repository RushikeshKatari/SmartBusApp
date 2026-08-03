import 'package:flutter/material.dart';
import '../../mock/mock_data.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_widgets.dart';

class AdminAdvertisements extends StatefulWidget {
  const AdminAdvertisements({super.key});

  @override
  State<AdminAdvertisements> createState() => _AdminAdvertisementsState();
}

class _AdminAdvertisementsState extends State<AdminAdvertisements> {
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final ads = MockData.advertisements.where((ad) {
      if (_selectedStatus == 'All') return true;
      return ad.status == _selectedStatus;
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
                      const Text(
                        'Advertisement Management',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Manage in-app banner announcements and schedules',
                        style: const TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                PrimaryButton(
                  label: 'Upload Banner',
                  icon: Icons.upload_rounded,
                  onPressed: () => _showUploadAdDialog(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Filtering ChoiceChips
            Row(
              children: ['All', 'Active', 'Inactive', 'Scheduled'].map((status) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedStatus = status);
                    },
                    selectedColor: AppColors.primary.withOpacity(.15),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Gallery Grid Layout
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = (constraints.maxWidth / 300).floor().clamp(1, 3);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: ads.length,
                  itemBuilder: (context, index) {
                    final ad = ads[index];
                    return AdminAdCard(
                      ad: ad,
                      onEdit: () => _showEditAdDialog(ad),
                      onDelete: () => _showDeleteConfirmation(ad),
                      onToggle: () => _toggleAdStatus(ad),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadAdDialog() {
    final titleCtrl = TextEditingController();
    final subtitleCtrl = TextEditingController();
    final tagCtrl = TextEditingController();
    final dateFromCtrl = TextEditingController();
    final dateToCtrl = TextEditingController();
    Color selectedColor = AppColors.primary;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Upload Ad Banner', style: TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: tagCtrl, decoration: const InputDecoration(labelText: 'Tag / Category (e.g. SAFETY)')),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Banner Title')),
                TextField(controller: subtitleCtrl, decoration: const InputDecoration(labelText: 'Subtitle Description')),
                TextField(controller: dateFromCtrl, decoration: const InputDecoration(labelText: 'Scheduled From (e.g. 1 Aug 2026)')),
                TextField(controller: dateToCtrl, decoration: const InputDecoration(labelText: 'Scheduled To (e.g. 31 Aug 2026)')),
                const SizedBox(height: 16),
                const Text('Select Banner Background Color', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [AppColors.primary, const Color(0xFF7C3AED), AppColors.success, const Color(0xFF0891B2), const Color(0xFFEC4899)].map((color) {
                    final isSel = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setS(() => selectedColor = color),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSel ? Border.all(color: Colors.white, width: 3) : null,
                          boxShadow: isSel ? [const BoxShadow(color: Colors.black26, blurRadius: 4)] : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Banner upload saved successfully ✓'), behavior: SnackBarBehavior.floating),
                );
                Navigator.pop(context);
              },
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAdDialog(AdminAdvertisement ad) {
    final titleCtrl = TextEditingController(text: ad.title);
    final subtitleCtrl = TextEditingController(text: ad.subtitle);
    final tagCtrl = TextEditingController(text: ad.tag);
    final dateFromCtrl = TextEditingController(text: ad.scheduledFrom);
    final dateToCtrl = TextEditingController(text: ad.scheduledTo);
    Color selectedColor = ad.color;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Edit Ad Banner', style: TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: tagCtrl, decoration: const InputDecoration(labelText: 'Tag / Category')),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Banner Title')),
                TextField(controller: subtitleCtrl, decoration: const InputDecoration(labelText: 'Subtitle Description')),
                TextField(controller: dateFromCtrl, decoration: const InputDecoration(labelText: 'Scheduled From')),
                TextField(controller: dateToCtrl, decoration: const InputDecoration(labelText: 'Scheduled To')),
                const SizedBox(height: 16),
                const Text('Select Banner Background Color', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [AppColors.primary, const Color(0xFF7C3AED), AppColors.success, const Color(0xFF0891B2), const Color(0xFFEC4899)].map((color) {
                    final isSel = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setS(() => selectedColor = color),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSel ? Border.all(color: Colors.white, width: 3) : null,
                          boxShadow: isSel ? [const BoxShadow(color: Colors.black26, blurRadius: 4)] : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Banner edited successfully ✓'), behavior: SnackBarBehavior.floating),
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

  void _showDeleteConfirmation(AdminAdvertisement ad) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Banner', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to delete "${ad.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Banner deleted successfully ✓'), behavior: SnackBarBehavior.floating),
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

  void _toggleAdStatus(AdminAdvertisement ad) {
    final toActive = ad.status != 'Active';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Banner is now ${toActive ? 'Active' : 'Inactive'} ✓'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
