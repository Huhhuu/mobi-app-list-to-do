import 'package:flutter/material.dart';

import '../models/notification_models.dart';
import '../models/task_item.dart';
import 'task_share_screen.dart';
import 'task_list_bucket_screen.dart';

class _PermissionRequestEntry {
  _PermissionRequestEntry({
    required this.listName,
    required this.ownerName,
    required this.requestedBy,
    required this.requestTime,
  });

  final String listName;
  final String ownerName;
  final String requestedBy;
  final String requestTime;
  bool isResolved = false;
  bool isApproved = false;
}

class _SharedListInfo {
  _SharedListInfo({
    required this.sharedBy,
    required this.ownerName,
    required this.tasks,
    required this.isConfirmed,
  });

  final String sharedBy;
  final String ownerName;
  List<TaskItem> tasks;
  bool isConfirmed;
}

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => HomeDashboardScreenState();
}

class HomeDashboardScreenState extends State<HomeDashboardScreen> {
  static const String _currentUserName = 'Nguyen Van A';

  int _personalSeed = 1;
  int _sharedSeed = 1;

  final Map<String, List<TaskItem>> _personalLists = <String, List<TaskItem>>{
    'Danh sach mac dinh': <TaskItem>[],
  };
  final Map<String, _SharedListInfo> _sharedLists = <String, _SharedListInfo>{
    'Danh sach sprint mobile': _SharedListInfo(
      sharedBy: 'Tran Thi B',
      ownerName: 'Tran Thi B',
      tasks: <TaskItem>[],
      isConfirmed: true,
    ),
    'Danh sach thuc tap': _SharedListInfo(
      sharedBy: 'Le Van C',
      ownerName: 'Le Van C',
      tasks: <TaskItem>[],
      isConfirmed: false,
    ),
  };
  final List<_PermissionRequestEntry> _permissionRequests =
      <_PermissionRequestEntry>[];

  bool _canManageSharedList(_SharedListInfo info) {
    return info.ownerName == _currentUserName;
  }

  List<TaskNotificationData> getTaskNotifications() {
    return const <TaskNotificationData>[
      TaskNotificationData(
        title: 'Nhac viec den han',
        message: 'Bao cao tuan can hoan thanh truoc 17:00 hom nay.',
        time: '08:30',
      ),
      TaskNotificationData(
        title: 'Nhac viec lap lich',
        message: 'Hop sprint vao 14:00, hay kiem tra danh sach cong viec.',
        time: '07:45',
      ),
    ];
  }

  List<ShareInviteData> getShareInviteNotifications() {
    return _sharedLists.entries
        .where((MapEntry<String, _SharedListInfo> entry) {
          return !_canManageSharedList(entry.value);
        })
        .map((MapEntry<String, _SharedListInfo> entry) {
          return ShareInviteData(
            listName: entry.key,
            sharedBy: entry.value.sharedBy,
            isConfirmed: entry.value.isConfirmed,
          );
        })
        .toList();
  }

  String get currentUserName => _currentUserName;

  List<PermissionRequestData> getPermissionRequests() {
    return _permissionRequests.map((_PermissionRequestEntry request) {
      return PermissionRequestData(
        listName: request.listName,
        ownerName: request.ownerName,
        requestedBy: request.requestedBy,
        requestTime: request.requestTime,
        isResolved: request.isResolved,
        isApproved: request.isApproved,
      );
    }).toList();
  }

  void resolvePermissionRequest(PermissionRequestData request, bool approve) {
    final int index = _permissionRequests.indexWhere(
      (_PermissionRequestEntry item) =>
          item.listName == request.listName &&
          item.ownerName == request.ownerName &&
          item.requestedBy == request.requestedBy &&
          item.requestTime == request.requestTime,
    );
    if (index < 0) {
      return;
    }

    setState(() {
      _permissionRequests[index].isResolved = true;
      _permissionRequests[index].isApproved = approve;
    });
  }

