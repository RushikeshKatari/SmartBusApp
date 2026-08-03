import 'package:flutter/material.dart';
import '../../mock/mock_data.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_widgets.dart';

class AdminNotifications extends StatefulWidget {
  const AdminNotifications({super.key});

  @override
  State<AdminNotifications> createState() => _AdminNotificationsState();
}

class _AdminNotificationsState extends State<AdminNotifications> {
  final _titleCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  String _selectedAudience = 'All Students';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _sendNotification() {
    if (_titleCtrl.text.isEmpty || _msgCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out both title and message!'), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification sent to $_selectedAudience successfully ✓'), behavior: SnackBarBehavior.floating),
    );

    setState(() {
      _titleCtrl.clear();
      _msgCtrl.clear();
      _selectedAudience = 'All Students';
    });
  }

  @override
  Widget build(BuildContext context) {
    final audienceOptions = ['All Students', 'Specific Bus (SB-04)', 'Specific Route', 'Bus Incharges'];
    final sentList = MockData.sentNotifications;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 750;
            return wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildComposeForm(audienceOptions)),
                      const SizedBox(width: 20),
                      Expanded(child: _buildSentHistory(sentList)),
                    ],
                  )
                : Column(
                    children: [
                      _buildComposeForm(audienceOptions),
                      const SizedBox(height: 24),
                      _buildSentHistory(sentList),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildComposeForm(List<String> audienceOptions) {
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
          const AdminSectionHeader(title: 'Compose Notification'),
          const SizedBox(height: 20),
          TextField(
            controller: _titleCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Notification Title',
              prefixIcon: const Icon(Icons.title_rounded, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _msgCtrl,
            onChanged: (_) => setState(() {}),
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Message Body',
              alignLabelWithHint: true,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 56),
                child: Icon(Icons.message_rounded, color: AppColors.primary),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Target Audience', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: audienceOptions.map((aud) {
              final isSel = _selectedAudience == aud;
              return ChoiceChip(
                label: Text(aud),
                selected: isSel,
                onSelected: (val) {
                  if (val) setState(() => _selectedAudience = aud);
                },
                selectedColor: AppColors.primary.withOpacity(.15),
                labelStyle: TextStyle(
                  color: isSel ? AppColors.primary : AppColors.muted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          const Text('Live Preview', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 8),
          _buildLivePreviewCard(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Broadcast Notification',
              icon: Icons.send_rounded,
              onPressed: _sendNotification,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivePreviewCard() {
    final title = _titleCtrl.text.isEmpty ? 'Notification Title Placeholder' : _titleCtrl.text;
    final msg = _msgCtrl.text.isEmpty ? 'The content of your notification announcement will appear here in real-time as you type...' : _msgCtrl.text;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                      child: Text(_selectedAudience.split(' ').first.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(msg, style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentHistory(List<AdminNotificationItem> list) {
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
          const AdminSectionHeader(title: 'Notification History'),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 24, color: Color(0xFFF1F5F9)),
            itemBuilder: (_, index) {
              final item = list[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.notifications_active_rounded, color: AppColors.muted, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(item.message, style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.3)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(item.sentAt, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                            const Spacer(),
                            const Icon(Icons.people_alt_rounded, size: 12, color: AppColors.muted),
                            const SizedBox(width: 4),
                            Text('Reached ${item.reachCount}', style: const TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
