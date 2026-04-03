import 'package:flutter/material.dart';

import '../models/notification_models.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({
    required this.taskNotifications,
    required this.shareInvites,
    required this.permissionRequests,
    required this.currentUserName,
    required this.onConfirmShare,
    required this.onResolvePermissionRequest,
    super.key,
  });

  final List<TaskNotificationData> taskNotifications;
  final List<ShareInviteData> shareInvites;
  final List<PermissionRequestData> permissionRequests;
  final String currentUserName;
  final ValueChanged<String> onConfirmShare;
  final void Function(PermissionRequestData request, bool approve)
  onResolvePermissionRequest;

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  late final List<ShareInviteData> _shareInvites = List<ShareInviteData>.from(
    widget.shareInvites,
  );
  late final List<PermissionRequestData> _permissionRequests =
      List<PermissionRequestData>.from(widget.permissionRequests);

  void _confirmInvite(ShareInviteData invite) {
    widget.onConfirmShare(invite.listName);

    final int index = _shareInvites.indexWhere(
      (ShareInviteData element) => element.listName == invite.listName,
    );
    if (index >= 0) {
      _shareInvites[index] = ShareInviteData(
        listName: invite.listName,
        sharedBy: invite.sharedBy,
        isConfirmed: true,
      );
    }

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Da xac nhan danh sach: ${invite.listName}')),
    );
  }

  void _resolvePermission(PermissionRequestData request, bool approve) {
    widget.onResolvePermissionRequest(request, approve);

    final int index = _permissionRequests.indexWhere(
      (PermissionRequestData item) =>
          item.listName == request.listName &&
          item.ownerName == request.ownerName &&
          item.requestedBy == request.requestedBy &&
          item.requestTime == request.requestTime,
    );
    if (index >= 0) {
      _permissionRequests[index] = request.copyWith(
        isResolved: true,
        isApproved: approve,
      );
    }

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          approve
              ? 'Da cap quyen cho ${request.requestedBy}.'
              : 'Da tu choi yeu cau cua ${request.requestedBy}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Thong bao')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'Thong bao cong viec',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...widget.taskNotifications.map((TaskNotificationData item) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.alarm_rounded)),
                title: Text(item.title),
                subtitle: Text(item.message),
                trailing: Text(item.time),
              ),
            );
          }),
          const SizedBox(height: 8),
          Text(
            'Danh sach chia se can xac nhan',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ..._shareInvites.map((ShareInviteData invite) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            invite.listName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (invite.isConfirmed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Da xac nhan',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Nguoi chia se: ${invite.sharedBy}'),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: invite.isConfirmed
                            ? null
                            : () => _confirmInvite(invite),
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: const Text('Xac nhan danh sach'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          Text(
            'Yeu cau cap quyen',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (_permissionRequests.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text('Chua co yeu cau cap quyen nao.'),
              ),
            ),
          ..._permissionRequests.map((PermissionRequestData request) {
            final bool isOwner = request.ownerName == widget.currentUserName;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      request.listName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Nguoi yeu cau: ${request.requestedBy}'),
                    Text('Nguoi chia se: ${request.ownerName}'),
                    Text('Thoi gian: ${request.requestTime}'),
                    const SizedBox(height: 10),
                    if (!request.isResolved && isOwner)
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _resolvePermission(request, false),
                              child: const Text('Tu choi'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _resolvePermission(request, true),
                              child: const Text('Cap quyen'),
                            ),
                          ),
                        ],
                      ),
                    if (!request.isResolved && !isOwner)
                      Text(
                        'Da gui den thong bao cua ${request.ownerName}.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (request.isResolved)
                      Text(
                        request.isApproved
                            ? 'Trang thai: Da cap quyen'
                            : 'Trang thai: Da tu choi',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