  void _requestPermissionForSharedList(String listName) {
    final _SharedListInfo? info = _sharedLists[listName];
    if (info == null) {
      return;
    }
    if (_canManageSharedList(info)) {
      return;
    }

    final bool alreadyPending = _permissionRequests.any(
      (_PermissionRequestEntry request) =>
          request.listName == listName &&
          request.ownerName == info.ownerName &&
          request.requestedBy == _currentUserName &&
          !request.isResolved,
    );
    if (alreadyPending) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeu cau cap quyen dang cho duyet.')),
      );
      return;
    }

    setState(() {
      _permissionRequests.add(
        _PermissionRequestEntry(
          listName: listName,
          ownerName: info.ownerName,
          requestedBy: _currentUserName,
          requestTime: TimeOfDay.now().format(context),
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Da gui yeu cau cap quyen den ${info.ownerName}.'),
      ),
    );
  }

  void _openShareCenter() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const TaskShareScreen(),
      ),
    );
  }

  void confirmSharedList(String listName) {
    final _SharedListInfo? info = _sharedLists[listName];
    if (info == null || info.isConfirmed) {
      return;
    }
    setState(() {
      info.isConfirmed = true;
    });
  }

  void _addList(bool isShared) {
    setState(() {
      if (isShared) {
        _sharedSeed += 1;
        _sharedLists['Danh sach chia se $_sharedSeed'] = _SharedListInfo(
          sharedBy: _currentUserName,
          ownerName: _currentUserName,
          tasks: <TaskItem>[],
          isConfirmed: true,
        );
      } else {
        _personalSeed += 1;
        _personalLists['Danh sach cua toi $_personalSeed'] = <TaskItem>[];
      }
    });
  }

  Future<bool> _deleteList({
    required String listName,
    required bool isShared,
  }) async {
    final bool? accepted = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xoa danh sach con'),
          content: Text('Ban co chac muon xoa "$listName"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Huy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xoa'),
            ),
          ],
        );
      },
    );

    if (accepted != true) {
      return false;
    }

    if (isShared) {
      final _SharedListInfo? info = _sharedLists[listName];
      if (info != null && !_canManageSharedList(info)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chi nguoi tao moi duoc xoa danh sach chia se.'),
          ),
        );
        return false;
      }
    }

    setState(() {
      if (isShared) {
        _sharedLists.remove(listName);
      } else {
        _personalLists.remove(listName);
      }
    });
    return true;
  }

  void _openBucket(String listName, bool isShared) {
    final Map<String, List<TaskItem>> source = _personalLists;
    String currentKey = listName;

    if (isShared) {
      final _SharedListInfo? sharedInfo = _sharedLists[listName];
      if (sharedInfo == null) {
        return;
      }
      if (!sharedInfo.isConfirmed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xac nhan danh sach chia se trong thong bao truoc.'),
          ),
        );
        return;
      }

      final bool canManageList = _canManageSharedList(sharedInfo);

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => TaskListBucketScreen(
            title: listName,
            isShared: true,
            canManageList: canManageList,
            initialTasks: sharedInfo.tasks,
            onShareRequested: _openShareCenter,
            onDeleteRequested: () =>
                _deleteList(listName: currentKey, isShared: true),
            onRequestPermission: () =>
                _requestPermissionForSharedList(currentKey),
            onTitleChanged: (String newTitle) {
              if (!canManageList) {
                return;
              }
              if (newTitle.trim().isEmpty || newTitle == currentKey) {
                return;
              }
              if (_sharedLists.containsKey(newTitle)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ten danh sach da ton tai.')),
                );
                return;
              }
              setState(() {
                final _SharedListInfo data = _sharedLists.remove(currentKey)!;
                _sharedLists[newTitle] = data;
                currentKey = newTitle;
              });
            },
            onTasksChanged: (List<TaskItem> nextTasks) {
              setState(() {
                final _SharedListInfo? target = _sharedLists[currentKey];
                if (target != null) {
                  target.tasks = nextTasks;
                }
              });
            },
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => TaskListBucketScreen(
          title: listName,
          isShared: false,
          canManageList: true,
          initialTasks: source[listName] ?? <TaskItem>[],
          onShareRequested: _openShareCenter,
          onDeleteRequested: () =>
              _deleteList(listName: currentKey, isShared: false),
          onTitleChanged: (String newTitle) {
            if (newTitle.trim().isEmpty || newTitle == currentKey) {
              return;
            }
            if (source.containsKey(newTitle)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ten danh sach da ton tai.')),
              );
              return;
            }
            setState(() {
              final List<TaskItem> tasks =
                  source.remove(currentKey) ?? <TaskItem>[];
              source[newTitle] = tasks;
              currentKey = newTitle;
            });
          },
          onTasksChanged: (List<TaskItem> nextTasks) {
            setState(() {
              source[currentKey] = nextTasks;
            });
          },
        ),
      ),
    );
  }

  Widget _listTile({
    required String name,
    required int taskCount,
    required bool isShared,
    String? sharedBy,
    bool isConfirmed = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openBucket(name, isShared),
        child: Ink(
          height: 108,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          isShared
                              ? Icons.groups_rounded
                              : Icons.folder_shared_rounded,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    if (isShared && sharedBy != null) const SizedBox(height: 6),
                    if (isShared && sharedBy != null)
                      Text(
                        'Nguoi chia se: $sharedBy',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$taskCount',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (!isConfirmed)
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Cho xac nhan',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addTile(bool isShared) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _addList(isShared),
        child: Ink(
          height: 108,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.add_rounded),
              SizedBox(width: 8),
              Text('Them cong viec'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _groupCard({
    required String title,
    required bool isShared,
    required Map<String, List<TaskItem>> personalLists,
    required Map<String, _SharedListInfo> sharedLists,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              const double spacing = 10;
              final double tileWidth = (constraints.maxWidth - spacing) / 2;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: <Widget>[
                  if (isShared)
                    ...sharedLists.entries.map((
                      MapEntry<String, _SharedListInfo> entry,
                    ) {
                      return SizedBox(
                        width: tileWidth,
                        child: _listTile(
                          name: entry.key,
                          taskCount: entry.value.tasks.length,
                          isShared: true,
                          sharedBy: entry.value.sharedBy,
                          isConfirmed: entry.value.isConfirmed,
                        ),
                      );
                    }),
                  if (!isShared)
                    ...personalLists.entries.map((
                      MapEntry<String, List<TaskItem>> entry,
                    ) {
                      return SizedBox(
                        width: tileWidth,
                        child: _listTile(
                          name: entry.key,
                          taskCount: entry.value.length,
                          isShared: false,
                        ),
                      );
                    }),
                  SizedBox(width: tileWidth, child: _addTile(isShared)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _groupCard(
          title: 'Danh sach cua toi',
          isShared: false,
          personalLists: _personalLists,
          sharedLists: _sharedLists,
        ),
        _groupCard(
          title: 'Danh sach chia se',
          isShared: true,
          personalLists: _personalLists,
          sharedLists: _sharedLists,
        ),
      ],
    );
  }
}
