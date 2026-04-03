class TaskNotificationData {
  const TaskNotificationData({
    required this.title,
    required this.message,
    required this.time,
  });

  final String title;
  final String message;
  final String time;

  TaskNotificationData copyWith({
    String? title,
    String? message,
    String? time,
  }) {
    return TaskNotificationData(
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
    );
  }
}

class ShareInviteData {
  const ShareInviteData({
    required this.listName,
    required this.sharedBy,
    required this.isConfirmed,
  });

  final String listName;
  final String sharedBy;
  final bool isConfirmed;

  ShareInviteData copyWith({
    String? listName,
    String? sharedBy,
    bool? isConfirmed,
  }) {
    return ShareInviteData(
      listName: listName ?? this.listName,
      sharedBy: sharedBy ?? this.sharedBy,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}

class PermissionRequestData {
  const PermissionRequestData({
    required this.listName,
    required this.ownerName,
    required this.requestedBy,
    required this.requestTime,
    required this.isResolved,
    required this.isApproved,
  });

  final String listName;
  final String ownerName;
  final String requestedBy;
  final String requestTime;
  final bool isResolved;
  final bool isApproved;

  PermissionRequestData copyWith({
    String? listName,
    String? ownerName,
    String? requestedBy,
    String? requestTime,
    bool? isResolved,
    bool? isApproved,
  }) {
    return PermissionRequestData(
      listName: listName ?? this.listName,
      ownerName: ownerName ?? this.ownerName,
      requestedBy: requestedBy ?? this.requestedBy,
      requestTime: requestTime ?? this.requestTime,
      isResolved: isResolved ?? this.isResolved,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}
