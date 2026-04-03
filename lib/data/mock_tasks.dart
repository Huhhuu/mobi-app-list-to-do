import '../models/task_item.dart';

class MockTasks {
  MockTasks._();

  static List<TaskItem> build() {
    final DateTime now = DateTime.now();

    return <TaskItem>[
      TaskItem(
        title: 'Hoan thanh bao cao tuan',
        category: 'Cong viec',
        dueTime: now.add(const Duration(hours: 5)),
        isDone: false,
        priority: 3,
        isShared: false,
        reminderEnabled: true,
        note: 'Can gui ban nhap cho truong nhom truoc 16:00.',
        subtasks: <String>[
          'Tong hop doanh thu',
          'Kiem tra loi chinh ta',
          'Gui mail cho quan ly',
        ],
      ),
      TaskItem(
        title: 'Mua do dung ca nhan',
        category: 'Ca nhan',
        dueTime: now.add(const Duration(days: 5, hours: 2)),
        isDone: false,
        priority: 2,
        isShared: false,
        reminderEnabled: false,
        note: 'Mua o sieu thi gan nha vao buoi toi.',
        subtasks: <String>['Kem danh rang', 'Sua tam'],
      ),
      TaskItem(
        title: 'Luyen tap Flutter 45 phut',
        category: 'Hoc tap',
        dueTime: now.add(const Duration(hours: 8)),
        isDone: true,
        priority: 1,
        isShared: true,
        reminderEnabled: true,
        note: 'On lai state management va animation co ban.',
        subtasks: <String>['Doc tai lieu 15 phut', 'Code bai tap 30 phut'],
      ),
      TaskItem(
        title: 'Dat lich kham suc khoe',
        category: 'Suc khoe',
        dueTime: now.add(const Duration(days: 20)),
        isDone: false,
        priority: 2,
        isShared: true,
        reminderEnabled: true,
        note: 'Uu tien lich buoi sang, mang theo bao hiem y te.',
        subtasks: <String>['Chon benh vien', 'Xac nhan lich hen'],
      ),
      TaskItem(
        title: 'Len ke hoach du lich gia dinh',
        category: 'Gia dinh',
        dueTime: now.add(const Duration(days: 45)),
        isDone: false,
        priority: 1,
        isShared: true,
        reminderEnabled: false,
        note: 'Thong nhat dia diem voi ca nha cuoi tuan nay.',
        subtasks: <String>['Lap danh sach dia diem', 'Du tru chi phi'],
      ),
    ];
  }
}
