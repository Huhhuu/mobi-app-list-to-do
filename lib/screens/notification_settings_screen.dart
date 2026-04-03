import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _dailySummary = true;
  bool _beforeDeadline = true;
  bool _sound = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cai dat thong bao')),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            value: _dailySummary,
            onChanged: (bool value) {
              setState(() {
                _dailySummary = value;
              });
            },
            title: const Text('Thong bao tong ket moi ngay'),
          ),
          SwitchListTile(
            value: _beforeDeadline,
            onChanged: (bool value) {
              setState(() {
                _beforeDeadline = value;
              });
            },
            title: const Text('Nhac truoc han 30 phut'),
          ),
          SwitchListTile(
            value: _sound,
            onChanged: (bool value) {
              setState(() {
                _sound = value;
              });
            },
            title: const Text('Am thanh thong bao'),
          ),
        ],
      ),
    );
  }
}
