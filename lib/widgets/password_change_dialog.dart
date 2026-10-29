import 'package:flutter/material.dart';

import '../services/account_api_service.dart';

Future<void> showPasswordChangeDialog(BuildContext context) async {
  final current = TextEditingController();
  final next = TextEditingController();
  final confirm = TextEditingController();
  var saving = false;
  var error = '';
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: const Text('Change password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: current,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            TextField(
              controller: next,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password (8+ characters)'),
            ),
            TextField(
              controller: confirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm new password'),
            ),
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: saving ? null : () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: saving
                ? null
                : () async {
                    if (next.text.length < 8) {
                      setState(() => error = 'Use at least 8 characters.');
                      return;
                    }
                    if (next.text != confirm.text) {
                      setState(() => error = 'The new passwords do not match.');
                      return;
                    }
                    setState(() {
                      saving = true;
                      error = '';
                    });
                    final response = await AccountApiService.changePassword(
                      currentPassword: current.text,
                      newPassword: next.text,
                    );
                    if (!dialogContext.mounted) return;
                    if (response == null) {
                      setState(() {
                        saving = false;
                        error = 'Could not update password. Check your current password and connection.';
                      });
                      return;
                    }
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password changed.')),
                    );
                  },
            child: Text(saving ? 'Saving…' : 'Update password'),
          ),
        ],
      ),
    ),
  );
  current.dispose();
  next.dispose();
  confirm.dispose();
}
