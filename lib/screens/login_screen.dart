import 'package:flutter/material.dart';

import '../core/app_router.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void _goToHome() {
    Navigator.of(context).pushReplacementNamed(AppRouter.home);
  }

  Future<void> _loginByMail() async {
    final TextEditingController mailController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dang nhap bang Mail'),
          content: TextField(
            controller: mailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Nhap dia chi mail',
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
                final String email = mailController.text.trim();
                if (!email.contains('@')) {
                  return;
                }
                Navigator.of(context).pop();
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('Dang nhap bang Mail: $email (mock UI).'),
                  ),
                );
                _goToHome();
              },
              child: const Text('Dang nhap'),
            ),
          ],
        );
      },
    );

    mailController.dispose();
  }

  void _loginByProvider(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dang nhap bang $provider (mock UI).')),
    );
    _goToHome();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFFEAF4FF),
              Color(0xFFF3F8EC),
              Color(0xFFFFF2E8),
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -60,
              left: -20,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D3B66).withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              right: -10,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  color: const Color(0xFFF77F00).withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: <Color>[
                                  Color(0xFF0D3B66),
                                  Color(0xFF1D5D96),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                  color: Color(0x330D3B66),
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.checklist_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Task Planner',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.2,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: colorScheme.primary.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'DANG NHAP TAI KHOAN',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 16),
                              SocialLoginButton(
                                label: 'Dang nhap voi Google',
                                icon: Icons.g_mobiledata_rounded,
                                backgroundColor: const Color(0xFFDB4437),
                                onPressed: () => _loginByProvider('Google'),
                              ),
                              const SizedBox(height: 10),
                              SocialLoginButton(
                                label: 'Dang nhap voi Mail',
                                icon: Icons.mail_outline_rounded,
                                backgroundColor: const Color(0xFF0D3B66),
                                onPressed: _loginByMail,
                              ),
                              const SizedBox(height: 10),
                              SocialLoginButton(
                                label: 'Dang nhap voi Facebook',
                                icon: Icons.facebook_rounded,
                                backgroundColor: const Color(0xFF1877F2),
                                onPressed: () => _loginByProvider('Facebook'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
