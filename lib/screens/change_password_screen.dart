import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _mailController = TextEditingController(
    text: 'nguyenvana@email.com',
  );
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _codeSent = false;

  @override
  void dispose() {
    _mailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _sendMailCode() {
    final String email = _mailController.text.trim();
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long nhap email hop le de nhan ma.')),
      );
      return;
    }

    setState(() {
      _codeSent = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Da gui ma xac nhan den $email (mock UI).')),
    );
  }

  void _savePassword() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Da cap nhat mat khau (mock UI).')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doi mat khau')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: _mailController,
              readOnly: true,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email nhan ma',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _sendMailCode,
              icon: const Icon(Icons.mark_email_read_rounded),
              label: Text(_codeSent ? 'Gui lai ma mail' : 'Nhan ma mail'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ma xac nhan tu mail',
                border: OutlineInputBorder(),
              ),
              validator: (String? value) {
                if (!_codeSent) {
                  return 'Hay nhan ma mail truoc';
                }
                if ((value ?? '').trim().length < 4) {
                  return 'Ma xac nhan khong hop le';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mat khau moi',
                border: OutlineInputBorder(),
              ),
              validator: (String? value) {
                if (value == null || value.length < 6) {
                  return 'Mat khau moi toi thieu 6 ky tu';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Xac nhan mat khau moi',
                border: OutlineInputBorder(),
              ),
              validator: (String? value) {
                if (value != _newPasswordController.text) {
                  return 'Xac nhan mat khau khong khop';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _savePassword,
              child: const Text('Cap nhat mat khau'),
            ),
          ],
        ),
      ),
    );
  }
}
