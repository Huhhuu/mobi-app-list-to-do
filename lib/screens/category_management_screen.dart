import 'package:flutter/material.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final List<String> _categories = <String>[
    'Cong viec',
    'Hoc tap',
    'Ca nhan',
    'Gia dinh',
    'Suc khoe',
  ];
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showCategoryDialog({int? index}) {
    final bool isEditing = index != null;
    _controller.text = isEditing ? _categories[index] : '';

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Chinh sua nhom' : 'Them nhom moi'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Nhap ten nhom cong viec',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Huy'),
            ),
            ElevatedButton(
              onPressed: () {
                final String value = _controller.text.trim();
                if (value.isEmpty) {
                  return;
                }
                setState(() {
                  if (isEditing) {
                    _categories[index] = value;
                  } else {
                    _categories.add(value);
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Luu' : 'Them'),
            ),
          ],
        );
      },
    );
  }

  void _removeCategory(int index) {
    final String name = _categories[index];
    setState(() {
      _categories.removeAt(index);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Da xoa nhom "$name".')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quan ly nhom cong viec')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Them nhom'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.folder_copy_rounded, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tong so nhom hien co: ${_categories.length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories
                .map(
                  (String item) => ActionChip(
                    avatar: const Icon(Icons.label_outline_rounded, size: 18),
                    label: Text(item),
                    onPressed: () {
                      final int index = _categories.indexOf(item);
                      _showCategoryDialog(index: index);
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          ...List<Widget>.generate(_categories.length, (int index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.category_outlined),
                title: Text(_categories[index]),
                subtitle: const Text('Nhan de chinh sua nhanh nhom cong viec'),
                onTap: () => _showCategoryDialog(index: index),
                trailing: IconButton(
                  onPressed: () => _removeCategory(index),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
