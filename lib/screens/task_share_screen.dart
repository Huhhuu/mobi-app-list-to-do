import 'package:flutter/material.dart';

class TaskShareScreen extends StatefulWidget {
  const TaskShareScreen({super.key});

  @override
  State<TaskShareScreen> createState() => _TaskShareScreenState();
}

class _TaskShareScreenState extends State<TaskShareScreen> {
  final TextEditingController _linkController = TextEditingController(
    text: 'https://taskplanner.app/share/task-abc123',
  );
  final TextEditingController _gmailController = TextEditingController();

  final List<Map<String, dynamic>> _receivers = <Map<String, dynamic>>[
    <String, dynamic>{
      'name': 'Me',
      'group': 'Nguoi than',
      'gmail': 'me.family@gmail.com',
      'selected': true,
    },
    <String, dynamic>{
      'name': 'Anh Hai',
      'group': 'Nguoi than',
      'gmail': 'anhhai.family@gmail.com',
      'selected': false,
    },
    <String, dynamic>{
      'name': 'Lan',
      'group': 'Dong nghiep',
      'gmail': 'lan.work@gmail.com',
      'selected': true,
    },
    <String, dynamic>{
      'name': 'Khoa',
      'group': 'Dong nghiep',
      'gmail': 'khoa.work@gmail.com',
      'selected': false,
    },
    <String, dynamic>{
      'name': 'Minh',
      'group': 'Ban be',
      'gmail': 'minh.friend@gmail.com',
      'selected': false,
    },
  ];

  String _groupFilter = 'Tat ca';

  void _addReceiver() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController gmailController = TextEditingController();
    String group = 'Nguoi than';

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder:
              (
                BuildContext context,
                void Function(void Function()) setDialogState,
              ) {
                return AlertDialog(
                  title: const Text('Them nguoi nhan'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Ten nguoi nhan',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: gmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Gmail',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: group,
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem(
                            value: 'Nguoi than',
                            child: Text('Nguoi than'),
                          ),
                          DropdownMenuItem(
                            value: 'Dong nghiep',
                            child: Text('Dong nghiep'),
                          ),
                          DropdownMenuItem(
                            value: 'Ban be',
                            child: Text('Ban be'),
                          ),
                        ],
                        onChanged: (String? value) {
                          if (value == null) {
                            return;
                          }
                          setDialogState(() {
                            group = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Nhom',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Huy'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final String name = nameController.text.trim();
                        final String gmail = gmailController.text.trim();
                        if (name.isEmpty || !gmail.contains('@gmail.com')) {
                          return;
                        }
                        setState(() {
                          _receivers.add(<String, dynamic>{
                            'name': name,
                            'group': group,
                            'gmail': gmail,
                            'selected': true,
                          });
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text('Them'),
                    ),
                  ],
                );
              },
        );
      },
    ).then((_) {
      nameController.dispose();
      gmailController.dispose();
    });
  }

  @override
  void dispose() {
    _linkController.dispose();
    _gmailController.dispose();
    super.dispose();
  }

  void _copyLink() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Da sao chep link chia se cong viec (mock UI).'),
      ),
    );
  }

  void _shareByLink() {
    final int selectedCount = _receivers
        .where((Map<String, dynamic> item) => item['selected'] == true)
        .length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Da gui link chia se cho $selectedCount nguoi (mock UI).',
        ),
      ),
    );
  }

  void _shareByGmail() {
    final String email = _gmailController.text.trim();
    if (email.isEmpty || !email.contains('@gmail.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long nhap dung dia chi Gmail.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Da chia se cong viec qua Gmail: $email (mock UI).'),
      ),
    );
    _gmailController.clear();
  }

  List<Map<String, dynamic>> _filteredReceivers() {
    if (_groupFilter == 'Tat ca') {
      return _receivers;
    }

    return _receivers
        .where((Map<String, dynamic> item) => item['group'] == _groupFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> visibleReceivers = _filteredReceivers();

    return Scaffold(
      appBar: AppBar(title: const Text('Chia se cong viec')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Chia se bang link',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _linkController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Link chia se cong viec',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: _copyLink,
                        icon: const Icon(Icons.copy_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _shareByLink,
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Gui link chia se'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Chia se qua Gmail',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _gmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Nhap Gmail nguoi nhan',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _shareByGmail,
                      icon: const Icon(Icons.alternate_email_rounded),
                      label: const Text('Chia se qua Gmail'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Nguoi nhan: nguoi than, dong nghiep, ban be',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _addReceiver,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Them nguoi nhan'),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <String>['Tat ca', 'Nguoi than', 'Dong nghiep', 'Ban be']
                .map(
                  (String group) => ChoiceChip(
                    label: Text(group),
                    selected: _groupFilter == group,
                    onSelected: (_) {
                      setState(() {
                        _groupFilter = group;
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          ...List<Widget>.generate(visibleReceivers.length, (int index) {
            final Map<String, dynamic> person = visibleReceivers[index];
            final int originalIndex = _receivers.indexOf(person);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: CheckboxListTile(
                value: person['selected'] as bool,
                onChanged: (bool? value) {
                  setState(() {
                    _receivers[originalIndex]['selected'] = value ?? false;
                  });
                },
                title: Text(person['name'] as String),
                subtitle: Text('${person['group']} | ${person['gmail']}'),
                secondary: const Icon(Icons.person_add_alt_rounded),
                controlAffinity: ListTileControlAffinity.trailing,
              ),
            );
          }),
        ],
      ),
    );
  }
}
