# To-Do App

Ứng dụng quản lý công việc (To-Do List) được xây dựng bằng **Flutter**, sử dụng **Supabase** làm backend. Hỗ trợ đa nền tảng: Android, iOS, Web, Windows, macOS, Linux.

## Tính năng chính

- **Xác thực người dùng** — Đăng nhập / Đăng ký tài khoản với Supabase Auth, hỗ trợ đăng nhập mạng xã hội
- **Quản lý công việc (CRUD)** — Tạo, xem, sửa, xóa task với đầy đủ thông tin chi tiết
- **Phân loại công việc** — Quản lý danh mục (category) và danh sách (task list/bucket) để tổ chức task
- **Nhắc nhở & Thông báo** — Đặt nhắc nhở cho task với Local Notifications, trung tâm thông báo
- **Thống kê** — Dashboard tổng quan và thống kê chi tiết về tiến độ công việc
- **Chia sẻ công việc** — Chia sẻ task với người dùng khác
- **Quản lý tài khoản** — Chỉnh sửa thông tin cá nhân, đổi mật khẩu
- **Giao diện sáng/tối** — Hỗ trợ Light & Dark theme

## Công nghệ sử dụng

| Công nghệ | Mục đích |
|---|---|
| **Flutter** (Dart) | Framework phát triển ứng dụng đa nền tảng |
| **Supabase** | Backend-as-a-Service (Auth, Database, API) |
| **Provider** | Quản lý state |
| **GoRouter** | Điều hướng (Navigation & Routing) |
| **BotToast** | Hiển thị thông báo toast/snackbar |
| **Flutter Local Notifications** | Thông báo nhắc nhở cục bộ |
| **Google Fonts** | Typography tùy chỉnh |
| **flutter_dotenv** | Quản lý biến môi trường (.env) |
| **intl** | Định dạng ngày tháng (hỗ trợ tiếng Việt) |

## Cấu trúc dự án

```
lib/
├── main.dart                  # Entry point
├── config/
│   ├── routes/                # Cấu hình routing (GoRouter)
│   └── themes/                # Cấu hình theme (Light/Dark)
├── core/
│   ├── constants/             # Hằng số
│   ├── services/              # Service dùng chung (Notification)
│   ├── utils/                 # Tiện ích
│   └── widgets/               # Widget dùng chung
├── features/
│   ├── auth/                  # Xác thực (pages, providers, services, widgets)
│   ├── task/                  # Quản lý task (models, pages, providers, services, widgets)
│   └── task_list/             # Quản lý danh sách task (models, providers, services, widgets)
└── repositories/              # Repository layer
```

## Cài đặt & Chạy

### Yêu cầu

- Flutter SDK `>=3.11.4`
- Tài khoản [Supabase](https://supabase.com/)

### Các bước

1. **Clone repository**
   ```bash
   git clone https://github.com/Huhhuu/mobi-app-list-to-do.git
   cd mobi-app-list-to-do
   ```

2. **Tạo file `.env`** ở thư mục gốc
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

3. **Cài đặt dependencies**
   ```bash
   flutter pub get
   ```

4. **Chạy ứng dụng**
   ```bash
   flutter run
   ```

## Các màn hình

| Màn hình | Mô tả |
|---|---|
| Login | Đăng nhập / Đăng ký |
| Home Dashboard | Tổng quan công việc |
| Task Management | Quản lý danh sách task |
| Task Create | Tạo task mới |
| Task Detail | Chi tiết & chỉnh sửa task |
| Task Category | Phân loại task theo danh mục |
| Task List Bucket | Quản lý task theo danh sách |
| Task Reminder | Đặt nhắc nhở cho task |
| Task Share | Chia sẻ task |
| Task Statistics | Thống kê công việc |
| Notification Center | Trung tâm thông báo |
| Account Management | Quản lý tài khoản |
| Change Password | Đổi mật khẩu |

## Tác giả

- **Huhhuu** — [GitHub](https://github.com/Huhhuu)

## License

Dự án này được phát triển phục vụ mục đích học tập — Đồ án Lập trình Di động.
