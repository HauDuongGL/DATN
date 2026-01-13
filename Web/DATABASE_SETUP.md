# Hướng Dẫn Thiết Lập Cơ Sở Dữ Liệu

> [!IMPORTANT]
> **Yêu Cầu Thiết Lập Cơ Sở Dữ Liệu Đầy Đủ**
> 
> Cơ sở dữ liệu của bạn cần được thiết lập theo hai bước. Nếu bỏ qua Bước 1, bạn sẽ gặp lỗi như "Could not find the 'author_id' column" khi cố gắng sử dụng ứng dụng.

## Bước 1: Tạo Các Bảng Cơ Bản (BẮT BUỘC - Làm Bước Này Trước!)

Các bảng cơ bản bao gồm profiles, posts, comments, likes, follows, notifications, và nhiều hơn nữa. **Bạn phải chạy script này trước khi sử dụng ứng dụng.**

### Hướng Dẫn:

1. Mở Supabase Dashboard: https://supabase.com/dashboard
2. Điều hướng đến dự án của bạn
3. Vào **SQL Editor**
4. Click **New Query**
5. Copy toàn bộ nội dung của `scripts/000_initial_setup.sql`
6. Dán vào SQL Editor
7. Click **Run**
8. Đợi hoàn tất (bạn sẽ thấy thông báo thành công)

### Script Này Tạo Gì:

**Các Bảng:**
- `profiles` - Hồ sơ người dùng với avatars, bio, và số đếm mạng xã hội
- `posts` - Bài viết về hoa với hình ảnh và chi tiết
- `post_media` - File đính kèm media cho bài viết
- `comments` - Bình luận trên bài viết
- `likes` - Lượt thích trên bài viết và bình luận
- `follows` - Mối quan hệ theo dõi giữa người dùng
- `notifications` - Thông báo hoạt động
- `admin_users` - Quyền truy cập quản trị và kiểm duyệt
- `reports` - Báo cáo kiểm duyệt nội dung

**Tính Năng Bổ Sung:**
- Chính sách Row Level Security (RLS) để bảo vệ dữ liệu
- Tự động tạo hồ sơ khi đăng ký
- Triggers đếm cho likes, comments, follows
- Storage buckets cho avatars và hình ảnh bài viết

---

## Bước 2: Thêm Tính Năng Mới (Tùy Chọn)

Sau khi hoàn thành Bước 1, bạn có thể thêm các tính năng Groups, Messaging và Onboarding.

### Hướng Dẫn:

1. Trong cùng Supabase SQL Editor
2. Click **New Query**
3. Copy toàn bộ nội dung của `scripts/100_consolidated_new_features.sql`
4. Dán vào SQL Editor
5. Click **Run**

### Script Này Thêm Gì:

**Bảng Mới:**
- `groups` - Nhóm cộng đồng
- `group_members` - Thành viên nhóm với vai trò
- `group_posts` - Bài viết trong nhóm
- `group_join_requests` - Yêu cầu tham gia nhóm riêng tư
- `conversations` - Cuộc trò chuyện nhắn tin riêng tư
- `conversation_participants` - Thành viên cuộc trò chuyện
- `messages` - Tin nhắn trực tiếp

**Bảng Được Sửa Đổi:**
- `profiles` - Thêm các trường onboarding (onboarding_completed, interests, favorite_flowers)

---

## Xác Minh Cài Đặt

Sau khi chạy các script, xác minh cơ sở dữ liệu của bạn đã được thiết lập đúng cách:

### Kiểm Tra Các Bảng Tồn Tại:

1. Trong Supabase Dashboard, vào **Table Editor**
2. Xác nhận bạn thấy các bảng này trong sidebar:

**Từ Bước 1 (Bảng Cơ Bản):**
- profiles
- posts
- post_media
- comments
- likes
- follows
- notifications
- admin_users
- reports

**Từ Bước 2 (Tính Năng Mới - nếu bạn đã chạy):**
- groups
- group_members
- group_posts
- group_join_requests
- conversations
- conversation_participants
- messages

### Kiểm Tra Storage Buckets:

1. Trong Supabase Dashboard, vào **Storage**
2. Xác nhận các buckets này tồn tại:
   - `avatars` (public)
   - `post-images` (public)

### Kiểm Tra Ứng Dụng:

1. Khởi động ứng dụng web của bạn: `cd Web && npm run dev`
2. Mở http://localhost:3000 trong trình duyệt
3. Đăng ký hoặc đăng nhập
4. Thử tạo một bài viết với hình ảnh
5. Xác nhận bài viết được tải lên thành công

---

## Khắc Phục Sự Cố

### Lỗi: "Could not find the 'author_id' column"
**Giải pháp:** Bạn chưa chạy Bước 1. Quay lại và chạy `000_initial_setup.sql` trước.

### Lỗi: "Could not find the table 'public.groups'"
**Giải pháp:** Bạn chưa chạy Bước 2. Chạy `100_consolidated_new_features.sql` hoặc xác minh bạn chưa cần các tính năng Groups/Messaging.

### Lỗi: "relation already exists"
**Giải pháp:** Các bảng đã được tạo. Điều này an toàn để bỏ qua. Nếu bạn muốn tạo lại chúng, bạn cần xóa các bảng hiện có trước (cẩn thận - điều này xóa tất cả dữ liệu).

### Upload Storage Thất Bại
**Giải pháp:** 
1. Kiểm tra storage buckets tồn tại trong Supabase Storage
2. Xác minh buckets được đặt là "public"
3. Kiểm tra chính sách RLS tồn tại cho storage.objects

---

## Cần Trợ Giúp?

Nếu bạn gặp bất kỳ vấn đề nào:
1. Kiểm tra logs Supabase trong Dashboard
2. Xác minh tất cả biến môi trường được thiết lập đúng trong `.env.local`
3. Đảm bảo `NEXT_PUBLIC_SUPABASE_URL` và `NEXT_PUBLIC_SUPABASE_ANON_KEY` đúng

