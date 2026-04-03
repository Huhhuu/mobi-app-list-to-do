import 'package:flutter/material.dart';

import '../core/app_router.dart';
import '../models/notification_models.dart';
import 'account_management_screen.dart';
import 'home_dashboard_screen.dart';
import 'notification_center_screen.dart';
import 'notification_settings_screen.dart';
import 'task_category_screen.dart';
import 'task_create_screen.dart';
import 'task_management_screen.dart';
import 'task_reminder_screen.dart';
import 'task_statistics_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  final GlobalKey<HomeDashboardScreenState> _homeDashboardKey =
      GlobalKey<HomeDashboardScreenState>();
  late final List<Widget> _screens;

  static const List<String> _titles = <String>[
    'Ngay cua toi',
    'Lich cong viec',
    'Home',
    'Phan loai cong viec',
    'Thong ke cong viec',
  ];

  @override
  void initState() {
    super.initState();
    _screens = <Widget>[
      const TaskManagementScreen(),
      const TaskReminderScreen(),
      HomeDashboardScreen(key: _homeDashboardKey),
      const TaskCategoryScreen(),
      const TaskStatisticsScreen(),
    ];
  }

  void _goToAccount() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const AccountManagementScreen(),
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushReplacementNamed(AppRouter.login);
  }

  void _openCreateTask() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const TaskCreateScreen(),
      ),
    );
  }

  Future<void> _openNotifications() async {
    final HomeDashboardScreenState? dashboardState =
        _homeDashboardKey.currentState;
    if (dashboardState == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => NotificationCenterScreen(
          taskNotifications: dashboardState.getTaskNotifications(),
          shareInvites: dashboardState.getShareInviteNotifications(),
          permissionRequests: dashboardState.getPermissionRequests(),
          currentUserName: dashboardState.currentUserName,
          onConfirmShare: (String listName) {
            dashboardState.confirmSharedList(listName);
          },
          onResolvePermissionRequest:
              (PermissionRequestData request, bool approve) {
                dashboardState.resolvePermissionRequest(request, approve);
              },
        ),
      ),
    );

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  bool _hasNotifications() {
    final HomeDashboardScreenState? dashboardState =
        _homeDashboardKey.currentState;
    if (dashboardState == null) {
      return true;
    }

    final List<TaskNotificationData> tasks = dashboardState
        .getTaskNotifications();
    final List<ShareInviteData> shareInvites = dashboardState
        .getShareInviteNotifications();
    final List<PermissionRequestData> permissionRequests = dashboardState
        .getPermissionRequests();

    return tasks.isNotEmpty ||
        shareInvites.any((ShareInviteData invite) => !invite.isConfirmed) ||
        permissionRequests.any(
          (PermissionRequestData request) => !request.isResolved,
        );
  }

  Widget _notificationMenuIcon(bool hasNotifications) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        const Icon(Icons.notifications_none_rounded),
        if (hasNotifications)
          const Positioned(
            right: -1,
            top: -1,
            child: SizedBox(
              width: 10,
              height: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _openNotificationSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const NotificationSettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasNotifications = _hasNotifications();

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: const Text('Nguyen Van A'),
              accountEmail: const Text('nguyenvana@email.com'),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person_rounded, size: 32),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('Quan ly tai khoan'),
              onTap: _goToAccount,
            ),
            ListTile(
              leading: _notificationMenuIcon(hasNotifications),
              title: const Text('Thong bao'),
              onTap: () {
                Navigator.of(context).pop();
                _openNotifications();
              },
            ),
            ListTile(
              leading: const Icon(Icons.tune_rounded),
              title: const Text('Cai dat thong bao'),
              onTap: _openNotificationSettings,
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Dang xuat'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _openCreateTask,
              shape: const CircleBorder(),
              tooltip: 'Them cong viec',
              child: const Icon(Icons.add_rounded),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.checklist_rtl_rounded),
            label: 'Ngay cua toi',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Lich',
          ),
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.category_rounded),
            label: 'Phan loai',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Thong ke',
          ),
        ],
      ),
    );
  }
}
