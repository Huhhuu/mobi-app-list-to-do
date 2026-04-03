import 'package:flutter/material.dart';

import 'account_edit_screen.dart';
import 'change_password_screen.dart';
import 'notification_settings_screen.dart';

class AccountManagementScreen extends StatelessWidget {
  const AccountManagementScreen({super.key});

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xoa tai khoan'),
          content: const Text(
            'Ban chac chan muon xoa tai khoan? Thao tac nay khong the hoan tac.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Huy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Da gui yeu cau xoa tai khoan (mock UI).'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD62828),
              ),
              child: const Text('Xoa tai khoan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quan ly tai khoan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  const CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.person_rounded, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Nguyen Van A',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text('nguyenvana@email.com'),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              const AccountEditScreen(),
                        ),
                      );
                    },
                    child: const Text('Chinh sua'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline_rounded),
              title: const Text('Doi mat khau'),
              subtitle: const Text('Cap nhat mat khau va xac nhan ma mail'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        const ChangePasswordScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Cai dat thong bao'),
              subtitle: const Text('Bat/tat nhac nho va thong bao tong hop'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.storage_rounded),
              title: Text('Sao luu va dong bo du lieu'),
              subtitle: Text('Lan dong bo cuoi: 10 phut truoc'),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFFFFF1F1),
            child: ListTile(
              leading: const Icon(
                Icons.delete_forever_rounded,
                color: Color(0xFFD62828),
              ),
              title: const Text(
                'Xoa tai khoan',
                style: TextStyle(color: Color(0xFFD62828)),
              ),
              subtitle: const Text(
                'Xoa vinh vien tai khoan va du lieu lien quan',
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFD62828),
              ),
              onTap: () => _confirmDelete(context),
            ),
          ),
        ],
      ),
    );
  }
}
